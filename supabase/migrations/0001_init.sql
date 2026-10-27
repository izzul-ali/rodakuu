-- =====================================================================
-- RodaKuu — migrasi awal
-- Jalankan sekali di Supabase SQL Editor.
-- =====================================================================

create extension if not exists btree_gist;

-- ---------------------------------------------------------------------
-- Fungsi bantu: perbarui kolom updated_at
-- ---------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------
-- PROFILES
-- ---------------------------------------------------------------------
create table public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  full_name   text not null default '',
  phone       text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Buat profil otomatis saat pengguna mendaftar
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', ''));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------
-- VEHICLES
-- ---------------------------------------------------------------------
create table public.vehicles (
  id             uuid primary key default gen_random_uuid(),
  type           text not null check (type in ('mobil', 'motor')),
  brand          text not null,
  name           text not null,
  year           smallint not null check (year between 1990 and 2100),
  transmission   text not null check (transmission in ('manual', 'matic')),
  fuel           text not null check (fuel in ('bensin', 'diesel', 'listrik')),
  seats          smallint not null check (seats between 1 and 12),
  price_per_day  integer not null check (price_per_day > 0),
  description    text not null default '',
  image_url      text,
  is_available   boolean not null default true,
  created_at     timestamptz not null default now()
);

create index vehicles_type_idx  on public.vehicles (type);
create index vehicles_price_idx on public.vehicles (price_per_day);

-- ---------------------------------------------------------------------
-- BOOKINGS
-- ---------------------------------------------------------------------
create table public.bookings (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references public.profiles (id) on delete cascade,
  vehicle_id       uuid not null references public.vehicles (id) on delete restrict,
  start_date       date not null,
  end_date         date not null,
  total_days       integer not null check (total_days between 1 and 30),
  price_per_day    integer not null check (price_per_day > 0),
  total_price      integer not null check (total_price > 0),
  pickup_location  text not null,
  notes            text,
  status           text not null default 'menunggu'
                   check (status in ('menunggu', 'dikonfirmasi', 'selesai', 'dibatalkan')),
  created_at       timestamptz not null default now(),
  constraint bookings_dates_valid check (end_date >= start_date),
  -- Cegah pemesanan ganda: kendaraan yang sama tidak boleh punya dua pesanan
  -- aktif dengan rentang tanggal beririsan.
  constraint bookings_no_overlap exclude using gist (
    vehicle_id with =,
    daterange(start_date, end_date, '[]') with &&
  ) where (status in ('menunggu', 'dikonfirmasi'))
);

create index bookings_user_idx on public.bookings (user_id, created_at desc);

-- ---------------------------------------------------------------------
-- ROW LEVEL SECURITY
-- ---------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.vehicles enable row level security;
alter table public.bookings enable row level security;

create policy "profiles_select_own"
  on public.profiles for select to authenticated
  using ((select auth.uid()) = id);

create policy "profiles_update_own"
  on public.profiles for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

create policy "vehicles_select_authenticated"
  on public.vehicles for select to authenticated
  using (true);

create policy "bookings_select_own"
  on public.bookings for select to authenticated
  using ((select auth.uid()) = user_id);

-- Sengaja TIDAK ada policy INSERT/UPDATE/DELETE pada bookings:
-- klien hanya boleh menulis lewat fungsi RPC di bawah.

-- ---------------------------------------------------------------------
-- RPC: buat pesanan (harga dihitung di server)
-- ---------------------------------------------------------------------
create or replace function public.create_booking(
  p_vehicle_id       uuid,
  p_start_date       date,
  p_end_date         date,
  p_pickup_location  text,
  p_notes            text default null
)
returns public.bookings
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user     uuid := auth.uid();
  v_vehicle  public.vehicles;
  v_days     integer;
  v_booking  public.bookings;
begin
  if v_user is null then
    raise exception 'Anda harus masuk terlebih dahulu.' using errcode = '28000';
  end if;

  if p_start_date is null or p_end_date is null or p_end_date < p_start_date then
    raise exception 'Rentang tanggal tidak valid.' using errcode = '22023';
  end if;

  if p_start_date < current_date then
    raise exception 'Tanggal mulai tidak boleh di masa lalu.' using errcode = '22023';
  end if;

  v_days := (p_end_date - p_start_date) + 1;
  if v_days > 30 then
    raise exception 'Durasi sewa maksimal 30 hari.' using errcode = '22023';
  end if;

  if length(trim(coalesce(p_pickup_location, ''))) < 3 then
    raise exception 'Lokasi pengambilan wajib diisi.' using errcode = '22023';
  end if;

  select * into v_vehicle from public.vehicles where id = p_vehicle_id;
  if not found then
    raise exception 'Kendaraan tidak ditemukan.' using errcode = 'P0002';
  end if;

  if not v_vehicle.is_available then
    raise exception 'Kendaraan sedang tidak tersedia.' using errcode = '22023';
  end if;

  insert into public.bookings (
    user_id, vehicle_id, start_date, end_date, total_days,
    price_per_day, total_price, pickup_location, notes
  )
  values (
    v_user, p_vehicle_id, p_start_date, p_end_date, v_days,
    v_vehicle.price_per_day, v_days * v_vehicle.price_per_day,
    trim(p_pickup_location), nullif(trim(coalesce(p_notes, '')), '')
  )
  returning * into v_booking;

  return v_booking;
end;
$$;

-- ---------------------------------------------------------------------
-- RPC: batalkan pesanan milik sendiri (hanya status 'menunggu')
-- ---------------------------------------------------------------------
create or replace function public.cancel_booking(p_booking_id uuid)
returns public.bookings
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_booking public.bookings;
begin
  update public.bookings
     set status = 'dibatalkan'
   where id = p_booking_id
     and user_id = auth.uid()
     and status = 'menunggu'
  returning * into v_booking;

  if not found then
    raise exception 'Pesanan tidak dapat dibatalkan.' using errcode = '22023';
  end if;

  return v_booking;
end;
$$;

-- ---------------------------------------------------------------------
-- RPC: rentang tanggal yang sudah terisi (tanpa membuka data pengguna lain)
-- ---------------------------------------------------------------------
create or replace function public.get_booked_ranges(p_vehicle_id uuid)
returns table (start_date date, end_date date)
language sql
stable
security definer
set search_path = ''
as $$
  select b.start_date, b.end_date
    from public.bookings b
   where b.vehicle_id = p_vehicle_id
     and b.status in ('menunggu', 'dikonfirmasi')
     and b.end_date >= current_date
   order by b.start_date;
$$;

-- Batasi eksekusi RPC hanya untuk pengguna yang sudah masuk
revoke all on function public.create_booking(uuid, date, date, text, text) from public, anon;
revoke all on function public.cancel_booking(uuid) from public, anon;
revoke all on function public.get_booked_ranges(uuid) from public, anon;
grant execute on function public.create_booking(uuid, date, date, text, text) to authenticated;
grant execute on function public.cancel_booking(uuid) to authenticated;
grant execute on function public.get_booked_ranges(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- STORAGE: bucket publik untuk foto kendaraan
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('vehicle-images', 'vehicle-images', true)
on conflict (id) do nothing;

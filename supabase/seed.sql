insert into public.vehicles
  (type, brand, name, year, transmission, fuel, seats, price_per_day, description, is_available)
values
  ('mobil', 'Toyota',     'Avanza',        2022, 'manual', 'bensin', 7, 350000,
   'MPV keluarga yang irit dan lega, nyaman untuk perjalanan dalam maupun luar kota.', true),
  ('mobil', 'Daihatsu',   'Xenia',         2023, 'matic',  'bensin', 7, 380000,
   'Transmisi otomatis membuat perjalanan di kota terasa lebih santai.', true),
  ('mobil', 'Honda',      'Brio',          2023, 'matic',  'bensin', 5, 320000,
   'Mungil dan lincah, mudah diparkir, cocok untuk pemakaian harian.', true),
  ('mobil', 'Toyota',     'Innova Reborn', 2021, 'matic',  'diesel', 7, 600000,
   'Kabin luas dan stabil di jalan jauh, pilihan tepat untuk rombongan keluarga.', true),
  ('mobil', 'Mitsubishi', 'Xpander',       2022, 'matic',  'bensin', 7, 470000,
   'Kabin lapang dengan ground clearance tinggi untuk berbagai kondisi jalan.', true),
  ('mobil', 'Suzuki',     'Ertiga',        2021, 'manual', 'bensin', 7, 400000,
   'Irit bahan bakar dan nyaman untuk tujuh penumpang.', false),
  ('motor', 'Honda',      'Beat',          2023, 'matic',  'bensin', 2,  90000,
   'Ringan dan irit, andalan mobilitas harian di dalam kota.', true),
  ('motor', 'Honda',      'Vario 160',     2023, 'matic',  'bensin', 2, 130000,
   'Tenaga lebih besar dengan bagasi luas untuk kebutuhan harian.', true),
  ('motor', 'Yamaha',     'NMAX',          2022, 'matic',  'bensin', 2, 190000,
   'Skuter besar yang stabil dan nyaman untuk jarak menengah.', true),
  ('motor', 'Honda',      'PCX 160',       2023, 'matic',  'bensin', 2, 210000,
   'Skuter premium dengan posisi berkendara nyaman untuk perjalanan jauh.', true);

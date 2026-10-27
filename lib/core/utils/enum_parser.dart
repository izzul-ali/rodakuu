/// Helper untuk memetakan string dari database ke enum Dart secara aman.
T parseEnum<T extends Enum>(List<T> values, String raw) {
  final normalized = raw.trim().toLowerCase();
  for (final value in values) {
    if (value.name.toLowerCase() == normalized) {
      return value;
    }
  }
  throw FormatException(
    'Nilai "$raw" tidak dikenali untuk tipe enum ${T.toString()}.',
  );
}

/// Helper opsional yang mengembalikan null jika nilai tidak dikenali.
T? tryParseEnum<T extends Enum>(List<T> values, String? raw) {
  if (raw == null) return null;
  final normalized = raw.trim().toLowerCase();
  for (final value in values) {
    if (value.name.toLowerCase() == normalized) {
      return value;
    }
  }
  return null;
}

import 'package:flutter/foundation.dart';

/// Entitas profil pengguna RodaKuu.
@immutable
class Profile {
  const Profile({
    required this.id,
    required this.fullName,
    this.phone,
    required this.email,
  });

  final String id;
  final String fullName;
  final String? phone;
  final String email;

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : '';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          phone == other.phone &&
          email == other.email;

  @override
  int get hashCode => Object.hash(id, fullName, phone, email);
}

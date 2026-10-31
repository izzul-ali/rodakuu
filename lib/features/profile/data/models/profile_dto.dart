import 'package:rodakuu/features/profile/domain/entities/profile.dart';

/// Data Transfer Object untuk profil pengguna dari tabel Supabase.
class ProfileDto {
  const ProfileDto({
    required this.id,
    required this.fullName,
    this.phone,
    required this.email,
  });

  final String id;
  final String fullName;
  final String? phone;
  final String email;

  factory ProfileDto.fromJson(
    Map<String, dynamic> json, {
    required String email,
  }) {
    return ProfileDto(
      id: json['id'] as String,
      fullName: (json['full_name'] as String?) ?? '',
      phone: json['phone'] as String?,
      email: email,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'full_name': fullName, 'phone': phone};
  }

  Profile toEntity() {
    return Profile(id: id, fullName: fullName, phone: phone, email: email);
  }
}

import 'package:material_ui/material_ui.dart';

/// Layar ubah data profil pengguna.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Profil')),
      body: const Center(child: Text('Form Ubah Profil')),
    );
  }
}

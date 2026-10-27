import 'package:material_ui/material_ui.dart';

/// Layar formulir pemesanan kendaraan.
class BookingFormScreen extends StatelessWidget {
  const BookingFormScreen({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Pemesanan')),
      body: Center(child: Text('Pesan Kendaraan: $vehicleId')),
    );
  }
}

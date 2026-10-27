import 'package:material_ui/material_ui.dart';

/// Layar rincian kendaraan.
class VehicleDetailScreen extends StatelessWidget {
  const VehicleDetailScreen({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kendaraan')),
      body: Center(child: Text('Detail Kendaraan: $vehicleId')),
    );
  }
}

import 'package:material_ui/material_ui.dart';

/// Layar rincian pesanan kendaraan.
class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: Center(child: Text('Detail Pesanan: $bookingId')),
    );
  }
}

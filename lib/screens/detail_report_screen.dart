// lib/screens/detail_report_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/models/report_model.dart';
import '/services/db_helper.dart';
import '/providers/report_notifier.dart';
import '/screens/edit_report_screen.dart';

class DetailReportScreen extends ConsumerWidget {
  final ReportModel report;

  const DetailReportScreen({super.key, required this.report});

  Future<void> _deleteReport(BuildContext context, WidgetRef ref) async {
    final DBHelper dbHelper = DBHelper();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Laporan'),
        content: Text(
          'Yakin hapus laporan "${report.judul}"? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        if (report.id == null)
          throw Exception("ID Laporan tidak valid untuk dihapus.");

        await dbHelper.deleteReport(report.id!);

        ref.invalidate(reportListProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Laporan berhasil dihapus!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus laporan: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = report.status == 1;
    final locationString =
        'Lat: ${report.latitude.toStringAsFixed(4)}, Lon: ${report.longitude.toStringAsFixed(4)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        actions: [
          if (report.id != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteReport(context, ref),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        FullScreenPhotoView(imageUrl: report.foto),
                  ),
                );
              },
              child: Hero(
                tag: 'reportPhoto_${report.id}',
                child: Image.network(
                  report.foto,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Status: ${isCompleted ? 'Selesai ✅' : 'Pending ⏳'}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isCompleted
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
              ),
            ),
            const Divider(),

            _buildDetailItem('Judul', report.judul),
            _buildDetailItem('Lokasi', locationString),
            _buildDetailItem('Deskripsi Pelapor', report.deskripsi),
            const SizedBox(height: 20),

            if (isCompleted) ...[
              const Text(
                'Detail Penyelesaian Oleh Officer 👨‍🔧',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildDetailItem(
                'Catatan Officer',
                report.officerNotes ?? 'Tidak Ada Catatan',
              ),
              if (report.officerFoto != null && report.officerFoto!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Foto Hasil Pengerjaan:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FullScreenPhotoView(
                              imageUrl: report.officerFoto!,
                            ),
                          ),
                        );
                      },
                      child: Image.network(
                        report.officerFoto!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Text('Gagal memuat foto hasil'),
                            ),
                      ),
                    ),
                  ],
                ),
              const Divider(),
            ],

            if (!isCompleted)
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Tandai Selesai'),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditReportScreen(report: report),
                    ),
                  );

                  ref.invalidate(reportListProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}

class FullScreenPhotoView extends StatelessWidget {
  final String imageUrl;

  const FullScreenPhotoView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: 'reportPhoto_$imageUrl',
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

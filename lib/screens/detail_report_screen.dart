import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/report_model.dart';
import '../providers/report_notifier.dart';
import 'edit_report_screen.dart';

class DetailReportScreen extends ConsumerWidget {
  final ReportModel report;

  const DetailReportScreen({required this.report, super.key});

  // Fungsi untuk Hapus Laporan (MAHASISWA 4)
  Future<void> _deleteReport(BuildContext context, WidgetRef ref) async {
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Anda yakin ingin menghapus laporan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (isConfirmed == true && report.id != null) {
      await ref.read(reportListProvider.notifier).deleteReport(report.id!);
      if (context.mounted) {
        Navigator.pop(context); // Kembali ke Dashboard
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan berhasil dihapus.')));
      }
    }
  }
  
  // Helper untuk membuka peta (simulasi)
  void _viewLocation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Simulasi membuka peta di Lat: ${report.latitude}, Long: ${report.longitude}'),
    ));
    // Implementasi nyata: Menggunakan URL launcher untuk Google Maps
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch list untuk memastikan data yang ditampilkan adalah yang terbaru
    final currentReports = ref.watch(reportListProvider).value;
    final currentReport = currentReports?.firstWhere((r) => r.id == report.id, orElse: () => report) ?? report;

    final isCompleted = currentReport.status == 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentReport.judul),
        actions: [
          // Tombol Edit/Mark Selesai (Navigasi ke EditScreen)
          IconButton(
            icon: Icon(isCompleted ? Icons.check_circle : Icons.edit),
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => EditReportScreen(report: currentReport)),
              );
            },
            tooltip: isCompleted ? 'Laporan Selesai' : 'Update Status',
          ),
          // Tombol Hapus Laporan (MAHASISWA 4)
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            onPressed: () => _deleteReport(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Foto Laporan Awal
            const Text('Foto Bukti Awal:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Center(
              child: Image.file(File(currentReport.foto), height: 250, fit: BoxFit.cover), // Foto Full Size
            ),
            
            const Divider(height: 30),
            
            // Detail Teks
            _buildDetailRow('Status', isCompleted ? 'Selesai' : 'Pending', isCompleted ? Colors.green : Colors.red),
            _buildDetailRow('Deskripsi', currentReport.deskripsi),
            const SizedBox(height: 10),

            // Lokasi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailRow('Koordinat', 'Lat: ${currentReport.latitude.toStringAsFixed(4)}, Long: ${currentReport.longitude.toStringAsFixed(4)}'),
                ElevatedButton.icon(
                  onPressed: () => _viewLocation(context),
                  icon: const Icon(Icons.map),
                  label: const Text('Lihat Lokasi'),
                ),
              ],
            ),
            
            // Detail Penyelesaian (Hanya jika Selesai)
            if (isCompleted) ...[
              const Divider(height: 30),
              const Text('Penyelesaian Oleh Petugas:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              _buildDetailRow('Catatan Petugas', currentReport.officerNotes ?? '-'),
              if (currentReport.officerFoto != null && currentReport.officerFoto!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Foto Hasil Pengerjaan:', style: TextStyle(fontWeight: FontWeight.w500)),
                Center(child: Image.file(File(currentReport.officerFoto!), height: 200, fit: BoxFit.cover)),
              ],
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 16, color: valueColor)),
        ],
      ),
    );
  }
}
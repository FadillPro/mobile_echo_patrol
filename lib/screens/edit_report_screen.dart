// lib/screens/edit_report_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
// Import yang disesuaikan dengan struktur folder mobile_echo_patrol
import '/models/report_model.dart';
import '/services/db_helper.dart';
import '/providers/report_notifier.dart';

class EditReportScreen extends ConsumerStatefulWidget {
  final ReportModel report;

  const EditReportScreen({super.key, required this.report});

  @override
  ConsumerState<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends ConsumerState<EditReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final DBHelper _dbHelper = DBHelper();

  String _officerNotes = '';
  File? _officerImageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _officerImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _completeReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    if (_officerImageFile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon tambahkan foto hasil pengerjaan.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final reportId = widget.report.id;
      if (reportId == null) throw Exception("ID Laporan tidak valid.");

      // 1. Upload Foto Hasil Pengerjaan ke Storage (Mengembalikan URL/Path)

      // 2. Buat objek yang diperbarui
      final updatedReport = widget.report.copyWith(
        status: 1,
        officerNotes: _officerNotes,
        officerFoto: _officerImageFile!.path,
      );

      // 3. Update Database menggunakan DBHelper (SQFlite)
      await _dbHelper.updateReport(updatedReport);
      

      ref.invalidate(reportListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil ditandai Selesai!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyelesaikan laporan: ${e.toString()}'),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tandai Selesai')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Laporan: ${widget.report.judul}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const Divider(height: 30),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Catatan Officer (Hasil Pengerjaan)',
                        border: OutlineInputBorder(),
                        hintText:
                            'Jelaskan detail tindakan yang sudah dilakukan...',
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Catatan pekerjaan harus diisi.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _officerNotes = value!;
                      },
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Foto Hasil Pengerjaan:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: _officerImageFile == null
                          ? ElevatedButton.icon(
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Ambil Foto Hasil'),
                              onPressed: _pickImage,
                            )
                          : Column(
                              children: [
                                Image.file(
                                  _officerImageFile!,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.change_circle),
                                  label: const Text('Ganti Foto'),
                                  onPressed: _pickImage,
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.done_all),
                      label: const Text('Selesaikan Laporan dan Update'),
                      onPressed: _completeReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        minimumSize: const Size(double.infinity, 50),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/report_model.dart';
import '../providers/report_notifier.dart';

final tempPhotoProvider = StateProvider<File?>((ref) => null);
final tempLocationProvider = StateProvider<Position?>((ref) => null);

class AddReportScreen extends ConsumerWidget {
  const AddReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final photoFile = ref.watch(tempPhotoProvider);
    final currentPosition = ref.watch(tempLocationProvider);

    Future<void> _pickImage(ImageSource source) async {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        ref.read(tempPhotoProvider.notifier).state = File(pickedFile.path);
      }
    }

    
    Future<void> _getCurrentLocation() async {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied.')));
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      ref.read(tempLocationProvider.notifier).state = position;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lokasi berhasil ditandai!')));
    }

    Future<void> _submitReport() async {
      if (titleController.text.isEmpty || descController.text.isEmpty || photoFile == null || currentPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap lengkapi semua data, foto, dan lokasi.')));
        return;
      }
      
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = p.basename(photoFile.path);
      final String newPath = p.join(directory.path, fileName);
      final File permanentFile = await photoFile.copy(newPath);

      final newReport = ReportModel(
        judul: titleController.text,
        deskripsi: descController.text,
        foto: permanentFile.path,
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
        status: 0, 
        officerNotes: '',
        officerFoto: '',
      );

      await ref.read(reportListProvider.notifier).addReport(newReport);
      ref.read(tempPhotoProvider.notifier).state = null;
      ref.read(tempLocationProvider.notifier).state = null;
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Lapor Sampah Liar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Form Input
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Judul Laporan')),
            const SizedBox(height: 10),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Deskripsi Masalah', border: OutlineInputBorder(),), maxLines: 3),
            const SizedBox(height: 20),

            Center(
              child: photoFile == null
                  ? const Text('Belum ada foto bukti.')
                  : Image.file(photoFile, height: 200, fit: BoxFit.cover),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Ambil Foto'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Dari Galeri'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Lokasi Laporan:', style: TextStyle(fontWeight: FontWeight.bold)),
            if (currentPosition != null)
              Text('Lat: ${currentPosition.latitude.toStringAsFixed(4)}, Long: ${currentPosition.longitude.toStringAsFixed(4)}'),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation, 
              icon: const Icon(Icons.location_on),
              label: const Text('Tag Lokasi Terkini'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _submitReport,
              child: const Text('Kirim Laporan'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
            ),
          ],
        ),
      ),
    );
  }
}
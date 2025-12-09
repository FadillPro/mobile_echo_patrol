import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_model.dart';
import '../services/db_helper.dart';

// Provider untuk DBHelper (Pastikan MAHASISWA 1 sudah mengimplementasi DBHelper)
final dbHelperProvider = Provider((ref) => DBHelper());

// AsyncNotifier untuk mengelola list laporan (MAHASISWA 2, 3, 4)
class ReportListNotifier extends AsyncNotifier<List<ReportModel>> {
  @override
  Future<List<ReportModel>> build() async {
    // Initial load: Panggil dari DB saat pertama kali diakses (MAHASISWA 3)
    return ref.read(dbHelperProvider).getReports();
  }

  // CREATE Logic (MAHASISWA 2)
  Future<void> addReport(ReportModel report) async {
    // Set state ke loading sementara menunggu operasi DB
    state = const AsyncValue.loading();
    try {
      final db = ref.read(dbHelperProvider);
      await db.insertReport(report);
      // Re-fetch data dari DB setelah insert
      state = AsyncValue.data(await db.getReports());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  // UPDATE Logic (MAHASISWA 4)
  Future<void> updateReport(ReportModel report) async {
    state = const AsyncValue.loading();
    try {
      final db = ref.read(dbHelperProvider);
      await db.updateReport(report);
      state = AsyncValue.data(await db.getReports());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // DELETE Logic (MAHASISWA 4)
  Future<void> deleteReport(int id) async {
    state = const AsyncValue.loading();
    try {
      final db = ref.read(dbHelperProvider);
      await db.deleteReport(id);
      state = AsyncValue.data(await db.getReports());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final reportListProvider = AsyncNotifierProvider<ReportListNotifier, List<ReportModel>>(() {
  return ReportListNotifier();
});
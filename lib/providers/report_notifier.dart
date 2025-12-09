import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_model.dart';
import '../services/db_helper.dart';

final dbHelperProvider = Provider((ref) => DBHelper());

class ReportListNotifier extends AsyncNotifier<List<ReportModel>> {
  @override
  Future<List<ReportModel>> build() async {
    return ref.read(dbHelperProvider).getReports();
  }

  Future<void> addReport(ReportModel report) async {
    state = const AsyncValue.loading();
    try {
      final db = ref.read(dbHelperProvider);
      await db.insertReport(report);
      state = AsyncValue.data(await db.getReports());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
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
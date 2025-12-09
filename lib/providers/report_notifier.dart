import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '/models/report_model.dart';
import './db_helper.dart';

class ReportNotifier extends StateNotifier<AsyncValue<bool>> {
  ReportNotifier() : super(const AsyncData(false));

  final DBHelper _db = DBHelper();

  Future<void> insertReport(ReportModel report) async {
    try {
      state = const AsyncLoading(); 

      await _db.insertReport(report);

      state = const AsyncData(true);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final reportNotifierProvider =
    StateNotifierProvider<ReportNotifier, AsyncValue<bool>>(
  (ref) => ReportNotifier(),
);

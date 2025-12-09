import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/report_notifier.dart';
import 'settings_screen.dart';
import 'add_report_screen.dart';
import 'detail_report_screen.dart';
import '../models/report_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportListAsync = ref.watch(reportListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoPatrol Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddReportScreen())),
        child: const Icon(Icons.add),
      ),
      
      body: Column(
        children: [
          ReportSummaryCard(reportListAsync: reportListAsync),
          
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Daftar Laporan:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          
      
          Expanded(
            child: reportListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (reports) {
                if (reports.isEmpty) {
                  return const Center(child: Text('Belum ada laporan.'));
                }
                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return ListTile(
                      title: Text(report.judul),
                      subtitle: Text(report.deskripsi, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: StatusBadge(status: report.status), // Status Badge
                      onTap: () {
                        // Navigasi ke Halaman Detail (MAHASISWA 4)
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => DetailReportScreen(report: report)),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ReportSummaryCard extends StatelessWidget {
  final AsyncValue<List<ReportModel>> reportListAsync;
  
  const ReportSummaryCard({required this.reportListAsync, super.key});
  
  @override
  Widget build(BuildContext context) {
    // Hitung ringkasan dari data state Riverpod
    final total = reportListAsync.value?.length ?? 0;
  final completed = reportListAsync.value?.where((r) => r.status == 1).length ?? 0;
    final pending = total - completed;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.lightGreen.shade50,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Ringkasan Status Laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SummaryItem(label: 'Total', count: total, color: Colors.blueGrey),
                  SummaryItem(label: 'Pending', count: pending, color: Colors.red),
                  SummaryItem(label: 'Selesai', count: completed, color: Colors.green),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  
  const SummaryItem({required this.label, required this.count, required this.color, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  final int status;

  const StatusBadge({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    final color = status == 1 ? Colors.green : Colors.red;
    final text = status == 1 ? 'Selesai' : 'Pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
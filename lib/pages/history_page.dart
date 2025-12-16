import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/empty_state.dart';
import 'daily_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final StorageService _store = StorageService();

  @override
  Widget build(BuildContext context) {
    final keys = _store.getAllKeys();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: [
        Text('History', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Expanded(
          child: keys.isEmpty
              ? const EmptyState(message: 'Belum ada catatan')
              : ListView.builder(
                  itemCount: keys.length,
                  itemBuilder: (c, i) {
                    final k = keys[i];
                    final entry = _store.getEntry(k);
                    final todos = entry?.todos ?? [];
                    final dones = todos.where((t) => t.done).toList();
                    final percent = todos.isEmpty ? 0.0 : (dones.length / todos.length);

                    return Card(
                      child: ListTile(
                        title: Text(_store.formattedDate(k)),
                        subtitle: Text((entry?.note ?? '').split('\n').firstWhere((s) => s.isNotEmpty, orElse: () => 'Belum ada catatan')),
                        trailing: SizedBox(
                          width: 88,
                          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text('${(percent * 100).round()}%', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 6),
                            ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: percent, minHeight: 6)),
                          ]),
                        ),
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => DailyDetailPage(dateKey: k)));
                          setState(() {});
                        },
                      ),
                    );
                  },
                ),
        )
      ]),
    );
  }
}

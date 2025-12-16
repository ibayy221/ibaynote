import 'dart:async';

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../widgets/progress_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_item.dart';

/// Page to view/edit a past or specific date (notes + todos)
class DailyDetailPage extends StatefulWidget {
  final String dateKey;
  const DailyDetailPage({super.key, required this.dateKey});

  @override
  State<DailyDetailPage> createState() => _DailyDetailPageState();
}

class _DailyDetailPageState extends State<DailyDetailPage> {
  final StorageService _store = StorageService();
  late DailyEntry _entry;
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _entry = _store.getEntry(widget.dateKey)!;
    _controller = TextEditingController(text: _entry.note);
    _controller.addListener(_onNote);
  }

  void _onNote() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _store.saveNote(widget.dateKey, _controller.text);
      setState(() => _entry = _store.getEntry(widget.dateKey)!);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    final text = await showDialog<String>(
      context: context,
      builder: (c) => SimpleDialog(
        title: const Text('Tambah Task'),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Tulis tugas...'),
              onSubmitted: (v) => Navigator.of(c).pop(v),
            ),
          )
        ],
      ),
    );
    if (text != null && text.trim().isNotEmpty) {
      await _store.addTodo(widget.dateKey, text.trim());
      setState(() => _entry = _store.getEntry(widget.dateKey)!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final todos = _entry.todos.where((t) => !t.done).toList();
    final dones = _entry.todos.where((t) => t.done).toList();
    final percent = _entry.todos.isEmpty ? 0.0 : (dones.length / _entry.todos.length);

    return Scaffold(
      appBar: AppBar(title: Text(_store.formattedDate(widget.dateKey))),
      floatingActionButton: FloatingActionButton(onPressed: _addTask, child: const Icon(Icons.add)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: _store.getProfileImage() != null ? MemoryImage(_store.getProfileImage()!) : null,
              child: _store.getProfileImage() == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(_store.formattedDate(widget.dateKey), style: Theme.of(context).textTheme.titleLarge)),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('To Do Hari Ini', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${(percent * 100).round()}%')
          ]),
          const SizedBox(height: 8),
          SimpleProgressBar(value: percent),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Daily Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  minLines: 4,
                  maxLines: null,
                  decoration: const InputDecoration.collapsed(hintText: 'Belum ada catatan'),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('To Do Hari Ini', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${(percent * 100).round()}%')
          ]),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (todos.isEmpty)
                  const EmptyState(message: 'Belum ada tugas')
                else ...todos.map((t) => TaskItem(
                      text: t.text,
                      done: t.done,
                      onChanged: (_) async {
                        await _store.toggleTodo(widget.dateKey, t.id);
                        setState(() => _entry = _store.getEntry(widget.dateKey)!);
                      },
                      onDelete: () async {
                        final ok = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text('Hapus task?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
                                  TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Hapus'))
                                ],
                              ),
                            ) ??
                            false;
                        if (ok) {
                          await _store.deleteTodo(widget.dateKey, t.id);
                          setState(() => _entry = _store.getEntry(widget.dateKey)!);
                        }
                      },
                    )),
                const SizedBox(height: 12),
                const Text('Sudah Dikerjakan', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (dones.isEmpty)
                  const EmptyState(message: 'Belum ada pekerjaan selesai')
                else ...dones.map((t) => TaskItem(
                      text: t.text,
                      done: t.done,
                      onChanged: (_) async {
                        await _store.toggleTodo(widget.dateKey, t.id);
                        setState(() => _entry = _store.getEntry(widget.dateKey)!);
                      },
                      onDelete: () async {
                        final ok = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text('Hapus task?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
                                  TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Hapus'))
                                ],
                              ),
                            ) ??
                            false;
                        if (ok) {
                          await _store.deleteTodo(widget.dateKey, t.id);
                          setState(() => _entry = _store.getEntry(widget.dateKey)!);
                        }
                      },
                    ))
              ]),
            ),
          )
        ]),
      ),
    );
  }
}

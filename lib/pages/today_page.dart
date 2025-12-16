import 'dart:async';

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../widgets/progress_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_item.dart';

/// Page showing today's entry: notes (autosave), todos and done list.
class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  final StorageService _store = StorageService();
  late DailyEntry _entry;
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _entry = _store.getToday();
    _controller = TextEditingController(text: _entry.note);
    _controller.addListener(_onNoteChanged);
  }

  void _onNoteChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _store.saveNote(_entry.dateKey, _controller.text);
      setState(() {
        _entry = _store.getEntry(_entry.dateKey)!;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _addTask() async {
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
    ) ??
        '';
    if (text.isNotEmpty) {
      await _store.addTodo(_entry.dateKey, text);
      setState(() {
        _entry = _store.getEntry(_entry.dateKey)!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final todos = _entry.todos.where((t) => !t.done).toList();
    final dones = _entry.todos.where((t) => t.done).toList();
    final percent = dones.isEmpty ? 0.0 : dones.length / _entry.todos.length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: _store.profilePath != null ? FileImage(File(_store.profilePath!)) : null,
            child: _store.profilePath == null ? const Icon(Icons.person_outline) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(StorageService().formattedDate(_entry.dateKey), style: Theme.of(context).textTheme.titleLarge)),
        ]),
        const SizedBox(height: 12),
        Card(
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Daily Notes', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                minLines: 4,
                maxLines: null,
                decoration: const InputDecoration.collapsed(hintText: 'Belum ada catatan hari ini'),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('To Do Hari Ini', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(children: [
            Text('${(percent * 100).round()}%'),
            const SizedBox(width: 8),
            IconButton(onPressed: _addTask, icon: const Icon(Icons.add))
          ])
        ]),
        const SizedBox(height: 8),
        SimpleProgressBar(value: percent),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (todos.isEmpty)
                const EmptyState(message: 'Belum ada tugas hari ini')
              else ...todos.map((t) => TaskItem(
                    text: t.text,
                    done: t.done,
                    onChanged: (_) async {
                      await _store.toggleTodo(_entry.dateKey, t.id);
                      setState(() {
                        _entry = _store.getEntry(_entry.dateKey)!;
                      });
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
                        await _store.deleteTodo(_entry.dateKey, t.id);
                        setState(() {
                          _entry = _store.getEntry(_entry.dateKey)!;
                        });
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
                      await _store.toggleTodo(_entry.dateKey, t.id);
                      setState(() => _entry = _store.getEntry(_entry.dateKey)!);
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
                        await _store.deleteTodo(_entry.dateKey, t.id);
                        setState(() => _entry = _store.getEntry(_entry.dateKey)!);
                      }
                    },
                  ))
            ]),
          ),
        )
      ]),
    );
  }
}

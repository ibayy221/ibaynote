import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

/// Simple singleton service to manage local storage (Hive) for daily entries.
/// Stores DailyEntry objects keyed by yyyy-MM-dd.
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late Box<DailyEntry> _box;
  late Box _settingsBox;

  String? get profilePath => _settingsBox.get('profilePath') as String?;

  Future<void> setProfilePath(String? path) async => await _settingsBox.put('profilePath', path);

  // Profile image is stored in settingsBox under 'profile_image' as List<int>
  Uint8List? getProfileImage() {
    final raw = _settingsBox.get('profile_image');
    if (raw == null) return null;
    return Uint8List.fromList(raw.cast<int>());
  }

  Future<void> setProfileImage(Uint8List bytes) async {
    await _settingsBox.put('profile_image', bytes.toList());
  }

  /// Return the entry for dateKey, create it if missing.
  Future<DailyEntry> getOrCreateEntry(String dateKey) async {
    if (!_box.containsKey(dateKey)) {
      final entry = DailyEntry(dateKey: dateKey);
      await _box.put(dateKey, entry);
    }
    return _box.get(dateKey)!;
  }

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TodoItemAdapter());
    Hive.registerAdapter(DailyEntryAdapter());
    _box = await Hive.openBox<DailyEntry>('entries');
    _settingsBox = await Hive.openBox('settings');
    await _ensureToday();
  }

  String _keyForDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  String formattedDate(String dateKey) {
    final dt = DateTime.parse(dateKey);
    return DateFormat('EEEE, dd MMM yyyy').format(dt);
  }

  Future<void> _ensureToday() async {
    final key = _keyForDate(DateTime.now());
    if (!_box.containsKey(key)) {
      final entry = DailyEntry(dateKey: key);
      await _box.put(key, entry);
    }
  }

  DailyEntry? getEntry(String dateKey) => _box.get(dateKey);

  DailyEntry getToday() => _box.get(_keyForDate(DateTime.now()))!;

  List<String> getAllKeys() {
    final keys = _box.keys.cast<String>().toList();
    keys.sort((a, b) => b.compareTo(a)); // newest first
    return keys;
  }

  Future<void> saveNote(String dateKey, String note) async {
    final entry = _box.get(dateKey);
    if (entry != null) {
      entry.note = note;
      await _box.put(dateKey, entry);
    }
  }

  Future<void> addTodo(String dateKey, String text) async {
    final entry = _box.get(dateKey);
    if (entry != null) {
      final id = DateTime.now().millisecondsSinceEpoch;
      entry.todos.add(TodoItem(id: id, text: text));
      await _box.put(dateKey, entry);
    }
  }

  Future<void> toggleTodo(String dateKey, int id) async {
    final entry = _box.get(dateKey);
    if (entry != null) {
      final idx = entry.todos.indexWhere((t) => t.id == id);
      if (idx != -1) {
        entry.todos[idx].done = !entry.todos[idx].done;
        await _box.put(dateKey, entry);
      }
    }
  }

  Future<void> deleteTodo(String dateKey, int id) async {
    final entry = _box.get(dateKey);
    if (entry != null) {
      entry.todos.removeWhere((t) => t.id == id);
      await _box.put(dateKey, entry);
    }
  }

  bool get isDark => _settingsBox.get('isDark', defaultValue: false) as bool;

  Future<void> setDark(bool v) async => await _settingsBox.put('isDark', v);
}

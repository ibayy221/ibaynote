import 'package:hive/hive.dart';
import 'todo_item.dart';

class DailyEntry {
  String dateKey; // yyyy-MM-dd
  String note;
  List<TodoItem> todos;

  DailyEntry({required this.dateKey, this.note = '', List<TodoItem>? todos}) : todos = todos ?? [];
}

class DailyEntryAdapter extends TypeAdapter<DailyEntry> {
  @override
  final int typeId = 1;

  @override
  DailyEntry read(BinaryReader reader) {
    final dateKey = reader.readString();
    final note = reader.readString();
    final todos = reader.readList().cast<TodoItem>();
    return DailyEntry(dateKey: dateKey, note: note, todos: todos);
  }

  @override
  void write(BinaryWriter writer, DailyEntry obj) {
    writer.writeString(obj.dateKey);
    writer.writeString(obj.note);
    writer.writeList(obj.todos);
  }
}

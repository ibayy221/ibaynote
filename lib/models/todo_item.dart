import 'package:hive/hive.dart';

class TodoItem {
  int id;
  String text;
  bool done;

  TodoItem({required this.id, required this.text, this.done = false});
}

class TodoItemAdapter extends TypeAdapter<TodoItem> {
  @override
  final int typeId = 0;

  @override
  TodoItem read(BinaryReader reader) {
    final id = reader.readInt();
    final text = reader.readString();
    final done = reader.readBool();
    return TodoItem(id: id, text: text, done: done);
  }

  @override
  void write(BinaryWriter writer, TodoItem obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.text);
    writer.writeBool(obj.done);
  }
}

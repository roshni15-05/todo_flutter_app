import 'package:hive/hive.dart';
part 'todo_model.g.dart';

@HiveType(typeId: 0)
class Todo {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  int priority;

  @HiveField(3)
  bool isCompleted;

  Todo({
    required this.title,
    required this.description,
    this.priority = 1,
    this.isCompleted = false,
  });
}
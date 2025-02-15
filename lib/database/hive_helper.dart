import 'package:hive/hive.dart';
import 'package:to_do_demo_app/models/todo_model.dart';
class HiveHelper {

  static Box<Todo> get _todoBox => Hive.box<Todo>('todos');
  static Future<void> addTodo(Todo todo) async {
    await _todoBox.add(todo);
  }

  static List<Todo> getTodos() {
    return _todoBox.values.toList();
  }

  static Future<void> updateTodo(int index, Todo updatedTodo) async {
    await _todoBox.putAt(index, updatedTodo);
  }

  static Future<void> deleteTodo(int index) async {
    await _todoBox.deleteAt(index);
  }

  static Future<void> toggleCompletion(int index, bool isCompleted)
  async{
    final todo = _todoBox.getAt(index);
    if (todo!=null){
      await _todoBox.putAt(index,
          Todo(title: todo.title,
            description: todo.description,
            priority: todo.priority,
            isCompleted: todo.isCompleted,
          ));
    }
  }
}
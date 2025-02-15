import 'package:flutter/material.dart';
import 'package:to_do_demo_app/database/hive_helper.dart';
import 'package:to_do_demo_app/models/todo_model.dart';
import 'package:to_do_demo_app/home_screen/add_edit_page.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;
  const HomeScreen({super.key, required this.toggleTheme, required this.isDarkMode});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Todo> _todos = [];
  List<Todo> _filteredTodos = []; // List to hold filtered todos
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTodos();
    _searchController.addListener(_filterTodos); // Listen for search input changes
  }

// Fetch all todos
  void _fetchTodos() {
    setState(() {
      _todos = HiveHelper.getTodos();
      _filteredTodos = _todos; // Initially, show all todos
    });
  }

// Filter the todos based on the search query
  void _filterTodos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTodos = _todos.where((todo) {
        return todo.title.toLowerCase().contains(query) ||
            todo.description.toLowerCase().contains(query);
      }).toList();
    });
  }

// Color based on priority
  Color _getPriorityColor(int priority) {
    if (priority == 2) {
      return Colors.red; // High priority
    } else if (priority == 1) {
      return Colors.orange; // Medium priority
    } else {
      return Colors.green; // Low priority
    }
  }

// Delete Todo from the list
  Future<void> _deleteTodo(int index) async {
    await HiveHelper.deleteTodo(index);
    _fetchTodos();
  }

// Edit Todo in the list
  void _editTodo(int index, Todo todo) {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => AddEditPage(todo: todo, index: index),
    ))
        .then((_) => _fetchTodos()); // Refresh list after edit
  }

// Change priority of the Todo
  Future<void> _changePriority(int index, Todo todo) async {
    int newPriority = todo.priority;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Priority'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('High'),
                onTap: () {
                  newPriority = 2;
                  Navigator.of(context).pop();
                },
              ),

              ListTile(
                title: const Text('Medium'),
                onTap: () {
                  newPriority = 1;
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Low'),
                onTap: () {
                  newPriority = 0;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );

    if (newPriority != todo.priority) {
      todo.priority = newPriority;
// Update the todo in the database
      await HiveHelper.updateTodo(index, todo);
      _fetchTodos(); // Refresh list after updating
    }
  }

  Future<void> _toggleCompletion(int index, bool isCompleted) async{
    await HiveHelper.toggleCompletion(index, isCompleted);
    _fetchTodos();
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose of the search controller
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO APP'),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        actions: [
          IconButton( icon: Icon(widget.isDarkMode ? Icons.dark_mode:Icons.light_mode),
            onPressed: (){
              widget.toggleTheme(!widget.isDarkMode);
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditPage()),
          );
          _fetchTodos();
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white, size: 40),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Todo...',
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = _filteredTodos[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(todo.priority),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: ListTile(
                    leading: Checkbox(value: todo.isCompleted,
                      onChanged: (bool ? value) async{
                        setState(() {
                          todo.isCompleted = value ?? false;
                        });
                        if(todo.isCompleted){
                          Future.delayed(const Duration(seconds: 1),() async{
                            await _deleteTodo(index);
                          });
                        }else {
                          setState(() {
                            todo.isCompleted = value ?? false;
                          });
                          await HiveHelper.updateTodo(index, todo);
                        }
                      },
                    ),

                    title: Text(todo.title),
                    subtitle: Text(todo.description),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteTodo(index);
                        } else if (value == 'edit') {
                          _editTodo(index, todo);
                        } else if (value == 'priority') {
                          _changePriority(index, todo); // Change priority
                        }
                      },

                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        const PopupMenuItem(value: 'priority', child: Text('Change Priority')),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
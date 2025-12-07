import 'package:flutter/material.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      home: const TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final ValueNotifier<List<ListItem>> _items = ValueNotifier([]);
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _items.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddTaskSheet({ListItem? itemToEdit, int? index}) {
    if (itemToEdit != null) {
      _nameController.text = itemToEdit.title;
      _descriptionController.text = itemToEdit.description;
    } else {
      _nameController.clear();
      _descriptionController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Task title',
                    prefixIcon: Icon(Icons.task_alt),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Description',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final title = _nameController.text.trim();
                    final description = _descriptionController.text.trim();

                    if (title.isEmpty) return;

                    final updatedItems = List<ListItem>.from(_items.value);

                    if (itemToEdit != null && index != null) {
                      updatedItems[index] = ListItem(
                        title: title,
                        isSelected: itemToEdit.isSelected,
                        description: description,
                      );
                    } else {
                      updatedItems.add(ListItem(
                        title: title,
                        isSelected: false,
                        description: description,
                      ));
                    }

                    _items.value = updatedItems;
                    _nameController.clear();
                    _descriptionController.clear();
                    Navigator.pop(context);
                  },
                  child: Text(itemToEdit != null ? 'Save Changes' : 'Add Task'),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      _nameController.clear();
      _descriptionController.clear();
    });
  }

  // String _getSubtitle(String title) {
  //   switch (title) {
  //     case "Read a book":
  //       return "Rest and recharge your batteries - your mind will thank you for it.";
  //     default:
  //       return "No description provided.";
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back, color: Colors.white),
        title: const Text("Todo Screen", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              if (_items.value.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete All Tasks"),
                    content: const Text("Are you sure you want to delete all tasks?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          _items.value = [];
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Delete All",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<ListItem>>(
        valueListenable: _items,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const Center(child: Text("No tasks yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 10),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () {
                    final updatedItems = List<ListItem>.from(_items.value);
                    updatedItems[index].isSelected = !updatedItems[index].isSelected;
                    _items.value = updatedItems;
                  },
                  leading: Icon(
                    item.isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: item.isSelected ? Colors.deepPurple : Colors.grey,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration:
                          item.isSelected ? TextDecoration.lineThrough : TextDecoration.none,
                      color: item.isSelected ? Colors.grey : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    item.description.isNotEmpty
                        ? item.description
                  : "no description provided"),
                  trailing: GestureDetector(
                    onTapDown: (TapDownDetails details) async {
                      final value = await showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          details.globalPosition.dx,
                          details.globalPosition.dy,
                          MediaQuery.of(context).size.width - details.globalPosition.dx,
                          MediaQuery.of(context).size.height - details.globalPosition.dy,
                        ),
                        items: const [
                          PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                          PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                        ],
                      );

                      if (value == 'delete') {
                        final updatedItems = List<ListItem>.from(_items.value);
                        updatedItems.removeAt(index);
                        _items.value = updatedItems;
                      } else if (value == 'edit') {
                        _showAddTaskSheet(itemToEdit: item, index: index);
                      }
                    },
                    child: const Icon(Icons.more_vert),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _showAddTaskSheet(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class ListItem {
  String title;
  bool isSelected;
  String description;

  ListItem({
    required this.title,
    required this.isSelected,
    required this.description,
  });
}

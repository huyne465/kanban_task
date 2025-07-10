import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kanban/widgets/card.dart';
import 'package:kanban/providers/kanban_provider.dart';
import 'package:kanban/models/task.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => KanbanProvider(),
      child: const MaterialApp(
        home: HomePage(),
        debugShowCheckedModeBanner: false,
        title: 'kanban',
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget buildKanbanColumn(String status, String title, Color headerColor) {
    return Consumer<KanbanProvider>(
      builder: (context, kanbanProvider, child) {
        final tasks = kanbanProvider.getTasksByStatus(status);

        return Column(
          children: [
            Container(
              width: 300,
              padding: EdgeInsets.symmetric(vertical: 12),
              color: headerColor,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            DragTarget<Task>(
              onAccept: (task) {
                kanbanProvider.updateTaskStatus(task.id, status);
              },
              builder: (context, candidateData, rejectedData) {
                bool isHovered = candidateData.isNotEmpty;
                return Container(
                  width: 300,
                  height: 500,
                  color: isHovered ? Colors.orange[50] : Colors.blueGrey[100],
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: tasks.map((task) {
                        return KanbanCard(
                          task: task,
                          headerColor: kanbanProvider.getHeaderColor(
                            task.status,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedStatus = 'requested';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Thêm Task Mới'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Tiêu đề',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Mô tả',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Trạng thái',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'requested',
                        child: Text('REQUESTED'),
                      ),
                      DropdownMenuItem(
                        value: 'inprogress',
                        child: Text('IN PROGRESS'),
                      ),
                      DropdownMenuItem(value: 'done', child: Text('DONE')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final newTask = Task(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        description: descriptionController.text,
                        status: selectedStatus,
                      );

                      Provider.of<KanbanProvider>(
                        context,
                        listen: false,
                      ).addTask(newTask);

                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildDeleteArea() {
    return Consumer<KanbanProvider>(
      builder: (context, kanbanProvider, child) {
        return DragTarget<Task>(
          onAccept: (task) {
            kanbanProvider.removeTask(task.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã xóa task: ${task.title}'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          },
          builder: (context, candidateData, rejectedData) {
            bool isHovered = candidateData.isNotEmpty;
            return AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: isHovered ? 40 : 30,
              height: isHovered ? 40 : 30,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isHovered ? Colors.red[400] : Colors.red[200],
                borderRadius: BorderRadius.circular(isHovered ? 70 : 80),
                border: Border.all(
                  color: isHovered ? Colors.red[700]! : Colors.red[400]!,
                  width: isHovered ? 3 : 2,
                ),
                boxShadow: isHovered
                    ? [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                Icons.delete_forever,
                size: isHovered ? 30 : 20,
                color: isHovered ? Colors.white : Colors.red[700],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Center(
          child: Text(
            'KanBan Board',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Thêm Task Mới',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Delete Area ở trên cùng
            Container(
              width: double.infinity,
              color: Colors.grey[100],
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Kéo task vào đây để xóa: ',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  buildDeleteArea(),
                ],
              ),
            ),
            // Kanban Board
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  color: Colors.blue[200],
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildKanbanColumn(
                          'requested',
                          'REQUESTED',
                          Colors.blue[900]!,
                        ),
                        SizedBox(width: 10),
                        buildKanbanColumn(
                          'inprogress',
                          'IN PROGRESS',
                          Colors.orange[800]!,
                        ),
                        SizedBox(width: 10),
                        buildKanbanColumn('done', 'DONE', Colors.green),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

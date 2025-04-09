import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  //Create an empty list of maps which represent our tasks
  final List<Map<String, dynamic>> tasks = [];

  //Create a variable that captures the input of a text input
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  //Fetch tasks from the db and also update the task list in memory
  Future<void> fetchTasks() async {
    final snapshots = await db.collection('tasks').orderBy('timestamp').get();

    setState(() {
      tasks.clear();
      tasks.addAll(
        snapshots.docs.map(
          (doc) => {
            'id': doc.id,
            'name': doc.get('name'),
            'completed': doc.get('completed') ?? false,
          },
        ),
      );
    });
  }

  //function add new tasks to local state & firestore database
  Future<void> addTask() async {
    final taskName = nameController.text.trim();

    if (taskName.isNotEmpty) {
      final newTask = {
        'name': taskName,
        'completed': false,
        'timestamp': FieldValue.serverTimestamp(),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: Image.asset('assets/rdplogo.png', height: 80)),
            Text(
              'RDP Daily Planner',
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 32,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 340,
              child: TableCalendar(
                calendarFormat: CalendarFormat.month,
                focusedDay: DateTime.now(),
                firstDay: DateTime(2025),
                lastDay: DateTime(2026),
              ),
            ),
            Expanded(
              child: Container(child: buildAddTaskSection(nameController)),
            ),
          ],
        ),
      ),
      drawer: Drawer(),
    );
  }
}

//Build the section for adding tasks
Widget buildAddTaskSection(nameController) {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            maxLength: 32,
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Add Task',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        ElevatedButton(onPressed: null, child: Text('Add Task')),
      ],
    ),
  );
}

Widget buildTaskList(tasks) {
  return ListView.builder(
    physics: NeverScrollableScrollPhysics(),
    itemCount: tasks.length,
    itemBuilder: (context, index) {
      return ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );
    },
  );
}

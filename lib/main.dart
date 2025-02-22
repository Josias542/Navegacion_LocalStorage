import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('notesBox');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Box notesBox = Hive.box('notesBox');
  int _selectedIndex = 0;

  void _addNote(String title, String content) {
    notesBox.add({'title': title, 'content': content});
    setState(() {});
  }

  void _deleteNote(int index) {
    notesBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.notes),
                  label: Text('Notas'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.add),
                  label: Text('Nueva Nota'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Usuario'),
                ),
              ],
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  NotesScreen(onDelete: _deleteNote),
                  NewNoteScreen(onAddNote: _addNote),
                  UserScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotesScreen extends StatelessWidget {
  final Function(int) onDelete;
  final Box notesBox = Hive.box('notesBox');

  NotesScreen({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Notas')),
      body: ValueListenableBuilder(
        valueListenable: notesBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return Center(child: Text('No hay notas.'));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              var note = box.getAt(index) as Map;
              return Card(
                child: ListTile(
                  title: Text(note['title']),
                  subtitle: Text(note['content']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onDelete(index),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NewNoteScreen extends StatefulWidget {
  final Function(String, String) onAddNote;

  NewNoteScreen({required this.onAddNote});

  @override
  NewNoteScreenState createState() => NewNoteScreenState();
}

class NewNoteScreenState extends State<NewNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  void _saveNote() {
    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      widget.onAddNote(_titleController.text, _contentController.text);
      _titleController.clear();
      _contentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nueva Nota')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Contenido'),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveNote,
              child: Text('Guardar Nota'),
            ),
          ],
        ),
      ),
    );
  }
}

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Información del Usuario')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            SizedBox(height: 10),
            Text('Nombre: Josias David Alcalá Gomez', style: TextStyle(fontSize: 18)),
            Text('Email: gomezjosias542@gmail.com', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tugas_week_9_1123150117/database/database_helper.dart';
import 'package:tugas_week_9_1123150117/models/note_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MySimpleNotes(),
    );
  }
}

class MySimpleNotes extends StatefulWidget {
  const MySimpleNotes({super.key});

  @override
  State<MySimpleNotes> createState() => _MySimpleNotesState();
}

class _MySimpleNotesState extends State<MySimpleNotes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple Notes dengan SQL')),
      body: FutureBuilder<List<Note>>(
        future: DatabaseHelper.instance.readAllNotes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Note note = snapshot.data![index];
              return Card(
                child: ListTile(
                  title: Text(note.title),
                  subtitle: Text(note.content),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await DatabaseHelper.instance.delete(note.id!);
                      setState(() {}); // Refresh UI
                    },
                  ), //IconButton
                ), // ListTile
              ); // Card
            },
          ); // ListView.builder
        },
      ), //FutureBuilder
      ////////////
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await DatabaseHelper.instance.create(
            Note(
              title: 'Catatan Baru',
              content: 'Isi catatan otomatis pada ${DateTime.now()}',
            ),
          );
          setState(() {}); // Refresh UI
        },
      ), // FloatingActionButton
      ////////////
    ); // Scaffold
  }
}

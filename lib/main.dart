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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Fungsi untuk memunculkan Form
  void _showForm() {
    // Bersihkan input field setiap kali form dibuka
    _titleController.clear();
    _contentController.clear();
    showModalBottomSheet(
      context: context,
      elevation: 5,
      // Agar form bisa full screen saat keyboard muncul
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          // Padding bawah mengikuti tinggi keyboard agar form tidak tertutup
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(hintText: 'Judul Catatan'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(hintText: 'Isi Catatan'),
              maxLines: 3, // Agar area ketik lebih luas
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // 1. Ambil teks dari controller
                String title = _titleController.text;
                String content = _contentController.text;
                if (title.isNotEmpty && content.isNotEmpty) {
                  // 2. Simpan ke Database
                  await DatabaseHelper.instance.create(
                    Note(title: title, content: content),
                  );
                  // 3. Tutup Form & Refresh UI
                  Navigator.of(context).pop();
                  setState(() {});
                }
              },
              child: Text('Simpan Catatan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple Notes dengan SQL')),
      body: FutureBuilder<List<Note>>(
        future: DatabaseHelper.instance.readAllNotes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                _showForm();
              },
            ),
            FloatingActionButton(
              child: Icon(Icons.sd_card),
              onPressed: () async {
                await DatabaseHelper.instance.create(
                  Note(
                    title: 'Catatan Baru',
                    content: 'Isi catatan otomatis pada ${DateTime.now()}',
                  ),
                );
                setState(() {}); // Refresh UI
              },
            ),
          ],
        ),
      ),
      ////////////
    ); // Scaffold
  }
}

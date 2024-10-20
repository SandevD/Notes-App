import 'package:flutter/material.dart';
import 'package:my_simple_note/models/note.dart';
import 'package:my_simple_note/services/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  String? _note;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'My Simple Note',
          style: TextStyle(fontSize: 28, color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://cdn-icons-png.flaticon.com/512/3209/3209265.png'), // Replace with a proper avatar URL
            ),
          ),
        ],
      ),
      floatingActionButton: _addNoteButton(),
      body: _noteList(),
    );
  }

  Widget _addNoteButton() {
    return FloatingActionButton(
      onPressed: () {
        _showAddNoteModal(context); // Triggering the modal on button press
      },
      backgroundColor: Colors.white,
      child: const Icon(Icons.add),
    );
  }

  void _showAddNoteModal(BuildContext context) {
    TextEditingController noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          padding: MediaQuery.of(context).viewInsets,
          child: _buildAddNoteModal(context, noteController),
        );
      },
    );
  }

  Widget _buildAddNoteModal(
      BuildContext context, TextEditingController noteController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white, // White background for the modal
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add Note',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Black text for contrast on white
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: noteController,
            decoration: const InputDecoration(
              labelText: 'Note Content',
              labelStyle: TextStyle(color: Colors.black), // Black label color
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black), // Black underline
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.blue), // Blue underline when focused
              ),
            ),
            style: const TextStyle(color: Colors.black), // Black text color
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              String noteContent = noteController.text.trim();
              if (noteContent.isNotEmpty) {
                setState(() {
                  // Add the new note to the database
                  _databaseService.addNotes(noteContent);
                });
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Button color
            ),
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white), // White text for contrast
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteList() {
    return FutureBuilder(
      future: _databaseService.getNotes(), // Replace with your actual method
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Error fetching notes"));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: snapshot.data?.length ?? 0,
          itemBuilder: (context, index) {
            Note note = snapshot.data![index];
            return _noteCard(note, context);
          },
        );
      },
    );
  }

  Widget _noteCard(Note note, BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showEditModal(context, note);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.content,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                note.content,
                style: const TextStyle(color: Colors.black),
                overflow: TextOverflow.ellipsis,
                maxLines: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context, Note note) {
    TextEditingController titleController =
        TextEditingController(text: note.content);
    TextEditingController contentController =
        TextEditingController(text: note.content);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          padding: MediaQuery.of(context).viewInsets,
          child: _buildEditModal(
              context, note, titleController, contentController),
        );
      },
    );
  }

  Widget _buildEditModal(
      BuildContext context,
      Note note,
      TextEditingController titleController,
      TextEditingController contentController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title of the modal
          const Text(
            'Edit Note',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20), // Spacer
          // Title input field
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Edit Title'),
          ),
          const SizedBox(height: 10),
          // Content input field
          TextField(
            controller: contentController,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Edit Content'),
          ),
          const SizedBox(height: 20),
          // Save buttonRow(
          Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceEvenly, // Centers the buttons with space between
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Update note and pop modal
                    // Update logic here
                    String noteContent = contentController.text.trim();
                    if (noteContent.isNotEmpty) {
                      setState(() {
                        // Add the new note to the database
                        _databaseService.updateNotes(note.id, noteContent);
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Button color
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(
                        color: Colors.white), // White text for contrast
                  ),
                ),
              ]),
        ],
      ),
    );
  }
}

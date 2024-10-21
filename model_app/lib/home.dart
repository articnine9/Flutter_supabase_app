import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Logger _logger = Logger();

void _showAddNoteDialog() {
  final TextEditingController noteController = TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Add a Note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(hintText: 'Enter your note here'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              final String noteContent = noteController.text;

              if (noteContent.isNotEmpty) {
                Supabase.instance.client
                    .from('data')
                    .insert({'body': noteContent})
                    .then((response) {
                      if (response != null && response.data != null) {
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(content: Text('Note added successfully!')),
                          );
                        }
                      } else {
                        // Handle the case where the response is null or error occurred
                        _logger.e('Error: ${response?.error?.message ?? 'Unknown error'}');
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text('Error: ${response?.error?.message ?? 'Unknown error'}')),
                          );
                        }
                      }
                    })
                    .catchError((error) {
                      _logger.e('Unexpected error: $error');
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(content: Text('Unexpected error: $error')),
                        );
                      }
                    });
              } else {
                // Show message if note is empty
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Please enter a note.')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note Demo'),
      ),
      body: const Center(
        child: Text('Press the button to add a note.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'database_helper.dart';

class EditSetScreen extends StatefulWidget {
  final int flashcardSetId;
  final DatabaseHelper dbHelper;
  final String initialTitle;
  final Function(String) onTitleUpdated;

  const EditSetScreen({
    Key? key,
    required this.flashcardSetId,
    required this.dbHelper,
    required this.initialTitle,
    required this.onTitleUpdated,
  }) : super(key: key);

  @override
  _EditSetScreenState createState() => _EditSetScreenState();
}

class _EditSetScreenState extends State<EditSetScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> _termControllers = [];
  final List<TextEditingController> _definitionControllers = [];

  @override
  void initState() {
    super.initState();
    _loadFlashcardSet();
  }

  Future<void> _loadFlashcardSet() async {
    final flashcardSet = await widget.dbHelper.queryFlashcardSet(widget.flashcardSetId);

    setState(() {
      _titleController.text = flashcardSet[DatabaseHelper.columnSetTitle];
    });

    final flashcards = await widget.dbHelper.queryAllFlashcardsInSet(widget.flashcardSetId);

    for (var flashcard in flashcards) {
      final termController = TextEditingController(text: flashcard[DatabaseHelper.columnTerm]);
      final definitionController = TextEditingController(text: flashcard[DatabaseHelper.columnDefinition]);

      setState(() {
        _termControllers.add(termController);
        _definitionControllers.add(definitionController);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Set'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                onChanged: (value) {
                  // Update the title controller when the text changes
                  setState(() {
                    _titleController.text = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _termControllers.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _termControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Term ${index + 1}',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _definitionControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Definition ${index + 1}',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
              ElevatedButton(
                onPressed: _addFlashcard,
                child: const Text('Add Flashcard'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addFlashcard() {
    setState(() {
      _termControllers.add(TextEditingController());
      _definitionControllers.add(TextEditingController());
    });
  }

 void _saveChanges() async {

  final setTitle = _titleController.text;
  await widget.dbHelper.updateFlashcardSet(widget.flashcardSetId, setTitle);

  final flashcards = await widget.dbHelper.queryAllFlashcardsInSet(widget.flashcardSetId);

  for (int i = 0; i < _termControllers.length; i++) {
    final term = _termControllers[i].text;
    final definition = _definitionControllers[i].text;

    if (term.isNotEmpty || definition.isNotEmpty) {
      final flashcardId = i < flashcards.length ? flashcards[i][DatabaseHelper.columnId] : null;

      if (flashcardId != null) {
        await widget.dbHelper.updateFlashcard(widget.flashcardSetId, flashcardId, term, definition);
      } else {
        await widget.dbHelper.insertFlashcard(widget.flashcardSetId, term, definition);
      }
    }
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Changes saved successfully')),
  );

  widget.onTitleUpdated(setTitle);
}

}
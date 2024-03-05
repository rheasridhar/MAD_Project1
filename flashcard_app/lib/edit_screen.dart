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
  bool _changesSaved = true;

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
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Set'),
          backgroundColor: const Color(0xFFCBB5F2),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _titleController,
                onChanged: (value) {
                  setState(() {
                    _changesSaved = false;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _termControllers.length,
                itemBuilder: (context, index) {
                  return _buildCard(index);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _addFlashcard,
                    child: const Text('Add Flashcard'),
                  ),
                  ElevatedButton(
                    onPressed: (_changesSaved || _fieldsAreEmpty()) ? null : () => _saveChangesAndUpdateButtonStyle(),
                    style: (_changesSaved || _fieldsAreEmpty()) ? null : ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 144, 93, 231)),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _termControllers[index],
                onChanged: (value) {
                  setState(() {
                    _changesSaved = false;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Term',
                  border: OutlineInputBorder(),
                  errorText: _termControllers[index].text.isEmpty ? 'Term is required' : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _definitionControllers[index],
                onChanged: (value) {
                  setState(() {
                    _changesSaved = false;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Definition',
                  border: OutlineInputBorder(),
                  errorText: _definitionControllers[index].text.isEmpty ? 'Definition is required' : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  _deleteFlashcard(index);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 225, 215, 242)),
                ),
                child: const Text('Delete'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addFlashcard() {
    setState(() {
      _termControllers.add(TextEditingController());
      _definitionControllers.add(TextEditingController());
      _changesSaved = false;
    });
  }

  void _deleteFlashcard(int index) {
    setState(() {
      _termControllers.removeAt(index);
      _definitionControllers.removeAt(index);
      _changesSaved = false;
    });
  }

  Future<bool> _onWillPop(BuildContext context) async {
    if (!_changesSaved && _changesMade()) {
      return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Discard Changes?'),
            content: const Text('Are you sure you want to leave without saving changes?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('No'),
              ),
            ],
          );
        },
      ) ?? false;
    }
    return true;
  }

  bool _changesMade() {
    if (_titleController.text != widget.initialTitle) {
      return true;
    }
    for (var i = 0; i < _termControllers.length; i++) {
      if (_termControllers[i].text.isNotEmpty || _definitionControllers[i].text.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  bool _fieldsAreEmpty() {
    for (int i = 0; i < _termControllers.length; i++) {
      if (_termControllers[i].text.trim().isEmpty || _definitionControllers[i].text.trim().isEmpty) {
        return true;
      }
    }
    return false;
  }

  void _saveChangesAndUpdateButtonStyle() {
    _saveChanges();
    setState(() {
      _changesSaved = true;
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

    for (int i = _termControllers.length; i < flashcards.length; i++) {
      final flashcardId = flashcards[i][DatabaseHelper.columnId];
      await widget.dbHelper.deleteFlashcard(widget.flashcardSetId, flashcardId);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved successfully')),
    );

    widget.onTitleUpdated(setTitle);
  }
}

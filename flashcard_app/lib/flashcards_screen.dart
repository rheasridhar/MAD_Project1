import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'practice_screen.dart';
import 'edit_screen.dart';

class FlashcardsScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const FlashcardsScreen({Key? key, required this.dbHelper}) : super(key: key);

  @override
  _FlashcardsScreenState createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  late Future<List<Map<String, dynamic>>> _flashcardSetsFuture;

  @override
  void initState() {
    super.initState();
    _reloadFlashcardSets();
  }

  void _reloadFlashcardSets() {
    setState(() {
      _flashcardSetsFuture = widget.dbHelper.queryAllFlashcardSets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _flashcardSetsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final flashcardSets = snapshot.data!;
            return ListView.builder(
              itemCount: flashcardSets.length,
              itemBuilder: (context, index) {
                final setTitle = flashcardSets[index][DatabaseHelper.columnSetTitle];
                final flashcardSetId = flashcardSets[index][DatabaseHelper.columnId];
                return FlashcardSetButton(
                  setTitle: setTitle,
                  flashcardSetId: flashcardSetId,
                  dbHelper: widget.dbHelper,
                  onPressed: () {
                    _navigateToEditSetScreen(context, flashcardSetId, setTitle);
                  },
                  onDelete: () async {
                    await _deleteFlashcardSet(context, flashcardSetId);
                    _reloadFlashcardSets(); 
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteFlashcardSet(BuildContext context, int flashcardSetId) async {
    await widget.dbHelper.deleteFlashcardSet(flashcardSetId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Flashcard set deleted')),
    );
  }

  void _navigateToEditSetScreen(BuildContext context, int flashcardSetId, String setTitle) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditSetScreen(
        flashcardSetId: flashcardSetId,
        dbHelper: widget.dbHelper,
        initialTitle: setTitle,
        onTitleUpdated: (newTitle) {
          _reloadFlashcardSets();
        },
      ),
    ),
  );
}

}

class FlashcardSetButton extends StatelessWidget {
  final String setTitle;
  final int flashcardSetId;
  final DatabaseHelper dbHelper;
  final VoidCallback onPressed;
  final VoidCallback onDelete;

  const FlashcardSetButton({
    Key? key,
    required this.setTitle,
    required this.flashcardSetId,
    required this.dbHelper,
    required this.onPressed,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: ElevatedButton(
        onPressed: () {
          _showOptionsPopup(context);
        },
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(setTitle),
                FutureBuilder<int>(
                  future: dbHelper.countFlashcardsInSet(flashcardSetId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    } else if (snapshot.hasError) {
                      return const SizedBox();
                    } else {
                      final count = snapshot.data!;
                      return Text('$count terms');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(setTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionButton(context, 'Practice'),
              const SizedBox(height: 10),
              _buildOptionButton(context, 'Quiz'),
              const SizedBox(height: 10),
              _buildOptionButton(context, 'Edit'),
              const SizedBox(height: 10),
              _buildOptionButton(context, 'Delete'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(BuildContext context, String text) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);

        if (text == 'Practice') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PracticeScreen(flashcardSetId: flashcardSetId),
            ),
          );
        } else if (text == 'Quiz') {
          // Navigate to quiz screen
        } else if (text == 'Edit') {
          onPressed();
        } else if (text == 'Delete') {
          _showDeleteConfirmationDialog(context);
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20.0),
        minimumSize: const Size(double.infinity, 60.0),
      ),
      child: Text(text),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this flashcard set?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onDelete();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

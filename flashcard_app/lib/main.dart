import 'package:flutter/material.dart';
import 'database_helper.dart';

//db
final dbHelper = DatabaseHelper();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
// initialize the database
  await dbHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Homepage'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to Flashcard App!',
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateSetScreen()),
                );
              },
              child: const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      'Add',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FlashcardsScreen()),
                );
              },
              child: const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      'Study',
                      style: TextStyle(fontSize: 20),
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

/* CREATE SET SCREEN */
class CreateSetScreen extends StatefulWidget {
  const CreateSetScreen({Key? key}) : super(key: key);

  @override
  _CreateSetScreenState createState() => _CreateSetScreenState();
}

class _CreateSetScreenState extends State<CreateSetScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> _termControllers = [];
  final List<TextEditingController> _definitionControllers = [];

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _termControllers) {
      controller.dispose();
    }
    for (var controller in _definitionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Set'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
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
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _definitionControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Definition ${index + 1}',
                          border: const OutlineInputBorder(),
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
                onPressed: _saveSet,
                child: const Text('Save Set'),
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

  void _saveSet() async {
    final setTitle = _titleController.text;

    // First, insert the flashcard set into the database
    final flashcardSetId = await dbHelper.insertFlashcardSet(setTitle);

    // Insert each flashcard into the database
    for (int i = 0; i < _termControllers.length; i++) {
      final term = _termControllers[i].text;
      final definition = _definitionControllers[i].text;
      await dbHelper.insertFlashcard(flashcardSetId, term, definition);
    }
    // Redirect to FlashcardsScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FlashcardsScreen()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Flashcard set saved successfully')),
    );
  }
}

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({Key? key}) : super(key: key);

  @override
  _FlashcardsScreenState createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  late Future<List<Map<String, dynamic>>> _flashcardSetsFuture;

  @override
  void initState() {
    super.initState();
    _flashcardSetsFuture = dbHelper.queryAllFlashcardSets();
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashcardSetScreen(
                          setTitle: setTitle,
                          flashcardSetId: flashcardSetId,
                        ),
                      ),
                    );
                  },
                  onDelete: () async {
                    await _deleteFlashcardSet(context, flashcardSetId);
                    setState(() {
                      _flashcardSetsFuture = dbHelper.queryAllFlashcardSets();
                    });
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
    await dbHelper.deleteFlashcardSet(flashcardSetId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Flashcard set deleted')),
    );
  }
}


class FlashcardSetButton extends StatelessWidget {
  final String setTitle;
  final int flashcardSetId;
  final VoidCallback onPressed;
  final VoidCallback onDelete;

  const FlashcardSetButton({
    Key? key,
    required this.setTitle,
    required this.flashcardSetId,
    required this.onPressed,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
        // practice screen
      } else if (text == 'Quiz') {
        // quiz screen
      } else if (text == 'Edit') {
        // edit screen
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
class FlashcardSetScreen extends StatelessWidget {
  final String setTitle;
  final int flashcardSetId;

  const FlashcardSetScreen({
    Key? key,
    required this.setTitle,
    required this.flashcardSetId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(setTitle),
      ),
      body: Center(
        child: Text('Flashcards for $setTitle'),
      ),
    );
  }
}
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
    _termControllers.forEach((controller) => controller.dispose());
    _definitionControllers.forEach((controller) => controller.dispose());
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
                decoration: InputDecoration(
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
      MaterialPageRoute(builder: (context) => FlashcardsScreen()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Flashcard set saved successfully')),
    );
  }
}

class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
      ),
      body: const Center(
        child: Text('This is the Flashcards screen.'),
      ),
    );
  }
}

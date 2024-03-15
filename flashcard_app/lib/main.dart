import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'flashcards_screen.dart';

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
        backgroundColor: const Color(0xFFC7B6EE), 
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to Flashcard App!',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              height: 300, 
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateSetScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 238, 228, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), 
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      size: 180, 
                      color: Color.fromARGB(255, 94, 52, 167),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Add',
                      style: TextStyle(fontSize: 40, color: Color.fromARGB(255, 94, 52, 167)), 
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 300, 
              height: 300, 
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FlashcardsScreen(dbHelper: dbHelper),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 135, 89, 215),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), 
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: 180, 
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Study',
                      style: TextStyle(fontSize: 40, color: Colors.white), 
                    ),
                  ],
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

    // Check if the title field is empty
    if (setTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    // Check if any term or definition field is empty
    for (int i = 0; i < _termControllers.length; i++) {
      final term = _termControllers[i].text;
      final definition = _definitionControllers[i].text;
      if (term.isEmpty || definition.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please fill all term and definition fields')),
        );
        return;
      }
    }

    // All fields are filled, proceed with saving the set

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
      MaterialPageRoute(
          builder: (context) => FlashcardsScreen(dbHelper: dbHelper)),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Flashcard set saved successfully')),
    );
  }
}

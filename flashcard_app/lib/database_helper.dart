import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

/*  The insertFlashcardSet method allows you to create a new flashcard set, 
while the insertFlashcard method allows you to add new flashcards to a specific set. 
The queryAllFlashcardsInSet method retrieves all 
flashcards belonging to a particular set based on the flashcardSetId. */
class DatabaseHelper {
  static const _databaseName = "Flashcards.db";
  static const _databaseVersion = 1;
  static const tableFlashcardSets = 'flashcard_sets';
  static const tableFlashcards = 'flashcards';
  static const columnId = '_id';
  static const columnSetTitle = 'setTitle';
  static const columnFlashcardSetId = 'flashcardSetId';
  static const columnTerm = 'term';
  static const columnDefinition = 'definition';
  late Database _db;

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create table for flashcard sets
    await db.execute('''
CREATE TABLE $tableFlashcardSets (
$columnId INTEGER PRIMARY KEY,
$columnSetTitle TEXT NOT NULL
)
''');

    // Create table for flashcards
    await db.execute('''
CREATE TABLE $tableFlashcards (
$columnId INTEGER PRIMARY KEY,
$columnFlashcardSetId INTEGER NOT NULL,
$columnTerm TEXT NOT NULL,
$columnDefinition TEXT NOT NULL,
FOREIGN KEY ($columnFlashcardSetId) REFERENCES $tableFlashcardSets($columnId)
)
''');
  }

  Future<int> insertFlashcardSet(String setTitle) async {
    Map<String, dynamic> row = {
      columnSetTitle: setTitle,
    };
    return await _db.insert(tableFlashcardSets, row);
  }

  Future<int> insertFlashcard(
      int flashcardSetId, String term, String definition) async {
    Map<String, dynamic> row = {
      columnFlashcardSetId: flashcardSetId,
      columnTerm: term,
      columnDefinition: definition,
    };
    return await _db.insert(tableFlashcards, row);
  }

  Future<List<Map<String, dynamic>>> queryAllFlashcardsInSet(
      int flashcardSetId) async {
    return await _db.query(tableFlashcards,
        where: '$columnFlashcardSetId = ?', whereArgs: [flashcardSetId]);
  }

Future<List<Map<String, dynamic>>> queryAllFlashcardSets() async {
    return await _db.query(tableFlashcardSets);
  }

  Future<int> countFlashcardsInSet(int flashcardSetId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) FROM $tableFlashcards WHERE $columnFlashcardSetId = ?',
      [flashcardSetId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
  // Additional methods for managing flashcard sets can be added here
}

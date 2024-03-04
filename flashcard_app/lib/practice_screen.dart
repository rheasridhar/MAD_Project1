import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'database_helper.dart';

class PracticeScreen extends StatefulWidget {
  final int flashcardSetId;

  const PracticeScreen({Key? key, required this.flashcardSetId}) : super(key: key);

  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late List<Map<String, dynamic>> _flashcards = [];
  int _currentIndex = 0;

  late DatabaseHelper dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    await dbHelper.init();
    _flashcards = await dbHelper.queryAllFlashcardsInSet(widget.flashcardSetId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice'),
      ),
      body: _flashcards.isEmpty
          ? Center(
              child: Text('No flashcards available.'),
            )
          : Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = (_currentIndex + 1) % _flashcards.length;
                  });
                },
                child: FlipCard(
                  direction: FlipDirection.HORIZONTAL,
                  front: _buildCard(_flashcards[_currentIndex]['term']!),
                  back: _buildCard(_flashcards[_currentIndex]['definition']!),
                ),
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: _previousCard,
            ),
            Text('${_currentIndex + 1} of ${_flashcards.length}'),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: _nextCard,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String text) {
    return Container(
      width: 320, 
      height: 560, 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }

  void _previousCard() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _flashcards.length) % _flashcards.length;
    });
  }

  void _nextCard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _flashcards.length;
    });
  }
}

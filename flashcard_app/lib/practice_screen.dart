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
    final orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.landscape) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40), 
          child: AppBar(
            title: const Text(
              'Practice',
              style: TextStyle(fontSize: 20), 
            ),
            backgroundColor: const Color(0xFFCBB5F2), 
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              iconSize: 22, 
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        body: _flashcards.isEmpty
            ? const Center(
                child: Text('No flashcards available.'),
              )
            : _buildLandscapeView(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Practice'),
          backgroundColor: const Color(0xFFCBB5F2), 
        ),
        body: _flashcards.isEmpty
            ? const Center(
                child: Text('No flashcards available.'),
              )
            : SafeArea(
                child: Center(
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
              ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousCard,
              ),
              Text('${_currentIndex + 1} of ${_flashcards.length}'),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _nextCard,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildLandscapeView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _previousCard,
            ),
            const SizedBox(width: 50), 
            Expanded(
              flex: 2, 
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6, 
                height: 240, 
                child: FlipCard(
                  direction: FlipDirection.HORIZONTAL,
                  front: _buildCard(_flashcards[_currentIndex]['term']!),
                  back: _buildCard(_flashcards[_currentIndex]['definition']!),
                ),
              ),
            ),
            const SizedBox(width: 50), 
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _nextCard,
            ),
          ],
        ),
        const SizedBox(height: 0), 
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            '${_currentIndex + 1} of ${_flashcards.length}',
            style: const TextStyle(fontSize: 14), 
          ),
        ),
      ],
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 24.0),
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

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class PracticeMissedScreen extends StatefulWidget {
  final List<Map<String, dynamic>> missedFlashcards;

  const PracticeMissedScreen({Key? key, required this.missedFlashcards})
      : super(key: key);

  @override
  _PracticeMissedScreenState createState() => _PracticeMissedScreenState();
}

class _PracticeMissedScreenState extends State<PracticeMissedScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Missed Questions'),
      ),
      body: widget.missedFlashcards.isEmpty
          ? const Center(
              child: Text('No missed questions available.'),
            )
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentIndex = (_currentIndex + 1) %
                              widget.missedFlashcards.length;
                        });
                      },
                      child: FlipCard(
                        direction: FlipDirection.HORIZONTAL,
                        front: _buildCard(
                            widget.missedFlashcards[_currentIndex]['term']),
                        back: _buildCard(widget.missedFlashcards[_currentIndex]
                            ['definition']),
                      ),
                    ),
                  ),
                ),
                BottomAppBar(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _previousCard,
                      ),
                      Text(
                          '${_currentIndex + 1} of ${widget.missedFlashcards.length}'),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _nextCard,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCard(String? text) {
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
          text ?? '',
          style: const TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }

  void _previousCard() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + widget.missedFlashcards.length) %
          widget.missedFlashcards.length;
    });
  }

  void _nextCard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.missedFlashcards.length;
    });
  }
}

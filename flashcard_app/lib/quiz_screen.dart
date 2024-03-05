import 'package:flutter/material.dart';
import 'practice-missed_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<Map<String, dynamic>> flashcards;

  QuizScreen({Key? key, required this.flashcards}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Map<String, dynamic>? _currentFlashcard;
  late TextEditingController _controller;
  int _score = 0;
  int _currentIndex = 0;
  bool _showResult = false;
  bool _submittedOnce = false;
  List<Map<String, dynamic>> _missedQuestions = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadQuestion();
  }

  void _loadQuestion() {
    setState(() {
      _showResult = false;
      _currentFlashcard = widget.flashcards[_currentIndex];
      _controller.clear();
    });
  }

  void _checkAnswer() {
    if (_currentFlashcard != null) {
      setState(() {
        if (_currentFlashcard!['term'] == _controller.text.trim()) {
          _score++;
        } else {
          _missedQuestions.add(_currentFlashcard!);
        }
        _showResult = true;
        _submittedOnce = true;
      });
    }
  }

  void _nextQuestion() {
    setState(() {
      if (_currentIndex < widget.flashcards.length - 1) {
        _currentIndex++;
        _loadQuestion();
        _submittedOnce = false;
      } else {
        // Quiz ends, show result
        _showQuizResults();
      }
    });
  }

  void _showQuizResults() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quiz Results'),
          content:
              Text('You scored $_score out of ${widget.flashcards.length}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _reviewMissedQuestions();
              },
              child: Text('Review Missed Questions'),
            ),
          ],
        );
      },
    );
  }

  void _reviewMissedQuestions() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PracticeMissedScreen(missedFlashcards: _missedQuestions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_currentFlashcard != null) ...[
              Text(
                'Definition:',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              Text(
                _currentFlashcard!['definition'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Enter Term',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _checkAnswer();
                },
                child: Text('Submit'),
              ),
              SizedBox(height: 20),
              if (_showResult)
                Text(
                  _currentFlashcard!['term'] == _controller.text.trim()
                      ? 'Correct!'
                      : 'Incorrect! The correct answer is: ${_currentFlashcard!['term']}',
                  style: TextStyle(fontSize: 18),
                ),
              if (_submittedOnce) // Only display Next button if submitted once
                Spacer(),
              if (_submittedOnce)
                ElevatedButton(
                  onPressed: () {
                    _nextQuestion();
                  },
                  child: Text('Next'),
                ),
            ] else
              Center(
                child: Text('No flashcards available'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

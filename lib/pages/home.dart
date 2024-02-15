import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int scores = 0;
  final Map<String, bool> score = {};
  final Map<String, Color> choices = {
    '🍎': Colors.red,
    '🥒': Colors.green,
    '🔵': Colors.blue,
    '🍍': Colors.yellow,
    '🍊': Colors.orange,
    '🍇': Colors.purple,
    '🥥': Colors.brown,
  };
  int index = 0;
  final play = AudioPlayer();
  int _remainingTime = 30; // Initial time limit in seconds
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer.cancel();
          // Handle when time runs out
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scores: $scores | Time: $_remainingTime seconds'),
      ),
      body: _remainingTime > 0 ? _buildGameContent() : _buildTimeOutMessage(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () {
          setState(() {
            score.clear();
            scores = 0;
            index++;
            _remainingTime = 30; // Reset time limit
            _timer.cancel(); // Cancel the previous timer
            _startTimer(); // Start a new timer
          });
        },
      ),
    );
  }

  Widget _buildGameContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: choices.keys.map((element) {
            return Expanded(
              child: Draggable<String>(
                data: element,
                child: Movable(element),
                feedback: Movable(element),
                childWhenDragging: Movable('🐰'),
              ),
            );
          }).toList(),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: choices.keys.map((element) {
            return buildTarget(element);
          }).toList()
            ..shuffle(Random(index)),
        ),
      ],
    );
  }

  Widget _buildTimeOutMessage() {
    return Center(
      child: Text(
        'Time Out',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildTarget(emoji) {
    return DragTarget<String>(
      builder: (context, incoming, rejects) {
        if (score[emoji] == true) {
          return Container(
            color: Colors.white,
            child: Text('Congratulations'),
            alignment: Alignment.center,
            height: 80,
            width: 200,
          );
        } else {
          return Container(
            color: choices[emoji],
            height: 80,
            width: 200,
          );
        }
      },
      onWillAccept: (data) => data == emoji,
      onAccept: (data) {
        setState(() {
          score[emoji] = true;
          scores++;
          play.play(AssetSource('clap.mp3'));
        });
      },
      onLeave: (data) {},
    );
  }
}

class Movable extends StatelessWidget {
  final String emoji;
  Movable(this.emoji);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        alignment: Alignment.center,
        height: 150,
        padding: EdgeInsets.all(15),
        child: Text(
          emoji,
          style: TextStyle(color: Colors.black, fontSize: 60),
        ),
      ),
    );
  }
}
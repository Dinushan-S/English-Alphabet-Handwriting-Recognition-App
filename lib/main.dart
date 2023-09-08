import 'package:flutter/material.dart';
import 'package:handwritten_number_recognizer/recognizer_screen.dart';

void main() => runApp(handwrittenRecognizerApp());

class handwrittenRecognizerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alphabet recognizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RecognizerScreen(
        title: 'Alphabet recognizer',
      ),
    );
  }
}

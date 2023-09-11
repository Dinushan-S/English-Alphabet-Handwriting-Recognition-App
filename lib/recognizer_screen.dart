import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:handwritten_number_recognizer/constants.dart';
import 'package:handwritten_number_recognizer/drawing_painter.dart';
import 'package:handwritten_number_recognizer/brain.dart';
import 'dart:math';

class RecognizerScreen extends StatefulWidget {
  RecognizerScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RecognizerScreen createState() => _RecognizerScreen();
}

class _RecognizerScreen extends State<RecognizerScreen> {
  List<Offset> points = List();
  AppBrain brain = AppBrain();
  List result = List();
  int count = 0;
  var alp;
  final player = AudioCache();

  void _cleanDrawing() {
    setState(() {
      points = List();
    });
  }

  List<String> getAlphebat() {
    List<String> alphabets = [];
    for (int i = 65; i <= 90; i++) {
      alphabets.add(String.fromCharCode(i));
    }
    // return alphabets[count].toString().split('');
    return alphabets;
  }

  @override
  void initState() {
    super.initState();
    brain.loadModel();
    printAlp();
    print("alp = " + alp);
  }

  void printAlp() {
    setState(() {
      alp = getAlphebat()[count];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Container(
                    padding: EdgeInsets.all(16),
                    margin: const EdgeInsets.all(30.0),
                    decoration: new BoxDecoration(
                      border: new Border.all(
                        width: 3.0,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child:
                        // Text('Header')
                        Column(
                      children: [
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: Text(
                            alp,
                            style: TextStyle(
                              fontSize: 100,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                      ],
                    ))),
            Container(
              decoration: new BoxDecoration(
                border: new Border.all(
                  width: 3.0,
                  color: Colors.blue,
                ),
              ),
              child: Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        RenderBox renderBox = context.findRenderObject();
                        points.add(
                            renderBox.globalToLocal(details.globalPosition));
                      });
                    },
                    onPanStart: (details) {
                      setState(() {
                        RenderBox renderBox = context.findRenderObject();
                        points.add(
                            renderBox.globalToLocal(details.globalPosition));
                      });
                    },
                    onPanEnd: (details) async {
                      points.add(null);
                      List predictions =
                          await brain.processCanvasPoints(points);
                      print(predictions);
                      result = predictions;
                      setState(() {
                        // _dialogBuilder(context);
                      });
                    },
                    child: ClipRect(
                      child: CustomPaint(
                        size: Size(kCanvasSize, kCanvasSize),
                        painter: DrawingPainter(
                          offsetPoints: points,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(30.0),
                // color: Colors.blue,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          child: FloatingActionButton(
                            onPressed: () {
                              player.play('$alp.mp3');
                              print(alp);
                            },
                            child: Icon(
                              Icons.volume_up,
                              color: Colors.white,
                              size: 40.0,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          width: 150,
                          child: FloatingActionButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            onPressed: () {
                              player.play(result
                                          .map((e) => e['label'] == alp
                                              ? 'reward.wav'
                                              : 'k')
                                          .toString() ==
                                      '(reward.wav)'
                                  ? 'reward.wav'
                                  : 'wrong.mp3');
                              _dialogBuilder(context);
                            },
                            child: Text('Check'),
                          ),
                        )
                      ],
                    ),
                    // Text('Result:'),
                    // Text(
                    //   result
                    //       .map((e) => e['index'] == count ? e['label'] : 'k')
                    //       .toString(),
                    // ),
                    // Text('${result.map((e) => e['confidence'])}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _cleanDrawing();
        },
        tooltip: 'Clean',
        child: Icon(Icons.delete),
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Result', textAlign: TextAlign.center),
          content: Container(
            width: 250,
            height: 350,
            child: Column(
              children: [
                Image.asset(
                  result
                              .map((e) => e['label'] == alp
                                  ? 'assets/reward.gif'
                                  : 'assets/wrong.gif')
                              .toString() ==
                          '(assets/reward.gif)'
                      ? 'assets/reward.gif'
                      : 'assets/wrong.gif',
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  result
                      .map((e) => e['label'] == alp
                          ? 'Letter = ${result.map((e) => e['index'] == count ? e['label'] : '').toString()},\n'
                              'confidence = ${result.map((e) => e['confidence'])}'
                          : 'Wrong')
                      .toString(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            result
                        .map((e) => e['label'] == alp ? 'next' : 'try again')
                        .toString() ==
                    '(next)'
                ? TextButton(
                    child: const Text('Next'),
                    onPressed: () {
                      setState(() {
                        if (count == 25) {
                          count = 0;
                        } else {
                          count++;
                        }
                        printAlp();
                      });
                      Navigator.of(context).pop();
                      _cleanDrawing();
                    },
                  )
                : TextButton(
                    child: const Text('Try Again'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _cleanDrawing();
                    },
                  ),
          ],
        );
      },
    );
  }
}

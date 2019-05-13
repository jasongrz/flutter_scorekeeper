import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Score Keeper',
      theme: ThemeData.dark(),
      home: new FirstScreen(),
    );
  }
}

class Sky extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      new Rect.fromLTRB(
          0.0, -80.0, 1.0, 80.0
      ),
      new Paint()..color = new Color(0xFF0099FF),
    );
  }

  @override
  bool shouldRepaint(Sky oldDelegate) {
    return false;
  }
}

class FirstScreen extends StatelessWidget{
  final myControllerOne = TextEditingController();
  final myControllerTwo = TextEditingController();
  final myControllerThree = TextEditingController();
  @override
  Widget build (BuildContext ctxt){
    return Scaffold(
      appBar: AppBar(
        title: Text("ScoreKeeper"),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextField(controller:myControllerOne,
              decoration: InputDecoration(hintText: 'Player One Name')),
            TextField(controller:myControllerTwo,
              decoration: InputDecoration(hintText: 'Player Two Name')),
            TextField(controller:myControllerThree,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'Match Length (minutes)')),
            RaisedButton(child: Text("Start Game"), onPressed: (){
              Navigator.push(
                ctxt,
                MaterialPageRoute(builder: (ctxt) => SecondScreen(myControllerOne.text, myControllerTwo.text, int.parse(myControllerThree.text))),
              );
            },)
          ]
        )
      )
    );
  }
}

class SecondScreen extends StatefulWidget {
  var playerOneName;
  var playerTwoName;
  var matchLength;
  SecondScreen(this.playerOneName, this.playerTwoName, this.matchLength);
  @override
  _SecondScreenState createState() => _SecondScreenState(playerOneName, playerTwoName, matchLength);
}

class _SecondScreenState extends State<SecondScreen> {
  final String playerOne, playerTwo;
  int matchLength;
  _SecondScreenState(this.playerOne, this.playerTwo, this.matchLength);
  final GlobalKey<AnimatedCircularChartState> _chartKey = new GlobalKey<AnimatedCircularChartState>();
  final _chartSize = const Size(250.0, 250.0);
  Color labelColor = Colors.blue;
  List<CircularStackEntry> _generateChartData(int min, int second){
    double temp = second * 0.6;
    double adjustedSeconds = second + temp;
    double tempmin = min * 0.6;
    double adjustedMinutes = min + tempmin;
    Color dialColor = Colors.blue;
    labelColor = dialColor;
    List<CircularStackEntry> data = [
      new CircularStackEntry(
        [new CircularSegmentEntry(adjustedSeconds, dialColor)]
      )
    ];
    if (min > 0){
      labelColor = Colors.green;
      data.removeAt(0);
      data.add(new CircularStackEntry(
        [new CircularSegmentEntry(adjustedSeconds, dialColor)]
      ));
      data.add(new CircularStackEntry(
        [new CircularSegmentEntry(adjustedMinutes, Colors.green)]
      ));
    }
    return data;
  }
  int _counterA = 0;
  int _counterB = 0;
  Stopwatch watch = new Stopwatch();
  Timer timer;
  String currentTime = '';
  updateTime(Timer timer){
    if (watch.isRunning){
      int matchLengthMilli = matchLength * 60 * 100 * 10;
      var milliseconds = matchLengthMilli - watch.elapsedMilliseconds;
      int hundreds = (milliseconds/10).truncate();
      int seconds = (hundreds/100).truncate();
      int minutes = (seconds/60).truncate();
      setState(() {
        currentTime = transformMilliSeconds(matchLengthMilli - watch.elapsedMilliseconds);
        if (seconds > 59){
          seconds = seconds - (59*minutes);
          seconds = seconds - minutes;
        }
        List<CircularStackEntry> data = _generateChartData(minutes, seconds);
        _chartKey.currentState.updateData(data);
      });
    }
  }
  startWatch(){
    watch.start();
    timer = new Timer.periodic(new Duration(milliseconds: 100), updateTime);
  }
  stopWatch(){
    watch.stop();
    setTime();
  }
  resetWatch(){
    watch.reset();
    setTime();
  }
  setTime(){
    int matchLengthMilli = matchLength * 60 * 100 * 10;
    var timeSoFar = matchLengthMilli - watch.elapsedMilliseconds;
    setState(() {
      currentTime = transformMilliSeconds(timeSoFar);
    });
  }
  transformMilliSeconds(int milliseconds){
    int hundreds = (milliseconds/10).truncate();
    int seconds = (hundreds/100).truncate();
    int minutes = (seconds/60).truncate();
    String minutesStr = (minutes % 60).toString().padLeft(2,'0');
    String secondsStr = (seconds % 60).toString().padLeft(2,'0');
    return "$minutesStr:$secondsStr";
  }
  void _incrementCounterA() {
    setState(() {
      _counterA++;
    });
  }
  void _decrementCounterA() {
    setState((){
      _counterA-=1;
    });
  }
  void _incrementCounterB() {
    setState(() {
      _counterB++;
    });
  }
  void _decrementCounterB() {
    setState((){
      _counterB-=1;
    });
  }
  void _resetScore(){
    setState((){
      _counterA = 0;
      _counterB = 0;
      resetWatch();
    });
  }
  Column scoreButtonColumn(String label, ) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[new Container(
        child: new Text(
          label,
          style: new TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      new Container(
          child: new RaisedButton(
            child: new Text('+1'),
            onPressed: (label == playerOne)?_incrementCounterA:_incrementCounterB,
          ),
        ),
        new Container(
          child: new Text(
            (label==playerOne)?'$_counterA':'$_counterB',
            style: new TextStyle(
              fontSize: 24.0,
            ),
          ),
        ),
      new Container(
        child: new RaisedButton(
          child: new Text('-1'),
          onPressed: (label == playerOne)?_decrementCounterA:_decrementCounterB,
        ),
      ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _labelStyle = Theme
      .of(context)
      .textTheme
      .title
      .merge(new TextStyle(color: labelColor));
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Match"),
      ),
      body: SingleChildScrollView( child: new Container(
        padding: const EdgeInsets.only(top: 15.0),
        child: new Column(
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                scoreButtonColumn(playerOne),
                new Container(
                  margin: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: new CustomPaint(
                    painter: new Sky(),
                  ),
                ),
                scoreButtonColumn(playerTwo),
              ],
            ),
            new Container(
              margin: const EdgeInsets.only(top: 42.0),
              child: new Column(
                children: <Widget>[
                  // new Text(currentTime, style: new TextStyle(fontSize:25.0)),
                  new Container(
                    child: new AnimatedCircularChart(
                      key: _chartKey,
                      size: _chartSize,
                      initialChartData: _generateChartData(0,0),
                      chartType: CircularChartType.Radial,
                      edgeStyle: SegmentEdgeStyle.round,
                      percentageValues: true,
                      holeLabel: currentTime,
                      labelStyle: _labelStyle,
                    ),
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new RaisedButton(
                        color: Colors.green,
                        onPressed: startWatch,
                        child: new Icon(Icons.play_arrow),
                      ),
                      new RaisedButton(
                        color: Colors.yellow,
                        onPressed: stopWatch,
                        child: new Icon(Icons.pause),
                      ),
                      new RaisedButton(
                        color: Colors.blue,
                        onPressed: _resetScore,
                        child: new Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ), ),
    );
  }
}

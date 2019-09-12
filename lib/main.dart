import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'quiz.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.white),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Quiz quiz;
  List<Results> results;
  Color c;
  Random random = Random();
  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchQuestions() async {
    var res = await http.get("https://opentdb.com/api.php?amount=20");
    var decRes = jsonDecode(res.body);
    print(decRes);
    c = Colors.black;
    quiz = Quiz.fromJson(decRes);
    results = quiz.results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz App"),
        elevation: 0.0,
      ),
      body: RefreshIndicator(
        onRefresh: fetchQuestions,
        child: FutureBuilder(
            future: fetchQuestions(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('Press button to start.');
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.done:
                  if (snapshot.hasError) return errorData(snapshot);
                  return questionList();
              }
              return null;
            }),

      ),
    );
  }

  Padding errorData(AsyncSnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Error: ${snapshot.error}',
          ),
          SizedBox(
            height: 20.0,
          ),
          RaisedButton(
            child: Text("Try Again"),
            onPressed: () {
              fetchQuestions();
              setState(() {});
            },
          )
        ],
      ),
    );
  }

  ListView questionList() {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => Card(
        color: Colors.white,
        elevation: 3.0,


            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                   "Q:${ results[index].question}",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FilterChip(
                          backgroundColor: Colors.grey[100],
                          label: Text(results[index].category),
                          onSelected: (b) {},
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        FilterChip(
                          backgroundColor: Colors.grey[100],
                          label: Text(
                            results[index].difficulty,
                          ),
                          onSelected: (b) {},
                        )
                      ],
                    ),
                  ),

                  ...(    results[index].allAnswers.map((m) {
      return AnswerWidget(results, index, m);
      }).toList()
                  )

                ],
              ),
            ),



      ),
    );
  }
}

class AnswerWidget extends StatefulWidget {
  final List<Results> results;
  final int index;
  final String m;

  AnswerWidget(this.results, this.index, this.m);

  @override
  _AnswerWidgetState createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  int right=0,wrong=0;
  Color c = Colors.black;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[



      GestureDetector(
        onTap: (){
          setState(() {
            if (widget.m == widget.results[widget.index].correctAnswer) {
              c = Colors.green;
              right=right+1;
              print(right);

            } else {
              c = Colors.red;
              wrong=wrong+1;
              print(wrong);
            }
          });
        },
        child: FittedBox(
          child: Row(
            children: <Widget>[
              Icon(Icons.check_circle,color: Colors.black,),
              SizedBox(width: 5.0,),
              Text(
                widget.m,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: c,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10,)
            ],
          ),
        ),
      ),
      ],
    );

  }
}

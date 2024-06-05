import 'package:flutter/material.dart';

void main() {
  runApp(Mystat_ful_widget());
}

int i = 0;
class Mystat_ful_widget extends StatefulWidget {
  const Mystat_ful_widget({super.key});
  State<Mystat_ful_widget> createState() => _Myapp();
}

class _Myapp extends State<Mystat_ful_widget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text("example of statfulwigdet"),
      ),
      body: Container(
        child: Column(children: [
          Text("hello $i"),
          IconButton(
              onPressed: () {
                setState(() {
                  i++;
                });
              },
              icon: Icon(Icons.add))
        ]),
      ),
    ));
  }
}

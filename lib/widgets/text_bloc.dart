import 'package:flutter/material.dart';

class Bloc extends StatelessWidget {
  final String header;
  final String content;
  const Bloc({Key key, this.header, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 550,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(45),
            border: Border.all(color: Colors.grey, width: 1)),
        child: Column(children: [
          SizedBox(
              child: Column(children: <Widget>[
            Text(header,
                style: TextStyle(
                  fontSize: 20,
                )),
            const Divider(
              color: Colors.grey,
              thickness: 1,
              height: 20,
            ),
            Text(content)
          ])),
        ]));
  }
}

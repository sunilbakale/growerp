import 'package:flutter/material.dart';
import '../widgets/text_bloc.dart';

class MoquiForm extends StatelessWidget {
  const MoquiForm({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Center(
            child: Wrap(
      spacing: 20,
      runSpacing: 20,
      children: <Widget>[
        Bloc(
            header: "header1",
            content: 'oiuy o oi oio ihoihoihoh oih oih ih oih oih oiho hoh o'
                'oiuy o oi oio ihoihoihoh oih oih ih oih oih oiho hoh o oiuy'
                'o oi oio ihoihoihoh oih oih ih oih oih oiho hoh o oiuy o oi'
                'oio ihoihoihoh oih oih ih oih oih oiho hoh o '),
        Bloc(
            header: "header2",
            content: 'oiuy o oi oio ihoihoihoh oih oih ih oih oih oiho hoh o'
                'oiuy o oi oio ihoihoihoh oih oih ih oih oih oiho hoh o oiuy'
                'o oi oio ihoihoihoh oih oih ih oih oih oiho hoh o oiuy o oi'
                'oiuy o oi oio ihoihoihoh oih oih ih oih oih oiho hoh o oiuy'
                'o oi oio ihoihoihoh oih oih ih oih oih oiho hoh o oiuy o oi'
                'oiuy o oi oio ihoihoihoh oih oih ih oih oih oiho hoh o oiuy'
                'o oi oio ihoihoihoh oih oih ih oih oih oiho hoh o oiuy o oi'
                'oio ihoihoihoh oih oih ih oih oih oiho hoh o '),
        Bloc(
            header: "header1",
            content: 'oiuy o oi oio ihoihoihoh oih oih ih oih oih oiho hoh o'
                'oiuy o oi oio ihoihoihoh oih oih ih oih oih oiho hoh o oiuy'
                'o oi oio ihoihoihoh oih oih ih oih oih oiho hoh o oiuy o oi'
                'oio ihoihoihoh oih oih ih oih oih oiho hoh o '),
        Bloc(
            header: "header1",
            content: 'oiuy o oi oio ihoihoihoh oih oih ih oih oih oiho hoh o'
                'oiuy o oi oio ihoihoihoh oih oih ih oih oih oiho hoh o oiuy'
                'o oi oio ihoihoihoh oih oih ih oih oih oiho hoh o oiuy o oi'
                'oio ihoihoihoh oih oih ih oih oih oiho hoh o '),
      ],
    )));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth.dart';

class NoConnectionForm extends StatelessWidget {
  NoConnectionForm({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('No connection!'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () =>
              BlocProvider.of<AuthBloc>(context).add(LoggedOut())
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.sentiment_dissatisfied, size: 100),
            SizedBox(height: 10),
            Text(
              'No Connection, Please check internet',
              style: TextStyle(fontSize: 20, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 80),
            RaisedButton.icon(
              onPressed: () => 
                BlocProvider.of<AuthBloc>(context).add(AppStarted()),
              icon: Icon(Icons.replay),
              label: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}



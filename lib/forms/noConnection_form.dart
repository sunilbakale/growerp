import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/authentication/authentication.dart';

class NoConnectionForm extends StatelessWidget {
  NoConnectionForm({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () =>
              BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut())
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.error_outline, size: 100),
            SizedBox(height: 10),
            Text(
              'No Connection, Please check internet',
              style: TextStyle(fontSize: 20, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 80),
            RaisedButton.icon(
              onPressed: () => 
                BlocProvider.of<AuthenticationBloc>(context).add(AppStarted()),
              icon: Icon(Icons.replay),
              label: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../bloc/bloc.dart';
import '../services/user_repository.dart';

class HomeForm extends StatefulWidget {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  HomeForm(
      {Key key,
      @required this.userRepository,
      @required this.authenticationBloc})
      : assert(userRepository != null, authenticationBloc != null);

  @override
  _HomeFormState createState() =>
      _HomeFormState(userRepository, authenticationBloc);
}

class _HomeFormState extends State<HomeForm> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  List<FocusNode> _focusNodes;

  _HomeFormState(this.userRepository, this.authenticationBloc);

  @override
  void initState() {
    _focusNodes = [FocusNode()];
    super.initState();
  }

  @override
  void dispose() {
    _focusNodes.forEach((focusNode) => focusNode.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
        userRepository: userRepository),
      child:  BlocBuilder<HomeBloc, FormBlocState>(
        condition: (previous, current) =>
          previous.runtimeType != current.runtimeType ||
          previous is FormBlocLoading && current is FormBlocLoading,
        builder: (context, state) {
          if (state is FormBlocLoading) {
            return Center(child: CircularProgressIndicator());
          } else {
            final homeFormBloc = context.bloc<HomeBloc>();
            return Scaffold(
              appBar: AppBar(
                title: Text('Home'),
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: () =>
                          BlocProvider.of<AuthenticationBloc>(context)
                              .add(LoggedOut()))
                ],
              ),
              body: Center(
                child: Column(
                  children: <Widget>[
                    Icon(Icons.tag_faces, size: 100),
                    SizedBox(height: 10),
                    Text(
                      'Home',
                      style: TextStyle(
                          fontSize: 54, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(homeFormBloc.company.value,
                      style: TextStyle(
                          fontSize: 20, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    RaisedButton(
                      onPressed: homeFormBloc.reload,
                      child: Text('Reload'),
                    ),
                  ]
                )
              )
            );
          }
        }
      )
    );
  }
}


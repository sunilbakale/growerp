import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../bloc/bloc.dart';
import '../services/user_repository.dart';

class HomeForm extends StatefulWidget {
  final UserRepository userRepository;
  final AuthBloc authBloc;

  HomeForm(
      {Key key,
      @required this.userRepository,
      @required this.authBloc})
      : assert(userRepository != null, authBloc != null);

  @override
  _HomeFormState createState() =>
      _HomeFormState(userRepository, authBloc);
}

class _HomeFormState extends State<HomeForm> {
  final UserRepository userRepository;
  final AuthBloc authBloc;

  List<FocusNode> _focusNodes;

  _HomeFormState(this.userRepository, this.authBloc);

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
            authBloc: BlocProvider.of<AuthBloc>(context),
            userRepository: userRepository),
        child: BlocBuilder<HomeBloc, FormBlocState>(
            condition: (previous, current) =>
                previous.runtimeType != current.runtimeType ||
                previous is FormBlocLoading && current is FormBlocLoading,
            builder: (context, state) {
              if (state is FormBlocLoading) {
                return Center(child: CircularProgressIndicator());
              } else {
                final homeBloc = context.bloc<HomeBloc>();
                return Scaffold(
                    appBar: AppBar(
                      title: Text('Home'),
                      actions: <Widget>[
                        IconButton(
                            icon: Icon(Icons.exit_to_app),
                            onPressed: () =>
                                BlocProvider.of<AuthBloc>(context)
                                    .add(LoggedOut()))
                      ],
                    ),
                    body: Center(
                        child: Column(children: <Widget>[
                      SizedBox(height: 100),
                      Icon(Icons.tag_faces, size: 100),
                      SizedBox(height: 10),
                      Text(
                        'Home',
                        style: TextStyle(fontSize: 54, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(homeBloc.authenticate.company.name,
                        style: TextStyle(
                            fontSize: 20, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(homeBloc.authenticate.user.name,
                        style: TextStyle(
                            fontSize: 20, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      RaisedButton(
                        onPressed: homeBloc.reload,
                        child: Text('Reload'),
                      ),
                    ])));
              }
            }));
  }
}

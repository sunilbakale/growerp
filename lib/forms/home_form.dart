import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:growerp/bloc/home_form_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/authentication/authentication.dart';
import '../services/user_repository.dart';


class HomeForm extends StatefulWidget {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  HomeForm({Key key, @required this.userRepository,
                     @required this.authenticationBloc})
    : assert(userRepository != null, authenticationBloc != null),
    super(key: key);

  @override
  _HomeFormState createState() => _HomeFormState(userRepository,authenticationBloc);
}
class _HomeFormState extends State<HomeForm> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  HomeFormBloc _formBloc;
  List<FocusNode> _focusNodes;

  _HomeFormState(this.userRepository, this.authenticationBloc);

  @override
  void initState() {
    _formBloc = HomeFormBloc(
      authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
      userRepository: userRepository);
    _focusNodes = [FocusNode()];
    super.initState();
  }

  @override
  void dispose() {
    _formBloc.close();
    _focusNodes.forEach((focusNode) => focusNode.dispose());
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeFormBloc(
        authenticationBloc: authenticationBloc, userRepository: userRepository),
      child: Builder(
        builder: (context) {
          final homeFormBloc = context.bloc<HomeFormBloc>();
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
            body: FormBlocListener<HomeFormBloc, String, String>( 
              child: BlocBuilder<HomeFormBloc, FormBlocState>(
                condition: (previous, current) =>
                    previous.runtimeType != current.runtimeType ||
                    previous is FormBlocLoading && current is FormBlocLoading,
                builder: (context, state) {
                  if (state is FormBlocLoading) {
                      return Center(child: CircularProgressIndicator());
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.tag_faces, size: 100),
                          SizedBox(height: 10),
                          Text('Home',
                            style: TextStyle(fontSize: 54, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text( 'ppp', //homeFormBloc.auth.user.firstName,
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                            SizedBox(height: 20),
                          RaisedButton(
                            onPressed: homeFormBloc.reload,
                            child: Text('Reload'),
                          ),
                        ]
                      )
                    );
                  }
                }
              )
            )
          );
        }
      )
    );
  }
}



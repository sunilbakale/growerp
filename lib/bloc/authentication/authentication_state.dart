import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import '../../models/models.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();
  @override
  List<Object> get props => [];
}

class AuthenticationLoading extends AuthenticationState {}
class AuthenticationUninitialized extends AuthenticationState {}
class AuthenticationConnectionProblem extends AuthenticationState {}
class AuthenticationRegister extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {
  final Authenticate authenticate;
  const AuthenticationAuthenticated({@required this.authenticate}) 
    : assert(authenticate != null);
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'Authenticated: userName: ${authenticate.user.name}';
}
class AuthenticationUnauthenticated extends AuthenticationState {
  final Authenticate authenticate;
  const AuthenticationUnauthenticated({this.authenticate}); 
  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'Unauthenticated: userName: ${authenticate?.user?.name}';
}

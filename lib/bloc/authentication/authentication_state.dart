import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import '../../models/models.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();
  @override
  List<Object> get props => [];
}

class AuthenticationUninitialized extends AuthenticationState {}
class AuthenticationConnectionProblem extends AuthenticationState {}
class AuthenticationUnauthenticated extends AuthenticationState {}
class AuthenticationAuthenticated extends AuthenticationState {
  final Authenticate authenticate;

  const AuthenticationAuthenticated({@required this.authenticate}) 
    : assert(authenticate != null);

  @override
  List<Object> get props => [authenticate];
  @override
  String toString() => 'Authenticated { authenticate: $authenticate.company.name }';
}
class AuthenticationLoading extends AuthenticationState {}

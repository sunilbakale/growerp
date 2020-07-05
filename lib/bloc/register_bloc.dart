import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../bloc/@bloc.dart';
import '../services/repos.dart';
import '../models/@models.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final Repos repos;
  final AuthBloc authBloc;

  RegisterBloc({
    @required this.repos,
    @required this.authBloc,
  })  : assert(repos != null),
        assert(authBloc != null),
        super(RegisterInitial());

  @override
  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    if (event is LoadRegister) {
      yield RegisterLoading();
      dynamic currencyList = await repos.getCurrencies();
      if (currencyList is List) {
        yield RegisterLoaded(currencyList);
      } else {
        yield RegisterError(errorMessage: currencyList);
      }
    } else if (event is RegisterButtonPressed) {
      yield RegisterSubmitting();
      final authenticate = await repos.register(
          companyName: event.companyName,
          currency: event.currency,
          firstName: event.firstName,
          lastName: event.lastName,
          email: event.email);
      if (authenticate is Authenticate) {
        await repos.persistAuthenticate(authenticate);
        yield RegisterSuccess();
      } else {
        yield RegisterError(errorMessage: authenticate);
      }
    }
  }
}

//--------------------------events ---------------------------------
@immutable
abstract class RegisterEvent extends Equatable {
  const RegisterEvent();
}

class LoadRegister extends RegisterEvent {
  @override
  List<Object> get props => [];
}

class RegisterButtonPressed extends RegisterEvent {
  final String companyName;
  final String currency;
  final String firstName;
  final String lastName;
  final String email;

  const RegisterButtonPressed({
    @required this.companyName,
    @required this.currency,
    @required this.firstName,
    @required this.lastName,
    @required this.email,
  });

  @override
  List<Object> get props => [companyName, currency, firstName, lastName, email];

  @override
  String toString() =>
      'RegisterButtonPressed { company name: $companyName, email: $email }';
}

// -------------------------------state ------------------------------
@immutable
abstract class RegisterState extends Equatable {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  @override
  List<Object> get props => [];
}

class RegisterLoading extends RegisterState {
  @override
  List<Object> get props => [];
}

class RegisterLoaded extends RegisterState {
  final List<String> currencies;
  RegisterLoaded(this.currencies);
  @override
  List<Object> get props => [currencies];

  @override
  String toString() => currencies != null
      ? 'RegisterLoaded { currencies size: ${currencies?.length},' +
          ' first:${currencies[0].toString()}  }'
      : 'RegisterLoaded { no currencies found }';
}

class RegisterSubmitting extends RegisterState {
  @override
  List<Object> get props => [];
}

class RegisterSuccess extends RegisterState {
  @override
  List<Object> get props => [];
}

class RegisterError extends RegisterState {
  final String errorMessage;

  const RegisterError({@required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];

  @override
  String toString() => 'RegisterError { error: $errorMessage }';
}

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
        assert(authBloc != null);

  @override
  RegisterState get initialState => RegisterLoading();

  @override
  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    if (event is LoadRegister) {
      yield* _mapLoadRegisterToState();
    } else if (event is RegisterButtonPressed) {
      yield RegisterLoading();
      final authenticate = await repos.register(
          companyName: event.companyName,
          currency: event.currency,
          firstName: event.firstName,
          lastName: event.lastName,
          email: event.email);
      if (authenticate is Authenticate) {
        authBloc.add(Login());
      } else {
        yield RegisterError(errorMessage: authenticate);
      }
    }
  }

  Stream<RegisterState> _mapLoadRegisterToState() async* {
    dynamic currencyList = await repos.getCurrencies();
    if (currencyList is List) {
      yield RegisterLoaded(currencyList);
    } else {
      yield RegisterError(errorMessage: currencyList);
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
  String toString() =>
      'RegisterLoaded { currencies size: ${currencies.length},' +
      ' first:${currencies[0].toString()}  }';
}

class RegisterError extends RegisterState {
  final String errorMessage;

  const RegisterError({@required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];

  @override
  String toString() => 'RegisterError { error: $errorMessage }';
}

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../models/@models.dart';
import '../services/repos.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final Repos repos;

  CatalogBloc({@required this.repos});

  @override
  CatalogState get initialState => CatalogLoading();

  @override
  Stream<CatalogState> mapEventToState(CatalogEvent event) async* {
    if (event is LoadCatalog) {
      yield* _mapLoadCatalogToState();
    }
  }

  Stream<CatalogState> _mapLoadCatalogToState() async* {
    yield CatalogLoading();
    dynamic catalog =
        await repos.getCatalog(companyPartyId: "100001");
    if (catalog is Catalog)
      yield CatalogLoaded(catalog);
    else {
      yield CatalogError(catalog);
    }
  }
}

// ################# events ###################
@immutable
abstract class CatalogEvent extends Equatable {
  const CatalogEvent();
}

class LoadCatalog extends CatalogEvent {
  @override
  List<Object> get props => [];
}

// ################## state ###################
@immutable
abstract class CatalogState extends Equatable {
  const CatalogState();
}

class CatalogLoading extends CatalogState {
  @override
  List<Object> get props => [];
}

class CatalogLoaded extends CatalogState {
  final Catalog catalog;

  const CatalogLoaded(this.catalog);

  @override
  List<Object> get props => [catalog];
}

class CatalogError extends CatalogState {
  final String errorMessage;

  const CatalogError(this.errorMessage);

  @override
  List<Object> get props => [];

    @override
  String toString() => 'CatalogError { error: $errorMessage }';
}

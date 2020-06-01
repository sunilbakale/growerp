import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../models/models.dart';
import '../services/repos.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final Repos repos;

  CatalogBloc({@required this.repos});

  @override
  CatalogState get initialState => CatalogLoading();

  @override
  Stream<CatalogState> mapEventToState(
    CatalogEvent event,
  ) async* {
    if (event is LoadCatalog) {
      yield* _mapLoadCatalogToState();
    }
  }

  Stream<CatalogState> _mapLoadCatalogToState() async* {
    yield CatalogLoading();
    dynamic userAndCompany =
        await repos.getUserAndCompany(companyPartyId: "100001");
    dynamic catalog =
        await repos.getCatalog(companyPartyId: "100001");
    if (catalog is Catalog && userAndCompany is UserAndCompany)
      yield CatalogLoaded(catalog,userAndCompany);
    else {
      if (catalog is String) yield CatalogError(catalog);
      else if (userAndCompany is String) yield CatalogError(userAndCompany);
      else yield CatalogError('Unknow error retrieving catalog');
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
  final UserAndCompany userAndCompany;

  const CatalogLoaded(this.catalog, this.userAndCompany);

  @override
  List<Object> get props => [catalog];
}

class CatalogError extends CatalogState {
  final String errorMessage;

  CatalogError(this.errorMessage);

  @override
  List<Object> get props => [];
}

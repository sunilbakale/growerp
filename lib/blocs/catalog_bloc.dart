import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../models/@models.dart';
import '../services/repos.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final Repos repos;

  CatalogBloc({@required this.repos}) : super(CatalogInitial());

  @override
  Stream<CatalogState> mapEventToState(CatalogEvent event) async* {
    if (event is LoadCatalog) {
      dynamic catalog;
      yield CatalogLoading();
      dynamic authenticate = await repos.getAuthenticate();
      String companyPartyId = authenticate?.company?.partyId;
      if (companyPartyId != null) {
        catalog = await repos.getCatalog(companyPartyId);
      }
      if (companyPartyId == null || catalog is String) {
        await repos.persistAuthenticate(null); // was not found, so remove
        // no company or catalog error find company from list:
        dynamic companies = await repos.getCompanies();
        if (companies is List && companies.length > 0) {
          companyPartyId = companies[0].partyId;
        } else {
          companyPartyId = null;
        }
      }
      if (companyPartyId == null) {
        // still not found so we give up.....
        yield CatalogError("No companies found in the system");
      } else {
        catalog = await repos.getCatalog(companyPartyId);
        if (catalog is Catalog)
          yield CatalogLoaded(catalog);
        else
          yield CatalogError(catalog);
      }
    }
  }
}

// ################# events ###################
@immutable
abstract class CatalogEvent extends Equatable {
  const CatalogEvent();
  @override
  List<Object> get props => [];
}

class LoadCatalog extends CatalogEvent {
  String toString() => "Loadcatalog: loading products and categories";
}

// ################## state ###################
@immutable
abstract class CatalogState extends Equatable {
  const CatalogState();
  @override
  List<Object> get props => [];
}

class CatalogInitial extends CatalogState {}

class CatalogLoading extends CatalogState {}

class CatalogLoaded extends CatalogState {
  final Catalog catalog;

  const CatalogLoaded(this.catalog);

  @override
  List<Object> get props => [catalog];
  @override
  String toString() =>
      'CatalogLoaded, categories: ${catalog.categories.length}' +
      ' products: ${catalog.products.length}';
}

class CatalogError extends CatalogState {
  final String errorMessage;

  const CatalogError(this.errorMessage);

  @override
  List<Object> get props => [];

  @override
  String toString() => 'CatalogError { error: $errorMessage }';
}

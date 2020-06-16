import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:growerp/bloc/@bloc.dart';
import 'package:growerp/services/repos.dart';
import '../data.dart';

class MockReposRepository extends Mock implements Repos {}

void main() {
  MockReposRepository mockReposRepository;

  setUp(() {
    mockReposRepository = MockReposRepository();
  });
  
  group('First catalog test', () {

    blocTest( 'check initial state',
      build: () async => CatalogBloc(repos: mockReposRepository),
      expect: <AuthState> [],
    );

    blocTest(
      'Catalog load success',
      build: () async => CatalogBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getCatalog(companyPartyId: "100001"))
          .thenAnswer((_) async => catalog);
        bloc.add(LoadCatalog());
      },
      expect: <CatalogState>[
        CatalogLoaded(catalog),
      ],
    );
    blocTest(
      'Catalog load error',
      build: () async => CatalogBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getCatalog(companyPartyId: "100001"))
          .thenAnswer((_) async => errorMessage);
        bloc.add(LoadCatalog());
      },
      expect: <CatalogState>[
        CatalogError(errorMessage),
      ],
    );

  });
}

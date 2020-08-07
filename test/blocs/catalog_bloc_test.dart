import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ecommerce/blocs/@bloc.dart';
import 'package:ecommerce/services/repos.dart';
import '../data.dart';

class MockReposRepository extends Mock implements Repos {}

void main() {
  MockReposRepository mockReposRepository;

  setUp(() {
    mockReposRepository = MockReposRepository();
  });

  group('First catalog test', () {
    blocTest(
      'check initial state',
      build: () => CatalogBloc(repos: mockReposRepository),
      expect: <CatalogState>[],
    );

    blocTest(
      'Catalog load success',
      build: () => CatalogBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getCatalog("100001"))
            .thenAnswer((_) async => catalog);
        when(mockReposRepository.getCompanies())
            .thenAnswer((_) async => companies);
        bloc.add(LoadCatalog());
      },
      expect: <CatalogState>[
        CatalogLoading(),
        CatalogLoaded(catalog),
      ],
    );
    blocTest(
      'Catalog load error',
      build: () => CatalogBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getCatalog("100001"))
            .thenAnswer((_) async => errorMessage);
        bloc.add(LoadCatalog());
      },
      expect: <CatalogState>[
        CatalogLoading(),
        CatalogError(errorMessage),
      ],
    );
  });
}

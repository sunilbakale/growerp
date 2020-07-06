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

  group('Cart bloc test: ', () {
    blocTest(
      'check initial state',
      build: () async => CartBloc(repos: mockReposRepository),
      expect: <CartState>[],
    );
    blocTest(
      'load with success',
      build: () async => CartBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getCart()).thenAnswer((_) async => emptyOrder);
        bloc.add(LoadCart());
      },
      expect: <CartState>[
        CartLoading(),
        CartLoaded(order: emptyOrder),
      ],
    );
    blocTest(
      'Cart load error',
      build: () async => CartBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getCart())
            .thenAnswer((_) async => errorMessage);
        bloc.add(LoadCart());
      },
      expect: <CartState>[
        CartLoading(),
        CartError(message: errorMessage),
      ],
    );
  });
}

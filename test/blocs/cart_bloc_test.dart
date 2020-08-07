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

  group('Cart bloc test: ', () {
    blocTest(
      'check initial state',
      build: () => CartBloc(repos: mockReposRepository),
      expect: <CartState>[],
    );
    blocTest(
      'load with success',
      build: () => CartBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getCart()).thenAnswer((_) async => emptyOrder);
        bloc.add(LoadCart());
      },
      expect: <CartState>[
        CartLoading(),
        CartLoaded(emptyOrder),
      ],
    );
    blocTest(
      'load error',
      build: () => CartBloc(repos: mockReposRepository),
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
    blocTest(
      'load, add, pay',
      build: () => CartBloc(repos: mockReposRepository),
      act: (bloc) async {
        when(mockReposRepository.getCart()).thenAnswer((_) async => emptyOrder);
        bloc.add(LoadCart());
        when(mockReposRepository.saveCart(order: totalOrder))
            .thenAnswer((_) async => null);
        bloc.add(AddOrderItem(orderItem1));
        when(mockReposRepository.saveCart(order: totalOrder))
            .thenAnswer((_) async => null);
        bloc.add(AddOrderItem(orderItem2));
        when(mockReposRepository.createOrder(totalOrder))
            .thenAnswer((_) async => 'orderId222222');
        when(mockReposRepository.saveCart(order: null))
            .thenAnswer((_) async => null);
        when(mockReposRepository.getCart()).thenAnswer((_) async => emptyOrder);
        bloc.add(PayOrder(totalOrder));
      },
//      wait: const Duration(milliseconds: 800),
      expect: <CartState>[
        CartLoading(),
        CartLoaded(emptyOrder),
        CartPaying(),
        CartPaid(orderId: '222222'),
        CartLoading(),
        CartLoaded(emptyOrder),
      ],
    );
  });
}

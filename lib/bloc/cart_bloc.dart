import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:money/money.dart';
import '../models/models.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  @override
  CartState get initialState => CartLoading();

  @override
  Stream<CartState> mapEventToState(
    CartEvent event,
  ) async* {
    if (event is LoadCart) {
      yield* _mapLoadCartToState();
    } else if (event is AddProduct) {
      yield* _mapAddProductToState(event);
    }
  }

  Stream<CartState> _mapLoadCartToState() async* {
    yield CartLoading();
    try {
      //await Future.delayed(Duration(seconds: 1));
      yield CartLoaded(products: []);
    } catch (_e) {
      yield CartError(errorMsg: _e);
    }
  }

  Stream<CartState> _mapAddProductToState(AddProduct event) async* {
    final currentState = state;
    if (currentState is CartLoaded) {
      try {
        yield CartLoaded(
          products: List.from(currentState.products)..add(event.product),
        );
      } catch (_e) {
      yield CartError(errorMsg: _e);
      }
    }
  }
}

// ===================events =====================
@immutable
abstract class CartEvent extends Equatable {
  const CartEvent();
}

class LoadCart extends CartEvent {
  @override
  List<Object> get props => [];
}

class AddProduct extends CartEvent {
  final Product product;

  const AddProduct(this.product);

  @override
  List<Object> get props => [product];
}

// ================= state ========================
@immutable
abstract class CartState extends Equatable {
  const CartState();
}

class CartLoading extends CartState {
  @override
  List<Object> get props => [];
}

class CartLoaded extends CartState {
  final List<Product> products;

  const CartLoaded({this.products});

  Money get totalPrice {
    if (products.length == 0) return null;     
    Money total = Money.fromString("0.00", products[0].price.currency);
    for (Product i in products) total += (i.price * i.quantity) ;
    return total;
  }
  @override
  List<Object> get props => [products];

}

class CartError extends CartState {
  final errorMsg;
  const CartError({this.errorMsg});
  @override
  List<Object> get props => [];
}


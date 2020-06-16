import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:money/money.dart';
import '../models/@models.dart';
import '../services/repos.dart';


class CartBloc extends Bloc<CartEvent, CartState> {
  final Repos repos;

  CartBloc({@required this.repos});

@override
  CartState get initialState => CartLoading();

  @override
  Stream<CartState> mapEventToState(CartEvent event) async* {
    if (event is LoadCart) {
      yield* _mapLoadCartToState();
    } else if (event is AddOrderItem) {
      yield* _mapAddOrderItemToState(event);
    }
  }

  Stream<CartState> _mapLoadCartToState() async* {
    yield CartLoading();
    try {
      //await Future.delayed(Duration(seconds: 1));
      yield CartLoaded(orderItems: []);
    } catch (_e) {
      yield CartError(errorMsg: _e);
    }
  }

  Stream<CartState> _mapAddOrderItemToState(AddOrderItem event) async* {
    final currentState = state;
    if (currentState is CartLoaded) {
      try {
        yield CartLoaded(
          orderItems: List.from(currentState.orderItems)..add(event.orderItem),
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

class AddOrderItem extends CartEvent {
  final OrderItem orderItem;

  const AddOrderItem(this.orderItem);

  @override
  List<Object> get props => [orderItem];
}
class PayOrderItem extends CartEvent {
  final List<OrderItem> orderItems;

  PayOrderItem(this.orderItems);

  @override
  List<Object> get props => [];
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
  final List<OrderItem> orderItems;

  const CartLoaded({this.orderItems});

  Money get totalPrice {
    if (orderItems.length == 0) return null;
    Money total = Money.fromString("0.00", orderItems[0].price.currency);
    for (OrderItem i in orderItems) total += (i.price * i.quantity);
    return total;
  }

  @override
  List<Object> get props => [orderItems];
}

class CartError extends CartState {
  final errorMsg;
  const CartError({this.errorMsg});
  @override
  List<Object> get props => [];
}

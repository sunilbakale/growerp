import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:money/money.dart';
import '../models/@models.dart';
import '../services/repos.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final Repos repos;
  Authenticate authenticate;

  CartBloc({@required this.repos});

  @override
  CartState get initialState => CartLoading();

  @override
  Stream<CartState> mapEventToState(CartEvent event) async* {
    if (event is LoadCart) {
      yield* _mapLoadCartToState();
    } else if (event is AddOrderItem) {
      yield* _mapAddOrderItemToState(event);
    } else if (event is PayOrder) {
      yield CartPaying();
      dynamic result = await repos.createOrder(order: event.order);
      if (result is String && result.startsWith('orderId')) {
        yield CartPaid(orderId: result.substring(8));
        repos.saveOrder(order: null);
        yield* _mapLoadCartToState();
      } else
        yield CartError(message: result);
    }
  }

  Stream<CartState> _mapLoadCartToState() async* {
    yield CartLoading();
    dynamic order = await repos.getOrder();
    if (order is String) {
      yield CartError(message: order);
    } else {
      if (order == null) {
        // no order yet to create
        order = Order(
            orderStatusId: "OrderOpen",
            partyId: authenticate?.user?.partyId,
            firstName: authenticate?.user?.firstName,
            lastName: authenticate?.user?.lastName,
            statusId: "Open",
            orderItems: [],
        );
      }
      yield CartLoaded(order: order);
    }
  }

  Stream<CartState> _mapAddOrderItemToState(AddOrderItem event) async* {
    final currentState = state;
    if (currentState is CartLoaded) {
      currentState.order.orderItems.add(event.orderItem);
      dynamic result = await repos.saveOrder(order: currentState.order);
      if (result is String)
        yield CartError(message: result);
      else
        yield CartLoaded(order: currentState.order);
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

class PayOrder extends CartEvent {
  final Order order;

  PayOrder(this.order);

  @override
  List<Object> get props => [];
}

// ================= state ========================
@immutable
abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object> get props => [];
}

class CartLoading extends CartState {
  @override
  List<Object> get props => [];
}

class CartLoaded extends CartState {
  final Order order;
  const CartLoaded({this.order});
  Money get totalPrice {
    if (order.orderItems.length == 0) return null;
    Money total = Money.fromString("0.00", order.orderItems[0].price.currency);
    for (OrderItem i in order.orderItems) total += (i.price * i.quantity);
    return total;
  }
  @override
  List<Object> get props => [order.orderItems];
}

class CartPaying extends CartState {
  final Order order;
  const CartPaying({this.order});
  @override
  List<Object> get props => [order];
}

class CartPaid extends CartState {
  final String orderId;
  const CartPaid({this.orderId});
  List<Object> get props => [orderId];
}

class CartError extends CartState {
  final message;
  const CartError({this.message});
  @override
  List<Object> get props => [message];
}

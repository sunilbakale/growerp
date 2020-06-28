import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/@bloc.dart';
import '../models/@models.dart';
import '../routing_constants.dart';
import 'login_form.dart';

class CartForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.home),
              onPressed: () => Navigator.pushNamed(context, HomeRoute)),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: _CartList(),
              ),
            ),
            Divider(height: 4, color: Colors.black),
            _CartTotal()
          ],
        ),
      ),
    );
  }
}

class _CartList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoading) return CircularProgressIndicator();
        if (state is CartLoaded) {
          return DataTable(
            columns: [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Total')),
            ],
            rows: state.order.orderItems
                .map((orderItem) => DataRow(cells: [
                      DataCell(Text(orderItem.description)),
                      DataCell(Text(orderItem.quantity.toString())),
                      DataCell(Text(orderItem.price.toString())),
                      DataCell(Text(
                          (orderItem.price * orderItem.quantity).toString())),
                    ]))
                .toList(),
          );
        }
        if (state is CartError) {
          return Center(
            child: Text(state.message),
          );
        }
        return Container();
      },
    );
  }
}

class _CartTotal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hugeStyle =
        Theme.of(context).textTheme.headline1.copyWith(fontSize: 48);
    Order order;
    bool result = false;
    return SizedBox(
        height: 200,
        child: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          BlocListener<CartBloc, CartState>(listener: (context, state) {
            if (state is CartPaid) {
              Navigator.pushNamed(context, HomeRoute);
            }
          }, child:
              BlocBuilder<CartBloc, CartState>(builder: (context, cartState) {
            if (cartState is CartLoading || cartState is CartPaying) {
              return CircularProgressIndicator();
            }
            if (cartState is CartError) {
              BlocProvider.of<CartBloc>(context).add(LoadCart());
              _showMessage(context, 'Cart error?', Colors.red, false);
            }
            if (cartState is CartLoaded) {
              return BlocBuilder<AuthBloc, AuthState>(
                  builder: (BuildContext context, authState) {
                order = cartState.order;
                return Row(children: <Widget>[
                  Text((cartState.totalPrice ?? 0.00).toString(),
                      style: hugeStyle),
                  RaisedButton(
                      disabledColor: Colors.white,
                      disabledTextColor: Colors.white,
                      child: Text('BUY', style: hugeStyle),
                      color: Colors.orange,
                      onPressed: order == null || order.orderItems.length == 0
                          ? null
                          : () async {
                              if (authState is AuthUnauthenticated)
                                result = await _loginDialog(context);
                              if (authState is AuthAuthenticated || result)
                                BlocProvider.of<CartBloc>(context)
                                    .add(PayOrder(order));
                              else
                                _showMessage(context, 'Should login first?',
                                    Colors.red, false);
                            }),
                ]);
              });
            }
            return Container();
          }))
        ])));
  }
}

_loginDialog(BuildContext context) async {
  return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoginForm();
      });
}

void _showMessage(context, message, colors, ind) {
  Scaffold.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$message'),
            if (ind) CircularProgressIndicator(),
          ],
        ),
        backgroundColor: colors,
      ),
    );
}

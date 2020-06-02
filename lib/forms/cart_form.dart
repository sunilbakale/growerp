import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';

class CartForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () => Navigator.pushNamed(context, '/'),
          ),
        ],
      ),
      body: Container(
//        color: Colors.yellow,
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
        if (state is CartLoading) {
          return CircularProgressIndicator();
        } else if (state is CartLoaded) {
          return DataTable(
            columns: [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Total')),
            ],
            rows: state.orderItems
                .map((orderItem) => DataRow(cells: [
                      DataCell(Text(orderItem.description)),
                      DataCell(Text(orderItem.quantity.toString())),
                      DataCell(Text(orderItem.price.toString())),
                      DataCell(Text(
                          (orderItem.price * orderItem.quantity).toString())),
                    ]))
                .toList(),
          );
        } else if (state is CartError) {
          return Center(
            child: Text(state.errorMsg),
          );
        } else
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

    return SizedBox(
      height: 200,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<CartBloc, CartState>(builder: (context, state) {
              if (state is CartLoading) {
                return CircularProgressIndicator();
              }
              if (state is CartLoaded) {
                return Text((state.totalPrice ?? 0.00).toString(),
                    style: hugeStyle);
              }
              return Text('Something went wrong!');
            }),
            SizedBox(width: 24),
            FlatButton(
              onPressed: () {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Buying not supported yet..',
                      textAlign: TextAlign.center),
                  backgroundColor: Colors.redAccent,
                ));
              },
              color: Colors.white,
              child: Text('BUY'),
            ),
          ],
        ),
      ),
    );
  }
}

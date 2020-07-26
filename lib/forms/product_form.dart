import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/@models.dart';
import '../blocs/@bloc.dart';

class ProductForm extends StatefulWidget {
  final Product product;

  const ProductForm({Key key, this.product}) : super(key: key);
  @override
  _ProductFormState createState() => _ProductFormState(product);
}

class _ProductFormState extends State<ProductForm> {
  final Product product;
  int quantity;
  OrderItem orderItem;
  Map<String, dynamic> args;
  bool isFavorite = false;

  _ProductFormState(this.product);

  @override
  Widget build(BuildContext context) {
    quantity ??= 1;
    return Scaffold(
        appBar: AppBar(
          title: Text('Product detail'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.only(bottom: 50),
          child: Stack(
            children: <Widget>[
              buildBodyColumn(),
              Align(
                alignment: Alignment.bottomCenter,
                child: buildActionsContainer(),
              ),
            ],
          ),
        ));
  }

  Widget buildBodyColumn() {
    Size size = MediaQuery.of(context).size;
    double screenWidth = size.width;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: screenWidth,
            height: 70,
          ),
          Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.25),
            child: Hero(
              tag: product.productId,
              child: Image(
                image: product.image,
                height: 200,
                width: screenWidth * 0.5,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Text(
              product.name,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 26),
            ),
            width: screenWidth * 0.9,
          ),
/*          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
              '${product.weight}g',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
*/
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                buildAmountButton(),
                Text(
                  (product.price * quantity).toString(),
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 26),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, top: 10),
            child: Text(
              'About the product',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              text,
              maxLines: 3,
              overflow: TextOverflow.fade,
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 75)
        ],
      ),
    );
  }

  Widget buildAmountButton() {
    return Container(
      width: 100,
      height: 35,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(45),
          border: Border.all(color: Colors.grey, width: 1)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            child: Icon(Icons.remove),
            onTap: () {
              setState(() {
                if (quantity > 1) --quantity;
              });
            },
            onLongPressStart: (_) {
              setState(() {
                quantity = 1;
              });
            },
          ),
          Text(quantity.toString()),
          GestureDetector(
            child: Icon(Icons.add),
            onTap: () {
              setState(() {
                if (quantity < 25) ++quantity;
              });
            },
            onLongPressStart: (_) {
              setState(() {
                quantity = 25;
              });
            },
          ),
        ],
      ),
    );
  }

  final String text =
      'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book';

  Widget buildActionsContainer() {
    return BlocBuilder<CartBloc, CartState>(builder: (context, state) {
      if (state is CartLoading) {
        return CircularProgressIndicator();
      }
      if (state is CartLoaded) {
        Size size = MediaQuery.of(context).size;
        double screenWidth = size.width;
        return Container(
          color: Color(0xfffafafa),
          width: screenWidth,
          height: 80,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 1)),
                  child: Center(
                      child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              isFavorite = !isFavorite;
                            });
                          })),
                ),
                MaterialButton(
                  onPressed: () => {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Added $quantity x ${product.name}',
                          textAlign: TextAlign.center),
                      backgroundColor: Colors.green,
                    )),
                    orderItem = OrderItem(
                        productId: product.productId,
                        quantity: quantity,
                        price: product.price,
                        description: product.name),
                    BlocProvider.of<CartBloc>(context)
                        .add(AddOrderItem(orderItem)),
                  },
                  splashColor: Theme.of(context).primaryColor,
                  color: Colors.amber[600],
                  elevation: 0,
                  child: Text(
                    'Add to cart',
                  ),
                  height: 50,
                  minWidth: screenWidth - 150,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(45)),
                )
              ],
            ),
          ),
        );
      }
      return Text('Something went wrong!');
    });
  }
}

import 'package:flutter/material.dart';
import '../models/@models.dart';

class CartDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double screenWidth = size.width;

    return Container(
      padding: EdgeInsets.all(20),
      width: screenWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 30, top: 40, bottom: 40),
            child: Text(
              'Cart',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 35),
            ),
          ),
//          ..._provider.food.map((f) => CartItem(f)).toList(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            width: screenWidth,
            height: 60,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey.withOpacity(0.5),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.amber[600],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('Delivery',
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                  ),
                ),
                Text('\$30',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
          SizedBox(height: 50),
          Container(
            width: screenWidth,
            padding: EdgeInsets.only(left: 10, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  'Total',
                  style: TextStyle(
                      color: Colors.grey.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
                /*           Text('\$${(_provider.getTotalPrice()+30).toStringAsFixed(2)}',style:TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 35)
                    )
    */
              ],
            ),
          ),
          SizedBox(height: 50),
          Center(
            child: MaterialButton(
              onPressed: () {},
              color: Colors.amber[600],
              elevation: 0,
              child: Text(
                'Next',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              height: 50,
              minWidth: screenWidth - 100,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45)),
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  final Product product;

  CartItem(this.product);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double screenWidth = size.width;
    double quantity;

    return Container(
      width: screenWidth,
      height: 60,
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.black,
            backgroundImage: AssetImage(product.image.toString()),
          ),
          Text(quantity.toString(),
              style: TextStyle(color: Colors.black, fontSize: 16)),
          Text('x', style: TextStyle(color: Colors.black, fontSize: 16)),
          Container(
            width: screenWidth * 0.5,
            child: Text(product.name,
                maxLines: 2,
                overflow: TextOverflow.fade,
                style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
          Text((quantity * product.price).toStringAsFixed(2),
              style: TextStyle(color: Colors.black, fontSize: 16)),
        ],
      ),
    );
  }
}

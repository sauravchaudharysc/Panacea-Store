import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery_app/providers/products.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import './cart_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;
  //
  // ProductDetailScreen(this.title);
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId =
    ModalRoute.of(context).settings.arguments as String;
    final loadedProduct = Provider.of<Products>(
        context,
        listen: false
    ).findById(productId);
    final carter = Provider.of<Cart>(context , listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
        actions: [
          Consumer<Cart> (
            builder: (_,cart,ch)=>Badge(
              child:ch,
              value : cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart_outlined,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 300,
              width: double.infinity,
              child: Image.network(loadedProduct.imageUrl,
                  fit: BoxFit.cover) ,
            ),
            SizedBox(height: 10),
            Container(
              height: 60,
              width: double.infinity,
              color: Colors.blueGrey,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '${loadedProduct.title}',
                style:TextStyle(

                  fontSize: 40,
                  color: Colors.black87,
                ) ,
              ),
            ),
            Text('Price : ${loadedProduct.price}',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 30,
              ),),
            SizedBox(height: 10),
            Container(
              child: FlatButton(
                child: Text('Add to Cart'),
                onPressed: () {
                  carter.addItem(loadedProduct.id, loadedProduct.price, loadedProduct.title);
                },
                color: Colors.deepOrange,
                textColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
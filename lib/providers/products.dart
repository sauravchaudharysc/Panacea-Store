import 'dart:convert';
import '../models/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    Product(
      id: 'p7',
      title: 'Kurkure',
      description: 'with a masala munch flavor',
      price: 19.99,
      imageUrl:
      'https://i5.walmartimages.ca/images/Enlarge/118/863/6000200118863.jpg',
    ),
    Product(
      id: 'p1',
      title: 'Chicken',
      description: 'Fresh Chicken..! Provided pieces as desired',
      price: 129.99,
      imageUrl:
          'https://i.ytimg.com/vi/Hq2pavmew58/maxresdefault.jpg',
    ),
  Product(
      id: 'p2',
      title: 'Rice',
      description: 'Polished basmati rice,product name India gate weighing 10kilogram',
      price: 539.99,
      imageUrl:
      'https://4.imimg.com/data4/BM/KX/MY-15922529/india-gate-basmati-rice-premium-500x500.jpg',
    ),
    Product(
      id: 'p3',
      title: 'knorr soup',
      description: 'A warm soup of knorr soup for snack and flavor of mix vegitable flavor',
      price: 49.99,
      imageUrl:
      'https://rukminim1.flixcart.com/image/352/352/j3rm8i80/soup/r/y/m/61-soup-mix-veg-vegetable-knorr-original-imaeusugqktrpm9e.jpeg?q=70',
    ),
      Product(
        id: 'p6',
        title: 'Lays',
        description: 'with a magic masala taste',
        price: 19.99,
        imageUrl:
        'https://images-na.ssl-images-amazon.com/images/I/81X7W2BrGaL._SX425_.jpg',
      ),
      Product(
        id: 'p8',
        title: 'Oreo',
        description: 'Twist,lick,dunk eat',
        price: 17.99,
        imageUrl:
        'https://images-na.ssl-images-amazon.com/images/I/41XPnuR-uJL.jpg',
      ),
      Product(
        id: 'p10',
        title: 'Almond hair oil',
        description: 'For silky hair and smooth hair',
        price: 159.99,
        imageUrl:
        'https://i5.walmartimages.ca/images/Enlarge/787/562/6000199787562.jpg',
      ),
      Product(
        id: 'p12',
        title: 'Dairy milk',
        description: 'chocolaty',
        price: 20.00,
        imageUrl:
        'https://www.fewabazar.com/images/thumbs/001/0014800_dairy-milk-52-gm-ktm.jpeg',
      ),
  ];
  var _showFavoritesOnly = false;

  List<Product> get items {
    if (_showFavoritesOnly) {
      return _items.where((prodItem) => prodItem.isFavorite).toList();
    }
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  void showFavoritesOnly(){
    _showFavoritesOnly=!_showFavoritesOnly;
    notifyListeners();
  }


  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProducts() async {
    const url = 'https://grocery-app-70eec.firebaseio.com/products.json';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: prodData['isFavorite'],
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items=(loadedProducts);
      print(_items);
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    const url = 'https://grocery-app-70eec.firebaseio.com/products.json';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = 'https://grocery-app-70eec.firebaseio.com/products/$id.json';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }


  Future<void> deleteProduct(String id) async {
    final url = 'https://grocery-app-70eec.firebaseio.com/products/$id.json';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}

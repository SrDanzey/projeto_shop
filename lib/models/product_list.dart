import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/product.dart';
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/utils/constants.dart';

class ProductList with ChangeNotifier {
  final List<Product> _products = [];

  List<Product> get products => [..._products];
  List<Product> get favoriteProducts =>
      _products.where((product) => product.isFavorite).toList();

  int get productsCount {
    return _products.length;
  }

  Future<void> loadProducts() async {
    _products.clear();
    final response =
        await http.get(Uri.parse('${Constants.PRODUCT_BASE_URL}.json'));
    if (response.body == "null") return;
    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((productId, productData) {
      _products.add(
        Product(
          id: productId,
          name: productData['name'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: productData['isFavorite'],
        ),
      );
    });
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('${Constants.PRODUCT_BASE_URL}.json'),
      body: jsonEncode(
        {
          "name": product.name,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
          "isFavorite": product.isFavorite,
        },
      ),
    );
    final id = jsonDecode(response.body)['name'];
    _products.add(Product(
      id: id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      isFavorite: product.isFavorite,
    ));
    notifyListeners();
  }

  Future<void> saveProduct(Map<String, Object> product) {
    bool hasId = product['id'] != null;

    final newProduct = Product(
      id: hasId ? product['id'] as String : Random().nextDouble().toString(),
      name: product['name'] as String,
      description: product['description'] as String,
      price: product['price'] as double,
      imageUrl: product['imageUrl'] as String,
    );

    if (hasId) {
      return updateProduct(newProduct);
    }

    return addProduct(newProduct);
  }

  Future<void> updateProduct(Product product) async {
    int index = _products.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      await http.patch(
        Uri.parse('${Constants.PRODUCT_BASE_URL}/${product.id}.json'),
        body: jsonEncode(
          {
            "name": product.name,
            "description": product.description,
            "price": product.price,
            "imageUrl": product.imageUrl,
          },
        ),
      );
    }
    _products[index] = product;
    notifyListeners();
  }

  Future<void> removeProduct(Product product) async {
    int index = _products.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      final product = _products[index];
      _products.remove(product);
      notifyListeners();

      final response = await http.delete(
        Uri.parse('${Constants.PRODUCT_BASE_URL}/${product.id}.json'),
      );

      if (response.statusCode >= 400) {
        _products.insert(index, product);
        notifyListeners();
        throw HttpException(
          msg: 'Não foi possível excluir o produto.',
          statusCode: response.statusCode,
        );
      }
    }
  }
}

  // List<Product> get products {
  //   if (_showFavoriteOnly) {
  //     return _products.where((product) => product.isFavorite).toList();
  //   }
  //   return [..._products];
  // }

  // void showFavoriteOnly() {
  //   _showFavoriteOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoriteOnly = false;
  //   notifyListeners();
  // }

  // void addProduct(Product product) {
  //   _products.add(product);
  //   notifyListeners();
  // }

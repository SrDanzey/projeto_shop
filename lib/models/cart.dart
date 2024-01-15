import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/product.dart';

class Cart with ChangeNotifier {
  Map<String, CartItem> _cartItem = {};

  Map<String, CartItem> get cartItem {
    return {..._cartItem};
  }

  double get totalAmount {
    double total = 0.0;
    _cartItem.forEach(
      (key, cart) {
        total += cart.price * cart.quantity;
      },
    );
    return total;
  }

  int get itemCount {
    return _cartItem.length;
  }

  void addCardItem(Product product) {
    if (_cartItem.containsKey(product.id)) {
      _cartItem.update(
        product.id,
        (existingItem) => CartItem(
          id: existingItem.id,
          productId: existingItem.productId,
          name: existingItem.name,
          quantity: existingItem.quantity + 1,
          price: existingItem.price,
        ),
      );
    } else {
      _cartItem.putIfAbsent(
        product.id,
        () => CartItem(
          id: Random().nextDouble().toString(),
          productId: product.id,
          name: product.name,
          quantity: 1,
          price: product.price,
        ),
      );
    }
    notifyListeners();
  }

  void removeCardItem(String productId) {
    _cartItem.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_cartItem.containsKey(productId)) {
      return;
    }

    if (_cartItem[productId]?.quantity == 1) {
      _cartItem.remove(productId);
    } else {
      _cartItem.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          productId: existingItem.productId,
          name: existingItem.name,
          quantity: existingItem.quantity - 1,
          price: existingItem.price,
        ),
      );
    }
    notifyListeners();
  }

  void clear() {
    _cartItem = {};
    notifyListeners();
  }
}

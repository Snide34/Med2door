import 'package:flutter/material.dart';

class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String? image;

  const OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.image,
  });
}

class Order {
  final String id;
  final String date;
  final String status;
  final List<OrderItem> items;
  final int totalItems;
  final double total;
  final String deliveryAddress;
  final String paymentMethod;

  const Order({
    required this.id,
    required this.date,
    required this.status,
    required this.items,
    required this.totalItems,
    required this.total,
    required this.deliveryAddress,
    required this.paymentMethod,
  });
}

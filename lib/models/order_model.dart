
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'],
      productName: map['productName'],
      quantity: map['quantity'],
      price: (map['price'] as num).toDouble(),
    );
  }
}

class Order {
  final String? orderId;
  final String customerId;
  final List<OrderItem> items;
  final double subtotal;
  final double shippingFee;
  final double total;
  final Timestamp orderDate;
  final String shippingAddress;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final String? notes;

  Order({
    this.orderId,
    required this.customerId,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.orderDate,
    required this.shippingAddress,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'total': total,
      'orderDate': orderDate,
      'shippingAddress': shippingAddress,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'notes': notes,
    };
  }

  factory Order.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      orderId: doc.id,
      customerId: data['customerId'],
      items: (data['items'] as List)
          .map((item) => OrderItem.fromMap(item))
          .toList(),
      subtotal: (data['subtotal'] as num).toDouble(),
      shippingFee: (data['shippingFee'] as num).toDouble(),
      total: (data['total'] as num).toDouble(),
      orderDate: data['orderDate'],
      shippingAddress: data['shippingAddress'],
      status: data['status'],
      paymentMethod: data['paymentMethod'],
      paymentStatus: data['paymentStatus'],
      notes: data['notes'],
    );
  }
}

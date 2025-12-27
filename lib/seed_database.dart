
// ignore_for_file: unused_import, depend_on_referenced_packages

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:faker/faker.dart';

// Hướng dẫn chạy file này:
// 1. Mở Terminal trong Android Studio.
// 2. Chạy lệnh sau: flutter run lib/seed_database.dart
// 3. Đợi cho đến khi terminal in ra "==> SEEDING COMPLETE! <==".
// 4. Kiểm tra dữ liệu trên Firebase Console.
// 5. Sau khi hoàn tất, bạn có thể xóa file này đi.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("==> STARTING DATABASE SEEDING <==");
  await seedDatabase();
  print("==> SEEDING COMPLETE! <==");
}

Future<void> seedDatabase() async {
  final firestore = FirebaseFirestore.instance;

  print("Deleting old data...");
  await _deleteCollection(firestore.collection('customers'));
  await _deleteCollection(firestore.collection('products'));
  await _deleteCollection(firestore.collection('orders'));

  print("Seeding customers...");
  final customerIds = await _seedCustomers(firestore);

  print("Seeding products...");
  final products = await _seedProducts(firestore);

  print("Seeding orders...");
  await _seedOrders(firestore, customerIds, products);
}

Future<void> _deleteCollection(CollectionReference collection) async {
  final snapshot = await collection.limit(500).get();
  final batch = FirebaseFirestore.instance.batch();
  for (var doc in snapshot.docs) {
    batch.delete(doc.reference);
  }
  await batch.commit();
}

Future<List<String>> _seedCustomers(FirebaseFirestore firestore) async {
  final collection = firestore.collection('customers');
  final List<String> customerIds = [];

  for (int i = 0; i < 5; i++) {
    final docRef = await collection.add({
      'email': faker.internet.email(),
      'fullName': faker.person.name(),
      'phoneNumber': faker.phoneNumber.us(),
      'address': faker.address.streetAddress(),
      'city': faker.address.city(),
      'postalCode': faker.address.zipCode(),
      'createdAt': Timestamp.now(),
      'isActive': true,
    });
    customerIds.add(docRef.id);
  }
  return customerIds;
}

Future<List<Map<String, dynamic>>> _seedProducts(FirebaseFirestore firestore) async {
  final collection = firestore.collection('products');
  final categories = ['Electronics', 'Clothing', 'Food', 'Books', 'Toys'];
  final brands = ['Apple', 'Nike', 'Nestle', 'Penguin', 'Lego'];
  final List<Map<String, dynamic>> productData = [];

  for (int i = 0; i < 15; i++) {
    final category = categories[i % categories.length];
    final brand = brands[i % brands.length];
    final price = (Random().nextDouble() * 1000) + 50;

    final docRef = await collection.add({
      // Lỗi đã được sửa ở đây: Xóa ký tự \ 
      'name': '${category.substring(0, 3)} Product ${i + 1}',
      'description': faker.lorem.sentence(),
      'price': price,
      'category': category,
      'brand': brand,
      'stock': Random().nextInt(100),
      'imageUrl': 'https://picsum.photos/seed/${i + 1}/400/300',
      'rating': (Random().nextDouble() * 4) + 1, // Rating from 1.0 to 5.0
      'reviewCount': Random().nextInt(200),
      'isAvailable': true,
      'createdAt': Timestamp.now(),
    });
    productData.add({
      'id': docRef.id,
      'name': '${category.substring(0, 3)} Product ${i + 1}',
      'price': price,
    });
  }
  return productData;
}

Future<void> _seedOrders(FirebaseFirestore firestore, List<String> customerIds, List<Map<String, dynamic>> products) async {
  final collection = firestore.collection('orders');
  final statuses = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'];
  final paymentMethods = ['cash', 'card', 'bank_transfer'];
  final paymentStatuses = ['pending', 'paid', 'failed'];
  final random = Random();

  for (int i = 0; i < 8; i++) {
    final customerId = customerIds[random.nextInt(customerIds.length)];
    final status = statuses[random.nextInt(statuses.length)];
    
    final int itemCount = random.nextInt(3) + 1; // 1 to 3 items per order
    final List<Map<String, dynamic>> orderItems = [];
    double subtotal = 0.0;

    for(int j = 0; j < itemCount; j++) {
        final product = products[random.nextInt(products.length)];
        final quantity = random.nextInt(5) + 1;
        final itemPrice = product['price'];
        subtotal += itemPrice * quantity;

        orderItems.add({
            'productId': product['id'],
            'productName': product['name'],
            'quantity': quantity,
            'price': itemPrice,
        });
    }

    final shippingFee = 30000.0;
    final total = subtotal + shippingFee;
    
    await collection.add({
      'customerId': customerId,
      'items': orderItems,
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'total': total,
      'orderDate': Timestamp.fromDate(DateTime.now().subtract(Duration(days: random.nextInt(30)))),
      'shippingAddress': faker.address.streetAddress(),
      'status': status,
      'paymentMethod': paymentMethods[random.nextInt(paymentMethods.length)],
      'paymentStatus': paymentStatuses[random.nextInt(paymentStatuses.length)],
      'notes': random.nextBool() ? faker.lorem.sentence() : null,
    });
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? productId;
  final String name;
  final String description;
  final double price;
  final String category;
  final String brand;
  final int stock;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final Timestamp createdAt;

  Product({
    this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.brand,
    required this.stock,
    required this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'brand': brand,
      'stock': stock,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
    };
  }

  factory Product.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      productId: doc.id,
      name: data['name'],
      description: data['description'],
      price: (data['price'] as num).toDouble(),
      category: data['category'],
      brand: data['brand'],
      stock: data['stock'],
      imageUrl: data['imageUrl'],
      rating: (data['rating'] as num).toDouble(),
      reviewCount: data['reviewCount'],
      isAvailable: data['isAvailable'],
      createdAt: data['createdAt'],
    );
  }
}

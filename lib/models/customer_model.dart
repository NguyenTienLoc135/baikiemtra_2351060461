
import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String? customerId;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String city;
  final String postalCode;
  final Timestamp createdAt;
  final bool isActive;

  Customer({
    this.customerId,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }

  factory Customer.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Customer(
      customerId: doc.id,
      email: data['email'],
      fullName: data['fullName'],
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      city: data['city'],
      postalCode: data['postalCode'],
      createdAt: data['createdAt'],
      isActive: data['isActive'],
    );
  }
}

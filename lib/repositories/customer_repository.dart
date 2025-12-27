
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final CollectionReference _customerCollection = FirebaseFirestore.instance.collection('customers');
  final CollectionReference _orderCollection = FirebaseFirestore.instance.collection('orders');

  Future<void> addCustomer(Customer customer) {
    return _customerCollection.add(customer.toMap());
  }

  // Phương thức mới để tìm khách hàng bằng email
  Future<Customer?> getCustomerByEmail(String email) async {
    final querySnapshot = await _customerCollection
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return Customer.fromDocument(querySnapshot.docs.first);
    }
    return null;
  }

  Future<Customer?> getCustomerById(String customerId) async {
    final doc = await _customerCollection.doc(customerId).get();
    if (doc.exists) {
      return Customer.fromDocument(doc);
    }
    return null;
  }

  Stream<List<Customer>> getAllCustomers() {
    return _customerCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Customer.fromDocument(doc)).toList();
    });
  }

  Future<void> updateCustomer(String customerId, Customer customer) {
    return _customerCollection.doc(customerId).update(customer.toMap());
  }

 Future<bool> canDeleteCustomer(String customerId) async {
    final querySnapshot = await _orderCollection.where('customerId', isEqualTo: customerId).limit(1).get();
    return querySnapshot.docs.isEmpty;
  }

  Future<void> deleteCustomer(String customerId) async {
     if (await canDeleteCustomer(customerId)) {
      return _customerCollection.doc(customerId).delete();
    } else {
      throw Exception('Không thể xóa khách hàng vì có đơn hàng liên quan.');
    }
  }
}

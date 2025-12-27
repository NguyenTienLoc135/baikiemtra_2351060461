
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order_model.dart';
import '../models/product_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder(Order order) async {
    final WriteBatch batch = _firestore.batch();

    final DocumentReference orderRef = _firestore.collection('orders').doc();

    for (final item in order.items) {
      final DocumentReference productRef = _firestore.collection('products').doc(item.productId);
      final DocumentSnapshot productDoc = await productRef.get();

      if (!productDoc.exists) {
        throw Exception('Sản phẩm với ID ${item.productId} không tồn tại.');
      }

      final currentStock = (productDoc.data() as Map<String, dynamic>)['stock'] as int;

      if (currentStock < item.quantity) {
        throw Exception('Không đủ hàng cho sản phẩm ${item.productName}.');
      }

      final newStock = currentStock - item.quantity;
      batch.update(productRef, {'stock': newStock});
    }

    batch.set(orderRef, order.toMap());

    await batch.commit();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final DocumentReference orderRef = _firestore.collection('orders').doc(orderId);
    final DocumentSnapshot orderDoc = await orderRef.get();

    if (!orderDoc.exists) {
      throw Exception('Đơn hàng không tồn tại.');
    }

    if (status == 'cancelled') {
      final Order order = Order.fromDocument(orderDoc);
      final WriteBatch batch = _firestore.batch();

      for (final item in order.items) {
        final DocumentReference productRef = _firestore.collection('products').doc(item.productId);
        batch.update(productRef, {'stock': FieldValue.increment(item.quantity)});
      }

      batch.update(orderRef, {'status': status});
      await batch.commit();
    } else {
      await orderRef.update({'status': status});
    }
  }

  Stream<List<Order>> getOrdersByCustomer(String customerId) {
    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map<Order>((doc) => Order.fromDocument(doc)).toList());
  }

  Stream<List<Order>> getOrdersByStatus(String status) {
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map<Order>((doc) => Order.fromDocument(doc)).toList());
  }

  Future<Order?> getOrderById(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (doc.exists) {
      return Order.fromDocument(doc);
    }
    return null;
  }
}

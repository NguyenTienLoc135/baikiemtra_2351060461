
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductRepository {
  final CollectionReference _productCollection = FirebaseFirestore.instance.collection('products');

  Future<void> addProduct(Product product) {
    return _productCollection.add(product.toMap());
  }

  Future<Product?> getProductById(String productId) async {
    final doc = await _productCollection.doc(productId).get();
    if (doc.exists) {
      return Product.fromDocument(doc);
    }
    return null;
  }

  Stream<List<Product>> getAllProducts() {
    return _productCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromDocument(doc)).toList();
    });
  }

  Stream<List<Product>> searchProducts(String query) {
    return _productCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromDocument(doc))
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()) ||
              product.brand.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Stream<List<Product>> getProductsByCategory(String category) {
     return _productCollection.where('category', isEqualTo: category).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromDocument(doc)).toList();
    });
  }

  Future<void> updateProduct(String productId, Product product) {
    return _productCollection.doc(productId).update(product.toMap());
  }
}

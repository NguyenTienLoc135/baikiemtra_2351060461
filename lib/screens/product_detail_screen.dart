
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductDetailScreen({
    Key? key,
    required this.product,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(product.imageUrl, width: double.infinity, height: 250, fit: BoxFit.cover,),
            const SizedBox(height: 16),
            Text(product.name, style: Theme.of(context).textTheme.headlineMedium,),
            const SizedBox(height: 8),
            Text('${product.price.toStringAsFixed(0)}đ', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20),),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                Text('${product.rating} (${product.reviewCount} đánh giá)'),
              ],
            ),
            const SizedBox(height: 16),
            Text(product.description),
            const SizedBox(height: 16),
            Text('Thương hiệu: ${product.brand}'),
            Text('Danh mục: ${product.category}'),
            Text('Còn lại: ${product.stock}'),
            const SizedBox(height: 24),
            if (product.stock > 0)
              ElevatedButton(
                onPressed: onAddToCart, // Call the VoidCallback directly
                child: const Text('Thêm vào giỏ hàng'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              )
            else
              const Center(
                child: Text('Hết hàng', style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),),
              ),
          ],
        ),
      ),
    );
  }
}

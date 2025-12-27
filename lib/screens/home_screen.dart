
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import 'login_form.dart';
import 'cart_screen.dart';
import 'order_list_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;
  const HomeScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductRepository _productRepository = ProductRepository();
  final _searchController = TextEditingController();

  Customer? _currentUser;
  List<OrderItem> _cart = [];
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<void> _loadCurrentUser() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('customers')
        .where('email', isEqualTo: widget.userEmail)
        .limit(1)
        .get();
    if (mounted && querySnapshot.docs.isNotEmpty) {
      setState(() {
        _currentUser = Customer.fromDocument(querySnapshot.docs.first);
      });
    }
  }

  void _addToCart(Product product) {
    setState(() {
      final index = _cart.indexWhere((item) => item.productId == product.productId);
      if (index != -1) {
        final existingItem = _cart[index];
         if (existingItem.quantity < product.stock) {
            _cart[index] = OrderItem(
              productId: existingItem.productId,
              productName: existingItem.productName,
              quantity: existingItem.quantity + 1,
              price: existingItem.price);
        } else {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số lượng đã đạt tối đa.')));
        }
      } else {
         if (product.stock > 0) {
            _cart.add(OrderItem(
              productId: product.productId!,
              productName: product.name,
              quantity: 1,
              price: product.price));
        } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sản phẩm đã hết hàng.')));
        }
      }
    });
    if(product.stock > 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm vào giỏ hàng!')));
    }
  }

  Future<void> _navigateToCart() async {
    final originalCartSize = _cart.length;
    final result = await Navigator.of(context).push<List<OrderItem>>(
      MaterialPageRoute(
        builder: (_) => CartScreen(
          cartItems: List<OrderItem>.from(_cart),
          currentUser: _currentUser,
        ),
      ),
    );

    if (result != null) {
      // Use a short delay to ensure the navigator is settled before updating state and UI.
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _cart = result;
          });
          if (result.isEmpty && originalCartSize > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đặt hàng thành công!')),
            );
          }
        }
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
    if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginForm()),
          (Route<dynamic> route) => false,
        );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<List<Product>> _getProductsStream() {
    if (_searchQuery.isNotEmpty) {
      return _productRepository.searchProducts(_searchQuery);
    }
    if (_selectedCategory != null) {
      return _productRepository.getProductsByCategory(_selectedCategory!);
    }
    return _productRepository.getAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('odoList App - 2351060461'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Tìm kiếm sản phẩm',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 8),
                _buildCategoryFilter(),
              ],
            ),
          ),
          Expanded(
            child: _currentUser == null
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<List<Product>>(
              stream: _getProductsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không tìm thấy sản phẩm nào.'));
                }

                final products = snapshot.data!;

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7, // Sửa lại tỷ lệ
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(product: product, onAddToCart: () => _addToCart(product));
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.history), onPressed: () {
              if (_currentUser?.customerId != null) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => OrderListScreen(customerId: _currentUser!.customerId!)));
              }
            }),
            IconButton(icon: const Icon(Icons.shopping_cart), onPressed: _navigateToCart),
            IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
          ],
        )
      ),
    );
  }

  Widget _buildCategoryFilter() {
    const categories = ['Electronics', 'Clothing', 'Food', 'Books', 'Toys'];

    return DropdownButton<String>(
      value: _selectedCategory,
      hint: const Text('Tất cả danh mục'),
      isExpanded: true,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Tất cả danh mục'),
        ),
        ...categories.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ],
      onChanged: (newValue) {
        setState(() {
          _searchQuery = '';
          _searchController.clear();
          _selectedCategory = newValue;
        });
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductCard({Key? key, required this.product, required this.onAddToCart})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: product,
              onAddToCart: onAddToCart,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thêm lại phần ảnh
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                  ),
                  if (product.stock == 0)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      alignment: Alignment.center,
                      child: const Text(
                        'Hết hàng',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${product.price.toStringAsFixed(0)}đ',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(product.rating.toStringAsFixed(1)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

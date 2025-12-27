
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../models/order_model.dart';
import '../repositories/order_repository.dart';

class CartScreen extends StatefulWidget {
  final List<OrderItem> cartItems;
  final Customer? currentUser;

  const CartScreen({
    Key? key,
    required this.cartItems,
    required this.currentUser,
  }) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<OrderItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List<OrderItem>.from(widget.cartItems);
  }

  double get _subtotal => _items.fold(
      0.0, (total, current) => total + (current.price * current.quantity));

  void _updateQuantity(String productId, int newQuantity) {
    setState(() {
      final index = _items.indexWhere((item) => item.productId == productId);
      if (index != -1) {
        if (newQuantity > 0) {
          _items[index] = OrderItem(
            productId: _items[index].productId,
            productName: _items[index].productName,
            price: _items[index].price,
            quantity: newQuantity,
          );
        } else {
          _items.removeAt(index);
        }
      }
    });
  }

  void _showCheckoutSheet() async {
    final bool? orderPlaced = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CheckoutSheet(
        cartItems: _items,
        subtotal: _subtotal,
        currentUser: widget.currentUser,
      ),
    );

    if (orderPlaced == true && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Lỗi đã được sửa ở đây: Chỉ định rõ kiểu dữ liệu trả về
          Navigator.of(context).pop(<OrderItem>[]); 
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_items);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Giỏ hàng'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(_items),
          ),
        ),
        body: _items.isEmpty
            ? const Center(
                child: Text('Giỏ hàng của bạn đang trống.', style: TextStyle(fontSize: 18)),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return ListTile(
                          title: Text(item.productName),
                          subtitle: Text('${item.price.toStringAsFixed(0)}đ'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => _updateQuantity(item.productId, item.quantity - 1),
                              ),
                              Text(item.quantity.toString()),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _updateQuantity(item.productId, item.quantity + 1),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tổng cộng:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('${_subtotal.toStringAsFixed(0)}đ', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _items.isNotEmpty ? _showCheckoutSheet : null,
                          child: const Text('Đặt hàng'),
                          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

class CheckoutSheet extends StatefulWidget {
  final List<OrderItem> cartItems;
  final double subtotal;
  final Customer? currentUser;

  const CheckoutSheet({
    Key? key,
    required this.cartItems,
    required this.subtotal,
    required this.currentUser,
  }) : super(key: key);

  @override
  _CheckoutSheetState createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  final _formKey = GlobalKey<FormState>();
  final _shippingAddressController = TextEditingController();
  String _paymentMethod = 'cash';
  final OrderRepository _orderRepository = OrderRepository();
  bool _isLoading = false;

  Future<void> _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      if (widget.currentUser?.customerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy thông tin khách hàng.')),
        );
        return;
      }

      setState(() { _isLoading = true; });

      const shippingFee = 30000.0;
      final total = widget.subtotal + shippingFee;

      final newOrder = Order(
        customerId: widget.currentUser!.customerId!,
        items: widget.cartItems,
        subtotal: widget.subtotal,
        shippingFee: shippingFee,
        total: total,
        orderDate: Timestamp.now(),
        shippingAddress: _shippingAddressController.text,
        status: 'pending',
        paymentMethod: _paymentMethod,
        paymentStatus: 'pending',
      );

      try {
        await _orderRepository.createOrder(newOrder);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi đặt hàng: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() { _isLoading = false; });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const shippingFee = 30000.0;
    final total = widget.subtotal + shippingFee;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hoàn tất đơn hàng', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextFormField(
              controller: _shippingAddressController,
              decoration: const InputDecoration(labelText: 'Địa chỉ giao hàng'),
              validator: (value) => value!.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
            ),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(labelText: 'Phương thức thanh toán'),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Thanh toán khi nhận hàng (COD)')),
                DropdownMenuItem(value: 'card', child: Text('Thẻ tín dụng')),
                DropdownMenuItem(value: 'bank_transfer', child: Text('Chuyển khoản ngân hàng')),
              ],
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Text('Phí vận chuyển: ${shippingFee.toStringAsFixed(0)}đ'),
            Text('Tổng thanh toán: ${total.toStringAsFixed(0)}đ', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitOrder,
                    child: const Text('Xác nhận đặt hàng'),
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

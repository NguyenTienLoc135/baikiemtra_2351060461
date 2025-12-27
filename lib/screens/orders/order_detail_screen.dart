
import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../repositories/order_repository.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderRepository _orderRepository = OrderRepository();

  Future<void> _cancelOrder(String orderId) async {
    try {
      await _orderRepository.updateOrderStatus(orderId, 'cancelled');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã hủy đơn hàng thành công.')),
      );
      // Refresh the state to show the updated status
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi hủy đơn hàng: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng'),
      ),
      body: FutureBuilder<Order?>(
        future: _orderRepository.getOrderById(widget.orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Không tìm thấy thông tin đơn hàng.'));
          }

          final order = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mã đơn hàng: ${order.orderId}', style: Theme.of(context).textTheme.titleLarge),
                Text('Ngày đặt: ${order.orderDate.toDate()}'),
                Text('Trạng thái: ${order.status}'),
                const Divider(height: 30),
                Text('Thông tin giao hàng', style: Theme.of(context).textTheme.titleMedium),
                Text('Địa chỉ: ${order.shippingAddress}'),
                const Divider(height: 30),
                Text('Sản phẩm đã đặt', style: Theme.of(context).textTheme.titleMedium),
                ...order.items.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.productName),
                  subtitle: Text('Số lượng: ${item.quantity}'),
                  trailing: Text('${item.price * item.quantity}đ'),
                )),
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text('Tạm tính'), Text('${order.subtotal}đ')],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text('Phí vận chuyển'), Text('${order.shippingFee}đ')],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng cộng', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${order.total}đ', style: const TextStyle(fontWeight: FontWeight.bold))
                  ],
                ),
                const SizedBox(height: 30),
                if (order.status == 'pending')
                  ElevatedButton(
                    onPressed: () => _cancelOrder(order.orderId!),
                    child: const Text('Hủy đơn hàng'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer_model.dart';
import '../repositories/customer_repository.dart';
import 'home_screen.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _customerRepository = CustomerRepository();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      final email = _emailController.text;

      // Kiểm tra xem email đã tồn tại chưa
      final existingCustomer = await _customerRepository.getCustomerByEmail(email);
      if (existingCustomer != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email này đã được sử dụng.')),
          );
          setState(() { _isLoading = false; });
        }
        return;
      }

      final newCustomer = Customer(
        email: email,
        fullName: _fullNameController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        city: _cityController.text,
        postalCode: _postalCodeController.text,
        createdAt: Timestamp.now(),
      );
      try {
        await _customerRepository.addCustomer(newCustomer);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', email);

        if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => HomeScreen(userEmail: email)),
              (route) => false, 
            );
        }
      } catch (e) {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đăng ký thất bại: ${e.toString()}')),
            );
            setState(() { _isLoading = false; });
         }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              // Lỗi đã được sửa ở đây: Thêm xác thực định dạng email
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Định dạng email không hợp lệ';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
              validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập họ tên' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
              // Lỗi đã được sửa ở đây: Thêm xác thực định dạng số điện thoại
              validator: (value) {
                 if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số điện thoại';
                }
                final phoneRegex = RegExp(r'^(\+84|0)?[0-9]{9,10}$');
                 if (!phoneRegex.hasMatch(value)) {
                  return 'Định dạng số điện thoại không hợp lệ';
                }
                return null;
              },
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Địa chỉ'),
              validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'Thành phố'),
              validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập thành phố' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _postalCodeController,
              decoration: const InputDecoration(labelText: 'Mã bưu điện'),
              validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập mã bưu điện' : null,
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(onPressed: _submit, child: const Text('Đăng ký')),
            
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Đã có tài khoản? Đăng nhập'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

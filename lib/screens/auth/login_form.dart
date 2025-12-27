
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';
import 'register_form.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  // The initState is no longer needed to check login status
  // @override
  // void initState() {
  //   super.initState();
  //   _checkLoginStatus();
  // }

  // This function is no longer called from initState
  // Future<void> _checkLoginStatus() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userEmail = prefs.getString('userEmail');
  //   if (mounted && userEmail != null) {
  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(builder: (_) => HomeScreen(userEmail: userEmail)),
  //     );
  //   }
  // }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      final email = _emailController.text;
      try {
        // You might want to verify user exists in Firestore first
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', email);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => HomeScreen(userEmail: email)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đăng nhập thất bại: ${e.toString()}')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập email' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(onPressed: _submit, child: const Text('Đăng nhập')),
              TextButton(
                onPressed: () {
                  // Navigate to the registration screen
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterForm()),
                  );
                },
                child: const Text('Chưa có tài khoản? Đăng ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

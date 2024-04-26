import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../components/my_button.dart';
import '../components/my_text_field.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signUpWithEmailandPassword(
        emailController.text,
        passwordController.text,
      );
      // Navigate to login or home page on successful sign up
      // Navigator.of(context).pushReplacementNamed('/home'); // Example navigation
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 120),
              Icon(
                Icons.mode_edit_outlined,
                size: 120,
                color: Colors.blue,
              ),
              SizedBox(height: 48),
              Text("Create an Account",
                  style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 24),
              MyTextField(
                controller: emailController,
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                obscureText: false,
              ),
              SizedBox(height: 16),
              MyTextField(
                controller: passwordController,
                hintText: 'Enter your password',
                obscureText: true,
              ),
              SizedBox(height: 16),
              MyTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm your password',
                obscureText: true,
              ),
              SizedBox(height: 24),
              MyButton(onTap: signUp, text: "Sign Up"),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already a member? '),
                  InkWell(
                    onTap: widget.onTap,
                    child: Text('Sign in here',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

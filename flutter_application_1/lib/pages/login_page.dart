import 'package:flutter/material.dart';
import '../components/my_button.dart';
import '../components/my_text_field.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signInWithEmailandPassword(
          emailController.text, passwordController.text);
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 120),
              const Icon(
                Icons.mode_edit_outlined,
                size: 120,
                color: Colors.blue,
              ),
              const SizedBox(height: 48),
              Text("Welcome Back",
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              MyTextField(
                controller: emailController,
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                obscureText: false,
              ),
              const SizedBox(height: 16),
              MyTextField(
                controller: passwordController,
                hintText: 'Enter your password',
                obscureText: true,
              ),
              const SizedBox(height: 24),
              MyButton(onTap: signIn, text: "Sign In"),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Not a member? '),
                  InkWell(
                    onTap: widget.onTap,
                    child: const Text('Register now',
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

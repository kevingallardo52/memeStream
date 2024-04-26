import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Add extends StatefulWidget {
  const Add({super.key});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: const Text("Add"));
  }
}

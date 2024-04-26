import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DeleteButton extends StatelessWidget {
  final void Function()? onTap;
  const DeleteButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Icon(
        CupertinoIcons.delete,
        color: Colors.black,
      ),
    );
  }
}

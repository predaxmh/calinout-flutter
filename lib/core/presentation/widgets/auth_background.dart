import 'package:calinout/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const AuthBackground({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary, AppColors.primary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
            child: child,
          ),
        ),
      ),
    );
  }
}

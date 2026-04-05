import 'package:calinout/core/theme/app_colors.dart';
import 'package:flutter/Material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      ),
    );
  }
}

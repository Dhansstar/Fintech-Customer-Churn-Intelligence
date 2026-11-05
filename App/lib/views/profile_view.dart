import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fintech_app/core/theme/app_colors.dart';
import 'package:fintech_app/core/widgets/custom_button.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  void _exitApp() {
    Get.defaultDialog(
      title: 'Exit Application',
      middleText: 'Are you sure you want to exit the application?',
      textCancel: 'Cancel',
      textConfirm: 'Exit',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.danger,
      onConfirm: () {
        SystemNavigator.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 45,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            'Enterprise Admin',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Text(
            'admin@bankfintech.id',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const Spacer(),
          CustomButton(
            text: 'Exit Application',
            icon: Icons.logout_rounded,
            backgroundColor: AppColors.danger,
            onPressed: _exitApp,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
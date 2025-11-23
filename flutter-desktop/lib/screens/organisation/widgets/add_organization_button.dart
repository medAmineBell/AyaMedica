import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddOrganizationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddOrganizationButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            width: 1,
            color: Color(0xFF2D2E2E),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 1,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add,
              size: 24,
              color: Color(0xFF2D2E2E),
            ),
            const SizedBox(width: 8),
            Text(
              'add_new_organization'.tr,
              style: const TextStyle(
                color: Color(0xFF2D2E2E),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.43,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
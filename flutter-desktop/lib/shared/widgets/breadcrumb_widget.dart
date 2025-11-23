import 'package:flutter/material.dart';

class BreadcrumbWidget extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const BreadcrumbWidget({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.asMap().entries.map((entry) {
        final isLast = entry.key == items.length - 1;
        return Row(
          children: [
            Text(
              entry.value.label,
              style: TextStyle(
                color: isLast ? const Color(0xFF1339FF) : const Color(0xFF858789),
                fontSize: 12,
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: isLast ? FontWeight.w700 : FontWeight.w400,
                height: 1.33,
                letterSpacing: isLast ? 0.36 : 0,
              ),
            ),
            if (!isLast) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_outlined,
                color: Color(0xFF858789),
                size: 12,
              ),
              const SizedBox(width: 8),
            ],
          ],
        );
      }).toList(),
    );
  }
}

class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  const BreadcrumbItem({
    required this.label,
    this.onTap,
  });
}

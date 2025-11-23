import 'package:flutter/material.dart';

class CompleteWalkInDialog extends StatelessWidget {
  final String studentName;

  const CompleteWalkInDialog({
    Key? key,
    required this.studentName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 700, // Limit the maximum width
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1FAE5), // Light green background
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF059669), // Dark green checkmark
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Complete walk in ?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151), // Dark grey
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280), // Regular grey
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'You are about to complete the walkin for '),
                    TextSpan(
                      text: studentName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151), // Dark grey for student name
                      ),
                    ),
                    const TextSpan(text: ', would you like to notify the parents'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Buttons row
              Row(
                children: [
                  // Recheck after school button
                  Expanded(
                    child: _buildButton(
                      text: 'Recheck after school',
                      isPrimary: false,
                      onPressed: () {
                        Navigator.of(context).pop('recheck');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Student will be picked up button
                  Expanded(
                    child: _buildButton(
                      text: 'Student will be picked up',
                      isPrimary: false,
                      onPressed: () {
                        Navigator.of(context).pop('picked_up');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Student is fine button
                  Expanded(
                    child: _buildButton(
                      text: 'Student is fine',
                      isPrimary: true,
                      onPressed: () {
                        Navigator.of(context).pop('fine');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFF3B82F6) : Colors.white,
        foregroundColor: isPrimary ? Colors.white : const Color(0xFF374151),
        side: BorderSide(
          color: isPrimary ? const Color(0xFF3B82F6) : const Color(0xFFD1D5DB),
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  static Future<String?> show(BuildContext context, String studentName) {
    return showDialog<String>(
      context: context,
      builder: (context) => CompleteWalkInDialog(studentName: studentName),
    );
  }
}
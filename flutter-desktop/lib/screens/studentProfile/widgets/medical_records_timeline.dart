import 'package:flutter/material.dart';

class MedicalRecordsTimeline extends StatefulWidget {
  const MedicalRecordsTimeline({Key? key}) : super(key: key);

  @override
  State<MedicalRecordsTimeline> createState() => _MedicalRecordsTimelineState();
}

class _MedicalRecordsTimelineState extends State<MedicalRecordsTimeline> {
  int selectedIndex = 0;

final List<Map<String, dynamic>> timelineItems = [
  {
    'specialty': 'Vaccination',
    'icon': Icons.medical_services,

  },
  {
    'specialty': 'Pediatric',
    'icon': Icons.child_care,

  },
  {
    'specialty': 'Orthopedics',
    'icon': Icons.accessible,

  },
  {
    'specialty': 'Cardiology',
    'icon': Icons.favorite,

  },
  {
    'specialty': 'Neurology',
    'icon': Icons.psychology,

  },
  {
    'specialty': 'Pediatrics',
    'icon': Icons.family_restroom,

  },
  {
    'specialty': 'Dermatology',
    'icon': Icons.face,

  },
];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: timelineItems.length,
        itemBuilder: (context, index) {
          final item = timelineItems[index];
          final isSelected = index == selectedIndex;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
           child: Column(
  children: [
    // Card container
    Container(
      width: 288,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
             Icon(
            item['icon']!,
            color: isSelected ? const Color(0xFFCDFF1F) : const Color(0xFF2D2E2E),
          ),
  
          const SizedBox(height: 12),
                  Text(
            item['specialty']!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isSelected ? const Color(0xFFD8FAE4) : const Color(0xFF2D2E2E),
            ),
          ),
       
        
        ],
      ),
    ),

    // Triangle pointer if selected
    if (isSelected) ...[
      const SizedBox(height: 6),
      Transform.rotate(
        angle: 3.14 , // upside down
        child: CustomPaint(
          size: const Size(24, 12),
          painter: _TrianglePainter(color: Color(0xFF2563EB)),
        ),
      ),
    ]
  ],
),
 ),
          );
        },
      ),
    );
  }
}
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)         // Top center
      ..lineTo(0, size.height)            // Bottom left
      ..lineTo(size.width, size.height)   // Bottom right
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

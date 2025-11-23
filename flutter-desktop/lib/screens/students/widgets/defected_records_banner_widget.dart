import 'package:flutter/material.dart';

class DefectedRecordsBanner extends StatelessWidget {
  final int defectedCount;
  final VoidCallback? onUploadCorrected;
  final VoidCallback? onDownloadDefected;

  const DefectedRecordsBanner({
    Key? key,
    required this.defectedCount,
    this.onUploadCorrected,
    this.onDownloadDefected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFFFEF2F2), // Light red background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color(0xFFFECACA), // Light red border
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Error Icon
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Color(0xFFEF4444), // Red background
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 12,
            ),
          ),
          
          SizedBox(width: 12),
          
          // Error Message Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '($defectedCount) defected records found',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF991B1B), // Dark red text
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Download the defected records file, correct it and re-upload it again.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7F1D1D), // Darker red text
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(width: 16),
          
          // Action Buttons
          Row(
            children: [
              // Upload Corrected Records Button
              OutlinedButton.icon(
                onPressed: onUploadCorrected,
                icon: Icon(
                  Icons.upload_outlined,
                  size: 16,
                  color: Color(0xFFEF4444),
                ),
                label: Text(
                  'Upload corrected records',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFEF4444),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Color(0xFFEF4444),
                    width: 1,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              
              SizedBox(width: 12),
              
              // Download Defected Records Button
              OutlinedButton.icon(
                onPressed: onDownloadDefected,
                icon: Icon(
                  Icons.download_outlined,
                  size: 16,
                  color: Color(0xFFEF4444),
                ),
                label: Text(
                  'Download defected records',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFEF4444),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Color(0xFFEF4444),
                    width: 1,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
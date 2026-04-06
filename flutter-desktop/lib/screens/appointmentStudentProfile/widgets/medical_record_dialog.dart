import 'package:flutter/material.dart';

class MedicalRecordDialog extends StatelessWidget {
  const MedicalRecordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        constraints: const BoxConstraints(
          maxWidth: 800,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Close button
                IconButton(
                  icon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E9ED),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(Icons.close, size: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 24),
                
                // Title section
                _buildHeader(context),
                const SizedBox(height: 24),
                
                // Created by section
                _buildCreatedBySection(),
                const SizedBox(height: 24),
                
                // Record details
                _buildRecordDetailsSection(),
                const SizedBox(height: 24),
                
                // Drugs details
                _buildDrugsSection(),
                const SizedBox(height: 24),
                
                // Attachments
                _buildAttachmentsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medical record details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2E2E),
            ),),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Creation date',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF707579),
                ),),
              ],
            ),
          ],
        ),
        // Empty container for spacing balance
        const SizedBox(width: 100, height: 40),
      ],
    );
  }

  Widget _buildCreatedBySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Created by',
          style: TextStyle(
            color: const Color(0xFF747677),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _buildHistoryItem(
          avatarColor: const Color(0xFFD8FAE4),
          name: 'User full name',
          date: '17/06/2025 | 04:37 AM',
        ),
        _buildHistoryItem(
          avatarColor: const Color(0xFFCDF7FF),
          name: 'Dr name goes here',
          date: '17/06/2025 | 04:37 AM',
        ),
        _buildInfoRow('Appointment date', 'Appointment date'),
        _buildInfoRow('Clinic / School details', 'Dr. Habib Al Ali'),
        _buildInfoRow('Address', 'Clinic address'),
      ],
    );
  }

  Widget _buildHistoryItem({
    required Color avatarColor,
    required String name,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: const Color(0xFFDCE0E4),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 16),
              ),
              const SizedBox(width: 8),
              Text(name),
            ],
          ),
          Text(
            date,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2E2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: const Color(0xFFDCE0E4),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF595A5B),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF2D2E2E),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Record details',
          style: TextStyle(
            color: const Color(0xFF747677),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow('Type', 'Pediatric - Regular checkup'),
        _buildInfoRow('Note', 'Patient has a history of hypertension...'),
      ],
    );
  }

  Widget _buildDrugsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Drugs details',
          style: TextStyle(
            color: const Color(0xFF747677),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 3 : 1,
                mainAxisExtent: 210,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 3,
              itemBuilder: (context, index) => _buildDrugCard(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDrugCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14000000),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Drug name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2E2E),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildDrugTag('Active ingredient'),
              _buildDrugTag('Oral'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'x2',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF595A5B),
                    ),),
                  Text(
                    'After Dinner',
                    style: TextStyle(
                      color: const Color(0xFF747677),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '4 days',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF595A5B),
                    ),),
                  Text(
                    'Every 24 hours',
                    style: TextStyle(
                      color: const Color(0xFF747677),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF1F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDateInfo('Starting date', '27/07/2025'),
                _buildDateInfo('End date', '31/07/2025'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF1F5),
        borderRadius: BorderRadius.circular(64),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF595A5B),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDateInfo(String title, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF747677),
            fontSize: 10,
          ),
        ),
        Text(
          date,
          style: TextStyle(
            color: const Color(0xFF1339FF),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments',
          style: TextStyle(
            color: const Color(0xFF747677),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: 4,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_getx_app/theme/app_typography.dart';

class TypographyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Typography'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildFontSection(context),
            const SizedBox(height: 32),
            _buildHeadingSection(context),
            const SizedBox(height: 32),
            _buildBodySection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF9500),
            Color(0xFFFFCC00),
          ],
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Typography',
            style: AppTypography.heading2.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The style guide provides to change stylistic for your design site.',
            style: AppTypography.bodyLargeRegular.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Degular Display',
                style: AppTypography.heading3,
              ),
              const SizedBox(height: 8),
              Text(
                'Download Font',
                style: AppTypography.bodySmallRegular.copyWith(
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildFontCard('Aa', 'Degular Display', 'Bold'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFontCard('Aa', 'Degular Display', 'Medium'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFontCard('Aa', 'Degular Display', 'Regular'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFontCard(String sample, String fontName, String weight) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sample,
            style: TextStyle(
              fontFamily: 'Degular',
              fontSize: 32,
              fontWeight: weight == 'Bold'
                  ? FontWeight.bold
                  : weight == 'Medium'
                      ? FontWeight.w500
                      : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fontName,
            style: AppTypography.bodySmallMedium,
          ),
          Text(
            weight,
            style: AppTypography.bodyXSmallRegular.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Heading',
          style: AppTypography.heading4,
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Heading 1',
                    style: AppTypography.heading1,
                  ),
                  Text(
                    'Heading 1 / Bold / 40px',
                    style: AppTypography.bodyXSmallRegular.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Heading 2',
                    style: AppTypography.heading2,
                  ),
                  Text(
                    'Heading 2 / Bold / 32px',
                    style: AppTypography.bodyXSmallRegular.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Heading 3',
                    style: AppTypography.heading3,
                  ),
                  Text(
                    'Heading 3 / Bold / 24px',
                    style: AppTypography.bodyXSmallRegular.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Heading 4',
                    style: AppTypography.heading4,
                  ),
                  Text(
                    'Heading 4 / Bold / 20px',
                    style: AppTypography.bodyXSmallRegular.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Heading 5',
                    style: AppTypography.heading5,
                  ),
                  Text(
                    'Heading 5 / Bold / 16px',
                    style: AppTypography.bodyXSmallRegular.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Heading 6',
                    style: AppTypography.heading6,
                  ),
                  Text(
                    'Heading 6 / Bold / 14px',
                    style: AppTypography.bodyXSmallRegular.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBodySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Body',
          style: AppTypography.heading4,
        ),
        const SizedBox(height: 24),
        _buildBodyTypeRow('Body Large', AppTypography.bodyLargeSemibold, AppTypography.bodyLargeMedium, AppTypography.bodyLargeRegular),
        const SizedBox(height: 24),
        _buildBodyTypeRow('Body Medium', AppTypography.bodyMediumSemibold, AppTypography.bodyMediumMedium, AppTypography.bodyMediumRegular),
        const SizedBox(height: 24),
        _buildBodyTypeRow('Body Small', AppTypography.bodySmallSemibold, AppTypography.bodySmallMedium, AppTypography.bodySmallRegular),
        const SizedBox(height: 24),
        _buildBodyTypeRow('Body XSmall', AppTypography.bodyXSmallSemibold, AppTypography.bodyXSmallMedium, AppTypography.bodyXSmallRegular),
        const SizedBox(height: 24),
        _buildBodyTypeRow('Body XXSmall', AppTypography.bodyXXSmallSemibold, AppTypography.bodyXXSmallMedium, AppTypography.bodyXXSmallRegular),
      ],
    );
  }

  Widget _buildBodyTypeRow(String title, TextStyle semibold, TextStyle medium, TextStyle regular) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodyMediumSemibold,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The quick brown fox jumps over the lazy dog',
                    style: semibold,
                  ),
                  Text(
                    '$title / Semibold / ${semibold.fontSize!.toInt()}px',
                    style: AppTypography.bodyXSmallRegular.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The quick brown fox jumps over the lazy dog',
                    style: medium,
                  ),
                  Text(
                    '$title / Medium / ${medium.fontSize!.toInt()}px',
                    style: AppTypography.bodyXSmallRegular.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The quick brown fox jumps over the lazy dog',
                    style: regular,
                  ),
                  Text(
                    '$title / Regular / ${regular.fontSize!.toInt()}px',
                    style: AppTypography.bodyXSmallRegular.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

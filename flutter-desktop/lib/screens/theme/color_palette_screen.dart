import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class ColorPaletteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Color Palette'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildColorSection(context, 'Info', AppTheme.colorPalette['info']!),
            const SizedBox(height: 32),
            _buildColorSection(context, 'Success', AppTheme.colorPalette['success']!),
            const SizedBox(height: 32),
            _buildColorSection(context, 'Danger', AppTheme.colorPalette['danger']!),
            const SizedBox(height: 32),
            _buildNeutralSection(context),
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
        color: AppTheme.colorPalette['info']!['main'],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Colors',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The style guide provides to change stylistic for your design site.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection(BuildContext context, String title, Map<String, Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(width: 8),
            Text(
              '6 colors',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildColorCard('Main', colors['main']!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildColorCard('Surface', colors['surface']!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildColorCard('Border', colors['border']!),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildColorCard('Hover', colors['hover']!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildColorCard('Pressed', colors['pressed']!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildColorCard('Focus', colors['focus']!),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNeutralSection(BuildContext context) {
    final neutralColors = AppTheme.colorPalette['neutral']!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Neutral',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(width: 8),
            Text(
              '10 colors',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildColorCard('10', neutralColors['10']!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildColorCard('20', neutralColors['20']!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildColorCard('30', neutralColors['30']!),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildColorCard('40', neutralColors['40']!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildColorCard('50', neutralColors['50']!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildColorCard('60', neutralColors['60']!),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildColorCard('70', neutralColors['70']!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildColorCard('80', neutralColors['80']!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildColorCard('90', neutralColors['90']!),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildColorCard('100', neutralColors['100']!),
      ],
    );
  }

  Widget _buildColorCard(String label, Color color) {
    final hexCode = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    final textColor = color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  hexCode,
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

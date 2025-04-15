import 'package:flutter/material.dart';

class RatingCategories extends StatelessWidget {
  final Map<String, dynamic> ratingData;

  const RatingCategories({Key? key, required this.ratingData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildRatingItem('EI', ratingData['emotionalIntelligence']),
        _buildRatingItem('V', ratingData['values']),
        _buildRatingItem('I', ratingData['intelligence']),
        _buildRatingItem('Vi', ratingData['vibe']),
        _buildRatingItem('C', ratingData['commitment']),
        _buildRatingItem('S', ratingData['stability']),
        _buildRatingItem('A', ratingData['attractiveness']),
      ],
    );
  }

  Widget _buildRatingItem(String label, double value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
// Performance optimizations
// Better error handling
// Code cleanup

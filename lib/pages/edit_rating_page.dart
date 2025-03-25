import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/rating_model.dart';

class EditRatingPage extends StatefulWidget {
  final String ratingId;
  final Map<String, dynamic> ratingData;
  final String ratedUserName;

  const EditRatingPage({
    Key? key,
    required this.ratingId,
    required this.ratingData,
    required this.ratedUserName,
  }) : super(key: key);

  @override
  State<EditRatingPage> createState() => _EditRatingPageState();
}

class _EditRatingPageState extends State<EditRatingPage> {
  late double _emotionalIntelligence;
  late double _values;
  late double _intelligence;
  late double _vibe;
  late double _commitment;
  late double _stability;
  late double _attractiveness;
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Initialize sliders with existing values
    _emotionalIntelligence = widget.ratingData['emotionalIntelligence'];
    _values = widget.ratingData['values'];
    _intelligence = widget.ratingData['intelligence'];
    _vibe = widget.ratingData['vibe'];
    _commitment = widget.ratingData['commitment'];
    _stability = widget.ratingData['stability'];
    _attractiveness = widget.ratingData['attractiveness'];
  }

  double get _overallRating {
    return _emotionalIntelligence +
        _values +
        _intelligence +
        _vibe +
        _commitment +
        _stability +
        _attractiveness;
  }

  Future<void> _updateRating() async {
    try {
      print('Creating rating with ID: ${widget.ratingId}'); // Debug print
      final rating = Rating(
        id: widget.ratingId,
        raterId: widget.ratingData['raterId'],
        ratedUserId: widget.ratingData['ratedUserId'],
        emotionalIntelligence: _emotionalIntelligence,
        values: _values,
        intelligence: _intelligence,
        vibe: _vibe,
        commitment: _commitment,
        stability: _stability,
        attractiveness: _attractiveness,
        timestamp: (widget.ratingData['timestamp'] as Timestamp).toDate(),
        likesCount: widget.ratingData['likesCount'] ?? 0,
        likedByUsers: List<String>.from(
          widget.ratingData['likedByUsers'] ?? [],
        ),
      );

      print('Calling updateRating with ID: ${widget.ratingId}'); // Debug print
      await _firestoreService.updateRating(widget.ratingId, rating);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error in _updateRating: $e'); // Debug print
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating rating: $e')));
      }
    }
  }

  Widget _buildSlider(
    String label,
    double value,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text(value.toStringAsFixed(1))],
        ),
        Slider(
          value: value,
          min: 0.0,
          max: max,
          divisions: (max * 10).toInt(),
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Rating for ${widget.ratedUserName}'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSlider(
              'Emotional Intelligence',
              _emotionalIntelligence,
              1.0,
              (value) => setState(() => _emotionalIntelligence = value),
            ),
            _buildSlider(
              'Values',
              _values,
              2.0,
              (value) => setState(() => _values = value),
            ),
            _buildSlider(
              'Intelligence',
              _intelligence,
              1.0,
              (value) => setState(() => _intelligence = value),
            ),
            _buildSlider(
              'Vibe',
              _vibe,
              1.0,
              (value) => setState(() => _vibe = value),
            ),
            _buildSlider(
              'Commitment',
              _commitment,
              1.0,
              (value) => setState(() => _commitment = value),
            ),
            _buildSlider(
              'Stability',
              _stability,
              1.0,
              (value) => setState(() => _stability = value),
            ),
            _buildSlider(
              'Attractiveness',
              _attractiveness,
              3.0,
              (value) => setState(() => _attractiveness = value),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Text(
                    'Overall Rating: ${_overallRating.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _updateRating,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text('Update Rating'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Performance improvements
// Better error handling
// Code optimization

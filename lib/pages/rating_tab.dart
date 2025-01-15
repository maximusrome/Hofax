import 'package:flutter/material.dart';
import '../models/rating_model.dart';
import '../services/rating_service.dart';
import '../auth.dart';
import '../utils/auth_utils.dart';

class RatingTab extends StatefulWidget {
  const RatingTab({Key? key}) : super(key: key);

  @override
  State<RatingTab> createState() => _RatingTabState();
}

class _RatingTabState extends State<RatingTab> {
  final RatingService _ratingService = RatingService();
  final _auth = AuthService();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedUserId;
  String? _selectedUserName;
  double _emotionalIntelligence = 0.5;
  double _values = 1.0;
  double _intelligence = 0.5;
  double _vibe = 0.5;
  double _commitment = 0.5;
  double _stability = 0.5;
  double _attractiveness = 1.5;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await _ratingService.searchUsers(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  Future<void> _submitRating() async {
    if (_selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please search and select a user to rate'),
          backgroundColor: Colors.purple,
        ),
      );
      return;
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      showSignInPrompt(
        context,
        message: 'You must be signed in to submit ratings',
      );
      return;
    }

    try {
      // Check if user has already rated this person
      final hasExistingRating = await _ratingService.hasExistingRating(
        currentUser.uid,
        _selectedUserId!,
      );

      if (hasExistingRating) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have already rated this user'),
              backgroundColor: Colors.purple,
            ),
          );
        }
        return;
      }

      final rating = Rating(
        raterId: currentUser.uid,
        ratedUserId: _selectedUserId!,
        emotionalIntelligence: _emotionalIntelligence,
        values: _values,
        intelligence: _intelligence,
        vibe: _vibe,
        commitment: _commitment,
        stability: _stability,
        attractiveness: _attractiveness,
      );

      await _ratingService.submitRating(rating);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating submitted successfully')),
        );
        // Reset form
        setState(() {
          _selectedUserId = null;
          _selectedUserName = null;
          _searchController.clear();
          _emotionalIntelligence = 0.5;
          _values = 1.0;
          _intelligence = 0.5;
          _vibe = 0.5;
          _commitment = 0.5;
          _stability = 0.5;
          _attractiveness = 1.5;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error submitting rating: $e')));
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search User',
              border: const OutlineInputBorder(),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                            _selectedUserId = null;
                            _selectedUserName = null;
                          });
                        },
                      )
                      : null,
            ),
            onChanged: _searchUsers,
          ),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_searchResults.isNotEmpty)
            Card(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  return ListTile(
                    title: Text(user['name']),
                    subtitle: Text(user['email']),
                    onTap: () {
                      setState(() {
                        _selectedUserId = user['id'];
                        _selectedUserName = user['name'];
                        _searchController.text = user['name'];
                        _searchResults = [];
                      });
                    },
                  );
                },
              ),
            ),
          if (_selectedUserName != null) ...[
            const SizedBox(height: 24),
            Text(
              'Rating for $_selectedUserName',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 24),
          Text(
            'Rating Categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
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
                  onPressed: _submitRating,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text('Submit Rating'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
}

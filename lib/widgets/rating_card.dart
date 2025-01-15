import 'package:flutter/material.dart';
import '../models/rating_model.dart';
import '../services/firestore_service.dart';
import '../pages/user_profile_page.dart';

class RatingCard extends StatelessWidget {
  final Rating rating;
  final bool showLikeButton;
  final VoidCallback? onLike;
  final bool isLiked;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const RatingCard({
    Key? key,
    required this.rating,
    this.showLikeButton = false,
    this.onLike,
    this.isLiked = false,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<Map<String, String>>(
                    future: _loadUserNames(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const LinearProgressIndicator();
                      }

                      return GestureDetector(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => UserProfilePage(
                                      userId: rating.ratedUserId,
                                      userName:
                                          snapshot.data!['ratedUserName'] ??
                                          'Unknown',
                                    ),
                              ),
                            ),
                        child: Text(
                          snapshot.data!['ratedUserName'] ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null || onDelete != null) ...[
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.purple),
                          onPressed: onEdit,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: onDelete,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                    ],
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          rating.likesCount.toString(),
                          style: TextStyle(
                            color: isLiked ? Colors.purple : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (showLikeButton)
                          IconButton(
                            onPressed: onLike,
                            icon: Icon(
                              Icons.thumb_up,
                              size: 16,
                              color: isLiked ? Colors.purple : Colors.grey[400],
                            ),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          )
                        else
                          Icon(
                            Icons.thumb_up,
                            size: 14,
                            color: isLiked ? Colors.purple : Colors.grey[400],
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRatingDetails(),
          ],
        ),
      ),
    );
  }

  Future<Map<String, String>> _loadUserNames() async {
    final firestoreService = FirestoreService();
    final raterName = await firestoreService.getUserName(rating.raterId);
    final ratedUserName = await firestoreService.getUserName(
      rating.ratedUserId,
    );
    return {'raterName': raterName, 'ratedUserName': ratedUserName};
  }

  Widget _buildRatingDetails() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.purple, size: 20),
              const SizedBox(width: 4),
              Text(
                'Overall: ${rating.overallRating.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRatingItem('EI', rating.emotionalIntelligence),
              _buildRatingItem('V', rating.values),
              _buildRatingItem('I', rating.intelligence),
              _buildRatingItem('Vi', rating.vibe),
              _buildRatingItem('C', rating.commitment),
              _buildRatingItem('S', rating.stability),
              _buildRatingItem('A', rating.attractiveness),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingItem(String label, double value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

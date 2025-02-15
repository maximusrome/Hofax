import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth.dart';
import 'user_profile_page.dart';
import '../utils/auth_utils.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({Key? key}) : super(key: key);

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final _auth = AuthService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleFollow(String userId, bool isFollowing) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      showSignInPrompt(
        context,
        message: 'You must be signed in to follow users',
      );
      return;
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final currentUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid);

    if (isFollowing) {
      // Unfollow
      await userRef.update({
        'followers': FieldValue.increment(-1),
        'followersList': FieldValue.arrayRemove([currentUser.uid]),
      });
      await currentUserRef.update({
        'following': FieldValue.arrayRemove([userId]),
      });
    } else {
      // Follow
      await userRef.update({
        'followers': FieldValue.increment(1),
        'followersList': FieldValue.arrayUnion([currentUser.uid]),
      });
      await currentUserRef.update({
        'following': FieldValue.arrayUnion([userId]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Users',
              border: const OutlineInputBorder(),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                      : null,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('users')
                    .orderBy('name')
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No users found'));
              }

              final currentUser = _auth.currentUser;
              final docs =
                  snapshot.data!.docs.where((doc) {
                    final userData = doc.data() as Map<String, dynamic>;
                    return userData['name'].toString().toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    );
                  }).toList();

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final userData = doc.data() as Map<String, dynamic>;
                  final isCurrentUser = doc.id == currentUser?.uid;
                  final isFollowing =
                      currentUser != null &&
                      (userData['followersList'] as List?)?.contains(
                            currentUser.uid,
                          ) ==
                          true;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  userData['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_outline,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${userData['ratingsReceived'] ?? 0} ratings',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.person_outline,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${userData['followers'] ?? 0} followers',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (!isCurrentUser) ...[
                            ElevatedButton(
                              onPressed:
                                  () => _toggleFollow(doc.id, isFollowing),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isFollowing
                                        ? Colors.grey[200]
                                        : Colors.purple,
                                foregroundColor:
                                    isFollowing ? Colors.purple : Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                minimumSize: const Size(0, 32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color:
                                        isFollowing
                                            ? Colors.purple
                                            : Colors.transparent,
                                  ),
                                ),
                              ),
                              child: Text(
                                isFollowing ? 'Following' : 'Follow',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                if (isCurrentUser || isFollowing) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => UserProfilePage(
                                            userId: doc.id,
                                            userName:
                                                userData['name'] ?? 'Unknown',
                                          ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Follow to view profile'),
                                      backgroundColor: Colors.purple,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.arrow_forward),
                              color: Colors.purple,
                              iconSize: 20,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minHeight: 32,
                                minWidth: 32,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
// User discovery improvements
// Better search functionality
// Profile optimization

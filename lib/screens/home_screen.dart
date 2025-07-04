import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _authService.updateUserStatus(true);
  }

  @override
  void dispose() {
    _authService.updateUserStatus(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Profile'),
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ),
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: () async {
                  await _authService.signOut();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getChatrooms(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No chats yet'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final chatroom = snapshot.data!.docs[index];
              final participants = List<String>.from(chatroom['participants']);
              final otherUserId = participants.firstWhere(
                  (id) => id != _authService.currentUser?.uid);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox();
                  }

                  final otherUser =
                      UserModel.fromMap(userSnapshot.data!.data() as Map<String, dynamic>);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: otherUser.photoUrl.isNotEmpty
                          ? NetworkImage(otherUser.photoUrl)
                          : null,
                      child: otherUser.photoUrl.isEmpty
                          ? Text(otherUser.name[0].toUpperCase())
                          : null,
                    ),
                    title: Text(otherUser.name),
                    subtitle: Text(
                      chatroom['lastMessage'] ?? 'No messages yet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _formatDateTime(chatroom['lastMessageTime']),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: otherUser,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/search'),
        child: const Icon(Icons.message),
      ),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final date = DateTime.parse(dateTime);
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
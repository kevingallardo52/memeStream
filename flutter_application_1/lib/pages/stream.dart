import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'chat_page.dart';

class Stream extends StatefulWidget {
  const Stream({super.key});

  @override
  State<Stream> createState() => _StreamState();
}

class _StreamState extends State<Stream> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: signOut,
          )
        ],
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        var filteredDocs = snapshot.data!.docs
            .where((doc) => _auth.currentUser!.email != doc['email'])
            .toList();
        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            var data = filteredDocs[index].data() as Map<String, dynamic>;
            return _buildUserListItem(data['email'], data['uid']);
          },
        );
      },
    );
  }

  Widget _buildUserListItem(String userEmail, String userId) {
    return ListTile(
      title: Text(userEmail),
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(userEmail[0].toUpperCase()),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverUserEmail: userEmail,
              receiverUserID: userId,
            ),
          ),
        );
      },
    );
  }
}

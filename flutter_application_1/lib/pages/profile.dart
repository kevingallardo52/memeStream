import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  // edit field
  Future<void> editField(String field) async {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Profile Page"),
          backgroundColor: Colors.blue,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(currentUser.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // get user data
              final userData = snapshot.data!.data() as Map<String, dynamic>;

              return ListView(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  // profile pic
                  const Icon(
                    Icons.person,
                    size: 72,
                  ),

                  //user email
                  Text(
                    currentUser.email!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // user details
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      'My Details',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),

                  // username
                  MyTextBox(
                    text: userData['username'],
                    sectionName: 'username',
                    onPressed: () => editField('username'),
                  ),

                  //bio
                  // username
                  MyTextBox(
                    text: 'No bio',
                    sectionName: 'bio',
                    onPressed: () => editField('bio'),
                  ),

                  const SizedBox(
                    height: 50,
                  ),

                  // user posts
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      'My Posts',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error${snapshot.error}'),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }
}

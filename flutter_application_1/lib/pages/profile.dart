import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/text_box.dart';
import 'package:flutter_application_1/resources/add_data.dart';
import 'package:flutter_application_1/utils.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  // all users
  final userCollection = FirebaseFirestore.instance.collection('Users');

  Uint8List? _image;

  get email => null;

  get password => null;

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  void saveImage() async {
    await StoreData().saveData(
        file: _image!, name: DateTime.now().millisecondsSinceEpoch.toString());

    setState(() {
      _image = null;
    });
  }

  // Edit field
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit " + field),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          // cancel button
          TextButton(
            child: Text(
              'Cancel',
            ),
            onPressed: () => Navigator.pop(context),
          ),

          // Save button
          TextButton(
            child: Text(
              'Save',
            ),
            onPressed: () => Navigator.of(context).pop(newValue),
          ),
        ],
      ),
    );

    //update in firestore

    if (newValue.trim().length > 0) {
      await userCollection.doc(currentUser.uid).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Check if document data is not null before casting
            final userData =
                snapshot.data?.data() as Map<String, dynamic>? ?? {};

            return ListView(
              children: [
                const SizedBox(height: 50),
                Center(
                  child: Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage: MemoryImage(_image!),
                            )
                          : CircleAvatar(
                              radius: 64,
                              backgroundImage:
                                  NetworkImage(userData['imageLink']),
                            ),
                      Positioned(
                          bottom: -15,
                          left: 92,
                          child: IconButton(
                            onPressed: () {
                              selectImage();
                            },
                            icon: const Icon(
                              Icons.add_a_photo,
                              color: Colors.black,
                            ),
                          )),
                    ],
                  ),
                ),
                Text(
                  currentUser.email ?? "No email",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: saveImage, child: Text("Save Profile Image")),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Details',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                MyTextBox(
                  text: userData['username'] ?? 'No username',
                  sectionName: 'username',
                  onPressed: () => editField('username'),
                ),
                MyTextBox(
                  text: userData['bio'] ?? 'No bio',
                  sectionName: 'bio',
                  onPressed: () => editField('bio'),
                ),
                const SizedBox(height: 50),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

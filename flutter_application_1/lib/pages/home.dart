import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/components/my_text_field.dart';
import 'package:flutter_application_1/components/post.dart';

import 'package:flutter_application_1/helper/helper_methods.dart';
import 'package:flutter_application_1/resources/add_post_image.dart';
import 'package:flutter_application_1/utils.dart';

import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// get current user
  final currentUser = FirebaseAuth.instance.currentUser!;

//text controller
  final textController = TextEditingController();

  String URL = "";

  Uint8List? _image;

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  Future<void> saveImage() async {
    if (_image != null) {
      URL = await StoreImage().saveData(
          file: _image!,
          name: DateTime.now().millisecondsSinceEpoch.toString());
    } else {
      URL = '';
    }
    setState(() {
      _image = null;
    });
  }

//sign out
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

// post message
  Future<void> postMessage() async {
    saveImage();
    // do not post empty string
    if (textController.text.isNotEmpty) {
      // store in firebase
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
        "imageURL": URL,
      });
    }

    //clear textfield
    setState(() {
      textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("meme Stream"),
        actions: [
          //sign out button
          IconButton(onPressed: signOut, icon: Icon(Icons.logout)),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            // meme stream
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy(
                      "TimeStamp",
                      descending: false,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        // get the message
                        final post = snapshot.data!.docs[index];
                        return Post(
                          imageURL: post['imageURL'],
                          message: post['Message'],
                          user: post['UserEmail'],
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                          time: formatDate(post['TimeStamp']),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error:${snapshot.error}'),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),

            //  post
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // textfield
                  Expanded(
                    child: MyTextField(
                      controller: textController,
                      hintText: 'Post to the memeStream...',
                      obscureText: false,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        selectImage();
                      },
                      icon: const Icon(CupertinoIcons.camera)),
                  //post button
                  IconButton(
                      onPressed: postMessage,
                      icon: const Icon(CupertinoIcons.add_circled_solid))
                ],
              ),
            ),

            // logged in as
            Text(
              "Logged in as: " + currentUser.email!,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}

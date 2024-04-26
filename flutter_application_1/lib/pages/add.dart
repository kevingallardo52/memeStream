import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/components/my_text_field.dart';
import 'package:flutter_application_1/components/post.dart';
import 'package:flutter_application_1/helper/helper_methods.dart';

class Add extends StatefulWidget {
  const Add({super.key});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
// get current user
  final currentUser = FirebaseAuth.instance.currentUser!;

//text controller
  final textController = TextEditingController();

//sign out
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

// post message
  void postMessage() {
    // do not post empty string
    if (textController.text.isNotEmpty) {
      // store in firebase
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
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
        title: Text("Your MemeStream Contributions"),
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
                    .where("UserEmail", isEqualTo: currentUser.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        // get the message
                        final post = snapshot.data!.docs[index];
                        return Post(
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

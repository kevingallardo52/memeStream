import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/comment.dart';
import 'package:flutter_application_1/components/comment_button.dart';
import 'package:flutter_application_1/components/like_button.dart';
import 'package:flutter_application_1/helper/helper_methods.dart';

class Post extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  const Post({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  // toggle likes
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    // get firebase doc
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);
    if (isLiked) {
      // if the post it liked, add the current user email to 'likes' field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      // if the post it unliked, remove the current user email to 'likes' field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  // add a comment
  void addComment(String CommentText) {
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": CommentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now(),
    });
  }

  // show a dialog box for adding a comment
  void showCommentDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Add Comment"),
              content: TextField(
                controller: _commentTextController,
                decoration: InputDecoration(hintText: "Write a comment..."),
              ),
              actions: [
                // cancel button
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // cleat text box
                    _commentTextController.clear();
                  },
                  child: Text("Cancel"),
                ),
                // post button
                TextButton(
                  onPressed: () {
                    addComment(_commentTextController.text);

                    Navigator.pop(context);

                    //clear text Box
                    _commentTextController.clear();
                  },
                  child: Text("Post"),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // post
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //message
              Text(widget.message),

              const SizedBox(
                height: 5,
              ),

              // user
              Row(
                children: [
                  Text(
                    widget.user,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  Text(
                    " . ",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  Text(
                    widget.time,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(
            width: 20,
          ),

          // buttons

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  // like button
                  LikeButton(
                    isLiked: isLiked,
                    onTap: toggleLike,
                  ),

                  // like count
                  Text(
                    widget.likes.length.toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                children: [
                  // comment button
                  CommentButton(onTap: showCommentDialog),

                  // comment count
                  Text(
                    '0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          // disply comments
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .collection("Comments")
                .orderBy("CommentTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              // loading circle
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView(
                shrinkWrap: true, //for nested lists
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  //get the comment
                  final commentData = doc.data() as Map<String, dynamic>;

                  // return the comment
                  return Comment(
                    text: commentData["CommentText"],
                    user: commentData["CommentedBy"],
                    time: formatDate(commentData["CommentTime"]),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}

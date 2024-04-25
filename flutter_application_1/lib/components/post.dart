import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/like_button.dart';

class Post extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;
  const Post({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Row(
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
            width: 20,
          ),
          // user and message
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user,
                style: TextStyle(color: Colors.grey[500]),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(widget.message),
            ],
          )
        ],
      ),
    );
  }
}

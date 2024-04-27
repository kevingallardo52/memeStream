import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "dart:typed_data";
import "package:firebase_storage/firebase_storage.dart";

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final currentUser = FirebaseAuth.instance.currentUser!;

class StoreImage {
  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref = _storage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> saveData({
    required Uint8List file,
    required String name,
  }) async {
    String resp = "Some Error";
    try {
      String imageUrl = await uploadImageToStorage("postImage" + name, file);
      //userCollection.doc(currentUser.email).update({field: newValue});
      resp = imageUrl;
    } catch (err) {
      resp = err.toString();
    }
    return resp;
  }
}

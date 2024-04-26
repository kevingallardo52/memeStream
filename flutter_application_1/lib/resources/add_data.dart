import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "dart:typed_data";
import "package:firebase_storage/firebase_storage.dart";

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final currentUser = FirebaseAuth.instance.currentUser!;

class StoreData {
  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref = _storage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> saveData({
    required Uint8List file,
  }) async {
    String resp = "Some Error";
    try {
      String imageUrl = await uploadImageToStorage("profileImage", file);
      await _firestore.collection("Users").doc(currentUser.uid).update({
        'imageLink': imageUrl,
      });
      //userCollection.doc(currentUser.email).update({field: newValue});
      resp = "success";
    } catch (err) {
      resp = err.toString();
    }
    return resp;
  }
}

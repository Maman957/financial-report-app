import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<String> getUserName() async {
    final String userEmail = await _firebaseAuth.currentUser!.email!;

    try {
      final QuerySnapshot userDocs = await _firebaseFirestore
          .collection("users")
          .where('email', isEqualTo: userEmail)
          .get();

      if (userDocs.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = userDocs.docs.first;

        String userName = documentSnapshot['name'];

        return userName;
      } else {
        return 'field does not exist in the document';
      }
    } catch (error) {
      return 'Error getting user name : $error';
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

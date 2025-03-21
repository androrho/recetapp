import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  void addUser() {
    String displayName = "Administrator";
    String login = "admin";
    String password = "admin1234";
    FirebaseFirestore db = FirebaseFirestore.instance;
    final user = <String, dynamic>{
      "display_name":displayName,
      "login":login,
      "password":password
    };

    db.collection("users").add(user).then((DocumentReference doc) =>
        print('DocumentSnapshot added with ID: ${doc.id}'));
  }
}
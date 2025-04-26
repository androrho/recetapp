import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:recetapp/model/user.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'users';

  Future<void> create(User object) async {
    final collection = FirebaseFirestore.instance.collection(_collection);
    final docRef = collection.doc();
    final newObject = object.copyWith(id: docRef.id);
    await docRef.set(newObject.toJson());
  }

  Stream<List<User>> watchAll() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return User.fromJson(data);
      }).toList();
    });
  }

  Stream<User> watchById(String id) {
    return _db.collection(_collection).doc(id).snapshots().map((docSnap) {
      if (docSnap.exists) {
        final data = docSnap.data()!;
        data['id'] = docSnap.id;
        return User.fromJson(data);
      }
      // Si no existe, devolvemos un placeholder
      return User(id: id, displayName: "n/a", login: "", password: "");
    });
  }

  @deprecated
  Future<List<User>> read() async {
    final snapshot = await _db.collection(_collection).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return User.fromJson(data);
    }).toList();
  }

  @deprecated
  Future<User?> readById(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return User.fromJson(data);
    }
    return User(id: "0", displayName: "n/a", login: "", password: "");
  }

  Future<void> update(String id, User object) async {
    await _db.collection(_collection).doc(id).update(object.toJson());
  }

  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/user.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'users';

  Future<void> create(User user) async {
    final collection = FirebaseFirestore.instance.collection(_collection);
    // Utilizamos el método toJson que internamente llama a _$UserToJson
    await _db.collection(_collection).add(user.toJson());
  }

  Stream<List<User>> read() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Si necesitas guardar el ID del documento en tu modelo, lo asignas aquí
        data['id'] = doc.id;
        return User.fromJson(data);
      }).toList();
    });
  }

  Future<User?> readById(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return User.fromJson(data);
    }
    return null;
  }

  Future<void> update(String id, User object) async {
    await _db.collection(_collection).doc(id).update(object.toJson());
  }

  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
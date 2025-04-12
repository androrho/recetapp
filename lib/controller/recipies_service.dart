import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:recetapp/model/recipie.dart';

class RecipiesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'recipies';

  Future<String> create(Recipie object) async {
    final collection = FirebaseFirestore.instance.collection(_collection);
    final docRef = collection.doc();
    final newObject = object.copyWith(id: docRef.id);
    await docRef.set(newObject.toJson());
    return docRef.id;
  }

  Future<List<Recipie>> read() async {
    final snapshot = await _db.collection(_collection).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Recipie.fromJson(data);
    }).toList();
  }

  Future<Recipie> readById(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return Recipie.fromJson(data);
    }
    return Recipie(
      id: "0",
      description: "n/a",
      personNumber: 0,
      title: "n/a",
      user: "0",
    );
  }

  Future<void> update(String id, Recipie object) async {
    await _db.collection(_collection).doc(id).update(object.toJson());
  }

  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/photo.dart';

class PhotosService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'photos';

  Future<void> create(Photo object) async {
    final collection = FirebaseFirestore.instance.collection(_collection);
    final docRef = collection.doc();
    final newObject = object.copyWith(id: docRef.id);
    await docRef.set(newObject.toJson());
  }

  Future<List<Photo>> read() async {
    final snapshot = await _db.collection(_collection).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Photo.fromJson(data);
    }).toList();
  }

  Future<Photo?> readById(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return Photo.fromJson(data);
    }
    return Photo(id: "0", path: "null", position: 0, recipie: "0");
  }

  Future<void> update(String id, Photo object) async {
    await _db.collection(_collection).doc(id).update(object.toJson());
  }

  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}

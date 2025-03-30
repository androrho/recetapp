import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/photo.dart';

class PhotosService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'photos';

  Future<void> create(Photo object) async {
    // Utilizamos el método toJson que internamente llama a _$UserToJson
    await _db.collection(_collection).add(object.toJson());
  }

  Stream<List<Photo>> read() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Si necesitas guardar el ID del documento en tu modelo, lo asignas aquí
        data['id'] = doc.id;
        return Photo.fromJson(data);
      }).toList();
    });
  }

  Future<Photo?> readById(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return Photo.fromJson(data);
    }
    return null;
  }

  Future<void> update(String id, Photo object) async {
    await _db.collection(_collection).doc(id).update(object.toJson());
  }

  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
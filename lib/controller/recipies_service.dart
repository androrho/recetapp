import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/recipie.dart';

class RecipiesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'recipies';

  Future<void> create(Recipie object) async {
    // Utilizamos el método toJson que internamente llama a _$UserToJson
    await _db.collection(_collection).add(object.toJson());
  }

  Stream<List<Recipie>> read() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Si necesitas guardar el ID del documento en tu modelo, lo asignas aquí
        data['id'] = doc.id;
        return Recipie.fromJson(data);
      }).toList();
    });
  }

  Future<Recipie?> readById(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return Recipie.fromJson(data);
    }
    return null;
  }

  Future<void> update(String id, Recipie object) async {
    await _db.collection(_collection).doc(id).update(object.toJson());
  }

  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
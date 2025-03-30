import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/step.dart';

class StepsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'steps';

  Future<void> create(Step object) async {
    final collection = FirebaseFirestore.instance.collection(_collection);
    final docRef = collection.doc();
    final newObject = object.copyWith(id: docRef.id);
    await docRef.set(newObject.toJson());
  }

  Stream<List<Step>> read() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Si necesitas guardar el ID del documento en tu modelo, lo asignas aquí
        data['id'] = doc.id;
        return Step.fromJson(data);
      }).toList();
    });
  }

  Future<Step?> readById(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return Step.fromJson(data);
    }
    return null;
  }

  Future<void> update(String id, Step object) async {
    await _db.collection(_collection).doc(id).update(object.toJson());
  }

  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
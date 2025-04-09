import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:recetapp/model/step.dart';

class StepsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'steps';

  Future<void> create(Step object) async {
    final collection = FirebaseFirestore.instance.collection(_collection);
    final docRef = collection.doc();
    final newObject = object.copyWith(id: docRef.id);
    await docRef.set(newObject.toJson());
  }

  Future<List<Step>> read() async {
    final snapshot = await _db.collection(_collection).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Step.fromJson(data);
    }).toList();
  }

  Future<Step> readById(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return Step.fromJson(data);
    }
    return Step(id: "0", position: 0, recipie: "0", text: "n/a");
  }

  Future<void> update(String id, Step object) async {
    await _db.collection(_collection).doc(id).update(object.toJson());
  }

  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}

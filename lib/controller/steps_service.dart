import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/step.dart';

/// A simple service to manage steps in Firestore.
/// You can add new steps, listen to changes, update, or delete them.
class StepsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'steps';

  /// Adds a new [object] to the steps collection.
  Future<void> create(Step object) async {
    final collection = _db.collection(_collection);
    final docRef = collection.doc();
    final newObject = object.copyWith(id: docRef.id);
    await docRef.set(newObject.toJson());
  }

  /// Watches all steps, ordered by their position.
  Stream<List<Step>> watchAll() {
    return _db
        .collection(_collection)
        .orderBy('position')
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
      final data = doc.data()..['id'] = doc.id;
      return Step.fromJson(data);
    }).toList());
  }

  /// Watches a single step by [id] and returns updates in a stream.
  Stream<Step> watchById(String id) {
    return _db.collection(_collection).doc(id).snapshots().map((docSnap) {
      final data = docSnap.data()!..['id'] = docSnap.id;
      return Step.fromJson(data);
    });
  }

  /// Watches steps for a specific recipe, ordered by position.
  Stream<List<Step>> watchByRecipe(String recipeId) {
    return _db
        .collection(_collection)
        .where('recipe', isEqualTo: recipeId)
        .orderBy('position')
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
      final data = doc.data()..['id'] = doc.id;
      return Step.fromJson(data);
    }).toList());
  }

  /// Updates the step document with [id] using values from [object].
  Future<void> update(String id, Step object) async {
    await _db.collection(_collection).doc(id).update(object.toJson());
  }

  /// Deletes the step document with the given [id].
  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}


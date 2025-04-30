import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/ingredient.dart';

/// A simple service to manage ingredients in Firestore.
/// You can add, watch, update, or delete ingredient records.
class IngredientsService {
  /// Firestore instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Name of the Firestore collection for ingredients
  final String _collection = 'ingredients';

  /// Adds a new [object] to the ingredients collection.
  Future<void> create(Ingredient object) async {
    final collection = _db.collection(_collection);
    final docRef = collection.doc();
    final newObject = object.copyWith(id: docRef.id);
    await docRef.set(newObject.toJson());
  }

  /// Watches all ingredients and returns a stream of lists.
  Stream<List<Ingredient>> watchAll() {
    return _db
        .collection(_collection)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
      final data = doc.data()..['id'] = doc.id;
      return Ingredient.fromJson(data);
    }).toList());
  }

  /// Watches a single ingredient by its [id] and returns a stream.
  Stream<Ingredient> watchById(String id) {
    return _db.collection(_collection).doc(id).snapshots().map((docSnap) {
      final data = docSnap.data()!..['id'] = docSnap.id;
      return Ingredient.fromJson(data);
    });
  }

  /// Watches ingredients that belong to a specific recipe.
  /// Use [recipeId] to filter the ingredients stream.
  Stream<List<Ingredient>> watchByRecipe(String recipeId) {
    return _db
        .collection(_collection)
        .where('recipe', isEqualTo: recipeId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
      final data = doc.data()..['id'] = doc.id;
      return Ingredient.fromJson(data);
    }).toList());
  }

  /// Updates the ingredient with [id] using data from [object].
  Future<void> update(String id, Ingredient object) async {
    await _db.collection(_collection).doc(id).update(object.toJson());
  }

  /// Deletes the ingredient document with the given [id].
  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}

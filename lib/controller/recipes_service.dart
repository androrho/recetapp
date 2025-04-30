import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/recipe.dart';

/// A simple service to work with recipes in Firestore.
/// You can add new recipes, listen to changes, update or delete them.
class RecipesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'recipes';

  /// Creates a new recipe in Firestore.
  /// Returns the generated document ID.
  Future<String> create(Recipe object) async {
    final collection = _db.collection(_collection);
    final docRef = collection.doc();
    final newObject = object.copyWith(id: docRef.id);
    await docRef.set(newObject.toJson());
    return docRef.id;
  }

  /// Returns a stream of all recipes.
  Stream<List<Recipe>> watchAll() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Recipe.fromJson(data);
      }).toList();
    });
  }

  /// Returns a stream of recipes created by the given user.
  Stream<List<Recipe>> watchByUser(String userId) {
    return _db
        .collection(_collection)
        .where('user', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Recipe.fromJson(data);
      }).toList();
    });
  }

  /// Returns a stream of a single recipe by its ID.
  /// If the document does not exist, returns an empty Recipe object.
  Stream<Recipe> watchById(String id) {
    return _db.collection(_collection).doc(id).snapshots().map((docSnap) {
      if (docSnap.exists) {
        final data = docSnap.data()!;
        data['id'] = docSnap.id;
        return Recipe.fromJson(data);
      }
      // fallback if not found
      return Recipe(
        id: id,
        title: '',
        description: '',
        personNumber: 0,
        user: '',
      );
    });
  }

  /// Updates the recipe with the given ID using the data in [object].
  Future<void> update(String id, Recipe object) async {
    await _db.collection(_collection).doc(id).update(object.toJson());
  }

  /// Deletes the recipe document with the given ID.
  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}

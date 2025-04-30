import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/recipe.dart';

class RecipesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'recipes';

  Future<String> create(Recipe object) async {
    final collection = FirebaseFirestore.instance.collection(_collection);
    final docRef = collection.doc();
    final newObject = object.copyWith(id: docRef.id);
    await docRef.set(newObject.toJson());
    return docRef.id;
  }

  Stream<List<Recipe>> watchAll() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Recipe.fromJson(data);
      }).toList();
    });
  }

  Stream<List<Recipe>> watchByUser(String userId) {
    return _db
        .collection(_collection)
        .where('user', isEqualTo: userId) // Filtramos por campo `user`
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Recipe.fromJson(data);
          }).toList();
        });
  }

  Stream<Recipe> watchById(String id) {
    return _db.collection(_collection).doc(id).snapshots().map((docSnap) {
      if (docSnap.exists) {
        final data = docSnap.data()!;
        data['id'] = docSnap.id;
        return Recipe.fromJson(data);
      }
      return Recipe(
        id: id,
        title: '',
        description: '',
        personNumber: 0,
        user: '',
      );
    });
  }

  Future<void> update(String id, Recipe object) async {
    await _db.collection(_collection).doc(id).update(object.toJson());
  }

  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}

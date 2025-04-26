import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:recetapp/model/ingredient.dart';

class IngredientsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'ingredients';

  Future<void> create(Ingredient object) async {
    final collection = FirebaseFirestore.instance.collection(_collection);
    final docRef = collection.doc();
    final newObject = object.copyWith(id: docRef.id);
    await docRef.set(newObject.toJson());
  }

  Stream<List<Ingredient>> watchAll() {
    return _db
        .collection(_collection)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
      final data = doc.data()..['id'] = doc.id;
      return Ingredient.fromJson(data);
    }).toList());
  }

  Stream<Ingredient> watchById(String id) {
    return _db
        .collection(_collection)
        .doc(id)
        .snapshots()
        .map((docSnap) {
      final data = docSnap.data()!..['id'] = docSnap.id;
      return Ingredient.fromJson(data);
    });
  }

  Stream<List<Ingredient>> watchByRecipe(String recipeId) {
    return _db
        .collection(_collection)
        .where('recipie', isEqualTo: recipeId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
      final data = doc.data()..['id'] = doc.id;
      return Ingredient.fromJson(data);
    }).toList());
  }

  @deprecated
  Future<List<Ingredient>> read() async {
    final snapshot = await _db.collection(_collection).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Ingredient.fromJson(data);
    }).toList();
  }

  @deprecated
  Future<Ingredient?> readById(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return Ingredient.fromJson(data);
    }
    return Ingredient(
      id: "0",
      name: "n/a",
      quantity: 0,
      quantityType: "n/a",
      recipie: "0",
    );
  }

  Future<void> update(String id, Ingredient object) async {
    await _db.collection(_collection).doc(id).update(object.toJson());
  }

  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}

import 'package:flutter/material.dart';

/// A simple class to hold the text controllers for one ingredient row.
/// It has three controllers:
///  - [ingredientController] for the ingredient name,
///  - [quantityController] for the amount,
///  - [unitTypeController] for the unit type.
class ListIngredientItem {
  final TextEditingController ingredientController;
  final TextEditingController quantityController;
  final TextEditingController unitTypeController;

  ListIngredientItem({
    required this.ingredientController,
    required this.quantityController,
    required this.unitTypeController,
  });
}

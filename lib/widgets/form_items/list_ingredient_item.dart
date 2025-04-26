import 'package:flutter/cupertino.dart';

/// Clase auxiliar para cada ingrediente.
/// Cada elemento tendrá tres controladores: para el nombre, la cantidad y el tipo de unidad.
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
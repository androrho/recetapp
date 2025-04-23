import 'package:flutter/material.dart';

class RecipieDetailScreen extends StatelessWidget {
  final String recipeId;

  const RecipieDetailScreen({
    Key? key,
    required this.recipeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Receta'),
      ),
      body: Center(
        child: Text(
          'ID de la receta: $recipeId'
        ),
      ),
    );
  }
}
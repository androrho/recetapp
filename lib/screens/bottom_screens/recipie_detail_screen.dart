import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;

  const RecipeDetailScreen({
    Key? key,
    required this.recipeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Receta'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              // Por ahora no hacemos nada,
              // puedes usar un switch(value) para futuras acciones
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Editar'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Eliminar'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Text(
          'ID de la receta: $recipeId'
        ),
      ),
    );
  }
}
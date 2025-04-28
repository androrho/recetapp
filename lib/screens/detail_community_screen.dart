import 'package:flutter/material.dart';
import 'package:recetapp/screens/recipie_detail.dart';

import '../controller/auth_service.dart';
import '../controller/recipes_service.dart';
import '../model/recipe.dart';

class DetailCommunityScreen extends StatelessWidget {
  final String recipeId;

  const DetailCommunityScreen({Key? key, required this.recipeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService().currentUserId;

    return StreamBuilder<Recipe>(
      stream: RecipesService().watchById(recipeId),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.active) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snap.error}')),
          );
        }
        final recipe = snap.data!;
        final isMine = recipe.user == currentUserId;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalle de Receta'),
            actions: isMine
                ? null
                : [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                onSelected: (value) {
                  if (value == 'save') {
                    // TODO: implementar guardado
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Receta guardada')),
                    );
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'save', child: Text('Guardar')),
                ],
              ),
            ],
          ),
          body: RecipeDetailScreen(recipeId: recipeId),
        );
      },
    );
  }
}
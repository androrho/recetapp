import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recetapp/screens/recipie_detail.dart';

import '../controller/auth_service.dart';
import '../controller/ingredients_service.dart';
import '../controller/recipes_service.dart';
import '../controller/steps_service.dart';
import '../model/ingredient.dart';
import '../model/recipe.dart';
import '../model/step.dart' as appStep;

class DetailCommunityScreen extends StatelessWidget {
  final String recipeId;

  const DetailCommunityScreen({Key? key, required this.recipeId})
      : super(key: key);

  Future<void> _copyRecipe(BuildContext context, Recipe recipe) async {
    final currentUserId = AuthService().currentUserId;
    if (currentUserId == null) {
      Fluttertoast.showToast(msg: 'Debes iniciar sesión para guardar');
      return;
    }
    try {
      // Creates new recipe for the logged user
      final newRecipe = Recipe(
        title: recipe.title,
        description: recipe.description,
        personNumber: recipe.personNumber,
        user: currentUserId,
      );
      final newRecipeId = await RecipesService().create(newRecipe);

      // Copy ingredients to new recipe
      final ingSvc = IngredientsService();
      final ingredients =
      await ingSvc.watchByRecipe(recipeId).first;
      for (final i in ingredients) {
        await ingSvc.create(
          Ingredient(
            name: i.name,
            quantity: i.quantity,
            quantityType: i.quantityType,
            recipe: newRecipeId,
          ),
        );
      }

      // Copy steps to new Recipe
      final stepSvc = StepsService();
      final steps = await stepSvc.watchByRecipe(recipeId).first;
      for (final s in steps) {
        await stepSvc.create(
          appStep.Step(
            position: s.position,
            recipe: newRecipeId,
            text: s.text,
          ),
        );
      }

      Fluttertoast.showToast(msg: "Receta guardada en Mis Recetas");
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error al guardar: $e');
    }
  }

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
                    _copyRecipe(context, recipe);
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
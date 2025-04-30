import 'package:flutter/material.dart';
import 'package:recetapp/screens/recipie_detail.dart';

import '../controller/ingredients_service.dart';
import '../controller/recipes_service.dart';
import '../controller/steps_service.dart';
import 'edit_recipe_screen.dart';

/// Screen that shows the details of one of the user’s own recipes.
///
/// - Displays the recipe content via [RecipeDetailScreen].
/// - Has a menu in the app bar to Edit or Delete the recipe.
class DetailMyRecipesScreen extends StatelessWidget {
  final String recipeId;

  const DetailMyRecipesScreen({Key? key, required this.recipeId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Receta'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditRecipieScreen(recipeId: recipeId),
                    ),
                  );
                  break;
                case 'delete':
                // Ask the user to confirm deletion
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('¿Eliminar receta?'),
                      content: const Text(
                          'Se eliminará la receta y todos sus datos.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                  if (confirm != true) return;

                  // Delete all ingredients for this recipe
                  final ingSvc = IngredientsService();
                  final ingredients =
                  await ingSvc.watchByRecipe(recipeId).first;
                  await Future.wait(
                      ingredients.map((i) => ingSvc.delete(i.id!)));

                  // Delete all steps for this recipe
                  final stepSvc = StepsService();
                  final steps = await stepSvc.watchByRecipe(recipeId).first;
                  await Future.wait(steps.map((s) => stepSvc.delete(s.id!)));

                  // Delete the recipe document
                  await RecipesService().delete(recipeId);

                  // Go back to the previous screen
                  Navigator.pop(context);
                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'delete', child: Text('Eliminar')),
            ],
          ),
        ],
      ),

      /// Displays the recipe details (title, description, ingredients, steps).
      body: RecipeDetailScreen(recipeId: recipeId),
    );
  }
}
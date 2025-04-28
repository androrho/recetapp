import 'package:flutter/material.dart';
import 'package:recetapp/screens/recipie_detail.dart';

import '../controller/ingredients_service.dart';
import '../controller/recipes_service.dart';
import '../controller/steps_service.dart';
import 'edit_recipe_screen.dart';

class DetailMyRecipesScreen extends StatelessWidget {
  final String recipeId;

  const DetailMyRecipesScreen({Key? key, required this.recipeId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double horizontalPadding = isLandscape ? 50.0 : 45.0;

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
                      builder: (_) => EditRecipieScreen(recipeId: recipeId),
                    ),
                  );
                  break;
                case 'delete':
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                      title: const Text('¿Eliminar receta?'),
                      content: const Text(
                        'Se eliminará la receta y todos sus datos.',
                      ),
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

                  // 1) Borrar todos los ingredientes de esta receta
                  final ingSvc = IngredientsService();
                  final ingredients = await ingSvc.watchByRecipe(recipeId).first;
                  await Future.wait(ingredients.map((i) => ingSvc.delete(i.id!)));

                  // 2) Borrar todos los pasos de esta receta
                  final stepSvc = StepsService();
                  final steps = await stepSvc.watchByRecipe(recipeId).first;
                  await Future.wait(steps.map((s) => stepSvc.delete(s.id!)));

                  // 3) Borrar la propia receta
                  await RecipesService().delete(recipeId);

                  // 4) Volver atrás (cierra detalle)
                  Navigator.pop(context);
                  break;
              }
            },
            itemBuilder:
                (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'delete', child: Text('Eliminar')),
            ],
          ),
        ],
      ),
      body: RecipeDetailScreen(recipeId: recipeId),
    );
  }
}
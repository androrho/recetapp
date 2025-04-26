import 'package:flutter/material.dart';
import '../../controller/recipes_service.dart';
import '../../model/ingredient.dart';
import 'package:recetapp/model/step.dart' as appStep;
import '../../controller/ingredients_service.dart';
import '../../controller/steps_service.dart';
import '../../model/recipe.dart';
import 'edit_recipe_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;

  const RecipeDetailScreen({Key? key, required this.recipeId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Márgenes iguales a AddRecipieScreen
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
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: StreamBuilder<Recipe>(
                stream: RecipesService().watchById(recipeId),
                builder: (ctxRec, snapRec) {
                  if (snapRec.connectionState != ConnectionState.active) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapRec.hasError) {
                    return Center(
                      child: Text('Error receta: ${snapRec.error}'),
                    );
                  }
                  final recipe = snapRec.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título
                      Text(
                        recipe.title ?? '',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),

                      // Descripción
                      Text(
                        recipe.description ?? '',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),

                      // 2) INGREDIENTES
                      Text(
                        'Ingredientes',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<List<Ingredient>>(
                        stream: IngredientsService().watchByRecipe(recipeId),
                        builder: (ctxIng, snapIng) {
                          if (snapIng.connectionState !=
                              ConnectionState.active) {
                            return const SizedBox();
                          }
                          if (snapIng.hasError) {
                            return Text('Error ingredientes: ${snapIng.error}');
                          }
                          final ingredients = snapIng.data!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                ingredients.map((i) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text(
                                      '• ${i.name} — ${i.quantity} ${i.quantityType}',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  );
                                }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // 3) PASOS
                      Text(
                        'Pasos',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<List<appStep.Step>>(
                        stream: StepsService().watchByRecipe(recipeId),
                        builder: (ctxSt, snapSt) {
                          if (snapSt.connectionState !=
                              ConnectionState.active) {
                            return const SizedBox();
                          }
                          if (snapSt.hasError) {
                            return Text('Error pasos: ${snapSt.error}');
                          }
                          final steps = snapSt.data!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                steps.map((s) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text(
                                      '${s.position}. ${s.text}',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  );
                                }).toList(),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

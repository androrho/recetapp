import 'package:flutter/material.dart';

import '../controller/ingredients_service.dart';
import '../controller/recipes_service.dart';
import '../controller/steps_service.dart';
import '../model/ingredient.dart';
import '../model/recipe.dart';
import '../model/step.dart' as appStep;

/// Screen that displays all the details of a recipe:
/// - Title (big text)
/// - Description (normal text)
/// - List of ingredients (each on its own line)
/// - List of steps (numbered)
class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;

  const RecipeDetailScreen({Key? key, required this.recipeId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double horizontalPadding = isLandscape ? 50.0 : 45.0;
    final theme = Theme.of(context);

    return SingleChildScrollView(
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
                  return Center(child: Text('Error receta: ${snapRec.error}'));
                }
                final recipe = snapRec.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      recipe.title ?? '',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      recipe.description ?? '',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),

                    // Ingredients section
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
                        if (ingredients.isEmpty) {
                          return const SizedBox();
                        }
                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ingredientes',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...ingredients.map((i) => Padding(
                                padding:
                                const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '• ${i.name} — ${i.quantity} ${i.quantityType}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              )),
                            ],
                          ),
                        );
                      },
                    ),

                    // Steps section
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
                        if (steps.isEmpty) {
                          return const SizedBox();
                        }
                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pasos',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...steps.map((s) => Padding(
                                padding:
                                const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '${s.position}. ${s.text}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              )),
                            ],
                          ),
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
    );
  }
}

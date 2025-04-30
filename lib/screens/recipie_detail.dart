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
                  return Center(
                      child: Text('Error receta: ${snapRec.error}'));
                }
                final recipe = snapRec.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      recipe.title ?? '',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      recipe.description ?? '',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),

                    // Ingredients header
                    Text(
                      'Ingredientes',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    // Listen to ingredients stream
                    StreamBuilder<List<Ingredient>>(
                      stream:
                      IngredientsService().watchByRecipe(recipeId),
                      builder: (ctxIng, snapIng) {
                        if (snapIng.connectionState !=
                            ConnectionState.active) {
                          return const SizedBox();
                        }
                        if (snapIng.hasError) {
                          return Text(
                              'Error ingredientes: ${snapIng.error}');
                        }
                        final ingredients = snapIng.data!;

                        // Show each ingredient on its own line
                        return Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: ingredients.map((i) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '• ${i.name} — ${i.quantity} ${i.quantityType}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Steps header
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

                        // Show each step numbered
                        return Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: steps.map((s) {
                            return Padding(
                              padding:
                              const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '${s.position}. ${s.text}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
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
    );
  }
}

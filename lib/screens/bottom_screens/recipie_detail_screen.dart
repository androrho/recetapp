import 'package:flutter/material.dart';
import '../../controller/recipes_service.dart';
import '../../model/ingredient.dart';
import 'package:recetapp/model/step.dart' as appStep;
import '../../controller/ingredients_service.dart';
import '../../controller/steps_service.dart';
import '../../model/recipe.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;

  const RecipeDetailScreen({
    Key? key,
    required this.recipeId,
  }) : super(key: key);

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
              if (value == 'delete') {
                // Pedimos confirmación
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('¿Eliminar receta?'),
                    content: const Text('Se eliminará la receta y todos sus datos.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true),  child: const Text('Eliminar')),
                    ],
                  ),
                );

                if (confirm == true) {
                  final recipeId = this.recipeId;

                  // 1. Borrar ingredientes asociados
                  final ingSvc = IngredientsService();
                  final allIng = await ingSvc.read();
                  for (final ing in allIng.where((i) => i.recipie == recipeId)) {
                    await ingSvc.delete(ing.id!);
                  }
                  // 2. Borrar pasos asociados
                  final stepSvc = StepsService();
                  final allSteps = await stepSvc.read();
                  for (final st in allSteps.where((s) => s.recipie == recipeId)) {
                    await stepSvc.delete(st.id!);
                  }
                  // 3. Borrar la receta
                  await RecipesService().delete(recipeId);

                  // Volvemos atrás
                  Navigator.pop(context);
                }
              }
            },
            itemBuilder: (_) => const [
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
              child: FutureBuilder<List<dynamic>>(
                future: Future.wait([
                  RecipesService().readById(recipeId),       // :contentReference[oaicite:0]{index=0}&#8203;:contentReference[oaicite:1]{index=1}
                  IngredientsService().read(),                // :contentReference[oaicite:2]{index=2}&#8203;:contentReference[oaicite:3]{index=3}
                  StepsService().read(),                      // asume StepsService.read() análogo
                ]),
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  }

                  final Recipe recipe = snap.data![0] as Recipe;
                  final allIng = snap.data![1] as List<Ingredient>;
                  final allSteps = snap.data![2] as List<appStep.Step>;

                  // Filtrar sólo los de esta receta
                  final ingredients = allIng
                      .where((i) => i.recipie == recipeId)
                      .toList();
                  final steps = allSteps
                      .where((s) => s.recipie == recipeId)
                      .toList()
                    ..sort((a, b) => (a.position ?? 0).compareTo(b.position ?? 0));

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // TÍTULO (más grande)
                        Text(
                          recipe.title ?? '',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),

                        // DESCRIPCIÓN
                        Text(
                          recipe.description ?? '',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),

                        // INGREDIENTES
                        Text('Ingredientes', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        ...ingredients.map((ing) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '• ${ing.name} - ${ing.quantity ?? 0} ${ing.quantityType}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )),

                        const SizedBox(height: 24),

                        // PASOS
                        Text('Pasos', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        ...steps.map((st) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '${st.position}. ${st.text}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      )

    );
  }
}
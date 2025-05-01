import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../controller/auth_service.dart';
import '../controller/ingredients_service.dart';
import '../controller/recipes_service.dart';
import '../controller/steps_service.dart';
import '../model/ingredient.dart';
import '../model/recipe.dart';
import '../model/step.dart' as app_step;
import '../widgets/form_items/list_ingredient_item.dart';
import '../widgets/form_items/list_step_item.dart';

/// Screen where the user can add a new recipe.
///
/// Shows a form with fields for title, description, number of people,
/// a list of dynamic ingredients, and a list of dynamic steps.
class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({Key? key}) : super(key: key);

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _numberController = TextEditingController();

  /// Lists that hold the dynamic ingredient and step items.
  final List<ListIngredientItem> _ingredientsList = [];
  final List<ListStepItem> _stepsList = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _numberController.dispose();
    for (final step in _stepsList) {
      step.stepController.dispose();
    }
    for (final item in _ingredientsList) {
      item.ingredientController.dispose();
      item.quantityController.dispose();
      item.unitTypeController.dispose();
    }
    super.dispose();
  }

  /// Validates the form, saves the recipe, ingredients, and steps,
  /// then closes this screen and shows a toast.
  Future<void> _saveFullRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    final String recipeId = await _saveRecipe();
    await _saveIngredients(recipeId);
    await _saveSteps(recipeId);

    Navigator.pop(context);
    Fluttertoast.showToast(msg: "Receta añadida");
  }

  /// Saves the main recipe data and returns its new ID.
  Future<String> _saveRecipe() async {
    final String? userId = AuthService().currentUserId;
    final int personNumber = int.tryParse(_numberController.text) ?? 0;
    final newRecipe = Recipe(
      title: _titleController.text,
      description: _descriptionController.text,
      personNumber: personNumber,
      user: userId,
    );
    return await RecipesService().create(newRecipe);
  }

  /// Loops through _ingredientsList and saves each ingredient.
  Future<void> _saveIngredients(String recipeId) async {
    for (final ingredient in _ingredientsList) {
      final double qty =
          double.tryParse(ingredient.quantityController.text) ?? 0.0;
      final obj = Ingredient(
        name: ingredient.ingredientController.text,
        quantity: qty,
        quantityType: ingredient.unitTypeController.text,
        recipe: recipeId,
      );
      await IngredientsService().create(obj);
    }
  }

  /// Loops through _stepsList and saves each step.
  Future<void> _saveSteps(String recipeId) async {
    for (int i = 0; i < _stepsList.length; i++) {
      final obj = app_step.Step(
        position: i + 1,
        recipe: recipeId,
        text: _stepsList[i].stepController.text,
      );
      await StepsService().create(obj);
    }
  }

  /// Add a new blank ingredient row.
  void _addIngredient() {
    setState(() {
      _ingredientsList.add(
        ListIngredientItem(
          ingredientController: TextEditingController(),
          quantityController: TextEditingController(),
          unitTypeController: TextEditingController(),
        ),
      );
    });
  }

  /// Remove one ingredient row by index.
  void _removeIngredient(int index) {
    setState(() {
      _ingredientsList.removeAt(index);
    });
  }

  /// Add a new blank step row.
  void _addStep() {
    setState(() {
      _stepsList.add(ListStepItem(stepController: TextEditingController()));
    });
  }

  /// Remove one step row by index.
  void _removeStep(int index) {
    setState(() {
      _stepsList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final horizontalPadding = isLandscape ? 50.0 : 45.0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Close button
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(child: Text('Nueva Receta')),
            // Save button
            ElevatedButton(
              onPressed: _saveFullRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title field
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese un título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Description field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese una descripción';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Number of people field
                    TextFormField(
                      controller: _numberController,
                      decoration: const InputDecoration(
                        labelText: 'Número de personas',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese un número';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Ingrese un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Steps section
                    Text("Pasos"),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        for (int i = 0; i < _stepsList.length; i++)
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller:
                                      _stepsList[i].stepController,
                                      decoration: const InputDecoration(
                                        hintText: 'Paso',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => _removeStep(i),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Add step button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Añadir paso'),
                            onPressed: _addStep,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Ingredients section
                    Text("Ingredientes"),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        for (int i = 0; i < _ingredientsList.length; i++)
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                children: [
                                  // Ingredient name row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _ingredientsList[i]
                                              .ingredientController,
                                          decoration: const InputDecoration(
                                            hintText: 'Ingrediente',
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Ingrese un ingrediente';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () =>
                                            _removeIngredient(i),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Quantity and unit row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _ingredientsList[i]
                                              .quantityController,
                                          decoration: const InputDecoration(
                                            labelText: 'Cantidad',
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType:
                                          TextInputType.number,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Ingrese un número';
                                            }
                                            if (double.tryParse(value) ==
                                                null) {
                                              return 'Ingrese un número válido';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _ingredientsList[i]
                                              .unitTypeController,
                                          decoration: const InputDecoration(
                                            hintText: 'Tipo',
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Ingrese un tipo';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Add ingredient button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Añadir ingrediente'),
                            onPressed: _addIngredient,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

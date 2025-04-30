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
import 'detail_my_recipes_screen.dart';

/// Screen for editing an existing recipe.
///
/// - Loads the recipe’s current data (title, description, people count,
///   ingredients, and steps) in initState.
/// - Lets the user modify all fields and save changes.
/// - Deletes the old recipe (and its ingredients/steps) before creating a new one.
/// - After saving, shows a toast and navigates to the updated recipe’s detail.
class EditRecipieScreen extends StatefulWidget {
  /// The ID of the recipe to edit.
  final String recipeId;

  const EditRecipieScreen({Key? key, required this.recipeId})
      : super(key: key);

  @override
  _EditRecipieScreenState createState() => _EditRecipieScreenState();
}

class _EditRecipieScreenState extends State<EditRecipieScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the main text fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _numberController = TextEditingController();

  // Dynamic lists for ingredients and steps
  final List<ListIngredientItem> _ingredientsList = [];
  final List<ListStepItem> _stepsList = [];

  @override
  void initState() {
    super.initState();
    _loadRecipie();
  }

  /// Loads the recipe data, pre-fills text fields,
  /// and builds the ingredient and step lists.
  Future<void> _loadRecipie() async {
    // Load the recipe object
    final recipe = await RecipesService()
        .watchById(widget.recipeId)
        .first;

    // Fill the title, description, and people count
    _titleController.text       = recipe.title       ?? '';
    _descriptionController.text = recipe.description ?? '';
    _numberController.text      = (recipe.personNumber ?? 0).toString();

    // Load and add each ingredient row
    final ingredients = await IngredientsService()
        .watchByRecipe(widget.recipeId)
        .first;
    for (var i in ingredients) {
      _ingredientsList.add(ListIngredientItem(
        ingredientController: TextEditingController(text: i.name),
        quantityController:   TextEditingController(text: i.quantity?.toString()),
        unitTypeController:   TextEditingController(text: i.quantityType),
      ));
    }

    // Load and add each step row
    final steps = await StepsService()
        .watchByRecipe(widget.recipeId)
        .first;
    for (var s in steps) {
      _stepsList.add(ListStepItem(
        stepController: TextEditingController(text: s.text),
      ));
    }

    setState(() {}); // refresh UI
  }

  /// Validates the form, deletes the old recipe (ingredients and steps),
  /// then saves a new recipe with updated data, and navigates to its detail.
  Future<void> _updateFullRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    // Remove old recipe data
    await _deleteFullRecipe(widget.recipeId);

    // Save new recipe and get its ID
    final newRecipeId = await _saveFullRecipe();

    Fluttertoast.showToast(msg: 'Receta actualizada');

    // Go back and open the new recipe detail
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DetailMyRecipesScreen(recipeId: newRecipeId),
      ),
    );
  }

  /// Deletes ingredients, steps, and the recipe itself.
  Future<void> _deleteFullRecipe(String recipeId) async {
    await _deleteIngredients(recipeId);
    await _deleteSteps(recipeId);
    await _deleteRecipe(recipeId);
  }

  Future<void> _deleteIngredients(String recipeId) async {
    final ingSvc = IngredientsService();
    final items = await ingSvc.watchByRecipe(recipeId).first;
    await Future.wait(items.map((i) => ingSvc.delete(i.id!)));
  }

  Future<void> _deleteSteps(String recipeId) async {
    final stepSvc = StepsService();
    final items = await stepSvc.watchByRecipe(recipeId).first;
    await Future.wait(items.map((s) => stepSvc.delete(s.id!)));
  }

  Future<void> _deleteRecipe(String recipeId) async {
    await RecipesService().delete(recipeId);
  }

  /// Saves the updated recipe, ingredients, and steps,
  /// and returns the new recipe’s ID.
  Future<String> _saveFullRecipe() async {
    final recipeId = await _saveRecipe();
    await _saveIngredients(recipeId);
    await _saveSteps(recipeId);
    return recipeId;
  }

  Future<String> _saveRecipe() async {
    final userId = AuthService().currentUserId;
    final int people = int.tryParse(_numberController.text) ?? 0;
    final newRecipe = Recipe(
      title: _titleController.text,
      description: _descriptionController.text,
      personNumber: people,
      user: userId,
    );
    return await RecipesService().create(newRecipe);
  }

  Future<void> _saveIngredients(String recipeId) async {
    for (final ing in _ingredientsList) {
      final qty = double.tryParse(ing.quantityController.text) ?? 0.0;
      final obj = Ingredient(
        name: ing.ingredientController.text,
        quantity: qty,
        quantityType: ing.unitTypeController.text,
        recipe: recipeId,
      );
      await IngredientsService().create(obj);
    }
  }

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

  // Helpers to add/remove dynamic rows
  void _addIngredient() {
    setState(() {
      _ingredientsList.add(ListIngredientItem(
        ingredientController: TextEditingController(),
        quantityController: TextEditingController(),
        unitTypeController: TextEditingController(),
      ));
    });
  }

  void _removeIngredient(int index) {
    setState(() => _ingredientsList.removeAt(index));
  }

  void _addStep() {
    setState(() {
      _stepsList.add(ListStepItem(stepController: TextEditingController()));
    });
  }

  void _removeStep(int index) {
    setState(() => _stepsList.removeAt(index));
  }

  @override
  void dispose() {
    // Dispose all controllers
    _titleController.dispose();
    _descriptionController.dispose();
    _numberController.dispose();
    for (final item in _ingredientsList) {
      item.ingredientController.dispose();
      item.quantityController.dispose();
      item.unitTypeController.dispose();
    }
    for (final step in _stepsList) {
      step.stepController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Padding adapts to orientation
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final horizontalPadding = isLandscape ? 50.0 : 45.0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Close icon
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(child: Text('Editar Receta')),
            // Save button
            ElevatedButton(
              onPressed: _updateFullRecipe,
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
                      validator: (v) =>
                      v == null || v.isEmpty ? 'Ingrese un título' : null,
                    ),
                    const SizedBox(height: 16),
                    // Description field
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                      v == null || v.isEmpty ? 'Ingrese una descripción' : null,
                    ),
                    const SizedBox(height: 16),
                    // People count
                    TextFormField(
                      controller: _numberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Número de personas',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingrese un número';
                        if (int.tryParse(v) == null) return 'Ingrese un número válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text("Pasos"),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        for (int i = 0; i < _stepsList.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color:
                                Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _stepsList[i].stepController,
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
                    Text("Ingredientes"),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        for (int i = 0; i < _ingredientsList.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color:
                                Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                children: [
                                  // Upper row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                          _ingredientsList[i]
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
                                        onPressed: () => _removeIngredient(i),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Lower row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                          _ingredientsList[i]
                                              .quantityController,
                                          decoration: const InputDecoration(
                                            labelText: 'Cantidad',
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Ingrese un número';
                                            }
                                            if (double.tryParse(value) == null) {
                                              return 'Ingrese un número válido';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                          _ingredientsList[i]
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
                    const SizedBox(height: 16),
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

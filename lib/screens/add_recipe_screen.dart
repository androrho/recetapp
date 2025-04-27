import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recetapp/model/recipe.dart';
import '../controller/ingredients_service.dart';
import '../controller/recipes_service.dart';
import '../controller/steps_service.dart';
import '../model/ingredient.dart';
import 'package:recetapp/model/step.dart' as app_step;

import '../widgets/form_items/list_ingredient_item.dart';
import '../widgets/form_items/list_step_item.dart';

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

  final List<ListStepItem> _stepsList = [];

  final List<ListIngredientItem> _ingredientsList = [];

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

  Future<void> _saveFullRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    final String recipeId = await _saveRecipe();
    _saveIngredients(recipeId);
    _saveSteps(recipeId);

    Navigator.pop(context);

    Fluttertoast.showToast(
      msg: "Receta añadida",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  Future<String> _saveRecipe() async {
    int personNumber = int.tryParse(_numberController.text) ?? 0;
    final newRecipe = Recipe(
      title: _titleController.text,
      description: _descriptionController.text,
      personNumber: personNumber,
      user: "0", // TODO: Asignar el id real del usuario
    );

    return await RecipesService().create(newRecipe);
  }

  Future<void> _saveIngredients(String recipeId) async {
    for (final ingredient in _ingredientsList) {
      final double quantity =
          double.tryParse(ingredient.quantityController.text) ?? 0.0;
      final ingredientObject = Ingredient(
        name: ingredient.ingredientController.text,
        quantity: quantity,
        quantityType: ingredient.unitTypeController.text,
        recipie: recipeId,
      );
      await IngredientsService().create(ingredientObject);
    }
  }

  Future<void> _saveSteps(String recipeId) async {
    for (int i = 0; i < _stepsList.length; i++) {
      final stepObject = app_step.Step(
        position: i + 1,
        recipe: recipeId,
        text: _stepsList[i].stepController.text,
      );
      await StepsService().create(stepObject);
    }
  }

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

  void _removeIngredient(int index) {
    setState(() {
      _ingredientsList.removeAt(index);
    });
  }

  void _addStep() {
    setState(() {
      _stepsList.add(ListStepItem(stepController: TextEditingController()));
    });
  }

  void _removeStep(int index) {
    setState(() {
      _stepsList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double horizontalPadding = isLandscape ? 50.0 : 45.0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Back button
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
                    //Títle
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

                    // Description
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

                    // Person number
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

                    // Steps
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

                        // Button add step
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

                    // Ingredients
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
                                  // First row
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

                                  // Bottom row
                                  Row(
                                    children: [
                                      // Quantity
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
                                            if (int.tryParse(value) == null) {
                                              return 'Ingrese un número válido';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Quantity type
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

                        // Button add ingredient
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

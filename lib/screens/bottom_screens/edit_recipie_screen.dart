import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recetapp/model/recipe.dart';
import 'package:recetapp/model/ingredient.dart';
import 'package:recetapp/model/step.dart' as appStep;
import '../../controller/recipes_service.dart';
import '../../controller/ingredients_service.dart';
import '../../controller/steps_service.dart';

/// Auxiliar para ingredientes pre-cargados
class ListIngredientItem {
  final TextEditingController ingredientController;
  final TextEditingController quantityController;
  final TextEditingController unitTypeController;

  ListIngredientItem({
    required this.ingredientController,
    required this.quantityController,
    required this.unitTypeController,
  });
}

/// Auxiliar para pasos pre-cargados
class ListStepItem {
  final TextEditingController stepController;

  ListStepItem({required this.stepController});
}

class EditRecipieScreen extends StatefulWidget {
  final String recipeId;

  const EditRecipieScreen({Key? key, required this.recipeId}) : super(key: key);

  @override
  _EditRecipieScreenState createState() => _EditRecipieScreenState();
}

class _EditRecipieScreenState extends State<EditRecipieScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _numberController = TextEditingController();

  final List<ListIngredientItem> _ingredientsList = [];
  final List<ListStepItem> _stepsList = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipie();
  }

  Future<void> _loadRecipie() async {
    // 1) Carga la receta
    final recipe = await RecipesService().readById(widget.recipeId);

    // 2) Precarga campos de texto
    _titleController.text = recipe.title ?? '';
    _descriptionController.text = recipe.description ?? '';
    _numberController.text = (recipe.personNumber ?? 0).toString();

    // 3) Carga todos los ingredientes y filtra
    final allIng = await IngredientsService().read();
    final myIng = allIng.where((i) => i.recipie == widget.recipeId);
    for (var i in myIng) {
      _ingredientsList.add(
        ListIngredientItem(
          ingredientController: TextEditingController(text: i.name),
          quantityController: TextEditingController(
            text: i.quantity?.toString(),
          ),
          unitTypeController: TextEditingController(text: i.quantityType),
        ),
      );
    }

    // 4) Carga todos los pasos y filtra y ordena
    final allSt = await StepsService().read();
    final mySt =
        allSt.where((s) => s.recipie == widget.recipeId).toList()
          ..sort((a, b) => (a.position ?? 0).compareTo(b.position ?? 0));
    for (var s in mySt) {
      _stepsList.add(
        ListStepItem(stepController: TextEditingController(text: s.text)),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _updateRecipie() async {
    // Aquí implementa tu lógica de actualización
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
  void dispose() {
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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final horizontalPadding = isLandscape ? 50.0 : 45.0;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(child: Text('Editar Receta')),
            ElevatedButton(
              onPressed: _updateRecipie,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
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
                vertical: 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (v) =>
                              (v == null || v.isEmpty)
                                  ? 'Ingrese un título'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator:
                          (v) =>
                              (v == null || v.isEmpty)
                                  ? 'Ingrese una descripción'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    // Número de personas
                    TextFormField(
                      controller: _numberController,
                      decoration: const InputDecoration(
                        labelText: 'Número de personas',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingrese un número';
                        return int.tryParse(v) == null
                            ? 'Número inválido'
                            : null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pasos
                    Text(
                      'Pasos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 16),

                    // Ingredientes
                    Text(
                      'Ingredientes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
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
                                      validator:
                                          (v) =>
                                              (v == null || v.isEmpty)
                                                  ? 'Ingrese un ingrediente'
                                                  : null,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => _removeIngredient(i),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
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
                                      validator:
                                          (v) =>
                                              (v == null ||
                                                      v.isEmpty ||
                                                      int.tryParse(v) == null)
                                                  ? 'Cantidad inválida'
                                                  : null,
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
                                      validator:
                                          (v) =>
                                              (v == null || v.isEmpty)
                                                  ? 'Ingrese un tipo'
                                                  : null,
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

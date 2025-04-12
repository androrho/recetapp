import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recetapp/model/recipie.dart';
import '../../controller/recipies_service.dart';

/// Clase auxiliar para cada paso.
/// Cada paso se representa con un único controlador.
class ListStepItem {
  final TextEditingController stepController;

  ListStepItem({required this.stepController});
}

/// Clase auxiliar para cada ingrediente.
/// Cada elemento tendrá tres controladores: para el nombre, la cantidad y el tipo de unidad.
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

class AddRecipieScreen extends StatefulWidget {
  const AddRecipieScreen({Key? key}) : super(key: key);

  @override
  _AddRecipieScreenState createState() => _AddRecipieScreenState();
}

class _AddRecipieScreenState extends State<AddRecipieScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _numberController = TextEditingController();

  // Lista dinámica de pasos
  final List<ListStepItem> _stepsList = [];

  // Lista dinámica de ingredientes
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

  Future<void> _saveRecipie() async {
    if (_formKey.currentState!.validate()) {
      int personNumber = int.tryParse(_numberController.text) ?? 0;
      final newRecipie = Recipie(
        title: _titleController.text,
        description: _descriptionController.text,
        personNumber: personNumber,
        user: "0", // TODO: Asignar el id real del usuario
      );

      // Aquí se crea la receta. Luego podrías guardar también los ingredientes y pasos,
      // asociándolos al id de la receta recién creada, según tu lógica.
      await RecipiesService().create(newRecipie);

      Fluttertoast.showToast(
        msg: "Receta añadida",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );

      Navigator.pop(context);
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
            // Botón para cerrar
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(child: Text('Nueva Receta')),
            // Botón para guardar la receta
            ElevatedButton(
              onPressed: _saveRecipie,
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
                    // Campo Título
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Campo Descripción
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una descripción';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Campo Número de personas
                    TextFormField(
                      controller: _numberController,
                      decoration: const InputDecoration(
                        labelText: 'Número de personas',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un número';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Debe ingresar un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Sección para Pasos
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
                                    ).colorScheme.surfaceVariant,
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
                        // Botón para añadir un paso
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

                    // Sección para Ingredientes
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
                                    ).colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                children: [
                                  // Fila superior: Campo para el nombre del ingrediente y botón de eliminación
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
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => _removeIngredient(i),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Fila inferior: Dos campos para cantidad/unidades y tipo de unidades
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                              _ingredientsList[i]
                                                  .quantityController,
                                          decoration: const InputDecoration(
                                            hintText: 'Cantidad / Unidades',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                              _ingredientsList[i]
                                                  .unitTypeController,
                                          decoration: const InputDecoration(
                                            hintText: 'Tipo de unidades',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Botón para añadir ingrediente
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

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:recetapp/model/recipie.dart';

import '../../controller/recipies_service.dart';

class ListItem {
  final TextEditingController ingredientController;
  final TextEditingController quantityController;
  final TextEditingController unitTypeController;

  ListItem({
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

  final List<ListItem> _itemsList = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _numberController.dispose();
    for (final item in _itemsList) {
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
        user: "0", //TODO: Add user id to recipie
      );

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

  void _addItem() {
    setState(() {
      _itemsList.add(ListItem(
        ingredientController: TextEditingController(),
        quantityController: TextEditingController(),
        unitTypeController: TextEditingController(),
      ));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _itemsList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {

    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final double horizontalPadding = isLandscape ? 50.0 : 45.0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(child: Text('Nueva Receta')),
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
            constraints: const BoxConstraints(
              maxWidth: 450,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    // 1) Campo de texto para el título
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

                    // 2) Campo de texto para la descripción
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

                    // 3) Campo texto número de personas
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

                    // 4) Lista para añadir ingredintes
                    Column(
                      children: [
                        for (int i = 0; i < _itemsList.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onSecondary,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                children: [
                                  // Fila superior: campo que ocupa toda la línea + botón X
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                          _itemsList[i].ingredientController,
                                          decoration: const InputDecoration(
                                            hintText: 'Ingrediente',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => _removeItem(i),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Fila inferior: dos campos para cantidad y tipo de unidades
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                          _itemsList[i].quantityController,
                                          decoration: const InputDecoration(
                                            hintText: 'Unidades',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                          _itemsList[i].unitTypeController,
                                          decoration: const InputDecoration(
                                            hintText: 'Tipo',
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
                        // Botón para añadir un nuevo ingrediente
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Añadir ingrediente'),
                            onPressed: _addItem,
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
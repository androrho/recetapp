import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:recetapp/model/recipie.dart';

import '../../controller/recipies_service.dart';

class ListItem {
  bool isChecked;
  TextEditingController controller;

  ListItem({
    this.isChecked = false,
    required this.controller,
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
      item.controller.dispose();
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
        backgroundColor: Colors.black54,
        textColor: Colors.white,
      );

      Navigator.pop(context);
    }
  }

  void _addItem() {
    setState(() {
      _itemsList.add(
        ListItem(controller: TextEditingController()),
      );
    });
  }

  /// Eliminar un ítem de la lista
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

                    // 4) Último campo de texto: Número de personas
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
                    Column(
                      children: [
                        for (int i = 0; i < _itemsList.length; i++)
                          Row(
                            children: [
                              // Campo de texto expandible
                              Expanded(
                                child: TextFormField(
                                  controller: _itemsList[i].controller,
                                  decoration: const InputDecoration(
                                    hintText: 'Ingrediente',
                                    border: UnderlineInputBorder(),
                                  ),
                                ),
                              ),
                              // Botón X para eliminar
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => _removeItem(i),
                              ),
                            ],
                          ),
                        // Botón para añadir un nuevo ítem
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
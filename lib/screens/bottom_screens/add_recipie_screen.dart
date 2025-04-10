import 'package:flutter/material.dart';

class AddRecipieScreen extends StatelessWidget {
  const AddRecipieScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Receta'),
      ),
      body: Center(
        child: Text(
          'Aquí va el contenido para agregar una nueva receta',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

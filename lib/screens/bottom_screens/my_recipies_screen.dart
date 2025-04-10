import 'package:flutter/material.dart';
import 'package:recetapp/screens/bottom_screens/add_recipie_screen.dart';

class MyRecipiesScreen extends StatelessWidget {
  const MyRecipiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Añadir receta", style: TextStyle(fontSize: 24)),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Añadir',
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => const AddRecipieScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
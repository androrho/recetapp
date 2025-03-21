import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddRecipieScreen extends StatelessWidget {
  const AddRecipieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Añadir receta", style: TextStyle(fontSize: 24)),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Añadir',
        onPressed: () {
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

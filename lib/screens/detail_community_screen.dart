import 'package:flutter/material.dart';
import 'package:recetapp/screens/recipie_detail.dart';

class DetailCommunityScreen extends StatelessWidget {
  final String recipeId;

  const DetailCommunityScreen({Key? key, required this.recipeId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Márgenes iguales a AddRecipieScreen
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double horizontalPadding = isLandscape ? 50.0 : 45.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Receta'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            onSelected: (value) async {
            },
            itemBuilder:
                (_) => const [
              PopupMenuItem(value: 'save', child: Text('Guardar')),
            ],
          ),
        ],
      ),
      body: RecipeDetailScreen(recipeId: recipeId),
    );
  }
}
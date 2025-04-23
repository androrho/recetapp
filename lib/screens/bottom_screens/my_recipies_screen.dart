import 'package:flutter/material.dart';
import 'package:recetapp/model/recipie.dart';
import '../../controller/recipies_service.dart';
import 'add_recipie_screen.dart';

class MyRecipiesScreen extends StatelessWidget {
  const MyRecipiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mismo cálculo de padding horizontal que en AddRecipieScreen
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double horizontalPadding = isLandscape ? 50.0 : 45.0;

    final service = RecipiesService();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: FutureBuilder<List<Recipie>>(
          future: service.read(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final recipes = snapshot.data!;
            if (recipes.isEmpty) {
              return const Center(child: Text('No tienes recetas aún'));
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final r = recipes[index];
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 300,
                      maxWidth: 600,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Título
                          Text(
                            r.title ?? '',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          // Descripción + Número con icono
                          Row(
                            children: [
                              // Descripción (flex mayor)
                              Expanded(
                                flex: 3,
                                child: Text(
                                  r.description ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Número de personas + icono de grupo
                              Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${r.personNumber ?? 0}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.group,
                                      size: 20,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Añadir',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => const AddRecipieScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
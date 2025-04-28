import 'package:flutter/material.dart';
import 'package:recetapp/model/recipe.dart';
import 'package:recetapp/screens/detail_my_recipes_screen.dart';
import '../../controller/auth_service.dart';
import '../../controller/recipes_service.dart';
import '../add_recipe_screen.dart';

class MyRecipesScreen extends StatefulWidget {
  const MyRecipesScreen({Key? key}) : super(key: key);

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  final _searchCtrl = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchTerm = _searchCtrl.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double horizontalPadding = isLandscape ? 50.0 : 45.0;
    final String? userId = AuthService().currentUserId;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child:
                userId == null
                    ? const Center(child: Text('Debes iniciar sesión'))
                    : Column(
                      children: [
                        const SizedBox(height: 8),
                        // Campo de búsqueda
                        TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            labelText: 'Buscar recetas',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Listado filtrado
                        Expanded(
                          child: StreamBuilder<List<Recipe>>(
                            stream: RecipesService().watchByUser(userId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              }
                              final recipes = snapshot.data!;

                              // Aplico filtro por título o descripción
                              final filtered =
                                  recipes.where((r) {
                                    final title = (r.title ?? '').toLowerCase();
                                    final desc =
                                        (r.description ?? '').toLowerCase();
                                    return title.contains(_searchTerm) ||
                                        desc.contains(_searchTerm);
                                  }).toList();

                              if (filtered.isEmpty) {
                                return const Center(
                                  child: Text('No hay recetas que coincidan'),
                                );
                              }
                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final r = filtered[index];
                                  return Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        minWidth: 300,
                                        maxWidth: 600,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => DetailMyRecipesScreen(
                                                    recipeId: r.id!,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.surfaceVariant,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                r.title ?? '',
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.titleLarge,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      r.description ?? '',
                                                      style:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          '${r.personNumber ?? 0}',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Icon(
                                                          Icons.group,
                                                          size: 20,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
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
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Añadir',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => const AddRecipeScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

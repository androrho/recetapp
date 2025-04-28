import 'package:flutter/material.dart';
import 'package:recetapp/model/recipe.dart';
import 'package:recetapp/screens/detail_community_screen.dart';
import '../../controller/recipes_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
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

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                const SizedBox(height: 16),
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
                // Listado de recetas filtrado
                Expanded(
                  child: StreamBuilder<List<Recipe>>(
                    stream: RecipesService().watchAll(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final recipes = snapshot.data ?? [];
                      // Aplico filtro por título o descripción
                      final filtered =
                      recipes.where((r) {
                        final title = (r.title ?? '').toLowerCase();
                        final desc = (r.description ?? '').toLowerCase();
                        return title.contains(_searchTerm) ||
                            desc.contains(_searchTerm);
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text('No hay recetas disponibles'),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final recipe = filtered[index];
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
                                          (_) => DetailCommunityScreen(
                                        recipeId: recipe.id!,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        recipe.title ?? '',
                                        style:
                                        Theme.of(context).textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              recipe.description ?? '',
                                              style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${recipe.personNumber ?? 0}',
                                                  style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                                ),
                                                const SizedBox(width: 4),
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
    );
  }
}

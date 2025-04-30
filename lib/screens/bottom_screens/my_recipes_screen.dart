import 'package:flutter/material.dart';

import '../../controller/auth_service.dart';
import '../../controller/recipes_service.dart';
import '../../model/recipe.dart';
import '../add_recipe_screen.dart';
import '../detail_my_recipes_screen.dart';

/// Screen that shows the current user’s recipes in a list.
///
/// Users can search by title or description, tap to see details,
/// and add a new recipe with the floating button.
class MyRecipesScreen extends StatefulWidget {
  const MyRecipesScreen({Key? key}) : super(key: key);

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  final _searchCtrl = TextEditingController();

  String _searchTerm = '';

  final RecipesService _service = RecipesService();

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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final horizontalPadding = isLandscape ? 50.0 : 45.0;

    final userId = AuthService().currentUserId;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: userId == null
            // If not logged in, show a message
                ? const Center(child: Text('Debes iniciar sesión'))
            // Otherwise show search and list
                : Column(
              children: [
                const SizedBox(height: 8),

                // Search box
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

                // List of recipes, filtered by the search term
                Expanded(
                  child: StreamBuilder<List<Recipe>>(
                    stream: _service.watchByUser(userId),
                    builder: _buildRecipeList,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Button to add a new recipe
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

  /// Builds the list view or shows loading/error messages.
  Widget _buildRecipeList(
      BuildContext context, AsyncSnapshot<List<Recipe>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }

    // Apply the search filter
    final recipes = snapshot.data ?? [];
    final filtered = recipes.where((r) {
      final title = (r.title ?? '').toLowerCase();
      final desc = (r.description ?? '').toLowerCase();
      return title.contains(_searchTerm) || desc.contains(_searchTerm);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No hay recetas que mostrar'));
    }

    // Show the filtered recipes
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) => _buildRecipeCard(ctx, filtered[i]),
    );
  }

  /// Builds one card showing a recipe’s title, description, and person icon.
  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 600),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DetailMyRecipesScreen(recipeId: recipe.id!),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Recipe title
                Text(
                  recipe.title ?? '',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Description
                    Expanded(
                      flex: 3,
                      child: Text(
                        recipe.description ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Person icon + count
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${recipe.personNumber ?? 0}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.group,
                            size: 20,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
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
  }
}

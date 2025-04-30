import 'package:flutter/material.dart';

import '../../controller/recipes_service.dart';
import '../../model/recipe.dart';
import '../detail_community_screen.dart';

/// Shows all public recipes in a list, with a search box to filter them.
///
/// The user can type in the search box to only see recipes whose title
/// or description contains the search term (case-insensitive).
/// Tapping on a recipe opens its detail page.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  /// Controller for the search text field.
  final _searchCtrl = TextEditingController();

  /// Current lowercase search term, updated whenever the user types.
  String _searchTerm = '';

  /// Service that provides a stream of all recipes from Firestore.
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
    // Calculate padding for landscape vs portrait.
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

                // List of recipes, filtered by `_searchTerm`
                Expanded(
                  child: StreamBuilder<List<Recipe>>(
                    stream: _service.watchAll(),
                    builder: _buildRecipeList,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the list or shows a loading/error message.
  Widget _buildRecipeList(
      BuildContext context,
      AsyncSnapshot<List<Recipe>> snapshot,
      ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }

    // Get all recipes and apply the search filter
    final recipes = snapshot.data ?? [];
    final filtered = recipes.where((recipe) {
      final title = (recipe.title ?? '').toLowerCase();
      final desc  = (recipe.description ?? '').toLowerCase();
      return title.contains(_searchTerm) ||
          desc.contains(_searchTerm);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No hay recetas que mostrar'));
    }

    // Build a scrollable list of recipe cards
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) => _buildRecipeCard(ctx, filtered[i]),
    );
  }

  /// Builds one recipe card showing title, description and person icon.
  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 600),
        child: GestureDetector(
          onTap: () {
            // Open the recipe detail screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DetailCommunityScreen(recipeId: recipe.id!),
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
                    // Recipe description
                    Expanded(
                      flex: 3,
                      child: Text(
                        recipe.description ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Number of people icon
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

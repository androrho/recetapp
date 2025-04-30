import 'package:flutter/material.dart';

import '../../controller/auth_service.dart';
import '../../controller/recipes_service.dart';
import '../login_screen.dart';

/// Shows the user's account details and lets them
/// sign out or delete all their recipes.
class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({Key? key}) : super(key: key);

  /// Ask the user to confirm sign out.
  /// If they agree, it signs out and goes back to login.
  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // Save the navigator before signing out
    final navigator = Navigator.of(context);

    // Sign out from Firebase and Google
    await AuthService().signOut();

    // Go to LoginScreen and remove all previous routes
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  /// Ask the user to type "confirmar" to delete all recipes.
  /// If confirmed, it deletes every recipe of the user.
  Future<void> _confirmDeleteAllRecipes(BuildContext context) async {
    final textCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar todas las recetas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Escribe "confirmar" para borrar todas tus recetas.',
            ),
            const SizedBox(height: 8),
            TextField(
              controller: textCtrl,
              decoration: const InputDecoration(
                labelText: 'Confirmar',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              ctx,
              textCtrl.text.trim().toLowerCase() == 'confirmar',
            ),
            child: const Text(
              'Borrar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final userId = AuthService().currentUserId;
    if (userId == null) return;

    await _deleteAllUserRecipes(userId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todas las recetas han sido borradas')),
    );
  }

  /// Deletes all recipes that belong to [userId].
  Future<void> _deleteAllUserRecipes(String userId) async {
    final recipes = await RecipesService().watchByUser(userId).first;
    await Future.wait(recipes.map((r) => RecipesService().delete(r.id!)));
  }

  @override
  Widget build(BuildContext context) {
    // Decide horizontal padding for portrait vs landscape
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final horizontalPadding = isLandscape ? 50.0 : 45.0;

    // Get current user info
    final user = AuthService().currentUser;
    final photoUrl = user?.photoURL;
    final name = user?.displayName ?? 'Usuario';
    final email = user?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Show profile photo if available
                  if (photoUrl != null) ...[
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(photoUrl),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Show user name
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),

                  // Show user email
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  // Button to sign out
                  ElevatedButton(
                    onPressed: () => _confirmSignOut(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                    ),
                    child: const Text('Cerrar sesión'),
                  ),
                  const SizedBox(height: 16),

                  // Button to delete all my recipes
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _confirmDeleteAllRecipes(context),
                    child: const Text('Borrar todas mis recetas'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../controller/auth_service.dart';
import '../../controller/recipes_service.dart';
import '../login_screen.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({Key? key}) : super(key: key);

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Estás seguro que quieres cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;

    final navigator = Navigator.of(context);

    await AuthService().signOut();

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _confirmDeleteAllRecipes(BuildContext context) async {
    final textCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
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
                onPressed:
                    () => Navigator.pop(
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

    _deleteAllUserRecipes(userId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todas las recetas han sido borradas')),
    );
  }

  Future<void> _deleteAllUserRecipes(String userId) async {
    final recipes = await RecipesService().watchByUser(userId).first;
    await Future.wait(recipes.map((r) => RecipesService().delete(r.id!)));
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double horizontalPadding = isLandscape ? 50.0 : 45.0;

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
                  // Profile Photo
                  if (photoUrl != null) ...[
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(photoUrl),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // User name
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  // Sign out
                  ElevatedButton(
                    onPressed: () => _confirmSignOut(context),
                    child: const Text('Cerrar sesión'),
                  ),
                  const SizedBox(height: 16),

                  // Delete recipes
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

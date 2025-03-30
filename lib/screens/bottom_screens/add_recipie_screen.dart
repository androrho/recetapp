import 'package:flutter/material.dart';
import 'package:recetapp/model/user.dart';

import '../../controller/recipies_service.dart';
import '../../model/recipie.dart';

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
          User u = User(displayName: "Administrator", login: "admin", password: "admin1234");
          Recipie r = Recipie(description: 'm', personNumber: 2, title: "macarrones", user: u);
          print(r.toJson());
          RecipiesService rs = RecipiesService();
          rs.create(r);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:json_annotation/json_annotation.dart';
import 'package:recetapp/model/recipie.dart';

part 'ingredient.g.dart';

@JsonSerializable()
class Ingredient {
  final String? id;
  final String name;
  final double quantity;
  final String quantityType;
  final Recipie recipie;

  Ingredient({
    this.id,
    required this.name,
    required this.quantity,
    required this.quantityType,
    required this.recipie,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientToJson(this);

  @override
  String toString() {
    return 'Ingredient{name: $name}';
  }
}
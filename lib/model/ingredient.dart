import 'package:json_annotation/json_annotation.dart';

part 'ingredient.g.dart';

@JsonSerializable()
class Ingredient {
  final String? id;
  String? name;
  double? quantity;
  String? quantityType;
  String? recipe;

  Ingredient({
    this.id,
    required this.name,
    required this.quantity,
    required this.quantityType,
    required this.recipe,
  });

  Ingredient copyWith({
    String? id,
    String? name,
    double? quantity,
    String? quantityType,
    String? recipe,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      quantityType: quantityType ?? this.quantityType,
      recipe: recipe ?? this.recipe,
    );
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$IngredientToJson(this);
    return json;
  }

  @override
  String toString() {
    return 'ingredients/$id';
  }
}
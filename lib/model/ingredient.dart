import 'package:json_annotation/json_annotation.dart';
import 'package:recetapp/model/recipie.dart';

part 'ingredient.g.dart';

@JsonSerializable()
class Ingredient {
  final String? id;
  String name;
  double quantity;
  String quantityType;
  Recipie recipie;

  Ingredient({
    this.id,
    required this.name,
    required this.quantity,
    required this.quantityType,
    required this.recipie,
  });

  Ingredient copyWith({
    String? id,
    String? name,
    double? quantity,
    String? quantityType,
    Recipie? recipie,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      quantityType: quantityType ?? this.quantityType,
      recipie: recipie ?? this.recipie,
    );
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientToJson(this);

  @override
  String toString() {
    return 'Ingredient{name: $name}';
  }
}
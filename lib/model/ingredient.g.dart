// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ingredient _$IngredientFromJson(Map<String, dynamic> json) => Ingredient(
  id: json['id'] as String?,
  name: json['name'] as String?,
  quantity: (json['quantity'] as num?)?.toDouble(),
  quantityType: json['quantityType'] as String?,
  recipie: json['recipie'] as String?,
);

Map<String, dynamic> _$IngredientToJson(Ingredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'quantity': instance.quantity,
      'quantityType': instance.quantityType,
      'recipie': instance.recipie,
    };

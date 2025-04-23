// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
  id: json['id'] as String?,
  description: json['description'] as String?,
  personNumber: (json['personNumber'] as num?)?.toInt(),
  title: json['title'] as String?,
  user: json['user'] as String?,
);

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
  'id': instance.id,
  'description': instance.description,
  'personNumber': instance.personNumber,
  'title': instance.title,
  'user': instance.user,
};

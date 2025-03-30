// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipie _$RecipieFromJson(Map<String, dynamic> json) => Recipie(
  id: json['id'] as String?,
  description: json['description'] as String,
  personNumber: (json['personNumber'] as num).toInt(),
  title: json['title'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RecipieToJson(Recipie instance) => <String, dynamic>{
  'id': instance.id,
  'description': instance.description,
  'personNumber': instance.personNumber,
  'title': instance.title,
  'user': instance.user,
};

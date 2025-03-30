// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Photo _$PhotoFromJson(Map<String, dynamic> json) => Photo(
  path: json['path'] as String,
  position: (json['position'] as num).toInt(),
  recipie: Recipie.fromJson(json['recipie'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PhotoToJson(Photo instance) => <String, dynamic>{
  'path': instance.path,
  'position': instance.position,
  'recipie': instance.recipie,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Step _$StepFromJson(Map<String, dynamic> json) => Step(
  id: json['id'] as String?,
  position: (json['position'] as num?)?.toInt(),
  recipe: json['recipie'] as String?,
  text: json['text'] as String?,
);

Map<String, dynamic> _$StepToJson(Step instance) => <String, dynamic>{
  'id': instance.id,
  'position': instance.position,
  'recipie': instance.recipe,
  'text': instance.text,
};

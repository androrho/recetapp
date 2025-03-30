// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Step _$StepFromJson(Map<String, dynamic> json) => Step(
  position: (json['position'] as num).toInt(),
  recipie: Recipie.fromJson(json['recipie'] as Map<String, dynamic>),
  text: json['text'] as String,
);

Map<String, dynamic> _$StepToJson(Step instance) => <String, dynamic>{
  'position': instance.position,
  'recipie': instance.recipie,
  'text': instance.text,
};

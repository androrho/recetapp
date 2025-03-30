import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:recetapp/model/recipie.dart';

part 'step.g.dart';

@JsonSerializable()
class Step {
  final String? id;
  int position;
  Recipie recipie;
  String text;

  Step({
    this.id,
    required this.position,
    required this.recipie,
    required this.text,
  });

  Step copyWith({
    String? id,
    int? position,
    Recipie? recipie,
    String? text,
  }) {
    return Step(
      id: id ?? this.id,
      position: position ?? this.position,
      recipie: recipie ?? this.recipie,
      text: text ?? this.text,
    );
  }

  factory Step.fromJson(Map<String, dynamic> json) => _$StepFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$StepToJson(this);
    json['recipie'] = recipie.id;
    return json;
  }

  @override
  String toString() {
    return 'steps/$text';
  }
}
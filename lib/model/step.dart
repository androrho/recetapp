import 'package:json_annotation/json_annotation.dart';
import 'package:recetapp/model/recipie.dart';

part 'step.g.dart';

@JsonSerializable()
class Step {
  final String? id;
  final int position;
  final Recipie recipie;
  final String text;

  Step({
    this.id,
    required this.position,
    required this.recipie,
    required this.text,
  });

  factory Step.fromJson(Map<String, dynamic> json) => _$StepFromJson(json);

  Map<String, dynamic> toJson() => _$StepToJson(this);

  @override
  String toString() {
    return 'Step{text: $text}';
  }
}
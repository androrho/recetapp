import 'package:json_annotation/json_annotation.dart';

part 'step.g.dart';

@JsonSerializable()
class Step {
  final String? id;
  int? position;
  String? recipe;
  String? text;

  Step({
    this.id,
    required this.position,
    required this.recipe,
    required this.text,
  });

  Step copyWith({String? id, int? position, String? recipie, String? text}) {
    return Step(
      id: id ?? this.id,
      position: position ?? this.position,
      recipe: recipie ?? recipe,
      text: text ?? this.text,
    );
  }

  factory Step.fromJson(Map<String, dynamic> json) => _$StepFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$StepToJson(this);
    return json;
  }

  @override
  String toString() {
    return 'steps/$text';
  }
}

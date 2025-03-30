import 'package:json_annotation/json_annotation.dart';
import 'package:recetapp/model/user.dart';

part 'recipie.g.dart';

@JsonSerializable()
class Recipie {
  final String? id;
  final String description;
  final int personNumber;
  final String title;
  final User user;

  Recipie({
    this.id,
    required this.description,
    required this.personNumber,
    required this.title,
    required this.user,
  });

  factory Recipie.fromJson(Map<String, dynamic> json) => _$RecipieFromJson(json);

  Map<String, dynamic> toJson() => _$RecipieToJson(this);

  @override
  String toString() {
    return 'Recipie{login: $title}';
  }
}
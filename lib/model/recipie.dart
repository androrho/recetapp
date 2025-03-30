import 'package:json_annotation/json_annotation.dart';
import 'package:recetapp/model/user.dart';

part 'recipie.g.dart';

@JsonSerializable()
class Recipie {
  final String? id;
  String description;
  int personNumber;
  String title;
  User user;

  Recipie({
    this.id,
    required this.description,
    required this.personNumber,
    required this.title,
    required this.user,
  });

  Recipie copyWith({
    String? id,
    String? description,
    int? personNumber,
    String? title,
    User? user,
  }) {
    return Recipie(
      id: id ?? this.id,
      description: description ?? this.description,
      personNumber: personNumber ?? this.personNumber,
      title: title ?? this.title,
      user: user ?? this.user,
    );
  }

  factory Recipie.fromJson(Map<String, dynamic> json) => _$RecipieFromJson(json);

  Map<String, dynamic> toJson() => _$RecipieToJson(this);

  @override
  String toString() {
    return 'recipies/$id';
  }
}
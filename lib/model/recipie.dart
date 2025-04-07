import 'package:json_annotation/json_annotation.dart';

part 'recipie.g.dart';

@JsonSerializable()
class Recipie {
  final String? id;
  String? description;
  int? personNumber;
  String? title;
  String? user;

  Recipie({
    this.id,
    this.description,
    this.personNumber,
    this.title,
    this.user,
  });

  Recipie copyWith({
    String? id,
    String? description,
    int? personNumber,
    String? title,
    String? user,
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

  Map<String, dynamic> toJson() {
    final json = _$RecipieToJson(this);
    return json;
  }

  @override
  String toString() {
    return 'recipies/$id';
  }
}
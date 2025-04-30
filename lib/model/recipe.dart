import 'package:json_annotation/json_annotation.dart';

part 'recipe.g.dart';

@JsonSerializable()
class Recipe {
  final String? id;
  String? description;
  int? personNumber;
  String? title;
  String? user;

  Recipe({this.id, this.description, this.personNumber, this.title, this.user});

  Recipe copyWith({
    String? id,
    String? description,
    int? personNumber,
    String? title,
    String? user,
  }) {
    return Recipe(
      id: id ?? this.id,
      description: description ?? this.description,
      personNumber: personNumber ?? this.personNumber,
      title: title ?? this.title,
      user: user ?? this.user,
    );
  }

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$RecipeToJson(this);
    return json;
  }

  @override
  String toString() {
    return 'recipes/$id';
  }
}

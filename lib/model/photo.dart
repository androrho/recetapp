import 'package:json_annotation/json_annotation.dart';
import 'package:recetapp/model/recipie.dart';

part 'photo.g.dart';

@JsonSerializable()
class Photo {
  final String? id;
  String path;
  int position;
  Recipie recipie;

  Photo({
    this.id,
    required this.path,
    required this.position,
    required this.recipie,
  });

  Photo copyWith({
    String? id,
    String? path,
    int? position,
    Recipie? recipie,
  }) {
    return Photo(
      id: id ?? this.id,
      path: path ?? this.path,
      position: position ?? this.position,
      recipie: recipie ?? this.recipie,
    );
  }

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$PhotoToJson(this);
    json['recipie'] = recipie.id;
    return json;
  }

  @override
  String toString() {
    return 'photos/$path';
  }
}
import 'package:json_annotation/json_annotation.dart';
import 'package:recetapp/model/recipie.dart';

part 'photo.g.dart';

@JsonSerializable()
class Photo {
  final String? id;
  final String path;
  final int position;
  final Recipie recipie;

  Photo({
    this.id,
    required this.path,
    required this.position,
    required this.recipie,
  });

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);

  Map<String, dynamic> toJson() => _$PhotoToJson(this);

  @override
  String toString() {
    return 'Photo{path: $path}';
  }
}
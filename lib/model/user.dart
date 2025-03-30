import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String? id;
  String displayName;
  String login;
  String password;

  User({
    this.id,
    required this.displayName,
    required this.login,
    required this.password,
  });

  User copyWith({
    String? id,
    String? displayName,
    String? login,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      login: login ?? this.login,
      password: password ?? this.password,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() {
    return 'users/$id';
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String?,
  displayName: json['displayName'] as String,
  login: json['login'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'displayName': instance.displayName,
  'login': instance.login,
  'password': instance.password,
};

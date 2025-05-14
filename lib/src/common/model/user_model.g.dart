// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  email: json['email'] as String?,
  name: json['name'] as String?,
  uid: json['uid'] as String?,
  profile: json['profile'] as String?,
  followers:
      (json['followers'] as List<dynamic>?)?.map((e) => e as String).toList(),
  followings:
      (json['followings'] as List<dynamic>?)?.map((e) => e as String).toList(),
  discription: json['discription'] as String?,
  followersCount: (json['followersCount'] as num?)?.toInt(),
  reviewCounts: (json['reviewCounts'] as num?)?.toInt(),
  followingsCount: (json['followingsCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'uid': instance.uid,
  'name': instance.name,
  'email': instance.email,
  'profile': instance.profile,
  'followers': instance.followers,
  'followings': instance.followings,
  'followersCount': instance.followersCount,
  'followingsCount': instance.followingsCount,
  'reviewCounts': instance.reviewCounts,
  'discription': instance.discription,
};

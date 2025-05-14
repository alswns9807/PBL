import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  final String? uid;
  final String? name;
  final String? email;
  final String? profile;
  final List<String>? followers;
  final List<String>? followings;
  final int? followersCount;
  final int? followingsCount;
  final int? reviewCounts;
  final String? discription;
  const UserModel({
    this.email,
    this.name,
    this.uid,
    this.profile,
    this.followers,
    this.followings,
    this.discription,
    this.followersCount,
    this.reviewCounts,
    this.followingsCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toMap() => _$UserModelToJson(this);
  UserModel copyWith({
    String? email,
    String? name,
    String? uid,
    String? profile,
    List<String>? followers,
    List<String>? followings,
    int? followersCount,
    int? followingsCount,
    int? reviewCount,
    String? discription,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profile: profile ?? this.profile,
      followers: followers ?? this.followers,
      followings: followings ?? this.followings,
      discription: discription ?? this.discription,
      followingsCount: followingsCount ?? this.followingsCount,
      followersCount: followersCount ?? this.followersCount,
      reviewCounts: reviewCount ?? reviewCounts,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    name,
    email,
    profile,
    followers,
    followings,
    discription,
    followingsCount,
    followersCount,
    reviewCounts,
  ];
}
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  naverBookInfo:
      json['naverBookInfo'] == null
          ? null
          : NaverBookInfo.fromJson(
            json['naverBookInfo'] as Map<String, dynamic>,
          ),
  value: (json['value'] as num?)?.toDouble(),
  likedUsers:
      (json['likedUsers'] as List<dynamic>?)?.map((e) => e as String).toList(),
  reivew: json['reivew'] as String?,
  bookId: json['bookId'] as String?,
  reviewerUid: json['reviewerUid'] as String?,
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'bookId': instance.bookId,
  'reivew': instance.reivew,
  'value': instance.value,
  'reviewerUid': instance.reviewerUid,
  'likedUsers': instance.likedUsers,
  'naverBookInfo': instance.naverBookInfo?.toJson(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

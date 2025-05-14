// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_review_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookReviewInfo _$BookReviewInfoFromJson(Map<String, dynamic> json) =>
    BookReviewInfo(
      bookId: json['bookId'] as String?,
      naverBookInfo:
          json['naverBookInfo'] == null
              ? null
              : NaverBookInfo.fromJson(
                json['naverBookInfo'] as Map<String, dynamic>,
              ),
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
      totalCounts: (json['totalCounts'] as num?)?.toDouble(),
      reviewerUids:
          (json['reviewerUids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$BookReviewInfoToJson(BookReviewInfo instance) =>
    <String, dynamic>{
      'naverBookInfo': instance.naverBookInfo?.toJson(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'bookId': instance.bookId,
      'totalCounts': instance.totalCounts,
      'reviewerUids': instance.reviewerUids,
    };

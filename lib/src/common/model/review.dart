import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'naver_book_info.dart';

part 'review.g.dart';

@JsonSerializable(explicitToJson: true)
class Review extends Equatable {
  final String? bookId;
  final String? reivew;
  final double? value;
  final String? reviewerUid;
  final List<String>? likedUsers;
  final NaverBookInfo? naverBookInfo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Review({
    this.updatedAt,
    this.createdAt,
    this.naverBookInfo,
    this.value,
    this.likedUsers,
    this.reivew,
    this.bookId,
    this.reviewerUid,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  Review copyWith({
    DateTime? updatedAt,
    DateTime? createdAt,
    NaverBookInfo? naverBookInfo,
    String? reviewerUid,
    List<String>? likedUsers,
    double? value,
    String? reivew,
    String? bookId,
  }) {
    return Review(
      bookId: bookId ?? this.bookId,
      reivew: reivew ?? this.reivew,
      value: value ?? this.value,
      likedUsers: likedUsers ?? this.likedUsers,
      reviewerUid: reviewerUid ?? this.reviewerUid,
      naverBookInfo: naverBookInfo ?? this.naverBookInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    reivew,
    value,
    naverBookInfo,
    createdAt,
    updatedAt,
    likedUsers,
    bookId,
    reviewerUid,
  ];
}
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'naver_book_info.dart';

part 'book_review_info.g.dart';

@JsonSerializable(explicitToJson: true)
class BookReviewInfo extends Equatable {
  final NaverBookInfo? naverBookInfo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? bookId;
  final double? totalCounts;
  final List<String>? reviewerUids;

  const BookReviewInfo({
    this.bookId,
    this.naverBookInfo,
    this.createdAt,
    this.updatedAt,
    this.totalCounts,
    this.reviewerUids,
  });

  factory BookReviewInfo.fromJson(Map<String, dynamic> json) =>
      _$BookReviewInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BookReviewInfoToJson(this);

  BookReviewInfo copyWith({
    List<String>? reviewerUids,
    double? totalCounts,
    String? bookId,
    DateTime? updatedAt,
    DateTime? createdAt,
    NaverBookInfo? naverBookInfo,
  }) {
    return BookReviewInfo(
      reviewerUids: reviewerUids ?? this.reviewerUids,
      totalCounts: totalCounts ?? this.totalCounts,
      bookId: bookId ?? this.bookId,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      naverBookInfo: naverBookInfo ?? this.naverBookInfo,
    );
  }

  @override
  List<Object?> get props => [
    reviewerUids,
    totalCounts,
    updatedAt,
    createdAt,
    naverBookInfo,
    bookId,
  ];
}
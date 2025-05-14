import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../common/enum/common_state_status.dart';
import '../../../common/model/book_review_info.dart';
import '../../../common/model/naver_book_info.dart';
import '../../../common/model/review.dart';
import '../../../common/repository/book_review_info_repository.dart';
import '../../../common/repository/review_repository.dart';



class ReviewWriteCubit extends Cubit<ReviewWriteState> {
  final BookReviewInfoRepository _bookReviewInfoRepository;
  final ReviewRepository _reviewRepository;
  ReviewWriteCubit(this._bookReviewInfoRepository, this._reviewRepository,
      String uid, NaverBookInfo naverBookInfo)
      : super(ReviewWriteState(
      reviewInfo: Review(
          bookId: naverBookInfo.isbn,
          reviewerUid: uid,
          naverBookInfo: naverBookInfo))) {
    _loadReviewInfo();
  }

  _loadReviewInfo() async {
    var reviewInfo = await _reviewRepository.loadReviewInfo(
        state.reviewInfo!.bookId!, state.reviewInfo!.reviewerUid!);
    emit(state.copyWith(
      isEditMode: reviewInfo != null,
      reviewInfo: reviewInfo,
      beforeValue: reviewInfo?.value,
    ));
  }

  changeValue(double value) {
    emit(state.copyWith(reviewInfo: state.reviewInfo!.copyWith(value: value)));
  }

  changeReview(String review) {
    emit(
        state.copyWith(reviewInfo: state.reviewInfo!.copyWith(reivew: review)));
  }

  Future<void> insert() async {
    var now = DateTime.now();
    emit(state.copyWith(
        reviewInfo:
        state.reviewInfo!.copyWith(createdAt: now, updatedAt: now)));
    await _reviewRepository.createReview(state.reviewInfo!);

    var bookId = state.reviewInfo!.bookId!;
    var bookReviewInfo =
    await _bookReviewInfoRepository.loadBookReviewInfo(bookId);
    if (bookReviewInfo == null) {
      //insert
      var bookReviewInfo = BookReviewInfo(
        bookId: bookId,
        totalCounts: state.reviewInfo!.value,
        naverBookInfo: state.reviewInfo!.naverBookInfo!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        reviewerUids: [state.reviewInfo!.reviewerUid!],
      );
      await _bookReviewInfoRepository.createBookReviewInfo(bookReviewInfo); //await 수정
    } else {
      //update
      bookReviewInfo.reviewerUids!.add(state.reviewInfo!.reviewerUid!);
      bookReviewInfo = bookReviewInfo.copyWith(
        totalCounts: bookReviewInfo.totalCounts! -
            (state.beforeValue ?? 0) +
            state.reviewInfo!.value!,
        reviewerUids: bookReviewInfo.reviewerUids!.toSet().toList(),
        updatedAt: DateTime.now(),
      );
      _bookReviewInfoRepository.updateBookReviewInfo(bookReviewInfo);
    }
  }

  Future<void> update() async {
    var updateData = state.reviewInfo!.copyWith(updatedAt: DateTime.now());
    await _reviewRepository.updateReview(updateData);
    var bookReviewInfo =
    await _bookReviewInfoRepository.loadBookReviewInfo(updateData.bookId!);
    if (bookReviewInfo != null) {
      bookReviewInfo = bookReviewInfo.copyWith(
        updatedAt: DateTime.now(),
        totalCounts: bookReviewInfo.totalCounts! -
            (state.beforeValue ?? 0) +
            state.reviewInfo!.value!,
      );
      await _bookReviewInfoRepository.updateBookReviewInfo(bookReviewInfo);
    }
  }

  save() async {
    emit(state.copyWith(status: CommonStateStatus.loading));
    var message = '';
    if (state.isEditMode!) {
      await update();
      message = '리뷰가 수정되었습니다.';
    } else {
      await insert();
      message = '리뷰가 등록되었습니다.';
    }
    emit(state.copyWith(status: CommonStateStatus.loaded, message: message));
  }
}

class ReviewWriteState extends Equatable {
  final CommonStateStatus status;
  final Review? reviewInfo;
  final bool? isEditMode;
  final double? beforeValue;
  final String? message;
  const ReviewWriteState({
    this.reviewInfo,
    this.isEditMode,
    this.beforeValue,
    this.status = CommonStateStatus.init,
    this.message,
  });
  ReviewWriteState copyWith({
    Review? reviewInfo,
    bool? isEditMode,
    double? beforeValue,
    CommonStateStatus? status,
    String? message,
  }) {
    return ReviewWriteState(
      reviewInfo: reviewInfo ?? this.reviewInfo,
      isEditMode: isEditMode ?? this.isEditMode,
      beforeValue: beforeValue ?? this.beforeValue,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    reviewInfo,
    isEditMode,
    beforeValue,
    message,
    status,
  ];
}
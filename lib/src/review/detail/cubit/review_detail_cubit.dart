import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../common/model/review.dart';
import '../../../common/model/user_model.dart';
import '../../../common/repository/review_repository.dart';
import '../../../common/repository/user_repository.dart';

class ReviewDetailCubit extends Cubit<ReviewDetailState> {
  final ReviewRepository _reviewRepository;
  final UserRepository _userRepository;
  final String bookId;
  final String uid;
  ReviewDetailCubit(
      this._reviewRepository,
      this._userRepository,
      this.bookId,
      this.uid,
      ) : super(ReviewDetailState()) {
    _loadReviewInfo();
    _loadUserInfoData();
  }
  void _loadReviewInfo() async {
    var reviewData = await _reviewRepository.loadReviewInfo(bookId, uid);
    if (reviewData != null) {
      emit(state.copyWith(review: reviewData));
    }
  }

  void toggleLikedReview(String myUid) async {
    if (state.review!.likedUsers == null) {
      // like 이벤트
      emit(state.copyWith(
          review:
          state.review!.copyWith(likedUsers: List.unmodifiable([myUid]))));
    } else {
      if (state.review!.likedUsers!.contains(myUid)) {
        // unlike 이벤트
        emit(state.copyWith(
            review: state.review!.copyWith(
                likedUsers: List.unmodifiable([
                  ...state.review!.likedUsers!.where((uid) => uid != myUid)
                ]))));
      } else {
        // like 이벤트
        emit(state.copyWith(
            review: state.review!.copyWith(
                likedUsers:
                List.unmodifiable([...state.review!.likedUsers!, myUid]))));
      }
    }
    await _reviewRepository.updateReview(state.review!);
  }

  void _loadUserInfoData() async {
    var userModel = await _userRepository.findUserOne(uid);
    if (userModel != null) {
      emit(state.copyWith(userInfo: userModel));
    }
  }
}

class ReviewDetailState extends Equatable {
  final Review? review;
  final UserModel? userInfo;
  const ReviewDetailState({this.review, this.userInfo});

  ReviewDetailState copyWith({Review? review, UserModel? userInfo}) {
    return ReviewDetailState(
      review: review ?? this.review,
      userInfo: userInfo ?? this.userInfo,
    );
  }

  @override
  List<Object?> get props => [review, userInfo];
}

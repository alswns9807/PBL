import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../common/model/review.dart';
import '../../common/repository/review_repository.dart';

class UserReviewCubit extends Cubit<UserReviewState> {
  final ReviewRepository _reviewRepository;
  final String uid;
  UserReviewCubit(this._reviewRepository, this.uid) : super(UserReviewState()) {
    _loadMyAllReviews();
  }

  void _loadMyAllReviews() async {
    var result = await _reviewRepository.loadMyAllReviews(uid);
    emit(state.copyWith(results: result));
  }

  refresh() {
    _loadMyAllReviews();
  }
}

class UserReviewState extends Equatable {
  final List<Review> results;
  const UserReviewState({this.results = const []});
  UserReviewState copyWith({List<Review>? results}) {
    return UserReviewState(results: results ?? this.results);
  }

  @override
  List<Object?> get props => [results];
}
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../common/enum/common_state_status.dart';
import '../../common/model/book_review_info.dart';
import '../../common/model/user_model.dart';
import '../../common/repository/book_review_info_repository.dart';
import '../../common/repository/user_repository.dart';

class BookInfoCubit extends Cubit<BookInfoState> {
  final BookReviewInfoRepository _bookReviewInfoRepository;
  final UserRepository _userRepository;
  final String bookId;
  final String uid;
  BookInfoCubit(
      this._bookReviewInfoRepository,
      this._userRepository,
      this.bookId,
      this.uid,
      ) : super(BookInfoState()) {
    _loadBookReviewInfo();
  }

  void refresh() {
    _loadBookReviewInfo();
  }

  void _loadBookReviewInfo() async {
    emit(state.copyWith(status: CommonStateStatus.loading));
    var data = await _bookReviewInfoRepository.loadBookReviewInfo(bookId);
    if (data != null) {
      //리뷰 정보가 있는 상태
      if (data.reviewerUids!.isEmpty) return;
      var reviewList =
      await _userRepository.allUserInfos(data.reviewerUids ?? []);
      emit(state.copyWith(
        status: CommonStateStatus.loaded,
        bookReviewInfo: data,
        reviewers: reviewList,
      ));
    } else {
      emit(state.copyWith(status: CommonStateStatus.loaded));
    }
  }
}

class BookInfoState extends Equatable {
  final CommonStateStatus status;
  final BookReviewInfo? bookReviewInfo;
  final List<UserModel>? reviewers;

  const BookInfoState({
    this.reviewers,
    this.bookReviewInfo,
    this.status = CommonStateStatus.init,
  });

  BookInfoState copyWith({
    List<UserModel>? reviewers,
    BookReviewInfo? bookReviewInfo,
    CommonStateStatus? status,
  }) {
    return BookInfoState(
      bookReviewInfo: bookReviewInfo ?? this.bookReviewInfo,
      reviewers: reviewers ?? this.reviewers,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [reviewers, bookReviewInfo, status];
}
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../common/model/book_review_info.dart';
import '../../common/repository/book_review_info_repository.dart';

class RecentlyReviewCubit extends Cubit<RecentlyReviewState> {
  final BookReviewInfoRepository _bookReviewInfoRepository;
  RecentlyReviewCubit(this._bookReviewInfoRepository)
      : super(RecentlyReviewState()) {
    _loadBookReviewInfos();
  }
  void _loadBookReviewInfos() async {
    var results = await _bookReviewInfoRepository.loadBookReviewRecentlyData();
    emit(state.copyWith(results: results));
  }

  void refresh() {
    _loadBookReviewInfos();
  }
}

class RecentlyReviewState extends Equatable {
  final List<BookReviewInfo>? results;
  const RecentlyReviewState({this.results});
  RecentlyReviewState copyWith({
    List<BookReviewInfo>? results,
  }) {
    return RecentlyReviewState(results: results ?? this.results);
  }

  @override
  List<Object?> get props => [results];
}
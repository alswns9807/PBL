import 'package:bloc/bloc.dart';
import 'package:book_mate/src/common/model/user_model.dart';
import 'package:book_mate/src/common/repository/review_repository.dart';
import 'package:book_mate/src/common/repository/user_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import '../repository/authentication_repository.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> with ChangeNotifier {
  final AuthenticationRepository _authenticationRepository;
  final UserRepository _userRepository;
  final ReviewRepository _reviewRepository;
  AuthenticationCubit(this._authenticationRepository, this._userRepository, this._reviewRepository)
    : super(AuthenticationState());

  void init() {
      _authenticationRepository.user.listen((user) {
        _userStateChangedEvent(user);
      });
    }

  void _userStateChangedEvent(UserModel? user) async {
    if (user == null) {
      emit(state.copyWith(status: AuthenticationStatus.unknown));
    } else {
      var result = await _userRepository.findUserOne(user.uid!);
      if (result == null) {
        emit(state.copyWith(
            user: user, status: AuthenticationStatus.unAuthenticated));
      } else {
        emit(
          state.copyWith(
            user: result,
            status: AuthenticationStatus.authentication,
          ),
        );
      }
    }

    notifyListeners();
  }
  void reloadAuth() {
    _userStateChangedEvent(state.user);
  }

  void googleLogin() async {
    await _authenticationRepository.signInWithGoogle();
  }

  void appleLogin() async {
    await _authenticationRepository.signInWithApple();
  }

  void logout() async {
    _authenticationRepository.logout();
  }

  Future<void> updateReviewCounts() async {
    var results = await _reviewRepository.loadMyAllReviews(state.user!.uid!);
    await _userRepository.updateReviewCounts(state.user!.uid!, results.length);
  }

  @override
  void onChange(Change<AuthenticationState> change) {
    super.onChange(change);
    print(change);
  }
}

enum AuthenticationStatus{
  authentication,
  unAuthenticated,
  unknown,
  init,
  error,
}

class AuthenticationState extends Equatable {
  final AuthenticationStatus status;
  final UserModel? user;
  const AuthenticationState({
    this.status = AuthenticationStatus.init,
    this.user,
  });

  AuthenticationState copyWith({
    AuthenticationStatus? status,
    UserModel? user,
  }) {
    return AuthenticationState(
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, user];
}

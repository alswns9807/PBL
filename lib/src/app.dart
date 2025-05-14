import 'package:book_mate/src/chatting/chatting_list_page.dart';
import 'package:book_mate/src/home/page/home_content_page.dart';
import 'package:book_mate/src/profile/cubit/user_profile_cubit.dart';
import 'package:book_mate/src/profile/cubit/user_review_cubit.dart';
import 'package:book_mate/src/profile/page/user_profile_page.dart';
import 'package:book_mate/src/review/detail/cubit/review_detail_cubit.dart';
import 'package:book_mate/src/review/detail/page/review_detail_page.dart';
import 'package:book_mate/src/review/write/cubit/review_write_cubit.dart';
import 'package:book_mate/src/review/write/page/review_write_page.dart';
import 'package:book_mate/src/root/page/root_page.dart';
import 'package:book_mate/src/search/cubit/search_book_cubit.dart';
import 'package:book_mate/src/search/page/search_page.dart';
import 'package:book_mate/src/search/page/search_user_page.dart';
import 'package:book_mate/src/signup/cubit/signup_cubit.dart';
import 'package:book_mate/src/signup/page/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'book_info/cubit/book_info_cubit.dart';
import 'book_info/page/book_info_page.dart';
import 'common/cubit/authentication_cubit.dart';
import 'common/model/naver_book_info.dart';
import 'common/repository/book_review_info_repository.dart';
import 'common/repository/naver_api_repository.dart';
import 'common/repository/review_repository.dart';
import 'common/repository/user_repository.dart';
import 'home/cubit/recently_review_cubit.dart';
import 'home/cubit/top_reviewer_cubit.dart';
import 'home/page/home_page.dart';
import 'login/page/login_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late GoRouter router;
  @override
  void initState() {
    super.initState();
    router = GoRouter(
      initialLocation: '/',
      refreshListenable: context.read<AuthenticationCubit>(),
      redirect: (context, state) {
        var authStatus = context.read<AuthenticationCubit>().state.status;
        var blockPageInAuthenticationState = ['/', '/login', '/signup'];
        switch (authStatus) {
          case AuthenticationStatus.authentication:
            return blockPageInAuthenticationState.contains(state.uri.toString())
                ? '/home'
                : state.uri.toString();
          case AuthenticationStatus.unAuthenticated:
            return '/signup';
          case AuthenticationStatus.unknown:
            return '/login';
          case AuthenticationStatus.init:
            break;
          case AuthenticationStatus.error:
            break;
        }
        return state.path;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const RootPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => BlocProvider(
            create: (context) => SignupCubit(
              context.read<AuthenticationCubit>().state.user!,
              context.read<UserRepository>(),
            ),
            child: const SignupPage(),
          ),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => BlocProvider(
            create: (context) =>
                SearchBookCubit(context.read<NaverBookRepository>()),
            child: const SearchPage(),
          ),
        ),
        GoRoute(
          path: '/search-user',
          builder: (context, state) => BlocProvider(
            create: (context) =>
                SearchBookCubit(context.read<NaverBookRepository>()),
            child: const SearchUserPage(),
          ),
        ),
        GoRoute(
          path: '/chatting',
          builder: (context, state) => BlocProvider(
            create: (context) =>
              TopReviewerCubit(context.read<UserRepository>()),
            child: const ChattingListPage(),
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(
                lazy: false,
                create: (context) => RecentlyReviewCubit(
                    context.read<BookReviewInfoRepository>()),
              ),
              BlocProvider(
                lazy: false,
                create: (context) =>
                    TopReviewerCubit(context.read<UserRepository>()),
              ),
              BlocProvider(
                create: (context) => UserReviewCubit(
                  context.read<ReviewRepository>(),
                  context.read<AuthenticationCubit>().state.user!.uid as String,
                ),
              ),
            ],
            child: const HomePage(),
          ),
        ),
        GoRoute(
          path: '/info',
          builder: (context, state) => BlocProvider(
              create: (context) => BookInfoCubit(
                context.read<BookReviewInfoRepository>(),
                context.read<UserRepository>(),
                (state.extra as NaverBookInfo).isbn!,
                context.read<AuthenticationCubit>().state.user!.uid!,
              ),
              child: BookInfoPage(state.extra as NaverBookInfo)),
        ),
        GoRoute(
          path: '/review',
          builder: (context, state) => BlocProvider(
              create: (context) {
                var bookInfo = state.extra as NaverBookInfo;
                var uid = context.read<AuthenticationCubit>().state.user!.uid!;
                return ReviewWriteCubit(
                    context.read<BookReviewInfoRepository>(),
                    context.read<ReviewRepository>(),
                    uid,
                    bookInfo
                );
              },
              child: ReviewWritePage(state.extra as NaverBookInfo)),
        ),
        GoRoute(
          path: '/review-detail/:bookId/:uid',
          builder: (context, state) => BlocProvider(
              create: (context) => ReviewDetailCubit(
                context.read<ReviewRepository>(),
                context.read<UserRepository>(),
                state.pathParameters['bookId'] as String,
                state.pathParameters['uid'] as String,
              ),
              child: ReviewDetailPage(state.extra as NaverBookInfo)),
        ),
        GoRoute(
          path: '/profile/:uid',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => UserProfileCubit(
                  context.read<UserRepository>(),
                  state.pathParameters['uid'] as String,
                ),
                lazy: false,
              ),
              BlocProvider(
                create: (context) => UserReviewCubit(
                  context.read<ReviewRepository>(),
                  state.pathParameters['uid'] as String,
                ),
                lazy: false,
              ),
            ],
            child: const UserProfilePage(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xff1C1C1C),
          titleTextStyle: TextStyle(color: Colors.white)
        ),
        scaffoldBackgroundColor: const Color(0xff1C1C1C)
      ),
    );
  }
}

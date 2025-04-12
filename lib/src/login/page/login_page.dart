import 'package:book_mate/src/common/components/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/cubit/authentication_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Widget _googleLoginBtn(BuildContext context) {
    return GestureDetector(
      onTap: context.read<AuthenticationCubit>().googleLogin,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 50),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Colors.white,
        ),
        child: Row(
          children: [
            SvgPicture.asset('assets/svg/icons/google_logo.svg'),
            SizedBox(width: 30),
            AppFont('Google로 계속하기', color: Colors.black, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _appleLoginBtn(BuildContext context) {
    return GestureDetector(
      onTap: context.read<AuthenticationCubit>().appleLogin,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Colors.black,
        ),
        child: Row(
          children: [
            SvgPicture.asset('assets/svg/icons/apple_log.svg'),
            SizedBox(width: 20),
            AppFont('Apple로 계속하기', size: 14),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/splash_bg.png', fit: BoxFit.cover),
          Container(
            color: Colors.black.withOpacity(0.6),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Column(
                    children: [
                      AppFont(
                        '모두가 함께 하는 독서 생활!',
                        size: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 30),
                      AppFont(
                        '로그인하여 친구들과 이야기를 나누어 보세요.\n독서 기록을 분석하여 맞춤형 책 추천을 제공합니다.',
                        size: 13,
                        color: Color(0xff878787),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const AppFont(
                        '회원가입 / 로그인',
                        size: 14,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      _googleLoginBtn(context),
                      const SizedBox(height: 30),
                      _appleLoginBtn(context),
                    ],
                  ),
                  SizedBox(height: 150),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

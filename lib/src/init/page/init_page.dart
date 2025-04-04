import 'package:book_mate/src/common/components/app_font.dart';
import 'package:book_mate/src/common/components/btn.dart';
import 'package:book_mate/src/init/cubit/init_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InitPage extends StatelessWidget {
  const InitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
                'assets/images/splash_bg.png',
                fit: BoxFit.cover
            ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom,
              left: 40,
              right: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppFont(
                    '모두와 함께하는 독서 생활,\n시작해보세요.',
                    textAlign : TextAlign.center,
                    size: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 20,),
                  const AppFont(
                    '북메이트에서 독서 감상평을 등록하고,\n다른 독자들과 소통할 수 있습니다.\n맞춤형 책 추천도 받아보세요.',
                    textAlign : TextAlign.center,
                    size: 13,
                    color: Color(0xff878787),
                  ),
                  const SizedBox(height: 20,),
                  Btn(
                    onTap: context.read<InitCubit>().startApp,
                    text: '시작하기',
                  ),
                  const SizedBox(height: 40,),
                ],
              ),
            )
          ],
        ),
    );
  }
}

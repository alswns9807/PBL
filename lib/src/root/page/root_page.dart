import 'package:book_mate/src/init/cubit/init_cubit.dart';
import 'package:book_mate/src/init/page/init_page.dart';
import 'package:book_mate/src/splash/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InitCubit,bool>(builder:(context, state){
      return state ? const SplashPage() : const InitPage();
      },
    );
  }
}

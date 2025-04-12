import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/components/app_font.dart';
import '../../common/components/btn.dart';
import '../../common/components/loading.dart';
import '../../common/cubit/authentication_cubit.dart';
import '../../common/cubit/upload_cubit.dart';
import '../cubit/signup_cubit.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  Widget _signupView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
          child: GestureDetector(
            onTap: () {},
            child: SvgPicture.asset('assets/svg/icons/icon_close.svg'),
          ),
        )
      ]),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          _UserProfileImageField(),
          const SizedBox(height: 50),
          const _NicknameField(),
          const SizedBox(height: 30),
          const _DiscriptionField(),
        ]),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 20 + MediaQuery.of(context).padding.bottom,
          top: 20,
        ),
        child: Row(
          children: [
            Expanded(
              child: Btn(
                onTap: context.read<SignupCubit>().save,
                text: '회원가입',
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Btn(
                onTap: () {},
                backgroundColor: Color(0xff212121),
                text: '취소',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          BlocListener<SignupCubit, SignupState>(
            listenWhen: (previous, current) =>
              previous.status != current.status,
            listener: (context, state) {
              switch (state.status) {
                case SignupStatus.init:
                  break;
                case SignupStatus.loading:
                  break;
                case SignupStatus.uploading:
                  context.read<UploadCubit>().uploadUserProfile(
                      state.profileFile!, state.userModel!.uid!);
                  break;
                case SignupStatus.success:
                  context.read<AuthenticationCubit>().reloadAuth();
                  break;
                case SignupStatus.fail:
                  break;
              }
            },
          ),
          BlocListener<UploadCubit, UploadState>(
            listener: (context, state) {
              switch (state.status) {
                case UplaodStatus.init:
                  break;
                case UplaodStatus.uploading:
                  context
                      .read<SignupCubit>()
                      .uploadPercent(state.percent!.toStringAsFixed(2));
                  break;
                case UplaodStatus.success:
                  context.read<SignupCubit>().updateProfileImageUrl(state.url!);
                  break;
                case UplaodStatus.fail:
                  break;
              }
            },
          )
        ],
        child: Stack(
          children: [
            _signupView(context),
            BlocBuilder<SignupCubit, SignupState>(
              buildWhen: (previous, current) =>
              previous.percent != current.percent ||
                  previous.status != current.status,
              builder: (context, state) {
                if (state.percent != null &&
                    state.status == SignupStatus.uploading) {
                  return Loading(loadingMessage: '${state.percent}%');
                } else {
                  return Container();
                }
              },
            ),
          ],
        ));
  }
}

class _UserProfileImageField extends StatelessWidget {
  _UserProfileImageField({super.key});
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    var profileFile =
      context.select<SignupCubit, File?>((cubit) => cubit.state.profileFile);
    return Center(
      child: GestureDetector(
        onTap: () async {
          var image = await _picker.pickImage(source: ImageSource.gallery);
          context.read<SignupCubit>().changeProfileImage(image);
        },
        child: CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 50,
          backgroundImage: profileFile == null
              ? Image.asset('assets/images/default_avatar.png').image
              : Image.file(profileFile).image,
        ),
      ),
    );
  }
}

class _NicknameField extends StatelessWidget {
  const _NicknameField({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppFont(
          '유저 이름',
          size: 16,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 15),
        TextField(
          onChanged: context.read<SignupCubit>().changeNickName,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xff232323),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              gapPadding: 0,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              gapPadding: 0,
              borderSide: BorderSide.none,
            ),
          ),
        )
      ],
    );
  }
}

class _DiscriptionField extends StatelessWidget {
  const _DiscriptionField({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppFont(
          '한줄 소개',
          size: 16,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 15),
        TextField(
          onChanged: context.read<SignupCubit>().changeDiscription,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          maxLength: 50,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xff232323),
            counterStyle: const TextStyle(color: Colors.white, fontSize: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              gapPadding: 0,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              gapPadding: 0,
              borderSide: BorderSide.none,
            ),
          ),
        )
      ],
    );
  }
}
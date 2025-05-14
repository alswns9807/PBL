import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../common/components/app_divider.dart';
import '../../common/components/app_font.dart';
import '../../common/components/icon_statistic_widget.dart';
import '../../common/cubit/authentication_cubit.dart';
import '../../common/enum/common_state_status.dart';
import '../cubit/user_profile_cubit.dart';
import '../cubit/user_review_cubit.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: context.pop,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SvgPicture.asset('assets/svg/icons/icon_arrow_back.svg'),
          ),
        ),
        title: BlocBuilder<UserProfileCubit, UserProfileState>(
            builder: (context, state) {
              return AppFont('${state.userInfo?.name} 리뷰어', size: 18);
            }),
        actions: [
          GestureDetector(
            onTap: () {
              var myUid = context.read<AuthenticationCubit>().state.user!.uid;
              context.read<UserProfileCubit>().followToggleEvent(myUid!);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: BlocBuilder<UserProfileCubit, UserProfileState>(
                  builder: (context, state) {
                    var myUid = context.read<AuthenticationCubit>().state.user!.uid;
                    var isFollowing =
                        state.userInfo?.followers?.contains(myUid) ?? false;
                    return SvgPicture.asset(isFollowing
                        ? 'assets/svg/icons/icon_follow_on.svg'
                        : 'assets/svg/icons/icon_follow_off.svg');
                  }),
            ),
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const _ProfileInfo(),
                const AppDivider(),
                const _ReviewList(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList();

  @override
  Widget build(BuildContext context) {
    var state = context.watch<UserReviewCubit>().state;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        mainAxisExtent: 270,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            context.push(
                '/review-detail/${state.results[index].bookId}/${state.results[index].reviewerUid}',
                extra: state.results[index].naverBookInfo!);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.network(
                    state.results[index].naverBookInfo?.image ?? '',
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: AppFont(
                  state.results[index].naverBookInfo?.title ?? '',
                  maxLine: 2,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: AppFont(
                  state.results[index].naverBookInfo?.author ?? '',
                  size: 12,
                  color: const Color(0xff878787),
                ),
              )
            ],
          ),
        );
      },
      itemCount: state.results.length,
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo();

  @override
  Widget build(BuildContext context) {
    var cubit = context.watch<UserProfileCubit>();
    return Column(
      children: [
        const SizedBox(height: 20),
        cubit.state.status == CommonStateStatus.loaded
            ? CircleAvatar(
          radius: 33,
          backgroundColor: Colors.grey,
          backgroundImage: cubit.state.userInfo?.profile == null
              ? Image.asset('assets/images/default_avatar.png').image
              : Image.network(cubit.state.userInfo?.profile ?? '').image,
        )
            : const Center(
          child: CircularProgressIndicator(
            strokeWidth: 1,
          ),
        ),
        const SizedBox(height: 20),
        AppFont(cubit.state.userInfo?.discription ?? ''),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: const Color(0xff5F5F5F),
                ),
              ),
              child: BlocBuilder<UserReviewCubit, UserReviewState>(
                  builder: (context, state) {
                    return IconStatisticWidget(
                      iconPath: 'assets/svg/icons/icon_journals.svg',
                      value: state.results.length,
                    );
                  }),
            ),
            const SizedBox(width: 5),
            Container(
                padding:
                const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: const Color(0xff5F5F5F),
                  ),
                ),
                child: BlocBuilder<UserProfileCubit, UserProfileState>(
                    builder: (context, state) {
                      return IconStatisticWidget(
                        iconPath: 'assets/svg/icons/icon_people.svg',
                        value: state.userInfo?.followers?.length ?? 0,
                      );
                    }))
          ],
        ),
      ],
    );
  }
}
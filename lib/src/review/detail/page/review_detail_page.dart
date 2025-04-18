import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../common/components/app_divider.dart';
import '../../../common/components/app_font.dart';
import '../../../common/components/book_review_header_widget.dart';
import '../../../common/cubit/authentication_cubit.dart';
import '../../../common/model/naver_book_info.dart';
import '../../../common/utils/data_util.dart';
import '../cubit/review_detail_cubit.dart';

class ReviewDetailPage extends StatelessWidget {
  final NaverBookInfo naverBookInfo;
  const ReviewDetailPage(this.naverBookInfo, {super.key});

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
        title: const AppFont('리뷰', size: 18),
      ),
      body: Column(
        children: [
          BookReviewHeaderWidget(
            naverBookInfo: naverBookInfo,
            reviewCountDisplayWidget: Row(
              children: [
                SvgPicture.asset(
                  'assets/svg/icons/icon_star.svg',
                  width: 22,
                ),
                const SizedBox(width: 5),
                BlocBuilder<ReviewDetailCubit, ReviewDetailState>(
                    builder: (context, state) {
                      return AppFont(
                        (state.review?.value ?? 0).toStringAsFixed(1),
                        color: const Color(0xffF4AA2B),
                        size: 16,
                      );
                    })
              ],
            ),
          ),
          const AppDivider(),
          Expanded(
            child: _ReviewInfoWidget(),
          ),
        ],
      ),
    );
  }
}

class _ReviewInfoWidget extends StatelessWidget {
  const _ReviewInfoWidget({super.key});

  Widget _profile(ReviewDetailState state, BuildContext context) {
    if (state.review == null) return Container();
    return GestureDetector(
      onTap: () {
        context.push('/profile/${state.userInfo!.uid}');
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 33,
            backgroundColor: Colors.grey,
            backgroundImage: state.userInfo?.profile == null
                ? Image.asset('assets/images/default_avatar.png').image
                : Image.network(state.userInfo!.profile!).image,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFont(
                  state.userInfo?.name ?? '',
                  size: 18,
                  color: const Color(0xffC9C9C9),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppFont(
                      '공감 ${state.review!.likedUsers?.length ?? 0} 개',
                      size: 15,
                      color: Color(0xffC9C9C9),
                      fontWeight: FontWeight.bold,
                    ),
                    AppFont(
                      AppDataUtil.dateFormat(
                          'yyyy.MM.dd', state.review!.createdAt!),
                      size: 12,
                      color: Color(0xff878787),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: BlocBuilder<ReviewDetailCubit, ReviewDetailState>(
          builder: (context, state) {
            var myUid = context.read<AuthenticationCubit>().state.user!.uid!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _profile(state, context),
                const SizedBox(height: 30),
                AppFont(
                  state.review?.reivew ?? '',
                  size: 14,
                  color: const Color(0xffA7A7A7),
                ),
                GestureDetector(
                  onTap: () {
                    context.read<ReviewDetailCubit>().toggleLikedReview(myUid);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: SvgPicture.asset(
                      'assets/svg/icons/icon_liked.svg',
                      width: 30,
                      colorFilter: state.review?.likedUsers?.contains(myUid) ??
                          false
                          ? const ColorFilter.mode(
                          Color(0xe49dce62), BlendMode.srcIn)
                          : const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                    ),
                  ),
                )
              ],
            );
          }),
    );
  }
}
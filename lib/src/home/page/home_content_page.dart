import 'package:book_mate/src/common/components/app_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../common/components/app_font.dart';
import '../../common/components/icon_statistic_widget.dart';
import '../../common/components/input_widget.dart';
import '../../common/cubit/authentication_cubit.dart';
import '../../common/model/book_review_info.dart';
import '../../profile/cubit/user_review_cubit.dart';
import '../cubit/recently_review_cubit.dart';
import '../cubit/top_reviewer_cubit.dart';

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage>{
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppFont(
                '북메이트',
                size: 25,
                fontWeight: FontWeight.bold,
                //textAlign: TextAlign.center,
              ),
              GestureDetector(
                onTap: () {
                  context.push('/chatting');
                },
                child: Icon(
                  Icons.sms,
                  color: Color(0xe49dce62),
                ),
              )
            ]
          ),
        ),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: () {
          context.read<TopReviewerCubit>().refresh();     // refresh 할 데이터
          context.read<RecentlyReviewCubit>().refresh();
          _refreshController.refreshCompleted();
        },
        onLoading: () {
          _refreshController.loadComplete();
        },
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const _ReviewList(),
                ],
              ),
            ),
          ],
        ),
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
        crossAxisCount: 1,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        //mainAxisExtent: 250,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            context.push(
                '/review-detail/${state.results[index].bookId}/${state.results[index].reviewerUid}',
                extra: state.results[index].naverBookInfo!);
          },
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: () {
                        context.push('/profile/${state.user!.uid}');
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: state.user?.profile == null
                              ? Image.asset('assets/images/default_avatar.png')
                              .image
                              : Image.network(state.user!.profile!).image,
                          ),
                          const SizedBox(width: 15),
                          AppFont(state.user?.name ?? '', size: 16),
                        ]
                      ),
                    );
                  }
                  //const SizedBox(height: 10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    state.results[index].naverBookInfo?.image ?? '',
                    height: 250,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                child: AppFont(
                  state.results[index].naverBookInfo?.title ?? '',
                  maxLine: 1,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                child: AppFont(
                  state.results[index].naverBookInfo?.author ?? '',
                  size: 12,
                  color: const Color(0xff878787),
                ),
              ),
            ],
          ),
        );
      },
      itemCount: state.results.length,
    );
  }
}



class _RecentlyReviewListWidget extends StatelessWidget {
  const _RecentlyReviewListWidget();
  Widget _header() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppFont(
            '최신리뷰',
            fontWeight: FontWeight.bold,
            size: 20,
          ),
          AppFont(
            '더보기',
            fontWeight: FontWeight.bold,
            size: 14,
            color: Color(0xe49dce62),
          )
        ],
      ),
    );
  }

  Widget _bookView(BookReviewInfo bookInfo, BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/info', extra: bookInfo.naverBookInfo);
      },
      behavior: HitTestBehavior.translucent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * 0.5,
                  child: Image.network(
                    bookInfo.naverBookInfo?.image ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.only(left: 15),
                    color: Colors.black.withOpacity(0.5),
                    child: Row(children: [
                      SvgPicture.asset('assets/svg/icons/icon_star.svg',
                          width: 22),
                      const SizedBox(width: 5),
                      AppFont(
                        ((bookInfo.totalCounts ?? 0) /
                            (bookInfo.reviewerUids?.length ?? 0))
                            .toStringAsFixed(1),
                        size: 16,
                        color: Color(0xe49dce62),
                      )
                    ]),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 15),
          AppFont(
            bookInfo.naverBookInfo?.title ?? '',
            maxLine: 2,
            overflow: TextOverflow.ellipsis,
            size: 13,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 10),
          AppFont(
            bookInfo.naverBookInfo?.author ?? '',
            size: 12,
            color: Color(0xff878787),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _header(),
        const SizedBox(height: 15),
        SizedBox(
          height: MediaQuery.of(context).size.width * 0.5 + 100,
          child: Padding(
            padding: const EdgeInsets.only(left: 25),
            child: BlocBuilder<RecentlyReviewCubit, RecentlyReviewState>(
                builder: (context, state) {
                  return PageView.builder(
                    padEnds: false,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(right: 25),
                        child: _bookView(state.results![index], context),
                      );
                    },
                    controller: PageController(viewportFraction: 0.45),
                    itemCount: state.results?.length ?? 0,
                  );
                }),
          ),
        )
      ],
    );
  }
}

class _TopReviewerListWidget extends StatelessWidget {
  const _TopReviewerListWidget();
  Widget _header() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: AppFont(
        '인기 리뷰어',
        fontWeight: FontWeight.bold,
        size: 20,
      ),
    );
  }

  Widget _reviewers() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: BlocBuilder<TopReviewerCubit, TopReviewerState>(
          builder: (context, state) {
            return Column(
              children: List.generate(
                state.results?.length ?? 0,
                    (index) {
                  return GestureDetector(
                    onTap: () {
                      context.push('/profile/${state.results![index].uid}');
                    },
                    child: Container(
                      height: 85,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(85),
                        color: const Color(0xff212121),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 32,
                              backgroundImage:
                              Image.network(state.results?[index].profile ?? '')
                                  .image,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppFont(
                                  state.results?[index].name ?? '',
                                  fontWeight: FontWeight.bold,
                                  size: 16,
                                ),
                                const SizedBox(height: 8),
                                AppFont(
                                  state.results?[index].discription ?? '',
                                  size: 12,
                                  color: const Color(
                                    0xff737373,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconStatisticWidget(
                                      iconPath:
                                      'assets/svg/icons/icon_journals.svg',
                                      value:
                                      state.results?[index].reviewCounts ?? 0,
                                    ),
                                    const SizedBox(width: 20),
                                    IconStatisticWidget(
                                      iconPath: 'assets/svg/icons/icon_people.svg',
                                      value:
                                      state.results?[index].followersCount ?? 0,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_header(), _reviewers()],
    );
  }
}
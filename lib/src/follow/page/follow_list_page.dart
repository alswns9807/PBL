import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../common/components/app_font.dart';
import '../../common/components/icon_statistic_widget.dart';
import '../../common/components/input_widget.dart';
import '../../home/cubit/top_reviewer_cubit.dart';

class FollowListPage extends StatefulWidget {
  const FollowListPage({super.key});

  @override
  State<StatefulWidget> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            //backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            //elevation: 0,
            expandedHeight: 110,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(15, 60, 20, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppFont(
                      '유저 검색',
                      fontWeight: FontWeight.bold,
                      size: 20,
                    ),
                    const SizedBox(height: 10),
                    InputWidget(
                      isEnabled: false,
                      onTap: () {
                        context.push('/search-user');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const _FollowList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowList extends StatelessWidget {
  const _FollowList();
  Widget _header() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: AppFont(
        '팔로우 목록',
        fontWeight: FontWeight.bold,
        size: 20,
      ),
    );
  }

  Widget _followView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
                        borderRadius: BorderRadius.circular(10),
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
                          ),
                          GestureDetector(
                            onTap: (){
                              context.push('/chatting');
                            },
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Icon(
                                Icons.sms,
                                color: Color(0xe49dce62),
                              ),
                            ),
                          ),
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
      children: [_header(), _followView()],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../common/components/app_font.dart';
import '../common/components/icon_statistic_widget.dart';
import '../common/components/input_widget.dart';
import '../home/cubit/top_reviewer_cubit.dart';

class ChattingListPage extends StatefulWidget {
  const ChattingListPage({super.key});

  @override
  State<StatefulWidget> createState() => _ChattingListPageState();
}

class _ChattingListPageState extends State<ChattingListPage>{
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
        centerTitle: false,
        title: AppFont(
          '채팅 목록',
          fontWeight: FontWeight.bold,
          size: 20,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const _ChattingList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChattingList extends StatelessWidget {
  const _ChattingList();
  // Widget _header() {
  //   return const Padding(
  //     padding: EdgeInsets.symmetric(horizontal: 15),
  //     child: AppFont(
  //       '채팅 목록',
  //       fontWeight: FontWeight.bold,
  //       size: 20,
  //     ),
  //   );
  // }

  Widget _chattingView() {
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
      children: [_chattingView()],
    );
  }
}
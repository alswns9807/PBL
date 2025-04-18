import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../common/components/app_divider.dart';
import '../../common/components/app_font.dart';
import '../../common/components/btn.dart';
import '../../common/model/naver_book_info.dart';
import '../cubit/book_info_cubit.dart';

class BookInfoPage extends StatelessWidget {
  final NaverBookInfo bookInfo;
  const BookInfoPage(this.bookInfo, {super.key});

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
        title: const AppFont('책 소개', size: 18),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _BookDisplayLayer(bookInfo),
            const AppDivider(),
            _BookSimpleInfoLayer(bookInfo),
            const AppDivider(),
            _ReviewerLayer(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.of(context).padding.bottom,
        ),
        child: Btn(
          onTap: () async {
            var isNeedsRefresh =
            await context.push<bool?>('/review', extra: bookInfo);
            if (isNeedsRefresh != null && isNeedsRefresh) {
              context.read<BookInfoCubit>().refresh();
            }
          },
          text: '감상 작성',
        ),
      ),
    );
  }
}

class _ReviewerLayer extends StatelessWidget {
  const _ReviewerLayer({super.key});

  Widget _noneReviewer() {
    return const Center(
      child: AppFont(
        '등록된 감상평이 없습니다',
        size: 17,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppFont(
            '리뷰어',
            size: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 20),
          BlocBuilder<BookInfoCubit, BookInfoState>(builder: (context, state) {
            if (state.bookReviewInfo == null) {
              return SizedBox(height: 70, child: _noneReviewer());
            } else {
              return SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        context.push(
                            '/review-detail/${state.bookReviewInfo!.bookId}/${state.reviewers![index].uid}',
                            extra: state.bookReviewInfo!.naverBookInfo!);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 32,
                        backgroundImage:
                        Image.network(state.reviewers![index].profile ?? '')
                            .image,
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                  const SizedBox(width: 20),
                  itemCount: state.reviewers?.length ?? 0,
                ),
              );
            }
          }),
        ],
      ),
    );
  }
}

class _BookSimpleInfoLayer extends StatelessWidget {
  final NaverBookInfo bookInfo;
  const _BookSimpleInfoLayer(this.bookInfo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppFont(
            '간단 소개',
            size: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 20),
          AppFont(
            bookInfo.description ?? '',
            size: 13,
            lineHeight: 1.5,
            color: const Color(0xff898989),
          ),
        ],
      ),
    );
  }
}

class _BookDisplayLayer extends StatelessWidget {
  final NaverBookInfo bookInfo;
  const _BookDisplayLayer(this.bookInfo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: SizedBox(
              width: 152,
              height: 227,
              child: Image.network(
                bookInfo.image ?? '',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/svg/icons/icon_star.svg'),
              const SizedBox(width: 5),
              BlocBuilder<BookInfoCubit, BookInfoState>(
                  builder: (context, state) {
                    return AppFont(
                      state.bookReviewInfo == null
                          ? '평점 없음'
                          : (state.bookReviewInfo!.totalCounts! /
                          state.bookReviewInfo!.reviewerUids!.length)
                          .toStringAsFixed(2),
                      size: 16,
                      color: Color(0xffF4AA2B),
                    );
                  })
            ],
          ),
          const SizedBox(height: 10),
          AppFont(
            bookInfo.title ?? '',
            textAlign: TextAlign.center,
            size: 16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 5),
          AppFont(
            bookInfo.author ?? '',
            size: 12,
            color: const Color(0xff878787),
          )
        ],
      ),
    );
  }
}
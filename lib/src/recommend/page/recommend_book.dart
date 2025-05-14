import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../common/components/app_font.dart';
import '../../profile/cubit/user_review_cubit.dart';

class RecommendBook extends StatefulWidget {
  const RecommendBook({super.key});

  @override
  State<StatefulWidget> createState() => _RecommendBookState();
}

class _RecommendBookState extends State<RecommendBook> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: AppFont(
          '이런 책은 어떠세요?',
          fontWeight: FontWeight.bold,
          size: 20,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const _RecommendBookList(),
              ],
            ),
          ),
        ],
      )
    );
  }
}

class _RecommendBookList extends StatelessWidget {
  const _RecommendBookList();

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

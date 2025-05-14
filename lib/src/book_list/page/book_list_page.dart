import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../common/components/app_font.dart';
import '../../common/components/input_widget.dart';
import '../../common/cubit/authentication_cubit.dart';
import '../../profile/cubit/user_review_cubit.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<BookListPage>{
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
            child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
                builder: (context, state) {
                  return GestureDetector(
                    onTap: () {
                      context.read<AuthenticationCubit>().logout();
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
                        Spacer(),
                        GestureDetector(
                          onTap: () {

                          },
                          child: AppFont(
                            '로그아웃',
                            size: 15,
                            color: const Color(0xff878787),
                          ),
                        )
                      ],
                    ),
                  );
                }),
          )),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputWidget(
                      isEnabled: false,
                      onTap: () {
                        context.push('/search');
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
                const _ReviewList(),
              ],
            ),
          ),
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
              ),
            ],
          ),
        );
      },
      itemCount: state.results.length,
    );
  }
}

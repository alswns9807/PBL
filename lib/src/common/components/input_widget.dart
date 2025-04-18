import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class InputWidget extends StatelessWidget {
  final bool isEnabled;
  final Function()? onTap;
  final Function(String)? onSearch;
  const InputWidget({
    super.key,
    this.onTap,
    this.onSearch,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50), color: Color(0xff232323)),
        child: Row(
          children: [
            SvgPicture.asset('assets/svg/icons/icon_search.svg'),
            Expanded(
              child: TextField(
                style: const TextStyle(color: Colors.white),
                onSubmitted: onSearch,
                decoration: InputDecoration(
                  hintText: '검색어를 입력해주세요.',
                  hintStyle: const TextStyle(
                    color: Color(0xff585858),
                  ),
                  enabled: isEnabled,
                  contentPadding: const EdgeInsets.only(left: 10),
                  enabledBorder:
                  const UnderlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder:
                  const UnderlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import 'app_font.dart';

class Loading extends StatelessWidget {
  final String? loadingMessage;
  const Loading({super.key, this.loadingMessage});

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.white,
                  ),
                  if (loadingMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: AppFont(
                        loadingMessage!,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ));
  }
}
import 'package:dio/dio.dart';

class CustomInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Naver-Client-Id'] = 'NyEYjbWJa4esc5of_YfM';
    options.headers['X-Naver-Client-Secret'] = 'Ig_qAQo4Za';
    super.onRequest(options, handler);
  }
}
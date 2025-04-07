import 'dart:convert';

import 'package:bookmate/model/webtoon_model.dart';
import 'package:http/http.dart' as http;

class ApiService {

  static final String baseUrl = "https://webtoon-crawler.nomadcoders.workers.dev";
  static final String today = "today";

  static Future<List<WebtoonModel>> getTodaysToons() async{
    List<WebtoonModel> webtoonInstances = [];
    final url = Uri.parse("${baseUrl}/${today}");
    final response = await http.get(url);

    if(response.statusCode == 200) {
      final webtoons = jsonDecode(response.body);
      for(var webtoon in webtoons){
        webtoonInstances.add(WebtoonModel.fromJson(webtoon));
      }
      return webtoonInstances;
    }
    throw Error();
  }
  
}
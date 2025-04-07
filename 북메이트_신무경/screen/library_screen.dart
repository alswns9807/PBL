import 'package:bookmate/model/webtoon_model.dart';
import 'package:bookmate/service/api_service.dart';
import 'package:flutter/material.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  Future<List<WebtoonModel>> webtoons = ApiService.getTodaysToons();
  List<WebtoonModel> filteredWebtoons = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    webtoons.then((data) {
      setState(() {
        filteredWebtoons = data; // 처음에는 전체 리스트를 표시
      });
    });
  }

  void filterSearchResults(String query) {
    webtoons.then((data) {
      setState(() {
        if (query.isEmpty) {
          filteredWebtoons = data;
        } else {
          filteredWebtoons = data
              .where((webtoon) =>
                  webtoon.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 202, 172, 126),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) => filterSearchResults(value),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: const Icon(Icons.photo_camera),
                    hintText: '책 검색',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    for (var i = 0; i < (filteredWebtoons.length / 3).ceil(); i++)
                      Container(
                        margin: EdgeInsets.only(bottom: 30),
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade800,
                              width: 15.0,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (var j = 0; j < 3; j++)
                              if (i * 3 + j < filteredWebtoons.length)
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      width: 120,
                                      padding: EdgeInsets.symmetric(vertical: 3),
                                      child: Text(
                                        filteredWebtoons[i * 3 + j].title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Expanded(
                                      child: Image.network(
                                        filteredWebtoons[i * 3 + j].thumb,
                                        fit: BoxFit.cover,
                                        headers: {
                                          "User-Agent":
                                              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36"
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

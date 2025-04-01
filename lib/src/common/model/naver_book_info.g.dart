// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'naver_book_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NaverBookInfo _$NaverBookInfoFromJson(Map<String, dynamic> json) =>
    NaverBookInfo(
      json['title'] as String?,
      json['link'] as String?,
      json['image'] as String?,
      json['author'] as String?,
      json['discount'] as String?,
      json['publisher'] as String?,
      json['pubdate'] as String?,
      json['isbn'] as String?,
      json['description'] as String?,
    );

Map<String, dynamic> _$NaverBookInfoToJson(NaverBookInfo instance) =>
    <String, dynamic>{
      'title': instance.title,
      'link': instance.link,
      'image': instance.image,
      'author': instance.author,
      'discount': instance.discount,
      'publisher': instance.publisher,
      'pubdate': instance.pubdate,
      'isbn': instance.isbn,
      'description': instance.description,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'naver_book_search_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NaverBookSearchOption _$NaverBookSearchOptionFromJson(
  Map<String, dynamic> json,
) => NaverBookSearchOption(
  query: json['query'] as String?,
  display: (json['display'] as num?)?.toInt(),
  start: (json['start'] as num?)?.toInt(),
  sort: $enumDecodeNullable(_$NaverBookSearchTypeEnumMap, json['sort']),
);

Map<String, dynamic> _$NaverBookSearchOptionToJson(
  NaverBookSearchOption instance,
) => <String, dynamic>{
  'query': instance.query,
  'display': instance.display,
  'start': instance.start,
  'sort': _$NaverBookSearchTypeEnumMap[instance.sort],
};

const _$NaverBookSearchTypeEnumMap = {
  NaverBookSearchType.date: 'date',
  NaverBookSearchType.sim: 'sim',
};

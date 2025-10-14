import 'package:dio/dio.dart';
import 'package:route_pick_fe/core/http/api_client.dart';
import 'package:route_pick_fe/features/posts/data/post_model.dart';

class PageResult<T> {
  final List<T> items;
  final bool hasNext;
  final int? nextPage;
  const PageResult({required this.items, required this.hasNext, this.nextPage});
}

class PostsApi {
  final Dio _dio;
  PostsApi({Dio? dio}) : _dio = dio ?? http;

  // 표준 페이지 요청 (Spring Data JPA 대응)
  Future<PageResult<Post>> listPaged({int page = 0, int size = 20}) async {
    final res = await _dio.get(
      '/posts',
      queryParameters: {
        'page': page,
        'size': size,
        // 백엔드가 Spring이면 보통 createdAt(프로퍼티명), 필요 시 created_at로 맞춰주기
        'sort': 'createdAt,desc',
      },
    );
    final data = res.data;

    dynamic rawList;
    bool? last; // Spring Page의 last(boolean) 지원
    int? totalPages; // Spring Page totalPages
    int? number; // Spring Page number(현재 페이지 index)
    bool? hasNextFlag; // 커스텀 API가 hasNext를 줄 수도 있음

    if (data is List) {
      rawList = data;
    } else if (data is Map) {
      if (data['content'] is List) {
        rawList = data['content'];
        last = data['last'] as bool?;
        totalPages = (data['totalPages'] is num)
            ? (data['totalPages'] as num).toInt()
            : null;
        number = (data['number'] is num)
            ? (data['number'] as num).toInt()
            : null;
      } else if (data['items'] is List) {
        rawList = data['items'];
        if (data['hasNext'] is bool) hasNextFlag = data['hasNext'] as bool;
      } else if (data['data'] is Map) {
        final inner = data['data'] as Map;
        if (inner['items'] is List) {
          rawList = inner['items'];
          if (inner['hasNext'] is bool) hasNextFlag = inner['hasNext'] as bool;
        } else if (inner['content'] is List) {
          rawList = inner['content'];
          if (inner['last'] is bool) last = inner['last'] as bool;
        }
      }
    }

    final list = (rawList is List) ? rawList : const <dynamic>[];
    final posts = list
        .map<Post>((e) => Post.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    bool hasNext;
    if (hasNextFlag != null) {
      hasNext = hasNextFlag;
    } else if (last != null) {
      hasNext = !last;
    } else if (totalPages != null && number != null) {
      hasNext = (number + 1) < totalPages;
    } else {
      // 정보가 없으면 "이번에 size만큼 왔으면 더 있을 것"으로 추정
      hasNext = posts.length == size;
    }

    return PageResult(
      items: posts,
      hasNext: hasNext,
      nextPage: hasNext ? page + 1 : null,
    );
  }

  Future<Post> getOne(String id) async {
    final res = await _dio.get('/posts/$id');
    final data = (res.data is Map)
        ? Map<String, dynamic>.from(res.data)
        : <String, dynamic>{};
    return Post.fromMap(data);
  }

  Future<String> create({
    required String title,
    required String content,
    String? region,
    List<String>? tags,
    double? latitude,
    double? longitude,
    required String accessToken,
  }) async {
    final res = await _dio.post(
      '/posts',
      data: {
        'title': title,
        'content': content,
        if (region != null && region.isNotEmpty) 'region': region,
        if (tags != null) 'tags': tags,
        if (latitude != null && longitude != null) ...{
          'latitude': latitude,
          'longitude': longitude,
        },
      },
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    final data = res.data;
    if (data is Map && data['id'] != null) return '${data['id']}';
    if (data is Map && data['data'] is Map && data['data']['id'] != null) {
      return '${data['data']['id']}';
    }
    return '$data';
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:route_pick_fe/features/posts/data/post_model.dart';
import 'package:route_pick_fe/features/posts/data/posts_api.dart';
import 'package:route_pick_fe/features/state/auth_providers.dart';

final postsApiProvider = Provider<PostsApi>((_) => PostsApi());

class PostsState {
  final List<Post> items;
  final int page; // 다음 요청할 페이지 index
  final bool isLoading; // 첫 로딩 or 새로고침 로딩
  final bool isLoadingMore; // 더 불러오는 중
  final bool hasMore; // 다음 페이지가 더 있는지
  final Object? error;

  const PostsState({
    required this.items,
    required this.page,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    this.error,
  });

  factory PostsState.initial() => const PostsState(
    items: [],
    page: 0,
    isLoading: true,
    isLoadingMore: false,
    hasMore: true,
    error: null,
  );

  PostsState copyWith({
    List<Post>? items,
    int? page,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Object? error = _sentinel,
  }) {
    return PostsState(
      items: items ?? this.items,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: identical(error, _sentinel) ? this.error : error,
    );
  }

  static const _sentinel = Object();
}

class PostsListController extends StateNotifier<PostsState> {
  PostsListController(this._api) : super(PostsState.initial()) {
    // 시작하자마자 첫 페이지 로드
    loadFirst();
  }

  final PostsApi _api;
  static const _pageSize = 20;
  bool _busy = false;

  Future<void> loadFirst() async {
    if (_busy) return;
    _busy = true;
    state = state.copyWith(
      isLoading: true,
      error: null,
      page: 0,
      hasMore: true,
    );
    try {
      final page = await _api.listPaged(page: 0, size: _pageSize);
      state = state.copyWith(
        items: page.items,
        page: page.nextPage ?? 1,
        hasMore: page.hasNext,
        isLoading: false,
        isLoadingMore: false,
        error: null,
      );
    } catch (e, s) {
      debugPrint('loadFirst error: $e\n$s');
      state = state.copyWith(isLoading: false, error: e);
    } finally {
      _busy = false;
    }
  }

  Future<void> loadMore() async {
    if (_busy || state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }
    _busy = true;
    state = state.copyWith(isLoadingMore: true, error: null);
    try {
      final pageRes = await _api.listPaged(page: state.page, size: _pageSize);
      state = state.copyWith(
        items: [...state.items, ...pageRes.items],
        page: pageRes.nextPage ?? state.page,
        hasMore: pageRes.hasNext,
        isLoadingMore: false,
      );
    } catch (e, s) {
      debugPrint('loadMore error: $e\n$s');
      // 더보기 실패는 목록 유지 + 토스트/스낵바로 처리(화면 쪽)
      state = state.copyWith(isLoadingMore: false, error: e);
    } finally {
      _busy = false;
    }
  }
}

final postsListControllerProvider =
    StateNotifierProvider.autoDispose<PostsListController, PostsState>((ref) {
      final api = ref.read(postsApiProvider);
      return PostsListController(api);
    });

// 상세는 그대로 family provider 유지 가능
final postDetailProvider = FutureProvider.family.autoDispose<Post, String>((
  ref,
  id,
) {
  final api = ref.read(postsApiProvider);
  return api.getOne(id);
});

class PostCreateState {
  final bool submitting;
  final Object? error;
  const PostCreateState({required this.submitting, this.error});
  factory PostCreateState.initial() => const PostCreateState(submitting: false);
  PostCreateState copyWith({bool? submitting, Object? error}) =>
      PostCreateState(submitting: submitting ?? this.submitting, error: error);
}

class PostCreateController extends StateNotifier<PostCreateState> {
  PostCreateController(this._api, this._ref) : super(PostCreateState.initial());
  final PostsApi _api;
  final Ref _ref;

  Future<String?> submit({
    required String title,
    required String content,
    String? region,
    List<String>? tags,
    double? latitude,
    double? longitude,
  }) async {
    if (state.submitting) return null;

    final token = _ref.read(accessTokenProvider);
    if (token == null || token.isEmpty) {
      state = state.copyWith(submitting: false, error: '로그인이 필요합니다');
      return null;
    }

    state = state.copyWith(submitting: true, error: null);
    try {
      final id = await _api.create(
        title: title,
        content: content,
        region: region,
        tags: tags,
        latitude: latitude,
        longitude: longitude,
        accessToken: token, // ✅ 토큰 전달
      );
      state = state.copyWith(submitting: false, error: null);
      return id;
    } catch (e) {
      state = state.copyWith(submitting: false, error: e);
      return null;
    }
  }
}

// 프로바이더 등록
final postCreateControllerProvider =
    StateNotifierProvider.autoDispose<PostCreateController, PostCreateState>(
      (ref) => PostCreateController(ref.read(postsApiProvider), ref),
    );

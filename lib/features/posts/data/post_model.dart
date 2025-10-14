class Post {
  final String id;
  final String title;
  final String? summary;

  Post({required this.id, required this.title, this.summary});

  factory Post.fromMap(Map<String, dynamic> m) {
    return Post(
      id: '${m['id']}',
      title: (m['title'] ?? '').toString(),
      summary: (m['summary'] ?? m['excerpt'] ?? m['content'])?.toString(),
    );
  }
}

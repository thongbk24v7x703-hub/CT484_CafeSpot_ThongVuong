class Review {
  final int? id;
  final int cafeId;
  final String author;
  final String content;
  final double rating;
  final DateTime createdAt;

  const Review({
    this.id,
    required this.cafeId,
    required this.author,
    required this.content,
    required this.rating,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'cafe_id': cafeId,
      'author': author,
      'content': content,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, Object?> map) {
    return Review(
      id: map['id'] as int?,
      cafeId: map['cafe_id'] as int,
      author: map['author'] as String,
      content: map['content'] as String,
      rating: (map['rating'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

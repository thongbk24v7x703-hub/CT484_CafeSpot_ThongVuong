class CafeCollection {
  final int? id;
  final String name;
  final DateTime createdAt;
  final int cafeCount;

  const CafeCollection({
    this.id,
    required this.name,
    required this.createdAt,
    this.cafeCount = 0,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CafeCollection.fromMap(Map<String, Object?> map) {
    return CafeCollection(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      cafeCount: (map['cafe_count'] as int?) ?? 0,
    );
  }
}

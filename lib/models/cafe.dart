class Cafe {
  final int? id;
  final String name;
  final String address;
  final String description;
  final String imageUrl;
  final double rating;
  final String category;
  final bool isFavorite;
  final DateTime createdAt;

  const Cafe({
    this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.imageUrl,
    this.rating = 0,
    required this.category,
    this.isFavorite = false,
    required this.createdAt,
  });

  Cafe copyWith({
    int? id,
    String? name,
    String? address,
    String? description,
    String? imageUrl,
    double? rating,
    String? category,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Cafe(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'description': description,
      'image_url': imageUrl,
      'rating': rating,
      'category': category,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Cafe.fromMap(Map<String, Object?> map) {
    return Cafe(
      id: map['id'] as int?,
      name: map['name'] as String,
      address: map['address'] as String,
      description: map['description'] as String,
      imageUrl: map['image_url'] as String,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      category: map['category'] as String,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

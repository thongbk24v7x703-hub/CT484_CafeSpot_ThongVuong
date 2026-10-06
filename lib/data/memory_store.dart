import '../models/cafe.dart';
import '../models/review.dart';

/// In-memory store cho web (sqflite không hỗ trợ browser).
class MemoryStore {
  MemoryStore._() {
    _seed();
  }

  static final MemoryStore instance = MemoryStore._();

  final List<Cafe> cafes = [];
  final List<Review> reviews = [];
  int _cafeId = 1;
  int _reviewId = 1;

  void _seed() {
    final now = DateTime.now();
    final seeds = [
      Cafe(
        id: _cafeId++,
        name: 'The Coffee House',
        address: 'Ninh Kiều, Cần Thơ',
        description: 'Không gian rộng, wifi ổn định, phù hợp học nhóm.',
        imageUrl: 'https://picsum.photos/seed/cafe1/800/500',
        rating: 4.5,
        category: 'Chuỗi',
        isFavorite: true,
        createdAt: now,
      ),
      Cafe(
        id: _cafeId++,
        name: 'Cộng Cà Phê',
        address: 'Xuân Khánh, Cần Thơ',
        description: 'Phong cách hoài cổ, đồ uống đậm đà.',
        imageUrl: 'https://picsum.photos/seed/cafe2/800/500',
        rating: 4.2,
        category: 'Specialty',
        createdAt: now,
      ),
      Cafe(
        id: _cafeId++,
        name: 'Highland Coffee',
        address: 'Cái Răng, Cần Thơ',
        description: 'View sông, bàn ngoài trời thoáng mát.',
        imageUrl: 'https://picsum.photos/seed/cafe3/800/500',
        rating: 4.0,
        category: 'Chuỗi',
        createdAt: now,
      ),
      Cafe(
        id: _cafeId++,
        name: 'Garden Beans',
        address: 'An Khánh, Ninh Kiều',
        description: 'Quán nhỏ yên tĩnh, phù hợp làm việc cá nhân.',
        imageUrl: 'https://picsum.photos/seed/cafe4/800/500',
        rating: 4.7,
        category: 'Local',
        isFavorite: true,
        createdAt: now,
      ),
    ];
    cafes.addAll(seeds);
  }

  List<Cafe> getCafes({String? query, String? category}) {
    Iterable<Cafe> list = cafes;
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where(
        (c) =>
            c.name.toLowerCase().contains(q) ||
            c.address.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q),
      );
    }
    if (category != null && category != 'Tất cả') {
      list = list.where((c) => c.category == category);
    }
    final result = list.toList()
      ..sort((a, b) {
        final byRating = b.rating.compareTo(a.rating);
        if (byRating != 0) return byRating;
        return b.createdAt.compareTo(a.createdAt);
      });
    return result;
  }

  List<Cafe> getFavorites() =>
      cafes.where((c) => c.isFavorite).toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  Cafe? getCafeById(int id) {
    for (final c in cafes) {
      if (c.id == id) return c;
    }
    return null;
  }

  int insertCafe(Cafe cafe) {
    final id = _cafeId++;
    cafes.add(cafe.copyWith(id: id));
    return id;
  }

  void updateCafe(Cafe cafe) {
    final i = cafes.indexWhere((c) => c.id == cafe.id);
    if (i >= 0) cafes[i] = cafe;
  }

  void deleteCafe(int id) {
    cafes.removeWhere((c) => c.id == id);
    reviews.removeWhere((r) => r.cafeId == id);
  }

  void toggleFavorite(int id, bool value) {
    final i = cafes.indexWhere((c) => c.id == id);
    if (i >= 0) cafes[i] = cafes[i].copyWith(isFavorite: value);
  }

  List<Review> getReviewsForCafe(int cafeId) {
    final list = reviews.where((r) => r.cafeId == cafeId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<Review> getAllReviews() {
    final list = [...reviews]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  int insertReview(Review review) {
    final id = _reviewId++;
    reviews.add(
      Review(
        id: id,
        cafeId: review.cafeId,
        author: review.author,
        content: review.content,
        rating: review.rating,
        createdAt: review.createdAt,
      ),
    );
    _recalc(review.cafeId);
    return id;
  }

  void deleteReview(int id, int cafeId) {
    reviews.removeWhere((r) => r.id == id);
    _recalc(cafeId);
  }

  void _recalc(int cafeId) {
    final cafeReviews = reviews.where((r) => r.cafeId == cafeId).toList();
    final avg = cafeReviews.isEmpty
        ? 0.0
        : cafeReviews.map((r) => r.rating).reduce((a, b) => a + b) /
            cafeReviews.length;
    final i = cafes.indexWhere((c) => c.id == cafeId);
    if (i >= 0) {
      cafes[i] = cafes[i].copyWith(
        rating: double.parse(avg.toStringAsFixed(1)),
      );
    }
  }
}

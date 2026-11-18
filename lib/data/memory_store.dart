import '../models/cafe.dart';
import '../models/cafe_collection.dart';
import '../models/review.dart';

class MemoryStore {
  MemoryStore._() {
    _seed();
  }

  static final MemoryStore instance = MemoryStore._();

  final List<Cafe> cafes = [];
  final List<Review> reviews = [];
  int _cafeId = 1;
  int _reviewId = 1;
  final List<CafeCollection> collections = [];
  final Map<int, Set<int>> collectionCafes = {};
  int _collectionId = 1;

  void _seed() {
    final now = DateTime.now();
    final seeds = [
      Cafe(
        id: _cafeId++,
        name: 'The Coffee House',
        address: 'Ninh Kiều, Cần Thơ',
        description: 'Không gian rộng, wifi ổn định, phù hợp học nhóm.',
        imageUrl: 'assets/images/cafe1.png',
        rating: 4.5,
        category: 'Chuỗi',
        isFavorite: true,
        createdAt: now,
        openHours: '07:00 - 22:00',
        phone: '0901 234 567',
        priceRange: 'Trung bình',
      ),
      Cafe(
        id: _cafeId++,
        name: 'Cộng Cà Phê',
        address: 'Xuân Khánh, Cần Thơ',
        description: 'Phong cách hoài cổ, đồ uống đậm đà.',
        imageUrl: 'assets/images/cafe2.png',
        rating: 4.2,
        category: 'Specialty',
        createdAt: now,
        openHours: '07:00 - 23:00',
        phone: '0902 345 678',
        priceRange: 'Trung bình',
      ),
      Cafe(
        id: _cafeId++,
        name: 'Highland Coffee',
        address: 'Cái Răng, Cần Thơ',
        description: 'View sông, bàn ngoài trời thoáng mát.',
        imageUrl: 'assets/images/cafe3.png',
        rating: 4.0,
        category: 'Chuỗi',
        createdAt: now,
        openHours: '06:30 - 22:30',
        phone: '0903 456 789',
        priceRange: 'Trung bình',
      ),
      Cafe(
        id: _cafeId++,
        name: 'Garden Beans',
        address: 'An Khánh, Ninh Kiều',
        description: 'Quán nhỏ yên tĩnh, phù hợp làm việc cá nhân.',
        imageUrl: 'assets/images/cafe4.png',
        rating: 4.7,
        category: 'Local',
        isFavorite: true,
        createdAt: now,
        openHours: '08:00 - 21:00',
        phone: '0904 567 890',
        priceRange: 'Bình dân',
      ),
    ];
    cafes.addAll(seeds);
  }

  List<Cafe> getCafes({String? query, String? category, String sort = 'rating'}) {
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
    final result = list.toList();
    if (sort == 'name') {
      result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (sort == 'new') {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      result.sort((a, b) {
        final byRating = b.rating.compareTo(a.rating);
        if (byRating != 0) return byRating;
        return b.createdAt.compareTo(a.createdAt);
      });
    }
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
    for (final ids in collectionCafes.values) {
      ids.remove(id);
    }
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

  void updateReview(Review review) {
    final i = reviews.indexWhere((r) => r.id == review.id);
    if (i >= 0) reviews[i] = review;
    _recalc(review.cafeId);
  }

  List<CafeCollection> getCollections() {
    final list = collections
        .map(
          (c) => CafeCollection(
            id: c.id,
            name: c.name,
            createdAt: c.createdAt,
            cafeCount: collectionCafes[c.id]?.length ?? 0,
          ),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  int insertCollection(String name) {
    final id = _collectionId++;
    collections.add(
      CafeCollection(id: id, name: name, createdAt: DateTime.now()),
    );
    collectionCafes[id] = {};
    return id;
  }

  void deleteCollection(int id) {
    collections.removeWhere((c) => c.id == id);
    collectionCafes.remove(id);
  }

  List<Cafe> getCafesInCollection(int collectionId) {
    final ids = collectionCafes[collectionId] ?? <int>{};
    return cafes.where((c) => ids.contains(c.id)).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  void setCafeInCollection(int collectionId, int cafeId, bool value) {
    final ids = collectionCafes.putIfAbsent(collectionId, () => <int>{});
    if (value) {
      ids.add(cafeId);
    } else {
      ids.remove(cafeId);
    }
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

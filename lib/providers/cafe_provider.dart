import 'package:flutter/foundation.dart';

import '../data/cafe_repository.dart';
import '../models/cafe.dart';
import '../models/cafe_collection.dart';
import '../models/review.dart';

class CafeProvider extends ChangeNotifier {
  CafeProvider(this._repo);

  final CafeRepository _repo;

  List<Cafe> _cafes = [];
  List<Cafe> _favorites = [];
  List<Review> _myReviews = [];
  List<CafeCollection> _collections = [];
  bool _loading = false;
  String _query = '';
  String _category = 'Tất cả';
  String _sort = 'rating';

  List<Cafe> get cafes => _cafes;
  List<Cafe> get favorites => _favorites;
  List<Review> get myReviews => _myReviews;
  List<CafeCollection> get collections => _collections;
  bool get loading => _loading;
  String get query => _query;
  String get category => _category;
  String get sort => _sort;

  static const categories = ['Tất cả', 'Chuỗi', 'Specialty', 'Local'];
  static const sortOptions = {
    'rating': 'Điểm cao nhất',
    'name': 'Tên A - Z',
    'new': 'Mới thêm',
  };

  Future<void> load({bool showLoading = true}) async {
    if (showLoading) {
      _loading = true;
      notifyListeners();
    }
    _cafes = await _repo.getCafes(
      query: _query,
      category: _category,
      sort: _sort,
    );
    _favorites = await _repo.getFavorites();
    _myReviews = await _repo.getAllReviews();
    _collections = await _repo.getCollections();
    _loading = false;
    notifyListeners();
  }

  Future<void> setFilter({String? query, String? category}) async {
    if (query != null) _query = query;
    if (category != null) _category = category;
    await load();
  }

  Future<void> setSort(String sort) async {
    _sort = sort;
    await load();
  }

  Future<Cafe?> getById(int id) => _repo.getCafeById(id);

  Future<void> saveCafe(Cafe cafe) async {
    if (cafe.id == null) {
      await _repo.insertCafe(cafe);
    } else {
      await _repo.updateCafe(cafe);
    }
    await load();
  }

  Future<void> deleteCafe(int id) async {
    await _repo.deleteCafe(id);
    await load();
  }

  Future<void> toggleFavorite(Cafe cafe) async {
    await _repo.toggleFavorite(cafe.id!, !cafe.isFavorite);
    await load();
  }

  Future<List<Review>> reviewsOf(int cafeId) => _repo.getReviewsForCafe(cafeId);

  Future<void> addReview(Review review) async {
    await _repo.insertReview(review);
    await load();
  }

  Future<void> updateReview(Review review) async {
    await _repo.updateReview(review);
    await load(showLoading: false);
  }

  Future<List<Cafe>> allCafes() => _repo.getCafes(sort: 'name');

  Future<List<Cafe>> cafesInCollection(int collectionId) =>
      _repo.getCafesInCollection(collectionId);

  Future<void> addCollection(String name) async {
    await _repo.insertCollection(name);
    await load(showLoading: false);
  }

  Future<void> deleteCollection(int id) async {
    _collections = _collections.where((c) => c.id != id).toList();
    notifyListeners();
    await _repo.deleteCollection(id);
    await load(showLoading: false);
  }

  Future<void> setCafeInCollection(
    int collectionId,
    int cafeId,
    bool value,
  ) async {
    await _repo.setCafeInCollection(collectionId, cafeId, value);
    await load(showLoading: false);
  }

  Future<void> removeReview(Review review) async {
    _myReviews = _myReviews.where((r) => r.id != review.id).toList();
    notifyListeners();
    await _repo.deleteReview(review.id!, review.cafeId);
    await load();
  }
}

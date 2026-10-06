import 'package:flutter/foundation.dart';

import '../data/cafe_repository.dart';
import '../models/cafe.dart';
import '../models/review.dart';

/// State chính của dữ liệu quán — phụ trách: Lưu Minh Thông
class CafeProvider extends ChangeNotifier {
  CafeProvider(this._repo);

  final CafeRepository _repo;

  List<Cafe> _cafes = [];
  List<Cafe> _favorites = [];
  List<Review> _myReviews = [];
  bool _loading = false;
  String _query = '';
  String _category = 'Tất cả';

  List<Cafe> get cafes => _cafes;
  List<Cafe> get favorites => _favorites;
  List<Review> get myReviews => _myReviews;
  bool get loading => _loading;
  String get query => _query;
  String get category => _category;

  static const categories = ['Tất cả', 'Chuỗi', 'Specialty', 'Local'];

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _cafes = await _repo.getCafes(query: _query, category: _category);
    _favorites = await _repo.getFavorites();
    _myReviews = await _repo.getAllReviews();
    _loading = false;
    notifyListeners();
  }

  Future<void> setFilter({String? query, String? category}) async {
    if (query != null) _query = query;
    if (category != null) _category = category;
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

  Future<void> removeReview(Review review) async {
    await _repo.deleteReview(review.id!, review.cafeId);
    await load();
  }
}

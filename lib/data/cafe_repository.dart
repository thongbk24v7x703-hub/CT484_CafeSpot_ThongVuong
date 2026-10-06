import 'package:flutter/foundation.dart';

import '../models/cafe.dart';
import '../models/review.dart';
import 'database_helper.dart';
import 'memory_store.dart';

class CafeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final MemoryStore _memory = MemoryStore.instance;

  bool get _useMemory => kIsWeb;

  Future<List<Cafe>> getCafes({String? query, String? category}) async {
    if (_useMemory) {
      return _memory.getCafes(query: query, category: category);
    }
    final db = await _dbHelper.database;
    final where = <String>[];
    final args = <Object?>[];

    if (query != null && query.trim().isNotEmpty) {
      where.add('(name LIKE ? OR address LIKE ? OR description LIKE ?)');
      final q = '%${query.trim()}%';
      args.addAll([q, q, q]);
    }
    if (category != null && category != 'Tất cả') {
      where.add('category = ?');
      args.add(category);
    }

    final maps = await db.query(
      'cafes',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'rating DESC, created_at DESC',
    );
    return maps.map(Cafe.fromMap).toList();
  }

  Future<List<Cafe>> getFavorites() async {
    if (_useMemory) return _memory.getFavorites();
    final db = await _dbHelper.database;
    final maps = await db.query(
      'cafes',
      where: 'is_favorite = 1',
      orderBy: 'name ASC',
    );
    return maps.map(Cafe.fromMap).toList();
  }

  Future<Cafe?> getCafeById(int id) async {
    if (_useMemory) return _memory.getCafeById(id);
    final db = await _dbHelper.database;
    final maps = await db.query('cafes', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Cafe.fromMap(maps.first);
  }

  Future<int> insertCafe(Cafe cafe) async {
    if (_useMemory) return _memory.insertCafe(cafe);
    final db = await _dbHelper.database;
    return db.insert('cafes', cafe.toMap()..remove('id'));
  }

  Future<int> updateCafe(Cafe cafe) async {
    if (_useMemory) {
      _memory.updateCafe(cafe);
      return 1;
    }
    final db = await _dbHelper.database;
    return db.update(
      'cafes',
      cafe.toMap(),
      where: 'id = ?',
      whereArgs: [cafe.id],
    );
  }

  Future<int> deleteCafe(int id) async {
    if (_useMemory) {
      _memory.deleteCafe(id);
      return 1;
    }
    final db = await _dbHelper.database;
    await db.delete('reviews', where: 'cafe_id = ?', whereArgs: [id]);
    return db.delete('cafes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleFavorite(int id, bool value) async {
    if (_useMemory) {
      _memory.toggleFavorite(id, value);
      return;
    }
    final db = await _dbHelper.database;
    await db.update(
      'cafes',
      {'is_favorite': value ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Review>> getReviewsForCafe(int cafeId) async {
    if (_useMemory) return _memory.getReviewsForCafe(cafeId);
    final db = await _dbHelper.database;
    final maps = await db.query(
      'reviews',
      where: 'cafe_id = ?',
      whereArgs: [cafeId],
      orderBy: 'created_at DESC',
    );
    return maps.map(Review.fromMap).toList();
  }

  Future<List<Review>> getAllReviews() async {
    if (_useMemory) return _memory.getAllReviews();
    final db = await _dbHelper.database;
    final maps = await db.query('reviews', orderBy: 'created_at DESC');
    return maps.map(Review.fromMap).toList();
  }

  Future<int> insertReview(Review review) async {
    if (_useMemory) return _memory.insertReview(review);
    final db = await _dbHelper.database;
    final id = await db.insert('reviews', review.toMap()..remove('id'));
    await _recalcCafeRating(review.cafeId);
    return id;
  }

  Future<int> deleteReview(int id, int cafeId) async {
    if (_useMemory) {
      _memory.deleteReview(id, cafeId);
      return 1;
    }
    final db = await _dbHelper.database;
    final result = await db.delete('reviews', where: 'id = ?', whereArgs: [id]);
    await _recalcCafeRating(cafeId);
    return result;
  }

  Future<void> _recalcCafeRating(int cafeId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT AVG(rating) as avg_rating FROM reviews WHERE cafe_id = ?',
      [cafeId],
    );
    final avg = (result.first['avg_rating'] as num?)?.toDouble() ?? 0;
    await db.update(
      'cafes',
      {'rating': double.parse(avg.toStringAsFixed(1))},
      where: 'id = ?',
      whereArgs: [cafeId],
    );
  }
}

import 'package:cafe_spot/models/cafe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Cafe toMap/fromMap giữ nguyên dữ liệu', () {
    final cafe = Cafe(
      id: 1,
      name: 'Garden Beans',
      address: 'An Khánh, Ninh Kiều',
      description: 'Quán nhỏ yên tĩnh',
      imageUrl: 'https://picsum.photos/seed/cafe4/800/500',
      rating: 4.7,
      category: 'Local',
      isFavorite: true,
      createdAt: DateTime(2026, 11, 1),
    );

    final copy = Cafe.fromMap(cafe.toMap());

    expect(copy.name, cafe.name);
    expect(copy.rating, 4.7);
    expect(copy.isFavorite, isTrue);
    expect(copy.createdAt, cafe.createdAt);
  });
}

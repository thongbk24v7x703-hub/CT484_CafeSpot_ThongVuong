import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/cafe_provider.dart';
import '../widgets/cafe_card.dart';
import '../widgets/responsive_center.dart';

/// Danh sách yêu thích — phụ trách: Nguyễn Quốc Vương
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<CafeProvider>().favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Yêu thích')),
      body: ResponsiveCenter(
        child: favorites.isEmpty
            ? const Center(
                child: Text('Chưa có quán yêu thích. Nhấn trái tim ở Trang chủ.'),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final count = gridCountForWidth(constraints.maxWidth);
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: count,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: count == 1 ? 1.35 : 0.78,
                    ),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final cafe = favorites[index];
                      return CafeCard(
                        cafe: cafe,
                        onTap: () => context.push('/cafe/${cafe.id}'),
                        onFavorite: () =>
                            context.read<CafeProvider>().toggleFavorite(cafe),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

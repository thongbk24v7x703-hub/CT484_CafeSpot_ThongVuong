import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/cafe_provider.dart';
import '../widgets/cafe_card.dart';
import '../widgets/responsive_center.dart';

/// Màn hình chính — phụ trách: Lưu Minh Thông
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CafeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CafeSpot'),
        actions: [
          IconButton(
            tooltip: 'Tìm kiếm',
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/cafe-form'),
        icon: const Icon(Icons.add),
        label: const Text('Thêm quán'),
      ),
      body: ResponsiveCenter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Khám phá quán cà phê',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Danh sách quán lưu cục bộ bằng SQLite — thêm, sửa, xóa và đánh giá.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: CafeProvider.categories.map((c) {
                  final selected = provider.category == c;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(c),
                      selected: selected,
                      onSelected: (_) => provider.setFilter(category: c),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: provider.loading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.cafes.isEmpty
                      ? const Center(child: Text('Chưa có quán nào.'))
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
                              itemCount: provider.cafes.length,
                              itemBuilder: (context, index) {
                                final cafe = provider.cafes[index];
                                return CafeCard(
                                  cafe: cafe,
                                  onTap: () => context.push('/cafe/${cafe.id}'),
                                  onFavorite: () => provider.toggleFavorite(cafe),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/cafe_provider.dart';
import '../widgets/cafe_card.dart';
import '../widgets/responsive_center.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CafeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CafeSpot'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Sắp xếp',
            icon: const Icon(Icons.sort),
            onSelected: provider.setSort,
            itemBuilder: (context) => CafeProvider.sortOptions.entries
                .map(
                  (e) => CheckedPopupMenuItem(
                    value: e.key,
                    checked: provider.sort == e.key,
                    child: Text(e.value),
                  ),
                )
                .toList(),
          ),
          IconButton(
            tooltip: 'Tìm kiếm',
            onPressed: () async {
              await context.push('/search');
              provider.setFilter(query: '');
            },
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
              'Chọn quán, xem đánh giá và lưu lại quán bạn thích.',
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
                            return RefreshIndicator(
                              onRefresh: () => provider.load(showLoading: false),
                              child: GridView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
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
                                    heroTag: 'cafe-${cafe.id}',
                                    onTap: () => context.push(
                                      '/cafe/${cafe.id}',
                                      extra: cafe,
                                    ),
                                    onFavorite: () => provider.toggleFavorite(cafe),
                                  );
                                },
                              ),
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

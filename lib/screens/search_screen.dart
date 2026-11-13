import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/cafe_provider.dart';
import '../widgets/cafe_image.dart';
import '../widgets/rating_stars.dart';
import '../widgets/responsive_center.dart';

/// Tìm kiếm quán — phụ trách: Nguyễn Quốc Vương
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CafeProvider>().setFilter(query: widget.initialQuery);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CafeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm')),
      body: ResponsiveCenter(
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Tên quán, địa chỉ, mô tả...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    provider.setFilter(query: '');
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => provider.setFilter(query: value),
              onSubmitted: (value) => provider.setFilter(query: value),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: provider.cafes.isEmpty
                  ? const Center(child: Text('Không tìm thấy kết quả.'))
                  : ListView.separated(
                      itemCount: provider.cafes.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final cafe = provider.cafes[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: CafeImage.providerOf(cafe.imageUrl),
                            onBackgroundImageError: (_, __) {},
                            child: const Icon(Icons.coffee),
                          ),
                          title: Text(cafe.name),
                          subtitle: Text(cafe.address),
                          trailing: RatingStars(rating: cafe.rating, size: 14),
                          onTap: () => context.push('/cafe/${cafe.id}'),
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

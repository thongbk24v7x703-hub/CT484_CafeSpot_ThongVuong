import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/cafe_provider.dart';
import '../widgets/rating_stars.dart';
import '../widgets/responsive_center.dart';

/// Tất cả đánh giá đã viết — phụ trách: Nguyễn Quốc Vương
class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CafeProvider>();
    final reviews = provider.myReviews;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá của tôi')),
      body: ResponsiveCenter(
        child: reviews.isEmpty
            ? const Center(child: Text('Bạn chưa viết đánh giá nào.'))
            : ListView.separated(
                itemCount: reviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Card(
                    child: ListTile(
                      title: Text(review.author),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RatingStars(rating: review.rating, size: 16),
                          const SizedBox(height: 4),
                          Text(review.content),
                          Text(
                            dateFormat.format(review.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            tooltip: 'Xem quán',
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () =>
                                context.push('/cafe/${review.cafeId}'),
                          ),
                          IconButton(
                            tooltip: 'Xóa',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => provider.removeReview(review),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

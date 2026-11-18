import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/review.dart';
import '../providers/cafe_provider.dart';
import '../widgets/rating_stars.dart';
import '../widgets/responsive_center.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  Future<void> _editReview(BuildContext context, Review review) async {
    final controller = TextEditingController(text: review.content);
    var rating = review.rating;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Sửa đánh giá'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingStars(
                rating: rating,
                size: 32,
                onChanged: (v) => setDialogState(() => rating = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    final content = controller.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nội dung đánh giá không được để trống')),
      );
      return;
    }
    await context.read<CafeProvider>().updateReview(
          Review(
            id: review.id,
            cafeId: review.cafeId,
            author: review.author,
            content: content,
            rating: rating,
            createdAt: review.createdAt,
          ),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật đánh giá')),
      );
    }
  }

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
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Dismissible(
                    key: ValueKey(review.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      provider.removeReview(review);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã xóa đánh giá')),
                      );
                    },
                    child: Card(
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
                          spacing: 0,
                          children: [
                            IconButton(
                              tooltip: 'Xem quán',
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () =>
                                  context.push('/cafe/${review.cafeId}'),
                            ),
                            IconButton(
                              tooltip: 'Sửa',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _editReview(context, review),
                            ),
                            IconButton(
                              tooltip: 'Xóa',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => provider.removeReview(review),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

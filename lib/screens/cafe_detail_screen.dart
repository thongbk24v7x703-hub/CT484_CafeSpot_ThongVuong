import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/cafe.dart';
import '../models/review.dart';
import '../providers/cafe_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../widgets/cafe_image.dart';
import '../widgets/rating_stars.dart';
import '../widgets/responsive_center.dart';

class CafeDetailScreen extends StatefulWidget {
  const CafeDetailScreen({super.key, required this.cafeId, this.cafe});

  final int cafeId;
  final Cafe? cafe;

  @override
  State<CafeDetailScreen> createState() => _CafeDetailScreenState();
}

class _CafeDetailScreenState extends State<CafeDetailScreen> {
  Cafe? _cafe;
  List<Review> _reviews = [];
  late bool _loading;
  final _contentCtrl = TextEditingController();
  double _rating = 5;

  @override
  void initState() {
    super.initState();
    _cafe = widget.cafe;
    _loading = widget.cafe == null;
    _load();
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final provider = context.read<CafeProvider>();
    final cafe = await provider.getById(widget.cafeId);
    final reviews = await provider.reviewsOf(widget.cafeId);
    if (!mounted) return;
    setState(() {
      _cafe = cafe;
      _reviews = reviews;
      _loading = false;
    });
  }

  Future<void> _submitReview() async {
    if (_cafe == null || _contentCtrl.text.trim().isEmpty) return;
    final author = context.read<SettingsProvider>().displayName;
    final settings = context.read<SettingsProvider>();
    await context.read<CafeProvider>().addReview(
          Review(
            cafeId: _cafe!.id!,
            author: author,
            content: _contentCtrl.text.trim(),
            rating: _rating,
            createdAt: DateTime.now(),
          ),
        );
    _contentCtrl.clear();
    if (settings.notificationsEnabled) {
      await NotificationService.instance.showCafeReminder(
        title: 'Đã thêm đánh giá',
        body: 'Bạn vừa đánh giá ${_cafe!.name}',
      );
    }
    await _load();
  }

  Future<void> _openUrl(Uri uri) async {
    var ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không mở được ứng dụng phù hợp')),
      );
    }
  }

  Future<bool> _confirm(String title, String content, String action) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _callCafe(String phone) async {
    final ok = await _confirm(
      'Gọi điện cho quán?',
      'Chuyển sang ứng dụng gọi điện với số $phone.',
      'Gọi',
    );
    if (!ok) return;
    await _openUrl(Uri(scheme: 'tel', path: phone.replaceAll(' ', '')));
  }

  Future<void> _openMap(Cafe cafe) async {
    final ok = await _confirm(
      'Mở bản đồ?',
      'Chuyển sang Google Maps để xem đường đến ${cafe.name}.',
      'Mở bản đồ',
    );
    if (!ok) return;
    await _openUrl(Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '${cafe.name}, ${cafe.address}',
    }));
  }

  Widget _infoRow(IconData icon, String text, {VoidCallback? onTap}) {
    final color = onTap == null ? null : Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 2),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Expanded(child: Text(text, style: TextStyle(color: color))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final cafe = _cafe;
    if (cafe == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Không tìm thấy quán.')),
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final image = CafeImage(
      source: cafe.imageUrl,
      fit: BoxFit.cover,
      errorIconSize: 64,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(cafe.name),
        actions: [
          IconButton(
            icon: Icon(cafe.isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () async {
              await context.read<CafeProvider>().toggleFavorite(cafe);
              await _load();
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await context.push('/cafe-form', extra: cafe);
              await _load();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xóa quán?'),
                  content: Text('Xóa "${cafe.name}" và toàn bộ đánh giá liên quan.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await context.read<CafeProvider>().deleteCafe(cafe.id!);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: ResponsiveCenter(
        child: ListView(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: widget.cafe == null
                    ? image
                    : Hero(tag: 'cafe-${cafe.id}', child: image),
              ),
            ),
            const SizedBox(height: 16),
            Text(cafe.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            _infoRow(Icons.place_outlined, cafe.address,
                onTap: () => _openMap(cafe)),
            if (cafe.openHours.isNotEmpty)
              _infoRow(Icons.schedule, 'Giờ mở cửa: ${cafe.openHours}'),
            if (cafe.phone.isNotEmpty)
              _infoRow(Icons.phone_outlined, cafe.phone,
                  onTap: () => _callCafe(cafe.phone)),
            if (cafe.priceRange.isNotEmpty)
              _infoRow(Icons.payments_outlined, 'Mức giá: ${cafe.priceRange}'),
            _infoRow(Icons.event_outlined,
                'Ngày thêm: ${dateFormat.format(cafe.createdAt)}'),
            const SizedBox(height: 8),
            Row(
              children: [
                RatingStars(rating: cafe.rating),
                const SizedBox(width: 8),
                Text('${cafe.rating.toStringAsFixed(1)} · ${cafe.category}'),
              ],
            ),
            const SizedBox(height: 12),
            Text(cafe.description),
            const Divider(height: 32),
            Text('Viết đánh giá', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            RatingStars(rating: _rating, size: 28, onChanged: (v) => setState(() => _rating = v)),
            const SizedBox(height: 8),
            TextField(
              controller: _contentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Cảm nhận của bạn về quán...',
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _submitReview,
                icon: const Icon(Icons.send),
                label: const Text('Gửi đánh giá'),
              ),
            ),
            const Divider(height: 32),
            Text('Đánh giá (${_reviews.length})', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_reviews.isEmpty)
              const Text('Chưa có đánh giá nào.')
            else
              ..._reviews.map(
                (r) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        r.author.isNotEmpty ? r.author[0].toUpperCase() : '?',
                      ),
                    ),
                    title: Text(r.author),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RatingStars(rating: r.rating, size: 14),
                        const SizedBox(height: 4),
                        Text(r.content),
                        Text(dateFormat.format(r.createdAt), style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await context.read<CafeProvider>().removeReview(r);
                        await _load();
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

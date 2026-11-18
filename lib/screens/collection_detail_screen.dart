import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/cafe.dart';
import '../providers/cafe_provider.dart';
import '../widgets/cafe_image.dart';
import '../widgets/rating_stars.dart';
import '../widgets/responsive_center.dart';

class CollectionDetailScreen extends StatefulWidget {
  const CollectionDetailScreen({
    super.key,
    required this.collectionId,
    required this.name,
  });

  final int collectionId;
  final String name;

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  List<Cafe> _cafes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cafes =
        await context.read<CafeProvider>().cafesInCollection(widget.collectionId);
    if (!mounted) return;
    setState(() {
      _cafes = cafes;
      _loading = false;
    });
  }

  Future<void> _pickCafes() async {
    final provider = context.read<CafeProvider>();
    final all = await provider.allCafes();
    final selected = _cafes.map((c) => c.id).toSet();
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chọn quán cho bộ sưu tập',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final cafe in all)
                      CheckboxListTile(
                        value: selected.contains(cafe.id),
                        title: Text(cafe.name),
                        subtitle: Text(cafe.address),
                        onChanged: (value) async {
                          final checked = value == true;
                          await provider.setCafeInCollection(
                            widget.collectionId,
                            cafe.id!,
                            checked,
                          );
                          setSheetState(() {
                            if (checked) {
                              selected.add(cafe.id);
                            } else {
                              selected.remove(cafe.id);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Xong (${selected.length} quán)'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await _load();
  }

  Future<void> _removeCafe(Cafe cafe) async {
    await context
        .read<CafeProvider>()
        .setCafeInCollection(widget.collectionId, cafe.id!, false);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
            tooltip: 'Chọn quán',
            icon: const Icon(Icons.playlist_add),
            onPressed: _pickCafes,
          ),
        ],
      ),
      body: ResponsiveCenter(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _cafes.isEmpty
                ? const Center(
                    child: Text('Chưa có quán nào. Bấm nút thêm ở góc trên.'),
                  )
                : ListView.separated(
                    itemCount: _cafes.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final cafe = _cafes[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CafeImage.providerOf(cafe.imageUrl),
                          onBackgroundImageError: (_, _) {},
                          child: const Icon(Icons.coffee),
                        ),
                        title: Text(cafe.name),
                        subtitle: RatingStars(rating: cafe.rating, size: 14),
                        trailing: IconButton(
                          tooltip: 'Bỏ khỏi bộ sưu tập',
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _removeCafe(cafe),
                        ),
                        onTap: () async {
                          await context.push('/cafe/${cafe.id}');
                          await _load();
                        },
                      );
                    },
                  ),
      ),
    );
  }
}

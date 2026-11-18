import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/cafe_provider.dart';
import '../widgets/responsive_center.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  Future<void> _addCollection(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo bộ sưu tập'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ví dụ: Quán học bài'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    await context.read<CafeProvider>().addCollection(name.trim());
  }

  Future<bool?> _confirmDelete(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bộ sưu tập?'),
        content: Text('Xóa "$name". Các quán trong bộ sưu tập vẫn được giữ lại.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CafeProvider>();
    final collections = provider.collections;

    return Scaffold(
      appBar: AppBar(title: const Text('Bộ sưu tập')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCollection(context),
        icon: const Icon(Icons.add),
        label: const Text('Tạo mới'),
      ),
      body: ResponsiveCenter(
        child: collections.isEmpty
            ? const Center(
                child: Text('Chưa có bộ sưu tập nào. Bấm Tạo mới để thêm.'),
              )
            : ListView.separated(
                itemCount: collections.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final collection = collections[index];
                  return Dismissible(
                    key: ValueKey('collection-${collection.id}'),
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
                    confirmDismiss: (_) =>
                        _confirmDelete(context, collection.name),
                    onDismissed: (_) =>
                        provider.deleteCollection(collection.id!),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.collections_bookmark_outlined),
                        title: Text(collection.name),
                        subtitle: Text('${collection.cafeCount} quán'),
                        trailing: IconButton(
                          tooltip: 'Xóa bộ sưu tập',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final ok =
                                await _confirmDelete(context, collection.name);
                            if (ok == true) {
                              provider.deleteCollection(collection.id!);
                            }
                          },
                        ),
                        onTap: () => context.push(
                          Uri(
                            path: '/collections/${collection.id}',
                            queryParameters: {'name': collection.name},
                          ).toString(),
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

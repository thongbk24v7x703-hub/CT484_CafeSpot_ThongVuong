import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/cafe.dart';
import '../providers/cafe_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../widgets/responsive_center.dart';

/// Form thêm/sửa quán — phụ trách: Lưu Minh Thông
class CafeFormScreen extends StatefulWidget {
  const CafeFormScreen({super.key, this.cafe});

  final Cafe? cafe;

  @override
  State<CafeFormScreen> createState() => _CafeFormScreenState();
}

class _CafeFormScreenState extends State<CafeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _description;
  late final TextEditingController _imageUrl;
  late String _category;
  bool _saving = false;

  bool get _isEdit => widget.cafe != null;

  @override
  void initState() {
    super.initState();
    final cafe = widget.cafe;
    _name = TextEditingController(text: cafe?.name ?? '');
    _address = TextEditingController(text: cafe?.address ?? '');
    _description = TextEditingController(text: cafe?.description ?? '');
    _imageUrl = TextEditingController(
      text: cafe?.imageUrl ??
          'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/800/500',
    );
    _category = cafe?.category ?? 'Local';
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _description.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final existing = widget.cafe;
    final cafe = Cafe(
      id: existing?.id,
      name: _name.text.trim(),
      address: _address.text.trim(),
      description: _description.text.trim(),
      imageUrl: _imageUrl.text.trim(),
      rating: existing?.rating ?? 0,
      category: _category,
      isFavorite: existing?.isFavorite ?? false,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    final cafeProvider = context.read<CafeProvider>();
    final settings = context.read<SettingsProvider>();
    await cafeProvider.saveCafe(cafe);
    if (settings.notificationsEnabled) {
      await NotificationService.instance.showCafeReminder(
        title: _isEdit ? 'Đã cập nhật quán' : 'Đã thêm quán mới',
        body: cafe.name,
      );
    }
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Sửa quán' : 'Thêm quán')),
      body: ResponsiveCenter(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Tên quán', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên quán' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Địa chỉ', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nhập địa chỉ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nhập mô tả' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrl,
                decoration: const InputDecoration(labelText: 'URL ảnh', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nhập URL ảnh' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Danh mục', border: OutlineInputBorder()),
                items: CafeProvider.categories
                    .where((c) => c != 'Tất cả')
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? 'Local'),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_isEdit ? 'Lưu thay đổi' : 'Tạo quán'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

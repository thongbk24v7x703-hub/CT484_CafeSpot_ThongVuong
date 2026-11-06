import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../widgets/responsive_center.dart';

/// Cài đặt & thông báo — phụ trách: Nguyễn Quốc Vương
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: context.read<SettingsProvider>().displayName,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ResponsiveCenter(
        child: ListView(
          children: [
            Text('Hồ sơ', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên hiển thị khi đánh giá',
                border: OutlineInputBorder(),
              ),
              onSubmitted: settings.setDisplayName,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => settings.setDisplayName(_nameCtrl.text),
                child: const Text('Lưu tên'),
              ),
            ),
            const Divider(height: 32),
            SwitchListTile(
              title: const Text('Chế độ tối'),
              subtitle: const Text('Lưu bằng SharedPreferences'),
              value: settings.darkMode,
              onChanged: settings.setDarkMode,
              secondary: const Icon(Icons.dark_mode_outlined),
            ),
            SwitchListTile(
              title: const Text('Bật thông báo cục bộ'),
              subtitle: const Text('Nhắc khi thêm quán / đánh giá'),
              value: settings.notificationsEnabled,
              onChanged: settings.setNotificationsEnabled,
              secondary: const Icon(Icons.notifications_outlined),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: settings.notificationsEnabled
                  ? () => NotificationService.instance.showCafeReminder(
                        title: 'CafeSpot',
                        body: 'Đây là thông báo thử nghiệm từ ứng dụng.',
                      )
                  : null,
              icon: const Icon(Icons.notification_add_outlined),
              label: const Text('Gửi thông báo thử'),
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: const Text('Nhóm thực hiện'),
              subtitle: const Text(
                'Lưu Minh Thông · BK24V7X703\nNguyễn Quốc Vương · DC24V7X414',
              ),
              isThreeLine: true,
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Phiên bản'),
              subtitle: const Text('CafeSpot 1.0.0 · CT484 HK1 2026-2027'),
            ),
          ],
        ),
      ),
    );
  }
}

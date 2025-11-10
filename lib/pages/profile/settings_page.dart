import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

bool _notificationsEnabled = true;
bool _darkModeEnabled = false;
String _selectedLanguage = 'Русский';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Уведомления'),
            subtitle: const Text('Получать уведомления о заказах и акциях'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Темная тема'),
            subtitle: const Text('Использовать темную тему оформления'),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Язык'),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.goNamed('language');
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('О приложении'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.goNamed('about');
            },
          ),
        ],
      ),
    );
  }
}

class SettingsLanguageDialog extends StatelessWidget {
  const SettingsLanguageDialog({super.key});

  @override
  Widget build(BuildContext context) => SimpleDialog(
    title: const Text('Выберите язык'),
    children: [
      SimpleDialogOption(
        onPressed: () {
          _selectedLanguage = 'Русский';
          Navigator.pop(context);
        },
        child: const Text('Русский'),
      ),
      SimpleDialogOption(
        onPressed: () {
          _selectedLanguage = 'English';
          Navigator.pop(context);
        },
        child: const Text('English'),
      ),
    ],
  );
}

class SettingsAboutDialog extends StatelessWidget {
  const SettingsAboutDialog({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('О приложении'),
    content: const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Демо приложение для навигации'),
        SizedBox(height: 8),
        Text('Версия: 1.0.0'),
        SizedBox(height: 8),
        Text('© 2025 Все права защищены'),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Закрыть'),
      ),
    ],
  );
}
// 4. App Settings Screen
import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _soundEnabled = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4DB6AC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'App Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView(
                  children: [
                    _buildSettingsHeader(),
                    const SizedBox(height: 30),
                    _buildSettingsSection('Notifications', [
                      _buildSwitchTile(
                        'Push Notifications',
                        'Receive notifications about new content',
                        Icons.notifications,
                        _notificationsEnabled,
                        (value) =>
                            setState(() => _notificationsEnabled = value),
                      ),
                    ]),
                    _buildSettingsSection('Appearance', [
                      _buildSwitchTile(
                        'Dark Mode',
                        'Use dark theme for the app',
                        Icons.dark_mode,
                        _darkModeEnabled,
                        (value) => setState(() => _darkModeEnabled = value),
                      ),
                    ]),
                    _buildSettingsSection('Audio', [
                      _buildSwitchTile(
                        'Sound Effects',
                        'Play sounds for interactions',
                        Icons.volume_up,
                        _soundEnabled,
                        (value) => setState(() => _soundEnabled = value),
                      ),
                    ]),
                    _buildSettingsSection('Language', [_buildLanguageTile()]),
                    _buildSettingsSection('Storage', [
                      _buildActionTile(
                        'Clear Cache',
                        'Free up storage space',
                        Icons.storage,
                        () => _showClearCacheDialog(),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsHeader() {
    return Column(
      children: [
        const Icon(Icons.settings, size: 60, color: Color(0xFF4DB6AC)),
        const SizedBox(height: 15),
        const Text(
          'App Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          'Customize your app experience',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4DB6AC),
          ),
        ),
        const SizedBox(height: 15),
        ...children,
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        secondary: Icon(icon, color: const Color(0xFF4DB6AC)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF4DB6AC),
      ),
    );
  }

  Widget _buildLanguageTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.language, color: Color(0xFF4DB6AC)),
        title: const Text(
          'Language',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _selectedLanguage,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showLanguageDialog(),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4DB6AC)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                ['English', 'Urdu', 'Arabic'].map((language) {
                  return RadioListTile<String>(
                    title: Text(language),
                    value: language,
                    groupValue: _selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                      Navigator.of(context).pop();
                    },
                    activeColor: const Color(0xFF4DB6AC),
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cache'),
          content: const Text(
            'Are you sure you want to clear the app cache? This will free up storage but may slow down the app temporarily.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache cleared successfully'),
                    backgroundColor: Color(0xFF4DB6AC),
                  ),
                );
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Color(0xFF4DB6AC)),
              ),
            ),
          ],
        );
      },
    );
  }
}

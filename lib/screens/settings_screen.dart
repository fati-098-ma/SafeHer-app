import 'package:flutter/material.dart';
import 'package:safeher/services/auth_service.dart';
import 'package:safeher/utils/constants.dart';
import 'package:safeher/services/local_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ADD THIS LINE - Fix for the error
  final LocalStorageService _storage = LocalStorageService();
  final AuthService _authService = AuthService();
  final TextEditingController _sosMessageController = TextEditingController();

  double _shakeSensitivity = AppConstants.defaultShakeSensitivity;
  bool _darkMode = false;
  bool _locationTracking = true;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _shakeSensitivity = _storage.getShakeSensitivity();
      _sosMessageController.text = _storage.getSosMessage();
      _darkMode = _storage.getDarkMode();
      _locationTracking = _storage.getLocationTracking();
      _notifications = _storage.getNotifications();
    });
  }

  void _saveShakeSensitivity(double value) {
    setState(() {
      _shakeSensitivity = value;
    });
    _storage.saveShakeSensitivity(value);
  }

  void _saveSosMessage(String message) {
    _storage.saveSosMessage(message);
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _darkMode = value;
    });
    _storage.saveDarkMode(value); // This was causing the error
  }

  void _toggleLocationTracking(bool value) {
    setState(() {
      _locationTracking = value;
    });
    _storage.saveLocationTracking(value);
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notifications = value;
    });
    _storage.saveNotifications(value);
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _authService.logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Reset all settings to default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _saveShakeSensitivity(AppConstants.defaultShakeSensitivity);
              _sosMessageController.text = AppConstants.defaultSosMessage;
              _saveSosMessage(AppConstants.defaultSosMessage);
              _toggleDarkMode(false);
              _toggleLocationTracking(true);
              _toggleNotifications(true);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _resetToDefaults,
            tooltip: 'Reset to Defaults',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SOS Message
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SOS Message',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _sosMessageController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter your emergency message',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: _saveSosMessage,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'This message will be sent to your emergency contacts along with your location.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Shake Sensitivity
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shake Sensitivity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.sensors, color: Colors.grey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Slider(
                          value: _shakeSensitivity,
                          min: 10.0,
                          max: 30.0,
                          divisions: 20,
                          label: _shakeSensitivity.toStringAsFixed(1),
                          onChanged: _saveShakeSensitivity,
                          activeColor: Colors.pink,
                          inactiveColor: Colors.grey.shade300,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.pink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _shakeSensitivity.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Lower = more sensitive, Higher = less sensitive',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // App Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'App Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Dark Mode
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Enable dark theme'),
                    value: _darkMode,
                    onChanged: _toggleDarkMode,
                    secondary: const Icon(Icons.dark_mode),
                    activeThumbColor: Colors.pink,
                  ),
                  const Divider(),
                  // Location Tracking
                  SwitchListTile(
                    title: const Text('Location Tracking'),
                    subtitle: const Text('Allow background location tracking'),
                    value: _locationTracking,
                    onChanged: _toggleLocationTracking,
                    secondary: const Icon(Icons.location_on),
                    activeThumbColor: Colors.pink,
                  ),
                  const Divider(),
                  // Notifications
                  SwitchListTile(
                    title: const Text('Notifications'),
                    subtitle: const Text('Receive emergency notifications'),
                    value: _notifications,
                    onChanged: _toggleNotifications,
                    secondary: const Icon(Icons.notifications),
                    activeThumbColor: Colors.pink,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Account Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('User Profile'),
                    subtitle: const Text('View and edit profile information'),
                    onTap: () {
                      // TODO: Navigate to profile screen
                    },
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.security_outlined),
                    title: const Text('Privacy & Security'),
                    subtitle: const Text('Manage privacy settings'),
                    onTap: () {
                      // TODO: Navigate to privacy screen
                    },
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & Support'),
                    subtitle: const Text('Get help using the app'),
                    onTap: () {
                      // TODO: Navigate to help screen
                    },
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Logout Button
          ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),

          // App Version
          Center(
            child: Text(
              'SafeHer v${AppConstants.appVersion}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sosMessageController.dispose();
    super.dispose();
  }
}
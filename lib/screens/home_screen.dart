import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safeher/services/auth_service.dart';
import 'package:safeher/services/location_service.dart';
import 'package:safeher/services/sms_service.dart';
import 'package:safeher/widgets/sos_button.dart';
import 'package:safeher/widgets/panic_sheet.dart'; // Add this import
import 'package:safeher/screens/contacts_screen.dart';
import 'package:safeher/screens/settings_screen.dart';
import 'package:safeher/screens/safe_walk_screen.dart';
import 'package:safeher/screens/sos_activated_screen.dart';
import 'package:safeher/screens/incident_report_screen.dart'; // Make sure this exists
import 'package:safeher/screens/safety_tips_screen.dart'; // Make sure this exists
import 'package:safeher/models/user_model.dart';
import 'package:safeher/utils/theme.dart'; // Add this import
import 'package:safeher/services/ringtone_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();
  final SmsService _smsService = SmsService();
  UserModel? _currentUser;
  final bool _isSafeWalkActive = false;
  bool _isLocationActive = true;
  User? _firebaseUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    try {
      _firebaseUser = FirebaseAuth.instance.currentUser;
      if (_firebaseUser != null) {
        await _locationService.initialize();
        _currentUser = await _authService.getUserData(_firebaseUser!.uid);
        _locationService.startBackgroundTracking();
      }
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error initializing app: $e');
      setState(() => _isLoading = false);
    }
  }

  void _triggerSOS() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SOSActivatedScreen()),
    );
    await _sendEmergencyAlerts();
  }

  Future<void> _sendEmergencyAlerts() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null && _currentUser != null) {
        String address = await _locationService.getAddressFromLatLng(
          position.latitude,
          position.longitude,
        );

        String locationUrl = await _locationService.getGoogleMapsUrl(
          position.latitude,
          position.longitude,
        );

        String message = '${_currentUser!.sosMessage}\n📍 $address\n🗺️ $locationUrl';

        if (_currentUser!.emergencyContacts.isNotEmpty) {
          await _smsService.sendEmergencySMS(
            _currentUser!.emergencyContacts,
            message,
          );
        }
      }
    } catch (e) {
      print('Error sending emergency alerts: $e');
    }
  }

  void _showPanicOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PanicSheet(
        onSOSPressed: _triggerSOS,
        onFakeCall: _triggerFakeCall,
        onEmergencyCall: _callEmergency,
      ),
    );
  }



  void _triggerFakeCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📞 Fake call will arrive in 10 seconds...'),
        backgroundColor: Colors.purple,
      ),
    );

    // Schedule the fake call after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;

      // PLAY RINGTONE when call arrives
      RingtoneService().playRingtone();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.phone, color: Colors.green),
              SizedBox(width: 10),
              Text('Incoming Call'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.pink[100],
                child: const Icon(Icons.person, size: 40, color: Colors.pink),
              ),
              const SizedBox(height: 10),
              const Text(
                'Mom',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text('Mobile', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              const Text(
                '🔔 Ringing...',
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ],
          ),
          actions: [
            // Decline Button - STOPS RINGTONE
            TextButton(
              onPressed: () {
                RingtoneService().stopRingtone();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Call declined')),
                );
              },
              child: const Text('Decline', style: TextStyle(color: Colors.red)),
            ),
            // Answer Button - STOPS RINGTONE
            TextButton(
              onPressed: () {
                RingtoneService().stopRingtone();
                Navigator.of(context).pop();
                _showActiveCallDialog(context);
              },
              child: const Text('Answer', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      );
    });
  }

  void _showActiveCallDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.pink,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Mom',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<int>(
              stream: Stream.periodic(const Duration(seconds: 1), (i) => i + 1),
              builder: (context, snapshot) {
                final seconds = snapshot.data ?? 0;
                final minutes = seconds ~/ 60;
                final secs = seconds % 60;
                return Text(
                  '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.blue),
                  onPressed: () {},
                  tooltip: 'Speaker',
                ),
                IconButton(
                  icon: const Icon(Icons.mic_off, color: Colors.orange),
                  onPressed: () {},
                  tooltip: 'Mute',
                ),
                IconButton(
                  icon: const Icon(Icons.pause, color: Colors.purple),
                  onPressed: () {},
                  tooltip: 'Hold',
                ),
              ],
            ),
          ],
        ),
        actions: [
          Center(
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.red,
              child: IconButton(
                icon: const Icon(Icons.call_end, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Call ended')),
                  );
                },
                tooltip: 'End Call',
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  void _callEmergency() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Calling emergency services...'),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  void _shareLiveLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        // Implement live location sharing
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location shared with emergency contacts'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      print('Error sharing location: $e');
    }
  }

  // Add this method for QuickAction widget
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Loading your safety profile...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SafeHer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              _currentUser != null ? 'Hello, ${_currentUser!.name}!' : 'Welcome',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Safety Status Card
            Card(
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: AppColors.success, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Safety Status: ACTIVE',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatusItem(
                          icon: Icons.location_on,
                          label: 'Location',
                          isActive: _isLocationActive,
                          onToggle: (value) {
                            setState(() => _isLocationActive = value);
                          },
                        ),
                        _buildStatusItem(
                          icon: Icons.vibration,
                          label: 'Shake Detection',
                          isActive: true,
                        ),
                        _buildStatusItem(
                          icon: Icons.notifications,
                          label: 'Alerts',
                          isActive: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // SOS Button
            Center(
              child: Column(
                children: [
                  const Text(
                    'Press and hold for SOS',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  SOSButton(
                    onActivate: _triggerSOS,
                    size: 180,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'or shake phone to activate',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Fixed this line
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildQuickAction(
                  icon: Icons.directions_walk,
                  label: 'Safe Walk',
                  color: AppColors.accent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SafeWalkScreen()),
                  ),
                ),
                _buildQuickAction(
                  icon: Icons.share_location,
                  label: 'Share Live',
                  color: AppColors.success,
                  onTap: _shareLiveLocation,
                ),
                _buildQuickAction(
                  icon: Icons.phone,
                  label: 'Fake Call',
                  color: AppColors.warning,
                  onTap: _triggerFakeCall,
                ),
                _buildQuickAction(
                  icon: Icons.contacts,
                  label: 'Contacts',
                  color: AppColors.secondary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ContactsScreen()),
                  ),
                ),
                _buildQuickAction(
                  icon: Icons.report,
                  label: 'Report',
                  color: AppColors.danger,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => IncidentReportScreen()),                  ),
                ),
                _buildQuickAction(
                  icon: Icons.lightbulb_outline,
                  label: 'Safety Tips',
                  color: AppColors.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SafetyTipsScreen()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Emergency Contacts Preview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Emergency Contacts',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ContactsScreen()),
                          ),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_currentUser?.emergencyContacts.isEmpty ?? true)
                      const Text(
                        'No contacts added yet',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      ..._currentUser!.emergencyContacts.take(3).map(
                            (contact) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Icon(Icons.person, color: AppColors.primary),
                          ),
                          title: Text(contact.name),
                          subtitle: Text(contact.phone),
                          trailing: IconButton(
                            icon: const Icon(Icons.phone, size: 20),
                            onPressed: () => _smsService.callEmergencyContact(contact),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPanicOptions,
        backgroundColor: AppColors.danger,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.emergency),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required bool isActive,
    Function(bool)? onToggle,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? AppColors.primary : Colors.grey,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppColors.primary : Colors.grey,
          ),
        ),
        if (onToggle != null) ...[
          const SizedBox(height: 4),
          Switch(
            value: isActive,
            onChanged: onToggle,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }

}
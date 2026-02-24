// widgets/panic_sheet.dart
import 'package:flutter/material.dart';
import 'package:safeher/utils/theme.dart';

class PanicSheet extends StatelessWidget {
  final VoidCallback onSOSPressed;
  final VoidCallback onFakeCall;
  final VoidCallback onEmergencyCall;

  const PanicSheet({
    super.key,
    required this.onSOSPressed,
    required this.onFakeCall,
    required this.onEmergencyCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Emergency Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Choose an emergency action',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 32),
              // SOS Button
              _buildEmergencyButton(
                context,
                icon: Icons.emergency,
                label: 'Send SOS Alert',
                description: 'Notify all emergency contacts with your location',
                color: AppColors.danger,
                onPressed: onSOSPressed,
              ),
              SizedBox(height: 16),
              // Fake Call Button
              _buildEmergencyButton(
                context,
                icon: Icons.phone,
                label: 'Fake Call',
                description: 'Receive a fake incoming call',
                color: AppColors.warning,
                onPressed: onFakeCall,
              ),
              SizedBox(height: 16),
              // Emergency Call Button
              _buildEmergencyButton(
                context,
                icon: Icons.local_police,
                label: 'Call Police',
                description: 'Direct call to emergency services',
                color: AppColors.primary,
                onPressed: onEmergencyCall,
              ),
              SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String description,
        required Color color,
        required VoidCallback onPressed,
      }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onPressed();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
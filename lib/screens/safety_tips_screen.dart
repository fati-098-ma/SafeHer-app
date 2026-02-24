// screens/safety_tips_screen.dart
import 'package:flutter/material.dart';
import 'package:safeher/utils/theme.dart';

class SafetyTipsScreen extends StatefulWidget {
  const SafetyTipsScreen({super.key});

  @override
  _SafetyTipsScreenState createState() => _SafetyTipsScreenState();
}

class _SafetyTipsScreenState extends State<SafetyTipsScreen> {
  final List<SafetyTip> _safetyTips = [
    SafetyTip(
      title: 'Walking Alone',
      icon: Icons.directions_walk,
      tips: [
        'Stay in well-lit areas',
        'Avoid using headphones',
        'Keep your phone charged',
        'Walk confidently',
        'Share your location with trusted contacts',
      ],
      color: AppColors.accent,
    ),
    SafetyTip(
      title: 'Public Transport',
      icon: Icons.directions_bus,
      tips: [
        'Sit near the driver',
        'Avoid empty compartments',
        'Stay alert at stations',
        'Have emergency numbers ready',
        'Trust your instincts',
      ],
      color: AppColors.secondary,
    ),
    SafetyTip(
      title: 'Night Safety',
      icon: Icons.nights_stay,
      tips: [
        'Plan your route in advance',
        'Use registered cabs',
        'Avoid isolated ATMs',
        'Carry a safety alarm',
        'Check in with friends',
      ],
      color: AppColors.primary,
    ),
    SafetyTip(
      title: 'Online Safety',
      icon: Icons.security,
      tips: [
        'Don\'t share personal details',
        'Meet in public places',
        'Tell someone about your plans',
        'Use the SafeWalk feature',
        'Keep emergency contacts updated',
      ],
      color: AppColors.success,
    ),
    SafetyTip(
      title: 'Emergency Response',
      icon: Icons.emergency,
      tips: [
        'Memorize emergency numbers',
        'Know your location',
        'Use SOS button immediately',
        'Scream and attract attention',
        'Run to crowded places',
      ],
      color: AppColors.danger,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Safety Tips'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _safetyTips.length,
        itemBuilder: (context, index) {
          final tip = _safetyTips[index];
          return SafetyTipCard(tip: tip);
        },
      ),
    );
  }
}

class SafetyTip {
  final String title;
  final IconData icon;
  final List<String> tips;
  final Color color;

  SafetyTip({
    required this.title,
    required this.icon,
    required this.tips,
    required this.color,
  });
}

class SafetyTipCard extends StatefulWidget {
  final SafetyTip tip;

  const SafetyTipCard({super.key, required this.tip});

  @override
  _SafetyTipCardState createState() => _SafetyTipCardState();
}

class _SafetyTipCardState extends State<SafetyTipCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.tip.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(widget.tip.icon, color: widget.tip.color),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.tip.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                SizedBox(height: 16),
                ...widget.tip.tips.map((tip) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: widget.tip.color,
                        size: 16,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
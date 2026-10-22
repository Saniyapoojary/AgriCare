import 'package:flutter/material.dart';

class SeverityStyle {
  final Color background;
  final Color textColor;
  final IconData icon;

  const SeverityStyle(this.background, this.textColor, this.icon);
}

SeverityStyle severityStyleFor(String severity) {
  switch (severity) {
    case 'Severe':
      return const SeverityStyle(Color(0xFFFEE2E2), Color(0xFF991B1B), Icons.error_rounded);
    case 'Moderate':
      return const SeverityStyle(Color(0xFFFFEDD5), Color(0xFFC2410C), Icons.warning_amber_rounded);
    case 'Mild':
      return const SeverityStyle(Color(0xFFFEF3C7), Color(0xFF92400E), Icons.info_outline_rounded);
    default:
      return const SeverityStyle(Color(0xFFDCFCE7), Color(0xFF166534), Icons.check_circle_rounded);
  }
}

class SeverityBadge extends StatelessWidget {
  final String severity;
  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final style = severityStyleFor(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: style.textColor.withAlpha(75)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 16, color: style.textColor),
          const SizedBox(width: 6),
          Text(
            '$severity Severity',
            style: TextStyle(color: style.textColor, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

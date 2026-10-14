import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Badge status pesanan (Diproses / Selesai / Dibatalkan) dengan warna berbeda.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  IconData get _icon => switch (status) {
        'Selesai' => Icons.check_circle_rounded,
        'Dibatalkan' => Icons.cancel_rounded,
        _ => Icons.hourglass_top_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

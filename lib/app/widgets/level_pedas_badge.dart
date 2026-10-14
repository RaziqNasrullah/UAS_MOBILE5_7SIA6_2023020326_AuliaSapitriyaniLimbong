import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Badge level pedas dengan warna berbeda per level.
class LevelPedasBadge extends StatelessWidget {
  const LevelPedasBadge({super.key, required this.level, this.compact = false});

  final String level;
  final bool compact;

  int get _jumlahCabai => switch (level) {
        'Sedang' => 1,
        'Pedas' => 2,
        'Extra Pedas' => 3,
        _ => 0,
      };

  @override
  Widget build(BuildContext context) {
    final color = AppColors.levelPedasColor(level);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 3 : 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_jumlahCabai == 0)
            Icon(Icons.eco_rounded, size: compact ? 12 : 14, color: color)
          else
            for (var i = 0; i < _jumlahCabai; i++)
              Icon(Icons.local_fire_department_rounded, size: compact ? 12 : 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              level,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: compact ? 10.5 : 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tombol +/- jumlah dengan batas minimal & maksimal (stok).
class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    required this.max,
    this.compact = false,
    this.enabled = true,
  });

  final int value;
  final int min;
  final int max;
  final bool compact;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 30.0 : 40.0;
    Widget tombol(IconData icon, bool aktif, VoidCallback onTap) => SizedBox(
          width: size,
          height: size,
          child: IconButton.filled(
            padding: EdgeInsets.zero,
            iconSize: compact ? 16 : 20,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.mint,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            onPressed: enabled && aktif ? onTap : null,
            icon: Icon(icon, color: Colors.white),
          ),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        tombol(Icons.remove_rounded, value > min, () => onChanged(value - 1)),
        SizedBox(
          width: compact ? 34 : 44,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: compact ? 14 : 18),
          ),
        ),
        tombol(Icons.add_rounded, value < max, () => onChanged(value + 1)),
      ],
    );
  }
}

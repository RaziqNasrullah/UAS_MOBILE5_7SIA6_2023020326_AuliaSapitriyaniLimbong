import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/formatter.dart';

/// Baris rincian biaya: label ........ nilai
class BiayaRow extends StatelessWidget {
  const BiayaRow({super.key, required this.label, required this.value, this.isTotal = false, this.isMinus = false, this.note});

  final String label;
  final double value;
  final bool isTotal;
  final bool isMinus;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final style = isTotal
        ? const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.tealDark)
        : TextStyle(color: isMinus ? AppColors.selesai : AppColors.textDark);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: style.copyWith(color: isTotal ? AppColors.tealDark : AppColors.textMuted)),
                if (note != null) Text(note!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Text(
            '${isMinus && value > 0 ? '- ' : ''}${Formatter.rupiah(value)}',
            style: isTotal ? style.copyWith(color: AppColors.coralDark) : style,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// ChoiceChip kategori (dipakai untuk filter di Katalog).
class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.label, required this.selected, required this.onSelected, this.icon});

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      avatar: icon == null ? null : Icon(icon, size: 18, color: selected ? Colors.white : AppColors.coral),
      selected: selected,
      onSelected: onSelected,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textDark,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    );
  }
}

/// Ikon Material berdasarkan kolom `ikon` / nama kategori.
IconData ikonKategori(String? ikon, [String nama = '']) {
  final key = (ikon ?? '').isNotEmpty ? ikon! : nama.toLowerCase();
  if (key.contains('rice') || key.contains('makan')) return Icons.rice_bowl_rounded;
  if (key.contains('cafe') || key.contains('minum')) return Icons.local_cafe_rounded;
  if (key.contains('fast') || key.contains('snack')) return Icons.fastfood_rounded;
  if (key.contains('ice') || key.contains('dessert')) return Icons.icecream_rounded;
  if (key.contains('cake') || key.contains('kue')) return Icons.cake_rounded;
  return Icons.restaurant_menu_rounded;
}

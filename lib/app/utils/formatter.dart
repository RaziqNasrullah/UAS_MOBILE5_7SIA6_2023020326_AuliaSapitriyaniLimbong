import 'package:intl/intl.dart';

/// Formatter rupiah & tanggal (locale Indonesia).
class Formatter {
  Formatter._();

  static final NumberFormat _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  /// 32000 -> "Rp32.000"
  static String rupiah(num value) => _rupiah.format(value);

  /// 14 Okt 2026, 13:05
  static String tanggalJam(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  /// Rabu, 14 Oktober 2026
  static String tanggalPanjang(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  /// 14/10/2026 13:05 (dipakai di struk PDF)
  static String tanggalStruk(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm', 'id_ID').format(date);
  }

  /// "Sen", "Sel" ... untuk label grafik
  static String hariSingkat(DateTime date) => DateFormat('E', 'id_ID').format(date);

  /// 150000 -> "150rb", 1250000 -> "1,3jt" (label sumbu grafik)
  static String ringkas(num value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1).replaceAll('.', ',')}jt';
    }
    if (value >= 1000) return '${(value / 1000).round()}rb';
    return value.toStringAsFixed(0);
  }

  /// Sapaan berdasarkan jam: pagi (04-10), siang (11-14), sore (15-17), malam.
  static String sapaan([DateTime? now]) {
    final jam = (now ?? DateTime.now()).hour;
    if (jam >= 4 && jam < 11) return 'Selamat Pagi';
    if (jam >= 11 && jam < 15) return 'Selamat Siang';
    if (jam >= 15 && jam < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  /// Mengganti karakter di luar Latin-1 (font bawaan PDF) dengan padanan ASCII.
  static String latin1Safe(String text) {
    const pengganti = {
      '—': '-', // em dash
      '–': '-', // en dash
      '‘': "'",
      '’': "'",
      '“': '"',
      '”': '"',
      '…': '...',
      '•': '-',
    };
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (pengganti.containsKey(char)) {
        buffer.write(pengganti[char]);
      } else if (rune <= 0xFF) {
        buffer.write(char);
      }
      // karakter lain (emoji, dsb.) dibuang
    }
    return buffer.toString();
  }
}

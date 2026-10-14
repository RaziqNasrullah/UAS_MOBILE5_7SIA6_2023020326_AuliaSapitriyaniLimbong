import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/services/api_config.dart';
import '../models/pesanan.dart';
import 'formatter.dart';

/// Membuat struk pesanan (PDF, kertas thermal 80 mm).
/// Font bawaan PDF (Helvetica) hanya mendukung Latin-1, maka semua teks
/// dilewatkan ke [Formatter.latin1Safe].
class StrukPdfGenerator {
  StrukPdfGenerator._();

  static String _t(String text) => Formatter.latin1Safe(text);

  static Future<Uint8List> generate(Pesanan p, {Uint8List? logo}) async {
    final doc = pw.Document(
      title: 'Struk ${p.nomorPesanan}',
      author: ApiConfig.namaKedai,
      creator: ApiConfig.namaAplikasi,
    );

    const teal = PdfColor.fromInt(0xFF1F5F66);
    const coral = PdfColor.fromInt(0xFFE0663F);
    const abu = PdfColor.fromInt(0xFF78858C);
    final base = pw.TextStyle(fontSize: 8.5);
    final bold = pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold);

    pw.Widget garis() => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 5),
          child: pw.Divider(height: 1, thickness: 0.6, borderStyle: pw.BorderStyle.dashed, color: abu),
        );

    pw.Widget baris(String label, String value, {bool tebal = false, PdfColor? warna}) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 1.2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(child: pw.Text(_t(label), style: tebal ? bold : base)),
              pw.SizedBox(width: 6),
              pw.Text(_t(value), style: (tebal ? bold : base).copyWith(color: warna)),
            ],
          ),
        );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80.copyWith(
          marginLeft: 5 * PdfPageFormat.mm,
          marginRight: 5 * PdfPageFormat.mm,
          marginTop: 6 * PdfPageFormat.mm,
          marginBottom: 8 * PdfPageFormat.mm,
        ),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if (logo != null)
              pw.Center(child: pw.Image(pw.MemoryImage(logo), width: 70, height: 70)),
            pw.Center(
              child: pw.Text(ApiConfig.namaKedai,
                  style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: teal)),
            ),
            pw.Center(child: pw.Text(_t('via aplikasi ${ApiConfig.namaAplikasi}'), style: base.copyWith(color: coral))),
            pw.Center(child: pw.Text(_t(ApiConfig.alamatKedai), style: base.copyWith(fontSize: 7.5))),
            pw.Center(child: pw.Text(_t('Telp. ${ApiConfig.teleponKedai}'), style: base.copyWith(fontSize: 7.5))),
            garis(),
            baris('No. Pesanan', p.nomorPesanan, tebal: true),
            baris('Tanggal', Formatter.tanggalStruk(p.tanggal)),
            baris('Pemesan', p.namaPemesan),
            baris('No. HP', p.noHp),
            baris('Tipe', p.tipePesanan),
            if (p.nomorMeja != null) baris('No. Meja', p.nomorMeja!),
            if (p.alamat != null)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 1.2),
                child: pw.Text(_t('Alamat: ${p.alamat}'), style: base),
              ),
            baris('Status', p.status),
            garis(),
            for (final item in p.items) ...[
              pw.Text(_t(item.namaMenu), style: bold),
              baris('  ${item.jumlah} x ${Formatter.rupiah(item.hargaSatuan)}', Formatter.rupiah(item.subtotal)),
              if (item.catatanItem != null)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 6, bottom: 2),
                  child: pw.Text(_t('Catatan: ${item.catatanItem}'),
                      style: base.copyWith(fontSize: 7.5, fontStyle: pw.FontStyle.italic, color: abu)),
                ),
              pw.SizedBox(height: 2),
            ],
            garis(),
            baris('Subtotal', Formatter.rupiah(p.subtotal)),
            baris('Biaya Layanan', Formatter.rupiah(p.biayaLayanan)),
            baris('Ongkir', Formatter.rupiah(p.ongkir)),
            baris('Diskon', p.diskon > 0 ? '-${Formatter.rupiah(p.diskon)}' : Formatter.rupiah(0)),
            garis(),
            pw.Row(
              children: [
                pw.Expanded(child: pw.Text('TOTAL BAYAR', style: bold.copyWith(fontSize: 11))),
                pw.Text(_t(Formatter.rupiah(p.total)), style: bold.copyWith(fontSize: 11, color: coral)),
              ],
            ),
            if (p.catatan != null) ...[
              garis(),
              pw.Text(_t('Catatan pesanan: ${p.catatan}'), style: base.copyWith(fontSize: 7.5)),
            ],
            garis(),
            pw.Center(child: pw.Text('Terima kasih telah memesan!', style: bold)),
            pw.Center(
              child: pw.Text(_t('Sweet moments, fresh flavors - ${ApiConfig.namaKedai}'),
                  style: base.copyWith(fontSize: 7.5, color: abu)),
            ),
          ],
        ),
      ),
    );
    return doc.save();
  }

  /// Nama file struk, mis. Struk_INV-20261014-001.pdf
  static String namaFile(Pesanan p) => 'Struk_${p.nomorPesanan}.pdf';
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard_controller.dart';
import '../../models/dashboard_summary.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/state_views.dart';
import '../../widgets/summary_card.dart';

/// Dashboard penjualan: kartu ringkasan + BarChart, LineChart, PieChart (fl_chart).
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  static const _warnaChart = [AppColors.coral, AppColors.mint, Color(0xFFF2A93B), Color(0xFFEC80A0), AppColors.tealDark];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Penjualan'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: () => controller.fetchSummary(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.summary.value == null) return const LoadingView();
        final s = controller.summary.value;
        if (s == null) {
          return ErrorState(
            message: controller.errorMessage.value ?? 'Data dashboard kosong',
            onRetry: controller.fetchSummary,
          );
        }
        return RefreshIndicator(
          color: AppColors.coral,
          onRefresh: () => controller.fetchSummary(silent: true),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  SummaryCard(
                    title: 'Total Pesanan',
                    value: '${s.totalPesanan}',
                    subtitle: 'Diproses ${s.pesananPerStatus['Diproses'] ?? 0} - Selesai ${s.pesananPerStatus['Selesai'] ?? 0}'
                        ' - Batal ${s.pesananPerStatus['Dibatalkan'] ?? 0}',
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.mint,
                  ),
                  SummaryCard(
                    title: 'Total Pendapatan',
                    value: Formatter.rupiah(s.totalPendapatan),
                    subtitle: 'Hanya pesanan berstatus Selesai',
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.coral,
                  ),
                  SummaryCard(
                    title: 'Menu Terlaris',
                    value: s.menuTerlaris.isEmpty ? '-' : s.menuTerlaris.first.namaMenu,
                    subtitle: s.menuTerlaris.isEmpty ? 'Belum ada penjualan' : '${s.menuTerlaris.first.totalTerjual} porsi terjual',
                    icon: Icons.emoji_events_rounded,
                    color: const Color(0xFFF2A93B),
                  ),
                  SummaryCard(
                    title: 'Porsi Terjual',
                    value: '${s.porsiTerjual}',
                    subtitle: 'Tidak termasuk pesanan Dibatalkan',
                    icon: Icons.ramen_dining_rounded,
                    color: AppColors.tealDark,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Catatan: pendapatan dihitung dari pesanan berstatus "Selesai". Menu terlaris dihitung dari '
                  'jumlah porsi pada pesanan yang tidak dibatalkan.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
              ),
              _ChartCard(
                title: '5 Menu Terlaris',
                subtitle: 'Jumlah porsi terjual',
                child: s.menuTerlaris.isEmpty ? const _Kosong() : _BarTerlaris(data: s.menuTerlaris, warna: _warnaChart),
              ),
              const SizedBox(height: 12),
              _ChartCard(
                title: 'Pendapatan 7 Hari Terakhir',
                subtitle: 'Pesanan Selesai per hari',
                child: _LinePendapatan(data: s.pendapatan7Hari),
              ),
              const SizedBox(height: 12),
              _ChartCard(
                title: 'Penjualan per Kategori',
                subtitle: 'Porsi terjual per kategori',
                child: s.penjualanKategori.isEmpty
                    ? const _Kosong()
                    : _PieKategori(data: s.penjualanKategori, warna: _warnaChart),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _Kosong extends StatelessWidget {
  const _Kosong();

  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 120,
        child: Center(child: Text('Belum ada data penjualan', style: TextStyle(color: AppColors.textMuted))),
      );
}

class _BarTerlaris extends StatelessWidget {
  const _BarTerlaris({required this.data, required this.warna});

  final List<MenuTerlaris> data;
  final List<Color> warna;

  @override
  Widget build(BuildContext context) {
    final maxY = data.map((e) => e.totalTerjual).reduce((a, b) => a > b ? a : b).toDouble();
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: maxY + 1,
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: maxY > 5 ? (maxY / 4).ceilToDouble() : 1,
                getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                    '${data[group.x].namaMenu}\n${rod.toY.toInt()} porsi',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: maxY > 5 ? (maxY / 4).ceilToDouble() : 1,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('#${value.toInt() + 1}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < data.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i].totalTerjual.toDouble(),
                        color: warna[i % warna.length],
                        width: 22,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < data.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: warna[i % warna.length], shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text('#${i + 1} ', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                Expanded(
                  child: Text(data[i].namaMenu, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                ),
                Text('${data[i].totalTerjual} porsi', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    );
  }
}

class _LinePendapatan extends StatelessWidget {
  const _LinePendapatan({required this.data});

  final List<PendapatanHarian> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const _Kosong();
    final maxVal = data.map((e) => e.pendapatan).reduce((a, b) => a > b ? a : b);
    // Skala sumbu Y dibulatkan ke kelipatan Rp10.000 agar label rapi (4 garis bantu).
    final interval = maxVal <= 0 ? 25000.0 : ((maxVal * 1.15 / 4) / 10000).ceil() * 10000.0;
    final maxY = interval * 4;
    final total = data.fold<double>(0, (s, e) => s + e.pendapatan);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY,
              minX: 0,
              maxX: (data.length - 1).toDouble(),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots
                      .map((s) => LineTooltipItem(
                            '${Formatter.hariSingkat(data[s.x.toInt()].tanggal)}\n${Formatter.rupiah(s.y)}',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                          ))
                      .toList(),
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: interval,
                    getTitlesWidget: (value, meta) => Text(
                      Formatter.ringkas(value),
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= data.length || value != i.toDouble()) return const SizedBox.shrink();
                      final d = data[i].tanggal;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text('${Formatter.hariSingkat(d)}\n${d.day}',
                            textAlign: TextAlign.center, style: const TextStyle(fontSize: 9.5, height: 1.1)),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].pendapatan)],
                  isCurved: true,
                  curveSmoothness: 0.2,
                  preventCurveOverShooting: true,
                  color: AppColors.coral,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.coral.withValues(alpha: 0.35), AppColors.coral.withValues(alpha: 0.02)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('Total 7 hari: ${Formatter.rupiah(total)}',
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.tealDark)),
      ],
    );
  }
}

class _PieKategori extends StatelessWidget {
  const _PieKategori({required this.data, required this.warna});

  final List<PenjualanKategori> data;
  final List<Color> warna;

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (s, e) => s + e.totalTerjual);
    return Row(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 30,
              sectionsSpace: 2,
              sections: [
                for (var i = 0; i < data.length; i++)
                  PieChartSectionData(
                    value: data[i].totalTerjual.toDouble(),
                    color: warna[i % warna.length],
                    radius: 42,
                    title: total == 0 ? '' : '${(data[i].totalTerjual / total * 100).round()}%',
                    titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < data.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: warna[i % warna.length], borderRadius: BorderRadius.circular(3)),
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: Text(data[i].namaKategori, style: const TextStyle(fontSize: 12.5))),
                      Text('${data[i].totalTerjual}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

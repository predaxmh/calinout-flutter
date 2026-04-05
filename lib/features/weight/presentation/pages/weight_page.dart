import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:calinout/features/home_manager/presentation/controllers/daily_log_controller.dart';
import 'package:calinout/features/user_profile/domain/entities/user_profile.dart';
import 'package:calinout/features/user_profile/presentation/controllers/profile_controller.dart';
import 'package:calinout/features/weight/presentation/controllers/weight_history_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class WeightPage extends ConsumerWidget {
  const WeightPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEntries = ref.watch(weightHistoryControllerProvider);
    final stats = ref.watch(weightStatsProvider);
    final range = ref.watch(weightRangeSelectorProvider);
    final profile = ref.watch(profileControllerProvider).value;

    return RefreshIndicator(
      color: AppColors.secondary,
      onRefresh: () =>
          ref.read(weightHistoryControllerProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Header ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildHeader(context, stats, profile),
            ),
          ),
          // ── Range selector ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: _RangeSelector(selected: range),
            ),
          ),

          // ── Chart ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: asyncEntries.when(
                loading: () => const _ChartSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
                data: (entries) => entries.length < 2
                    ? _buildNotEnoughDataCard(context)
                    : _WeightChart(entries: entries, profile: profile),
              ),
            ),
          ),

          // ── Stats row ─────────────────────────────────────────────
          if (stats != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _StatsRow(stats: stats),
              ),
            ),

          // ── Entry list header ─────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    'History',
                    style: AppTextStyles.headerMedium.copyWith(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  asyncEntries.whenOrNull(
                        data: (e) => Text(
                          '${e.length} entr${e.length == 1 ? 'y' : 'ies'}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ) ??
                      const SizedBox.shrink(),
                ],
              ),
            ),
          ),

          // ── Entry list ────────────────────────────────────────────
          asyncEntries.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverToBoxAdapter(
              child: _ErrorCard(
                message: err.toString(),
                onRetry: () => ref
                    .read(weightHistoryControllerProvider.notifier)
                    .refresh(),
              ),
            ),
            data: (entries) {
              if (entries.isEmpty) {
                return const SliverToBoxAdapter(child: _EmptyCard());
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _WeightEntryTile(
                      entry: entries[i],
                      onEdit: () => _openWeightSheet(
                        context,
                        ref,
                        date: entries[i].date,
                        existing: entries[i],
                      ),
                      onDelete: () => _deleteEntry(context, ref, entries[i]),
                    ),
                    childCount: entries.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────

  Widget _buildHeader(
    BuildContext context,
    WeightStats? stats,
    UserProfile? profile,
  ) {
    final current = stats?.current;
    final change = stats?.change;
    //final hasGoal = profile?.targetWeightKg != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weight',
              style: AppTextStyles.headerMedium.copyWith(
                color: AppColors.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  current != null ? current.toStringAsFixed(1) : '--',
                  style: AppTextStyles.headerMedium.copyWith(
                    color: AppColors.primary,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'kg',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        if (change != null) _ChangeBadge(change: change),
      ],
    );
  }

  Widget _buildNotEnoughDataCard(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.show_chart,
              size: 36,
              color: AppColors.grey.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Text(
              'Log at least 2 days to see the chart',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────

  void _openWeightSheet(
    BuildContext context,
    WidgetRef ref, {
    required DateTime date,
    WeightEntry? existing,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WeightInputSheet(
        date: date,
        existing: existing,
        onSave: (weight) async {
          Navigator.of(context).pop();
          await _saveWeight(context, ref, date, weight, existing);
        },
      ),
    );
  }

  Future<void> _saveWeight(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
    double weight,
    WeightEntry? existing,
  ) async {
    final controller = ref.read(dailyLogControllerProvider.notifier);

    // DailyLogController.updateWeight handles fetching the log for that date
    // if it's not today, then updating the weight field.
    await controller.updateWeight(weight, date);

    // Sync the weight history list locally — no full refetch needed.
    final updatedLog = existing?.sourceLog.copyWith(weightAtLog: weight);
    if (updatedLog != null) {
      ref
          .read(weightHistoryControllerProvider.notifier)
          .updateEntryLocal(date, weight, updatedLog);
    } else {
      // New entry — full refresh to get the log from backend
      ref.read(weightHistoryControllerProvider.notifier).refresh();
    }
  }

  Future<void> _deleteEntry(
    BuildContext context,
    WidgetRef ref,
    WeightEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Weight'),
        content: Text(
          'Remove weight entry for ${DateFormat('d MMM yyyy').format(entry.date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref
        .read(dailyLogControllerProvider.notifier)
        .updateWeight(null, entry.date);

    ref
        .read(weightHistoryControllerProvider.notifier)
        .updateEntryLocal(entry.date, null, entry.sourceLog);
  }
}

// ── Range selector ─────────────────────────────────────────────────────────

class _RangeSelector extends ConsumerWidget {
  final WeightRange selected;
  const _RangeSelector({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: WeightRange.values.map((r) {
          final active = r == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(weightRangeSelectorProvider.notifier).select(r);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  r.label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: active ? AppColors.white : AppColors.grey,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Chart ──────────────────────────────────────────────────────────────────

class _WeightChart extends ConsumerWidget {
  final List<WeightEntry> entries;
  final UserProfile? profile;

  const _WeightChart({required this.entries, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Entries sorted newest first — reverse for chart (oldest left)
    final sorted = entries.reversed.toList();
    final weights = sorted.map((e) => e.weightKg).toList();
    final minY = (weights.reduce((a, b) => a < b ? a : b) - 2)
        .clamp(0, double.infinity)
        .toDouble();
    final maxY = weights.reduce((a, b) => a > b ? a : b) + 2;

    final spots = sorted.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weightKg);
    }).toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.primary.withValues(alpha: 0.08),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: 2,
                getTitlesWidget: (val, _) => Text(
                  val.toStringAsFixed(0),
                  style: TextStyle(color: AppColors.grey, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: (sorted.length / 4).ceilToDouble(),
                getTitlesWidget: (val, _) {
                  final i = val.toInt();
                  if (i < 0 || i >= sorted.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    DateFormat('d/M').format(sorted[i].date),
                    style: TextStyle(color: AppColors.grey, fontSize: 9),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [
            // Main weight line
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.secondary,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.secondary,
                  strokeWidth: 2,
                  strokeColor: AppColors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.2),
                    AppColors.secondary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) {
                final entry = sorted[s.spotIndex];
                return LineTooltipItem(
                  '${entry.weightKg.toStringAsFixed(1)} kg\n',
                  TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: DateFormat('d MMM').format(entry.date),
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

// ── Stats row ──────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final WeightStats stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: 'Lowest',
          value: '${stats.lowest.toStringAsFixed(1)} kg',
          color: Colors.green,
        ),
        const SizedBox(width: 8),
        _StatCard(
          label: 'Highest',
          value: '${stats.highest.toStringAsFixed(1)} kg',
          color: AppColors.error,
        ),
        const SizedBox(width: 8),
        _StatCard(
          label: 'Average',
          value: '${stats.average.toStringAsFixed(1)} kg',
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Change badge ───────────────────────────────────────────────────────────

class _ChangeBadge extends StatelessWidget {
  final double change;
  const _ChangeBadge({required this.change});

  @override
  Widget build(BuildContext context) {
    final gained = change > 0;
    final color = gained ? AppColors.error : Colors.green;
    final icon = gained ? Icons.arrow_upward : Icons.arrow_downward;
    final label = '${gained ? '+' : ''}${change.toStringAsFixed(1)} kg';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Entry tile ─────────────────────────────────────────────────────────────

class _WeightEntryTile extends StatelessWidget {
  final WeightEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WeightEntryTile({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.date.toIso8601String()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false; // let onDelete handle state
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            // Date column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEE').format(entry.date).toUpperCase(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  DateFormat('d MMM').format(entry.date),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  DateFormat('yyyy').format(entry.date),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Divider
            Container(
              width: 1,
              height: 40,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            const SizedBox(width: 16),
            // Notes
            Expanded(
              child: Center(
                child: Text(
                  '---------------------------------------',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Weight
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  entry.weightKg.toStringAsFixed(1),
                  style: AppTextStyles.headerMedium.copyWith(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'kg',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            // Edit button
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.grey.withValues(alpha: 0.6),
              ),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Weight input bottom sheet ──────────────────────────────────────────────

class _WeightInputSheet extends StatefulWidget {
  final DateTime date;
  final WeightEntry? existing;
  final void Function(double weight) onSave;

  const _WeightInputSheet({
    required this.date,
    required this.existing,
    required this.onSave,
  });

  @override
  State<_WeightInputSheet> createState() => _WeightInputSheetState();
}

class _WeightInputSheetState extends State<_WeightInputSheet> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.existing != null
          ? widget.existing!.weightKg.toStringAsFixed(1)
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isToday {
    final now = DateTime.now();
    return widget.date.year == now.year &&
        widget.date.month == now.month &&
        widget.date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.existing != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCreamTop,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Edit Weight' : 'Log Weight',
                      style: AppTextStyles.headerMedium.copyWith(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _isToday
                          ? 'Today · ${DateFormat('d MMM yyyy').format(widget.date)}'
                          : DateFormat('EEE, d MMM yyyy').format(widget.date),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Weight field
            TextFormField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: AppTextStyles.textFieldTextStyle.copyWith(
                color: AppColors.primary,
                fontSize: 24,
              ),
              decoration: InputDecoration(
                labelText: 'Weight',
                hintText: '70.0',
                suffixText: 'kg',
                suffixStyle: TextStyle(
                  color: AppColors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                prefixIcon: Icon(
                  Icons.monitor_weight_outlined,
                  color: AppColors.secondary,
                ),
                labelStyle: AppTextStyles.textFieldLableStyle.copyWith(
                  fontSize: 14,
                  letterSpacing: 1,
                ),
                hintStyle: TextStyle(
                  color: AppColors.grey.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d{0,3}\.?\d{0,1}'),
                ),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter your weight';
                final val = double.tryParse(v);
                if (val == null || val <= 0) return 'Enter a valid weight';
                if (val > 500) return 'That seems too high';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  widget.onSave(double.parse(_controller.text));
                },
                child: Text(
                  isEdit ? 'UPDATE' : 'SAVE',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty / error states ───────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.monitor_weight_outlined,
              size: 52,
              color: AppColors.grey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No weight entries yet.\nTap + to log your first entry.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

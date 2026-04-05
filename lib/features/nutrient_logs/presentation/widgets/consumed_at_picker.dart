import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ConsumedAtPicker extends ConsumerStatefulWidget {
  final DateTime? initialValue;

  final ValueChanged<DateTime?> onChanged;

  const ConsumedAtPicker({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  @override
  ConsumerState<ConsumedAtPicker> createState() => _ConsumedAtPickerState();
}

class _ConsumedAtPickerState extends ConsumerState<ConsumedAtPicker> {
  DateTime? _value;

  static final _dateFmt = DateFormat('EEE, d MMM yyyy');
  static final _timeFmt = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  // Pickers

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _value ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) => _pickerTheme(context, child),
    );
    if (date == null) return;

    // Preserve existing time or default to current time.
    final existing = _value ?? now;
    final merged = DateTime(
      date.year,
      date.month,
      date.day,
      existing.hour,
      existing.minute,
    );
    setState(() => _value = merged);
    widget.onChanged(_value);
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final initial = _value ?? now;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
      builder: (context, child) => _pickerTheme(context, child),
    );
    if (time == null) return;

    // Preserve existing date or default to today.
    final base = _value ?? now;
    final merged = DateTime(
      base.year,
      base.month,
      base.day,
      time.hour,
      time.minute,
    );
    setState(() => _value = merged);
    widget.onChanged(_value);
  }

  void _clear() {
    setState(() => _value = null);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = _value != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label row
        Row(
          children: [
            Icon(
              Icons.access_time_outlined,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Consumed At',
              style: AppTextStyles.headerMedium.copyWith(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(optional)',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey,
                fontSize: 12,
              ),
            ),
            if (hasValue) ...[
              const Spacer(),
              GestureDetector(
                onTap: _clear,
                child: Row(
                  children: [
                    Icon(
                      Icons.close,
                      size: 14,
                      color: AppColors.grey.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Clear',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Pill row
        Row(
          children: [
            // Date pill
            Expanded(
              child: _PickerPill(
                icon: Icons.calendar_today_outlined,
                label: hasValue ? _dateFmt.format(_value!) : 'Pick date',
                hasValue: hasValue,
                onTap: _pickDate,
              ),
            ),
            const SizedBox(width: 10),
            // Time pill
            _PickerPill(
              icon: Icons.schedule_outlined,
              label: hasValue ? _timeFmt.format(_value!) : '--:--',
              hasValue: hasValue,
              onTap: hasValue ? _pickTime : null, // disabled until date chosen
            ),
          ],
        ),

        // Inline hint when no value selected
        if (!hasValue) ...[
          const SizedBox(height: 6),
          Text(
            'Leave blank to record as now.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  Widget _pickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.secondary,
        ),
      ),
      child: child!,
    );
  }
}

class _PickerPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool hasValue;
  final VoidCallback? onTap;

  const _PickerPill({
    required this.icon,
    required this.label,
    required this.hasValue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final bgColor = hasValue
        ? AppColors.primary.withValues(alpha: 0.08)
        : AppColors.white;
    final borderColor = hasValue
        ? AppColors.primary.withValues(alpha: 0.4)
        : AppColors.primary.withValues(alpha: 0.2);
    final contentColor = enabled
        ? (hasValue ? AppColors.primary : AppColors.grey)
        : AppColors.grey.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: contentColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: contentColor,
                fontSize: 13,
                fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

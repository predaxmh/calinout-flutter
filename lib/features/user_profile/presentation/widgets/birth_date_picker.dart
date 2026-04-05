import 'package:calinout/core/theme/app_colors.dart';
import 'package:calinout/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BirthDatePicker extends ConsumerStatefulWidget {
  final DateTime? initialValue;
  final ValueChanged<DateTime?> onChanged;

  const BirthDatePicker({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  @override
  ConsumerState<BirthDatePicker> createState() => _BirthDatePickerState();
}

class _BirthDatePickerState extends ConsumerState<BirthDatePicker> {
  DateTime? _value;
  static final _fmt = DateFormat('d MMM yyyy');

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  Future<void> _pick() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _value ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: now, // blocks future dates
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            secondary: AppColors.secondary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => _value = picked);
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
        // Label row
        Row(
          children: [
            Icon(Icons.cake_outlined, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'Date of Birth',
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

        // Pill button
        GestureDetector(
          onTap: _pick,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: hasValue
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasValue
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.primary.withValues(alpha: 0.2),
                width: hasValue ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: hasValue ? AppColors.primary : AppColors.grey,
                ),
                const SizedBox(width: 10),
                Text(
                  hasValue ? _fmt.format(_value!) : 'Pick a date',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: hasValue ? AppColors.primary : AppColors.grey,
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                // Age badge
                if (hasValue) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_age(_value!)} yrs',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _age(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }
}

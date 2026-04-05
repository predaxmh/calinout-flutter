import 'package:flutter/material.dart';
import 'package:calinout/core/theme/app_colors.dart';

class DailyNoteDialog extends StatefulWidget {
  final String initialNote;
  final ValueChanged<String> onSave;

  const DailyNoteDialog({
    super.key,
    required this.initialNote,
    required this.onSave,
  });

  @override
  State<DailyNoteDialog> createState() => _DailyNoteDialogState();
}

class _DailyNoteDialogState extends State<DailyNoteDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgCreamTop,
      title: const Text(
        'Daily Log Note',
        style: TextStyle(color: AppColors.primaryDark),
      ),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'How are you feeling today?',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.secondary, width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () {
            widget.onSave(_controller.text);
            Navigator.pop(context);
          },
          child: const Text('Save', style: TextStyle(color: AppColors.white)),
        ),
      ],
    );
  }
}

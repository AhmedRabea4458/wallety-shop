import 'package:flutter/material.dart';
import 'package:smart_expense/core/theme/app_colors.dart';
import 'package:smart_expense/shared/widgets/settings_row.dart';

class ToggleRow extends StatefulWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String label;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const ToggleRow({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.label,
    this.initialValue = false,
    this.onChanged,
  });

  @override
  State<ToggleRow> createState() => _ToggleRowState();
}

class _ToggleRowState extends State<ToggleRow> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _toggle() {
    setState(() {
      _value = !_value;
    });
    widget.onChanged?.call(_value);
  }

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: widget.icon,
      iconBackgroundColor: widget.iconBackgroundColor,
      iconColor: widget.iconColor,
      label: widget.label,
      trailing: Switch(
        value: _value,
        onChanged: (value) => _toggle(),
        activeThumbColor: AppColors.primaryForeground,
        activeTrackColor: AppColors.primary,
        inactiveThumbColor: AppColors.foreground,
        inactiveTrackColor: AppColors.withAlpha(AppColors.mutedForeground, 0.25),
      ),
    );
  }
}

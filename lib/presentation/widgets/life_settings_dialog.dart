import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../providers/settings_provider.dart';

/// Simple dialog for updating life settings (birthday and location)
class LifeSettingsDialog extends StatefulWidget {
  const LifeSettingsDialog({super.key});

  @override
  State<LifeSettingsDialog> createState() => _LifeSettingsDialogState();
}

class _LifeSettingsDialogState extends State<LifeSettingsDialog> {
  late DateTime _selectedDate;
  String? _selectedCountryCode;
  String? _selectedCountryName;
  String? _error;
  bool _isLoading = false;

  // Countries list (same as HeatmapSetupDialog)
  final List<Map<String, String>> _countries = [
    {'code': 'US', 'name': 'United States'},
    {'code': 'GB', 'name': 'United Kingdom'},
    {'code': 'CA', 'name': 'Canada'},
    {'code': 'AU', 'name': 'Australia'},
    {'code': 'DE', 'name': 'Germany'},
    {'code': 'FR', 'name': 'France'},
    {'code': 'JP', 'name': 'Japan'},
    {'code': 'KR', 'name': 'South Korea'},
    {'code': 'CN', 'name': 'China'},
    {'code': 'IN', 'name': 'India'},
    {'code': 'BR', 'name': 'Brazil'},
    {'code': 'MX', 'name': 'Mexico'},
    {'code': 'IT', 'name': 'Italy'},
    {'code': 'ES', 'name': 'Spain'},
    {'code': 'NL', 'name': 'Netherlands'},
    {'code': 'SE', 'name': 'Sweden'},
    {'code': 'NO', 'name': 'Norway'},
    {'code': 'DK', 'name': 'Denmark'},
    {'code': 'FI', 'name': 'Finland'},
    {'code': 'CH', 'name': 'Switzerland'},
  ];

  @override
  void initState() {
    super.initState();

    // Initialize with current settings
    final settingsProvider = context.read<SettingsProvider>();
    final currentSettings = settingsProvider.userSettings;

    _selectedDate = currentSettings?.dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 25));
    _selectedCountryCode = currentSettings?.countryCode;

    // Find country name from code
    if (_selectedCountryCode != null) {
      final country = _countries.firstWhere(
        (c) => c['code'] == _selectedCountryCode,
        orElse: () => {'code': _selectedCountryCode!, 'name': _selectedCountryCode!},
      );
      _selectedCountryName = country['name'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundSecondaryDark : AppColors.backgroundSecondaryLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Life Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                'Update your date of birth and country to recalculate your life heatmap.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),

              const SizedBox(height: 24),

              // Date of Birth Section
              Text(
                'Date of Birth',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              _buildDateSelector(context, isDark),

              const SizedBox(height: 20),

              // Country Section
              Text(
                'Country of Birth',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              _buildCountrySelector(context, isDark),

              const SizedBox(height: 24),

              // Error message
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                ),
                const SizedBox(height: 16),
              ],

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _updateSettings(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonGreen,
                      foregroundColor: AppColors.backgroundPrimaryDark,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _showDatePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundTertiaryDark : AppColors.backgroundTertiaryLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMMM d, yyyy').format(_selectedDate),
              style: TextStyle(fontSize: 16, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            ),
            Icon(
              Icons.calendar_today,
              size: 20,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountrySelector(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _showCountryPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundTertiaryDark : AppColors.backgroundTertiaryLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedCountryName ?? 'Select Country',
              style: TextStyle(
                fontSize: 16,
                color: _selectedCountryName != null
                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                    : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 24,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 300,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.backgroundSecondaryDark
                : AppColors.backgroundSecondaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Done',
                        style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              // Date picker
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate,
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      _selectedDate = newDateTime;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 300,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.backgroundSecondaryDark
                : AppColors.backgroundSecondaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Done',
                        style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              // Country picker
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedCountryCode = _countries[index]['code'];
                      _selectedCountryName = _countries[index]['name'];
                    });
                  },
                  children: _countries.map((country) {
                    return Center(child: Text(country['name']!, style: const TextStyle(fontSize: 16)));
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _canUpdate() {
    return _selectedCountryCode != null &&
        _selectedDate.isBefore(DateTime.now()) &&
        DateTime.now().difference(_selectedDate).inDays > 365; // At least 1 year old
  }

  Future<void> _updateSettings(BuildContext context) async {
    if (!_canUpdate()) {
      setState(() {
        _error = 'Please select a valid date of birth and country.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final settingsProvider = context.read<SettingsProvider>();
      final success = await settingsProvider.setupUser(dateOfBirth: _selectedDate, countryCode: _selectedCountryCode!);

      if (success) {
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Life settings updated successfully!'),
              backgroundColor: AppColors.neonGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        setState(() {
          _error = settingsProvider.error ?? 'Update failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

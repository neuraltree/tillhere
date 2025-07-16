import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../data/datasources/local/life_expectancy_local_datasource.dart';
import '../providers/settings_provider.dart';

/// Dialog for setting up the life heatmap with date of birth and country selection
class HeatmapSetupDialog extends StatefulWidget {
  const HeatmapSetupDialog({super.key});

  @override
  State<HeatmapSetupDialog> createState() => _HeatmapSetupDialogState();
}

class _HeatmapSetupDialogState extends State<HeatmapSetupDialog> {
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 25)); // Default to 25 years ago
  String? _selectedCountryCode;
  String? _selectedCountryName;
  List<Map<String, String>> _countries = [];
  bool _isLoadingCountries = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final dataSource = LifeExpectancyLocalDataSource();
      final result = await dataSource.getAllCountries();

      if (result.isSuccess) {
        final countriesData = result.data!;
        final countryList = <Map<String, String>>[];

        for (final country in countriesData) {
          countryList.add({'code': country.code, 'name': country.name});
        }

        // Sort countries alphabetically
        countryList.sort((a, b) => a['name']!.compareTo(b['name']!));

        setState(() {
          _countries = countryList;
          _isLoadingCountries = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load countries';
          _isLoadingCountries = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading countries: $e';
        _isLoadingCountries = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.backgroundPrimaryDark : AppColors.backgroundPrimaryLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Setup Life Heatmap',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us your date of birth and country to visualize your life journey.',
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

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
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
                Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, child) {
                    return ElevatedButton(
                      onPressed: _canSetup() && !settingsProvider.isLoading
                          ? () => _setupHeatmap(context, settingsProvider)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonGreen,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: settingsProvider.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : const Text('Setup Heatmap', style: TextStyle(fontWeight: FontWeight.w600)),
                    );
                  },
                ),
              ],
            ),
          ],
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
          color: isDark ? AppColors.backgroundSecondaryDark : AppColors.backgroundSecondaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('MMMM d, yyyy').format(_selectedDate),
              style: TextStyle(fontSize: 16, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountrySelector(BuildContext context, bool isDark) {
    if (_isLoadingCountries) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundSecondaryDark : AppColors.backgroundSecondaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 12),
            Text(
              'Loading countries...',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showCountryPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundSecondaryDark : AppColors.backgroundSecondaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.public, size: 20, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedCountryName ?? 'Select your country',
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedCountryName != null
                      ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
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
                  minimumDate: DateTime.now().subtract(const Duration(days: 365 * 120)), // 120 years ago
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
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
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
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

  bool _canSetup() {
    return _selectedCountryCode != null &&
        _selectedDate.isBefore(DateTime.now()) &&
        DateTime.now().difference(_selectedDate).inDays > 365; // At least 1 year old
  }

  Future<void> _setupHeatmap(BuildContext context, SettingsProvider settingsProvider) async {
    if (!_canSetup()) return;

    final success = await settingsProvider.setupUser(dateOfBirth: _selectedDate, countryCode: _selectedCountryCode!);

    if (success) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Life heatmap setup complete!'),
            backgroundColor: AppColors.neonGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      setState(() {
        _error = settingsProvider.error ?? 'Setup failed. Please try again.';
      });
    }
  }
}

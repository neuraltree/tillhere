import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../providers/navigation_provider.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_drawer.dart';

/// Export/Import page - data management
/// Following Clean Architecture principles - presentation layer
class ExportPage extends StatelessWidget {
  const ExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          appBar: const AppBarWidget(),
          drawer: const AppDrawer(),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).brightness == Brightness.dark
                      ? AppColors.backgroundPrimaryDark
                      : AppColors.backgroundPrimaryLight,
                  Theme.of(context).brightness == Brightness.dark
                      ? AppColors.backgroundSecondaryDark
                      : AppColors.backgroundSecondaryLight,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPageHeader(context),
                    const SizedBox(height: 24),
                    _buildExportSection(context),
                    const SizedBox(height: 24),
                    _buildImportSection(context),
                    const SizedBox(height: 24),
                    _buildBackupSection(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build page header
  Widget _buildPageHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Management',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Export, import, and backup your mood data',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// Build export section
  Widget _buildExportSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('⬆️', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Text(
                  'Export Data',
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Export your mood data in various formats for backup or analysis.',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            _buildExportOption(context, 'CSV Format', 'Spreadsheet-compatible format', Icons.table_chart),
            _buildExportOption(context, 'JSON Format', 'Raw data format for developers', Icons.code),
            _buildExportOption(context, 'PDF Report', 'Formatted report with charts', Icons.picture_as_pdf),
          ],
        ),
      ),
    );
  }

  /// Build export option
  Widget _buildExportOption(BuildContext context, String title, String description, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.neonGreen, size: 24),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: Icon(Icons.download, color: AppColors.neonGreen, size: 20),
        onTap: () {
          // TODO: Implement export functionality
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title export will be implemented'), backgroundColor: AppColors.neonGreen),
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Build import section
  Widget _buildImportSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.solarOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('⬇️', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Text(
                  'Import Data',
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Import mood data from other apps or previous backups.',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement import functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Import functionality will be implemented'),
                    backgroundColor: AppColors.solarOrange,
                  ),
                );
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Select File to Import'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.solarOrange,
                foregroundColor: AppColors.textPrimaryDark,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build backup section
  Widget _buildBackupSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cosmicBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('☁️', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Text(
                  'Cloud Backup',
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Cloud backup is currently disabled. See icloud_setup_guide.md for setup instructions.',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: null, // Disabled
                    icon: const Icon(Icons.backup),
                    label: const Text('Backup Now'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.grey[600]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: null, // Disabled
                    icon: const Icon(Icons.restore),
                    label: const Text('Restore'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      foregroundColor: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

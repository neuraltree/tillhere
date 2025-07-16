import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../providers/navigation_provider.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_drawer.dart';

/// Settings page - app configuration and preferences
/// Following Clean Architecture principles - presentation layer
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
                    _buildGeneralSection(context),
                    const SizedBox(height: 16),
                    _buildNotificationsSection(context),
                    const SizedBox(height: 16),
                    _buildPrivacySection(context),
                    const SizedBox(height: 16),
                    _buildDataSection(context),
                    const SizedBox(height: 16),
                    _buildAboutSection(context),
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
          'Settings',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Customize your mood tracking experience',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// Build general settings section
  Widget _buildGeneralSection(BuildContext context) {
    return _buildSettingsSection(context, 'General', '⚙️', [
      _buildSettingsTile(
        context,
        'Theme',
        'Dark mode',
        Icons.dark_mode,
        trailing: Switch(
          value: Theme.of(context).brightness == Brightness.dark,
          onChanged: (value) {
            // TODO: Implement theme switching
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Theme switching will be implemented')));
          },
          activeColor: AppColors.neonGreen,
        ),
      ),
      _buildSettingsTile(
        context,
        'Language',
        'English',
        Icons.language,
        onTap: () {
          // TODO: Implement language selection
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Language selection will be implemented')));
        },
      ),
      _buildSettingsTile(
        context,
        'Default Time Filter',
        'Day',
        Icons.filter_list,
        onTap: () {
          // TODO: Implement default filter selection
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Default filter selection will be implemented')));
        },
      ),
    ]);
  }

  /// Build notifications section
  Widget _buildNotificationsSection(BuildContext context) {
    return _buildSettingsSection(context, 'Notifications', '🔔', [
      _buildSettingsTile(
        context,
        'Daily Reminders',
        'Get reminded to log your mood',
        Icons.notifications,
        trailing: Switch(
          value: true,
          onChanged: (value) {
            // TODO: Implement notification toggle
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Notification settings will be implemented')));
          },
          activeColor: AppColors.neonGreen,
        ),
      ),
      _buildSettingsTile(
        context,
        'Reminder Time',
        '8:00 PM',
        Icons.schedule,
        onTap: () {
          // TODO: Implement time picker
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Time picker will be implemented')));
        },
      ),
      _buildSettingsTile(
        context,
        'Weekly Summary',
        'Get weekly mood insights',
        Icons.insights,
        trailing: Switch(
          value: false,
          onChanged: (value) {
            // TODO: Implement weekly summary toggle
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Weekly summary toggle will be implemented')));
          },
          activeColor: AppColors.neonGreen,
        ),
      ),
    ]);
  }

  /// Build privacy section
  Widget _buildPrivacySection(BuildContext context) {
    return _buildSettingsSection(context, 'Privacy & Security', '🔒', [
      _buildSettingsTile(
        context,
        'Biometric Lock',
        'Secure app with fingerprint/face',
        Icons.fingerprint,
        trailing: Switch(
          value: false,
          onChanged: (value) {
            // TODO: Implement biometric lock
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Biometric lock will be implemented')));
          },
          activeColor: AppColors.neonGreen,
        ),
      ),
      _buildSettingsTile(
        context,
        'Data Retention',
        'How long to keep your data',
        Icons.storage,
        onTap: () {
          // TODO: Implement data retention settings
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Data retention settings will be implemented')));
        },
      ),
    ]);
  }

  /// Build data section
  Widget _buildDataSection(BuildContext context) {
    return _buildSettingsSection(context, 'Data Management', '💾', [
      _buildSettingsTile(
        context,
        'Export Data',
        'Export your data for backup',
        Icons.download,
        onTap: () => _showExportDialog(context),
      ),
      _buildSettingsTile(
        context,
        'Import Data',
        'Import data from backup',
        Icons.upload,
        onTap: () => _showImportDialog(context),
      ),
      _buildSettingsTile(
        context,
        'Clear All Data',
        'Permanently delete all mood data',
        Icons.delete_forever,
        textColor: AppColors.error,
        onTap: () => _showClearDataDialog(context),
      ),
    ]);
  }

  /// Build about section
  Widget _buildAboutSection(BuildContext context) {
    return _buildSettingsSection(context, 'About', 'ℹ️', [
      _buildSettingsTile(context, 'Version', '1.0.0', Icons.info),
      _buildSettingsTile(
        context,
        'Privacy Policy',
        'Read our privacy policy',
        Icons.privacy_tip,
        onTap: () {
          // TODO: Open privacy policy
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Privacy policy will be implemented')));
        },
      ),
      _buildSettingsTile(
        context,
        'Terms of Service',
        'Read our terms of service',
        Icons.description,
        onTap: () {
          // TODO: Open terms of service
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Terms of service will be implemented')));
        },
      ),
      _buildSettingsTile(
        context,
        'Contact Support',
        'Get help with the app',
        Icons.support,
        onTap: () {
          // TODO: Open support contact
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Support contact will be implemented')));
        },
      ),
    ]);
  }

  /// Build settings section
  Widget _buildSettingsSection(BuildContext context, String title, String icon, List<Widget> children) {
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
                    color: AppColors.neonGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(icon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Build settings tile
  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = textColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.neonGreen, size: 24),
      title: Text(
        title,
        style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: AppColors.neonGreen) : null),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }

  /// Show export data dialog
  void _showExportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export Data'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text('Choose export format:'), SizedBox(height: 16)],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CSV export will be implemented'), backgroundColor: AppColors.neonGreen),
                );
              },
              child: const Text('CSV'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('JSON export will be implemented'),
                    backgroundColor: AppColors.neonGreen,
                  ),
                );
              },
              child: const Text('JSON'),
            ),
          ],
        );
      },
    );
  }

  /// Show import data dialog
  void _showImportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Import Data'),
          content: const Text('Select a backup file to import your mood data.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Import functionality will be implemented'),
                    backgroundColor: AppColors.solarOrange,
                  ),
                );
              },
              child: const Text('Select File'),
            ),
          ],
        );
      },
    );
  }

  /// Show clear data confirmation dialog
  void _showClearDataDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'Are you sure you want to permanently delete all your mood data? This action cannot be undone.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement data clearing
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data clearing will be implemented'), backgroundColor: AppColors.error),
                );
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }
}

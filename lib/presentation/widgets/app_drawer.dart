import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entities/navigation_item.dart';
import '../../core/theme/app_colors.dart';
import '../providers/navigation_provider.dart';

/// Side drawer component following Apple design standards
/// Width: 80% of viewport, Material Design elevation: 16dp
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.8; // 80% of screen width

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        elevation: 16, // Material Design elevation
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).brightness == Brightness.dark
                    ? AppColors.backgroundSecondaryDark
                    : AppColors.backgroundSecondaryLight,
                Theme.of(context).brightness == Brightness.dark
                    ? AppColors.backgroundTertiaryDark
                    : AppColors.backgroundTertiaryLight,
              ],
            ),
          ),
          child: Column(
            children: [
              _buildDrawerHeader(context),
              Expanded(child: _buildNavigationItems(context)),
              _buildDrawerFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Build drawer header with app branding
  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      height: 160, // Increased height to account for status bar
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20), // Top padding for status bar
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cosmicBlue, AppColors.cosmicBlueLight],
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'tilhere...',
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your Personal Journey',
              style: TextStyle(
                color: AppColors.textSecondaryDark.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build navigation items list
  Widget _buildNavigationItems(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: navigationProvider.navigationItems.length,
          itemBuilder: (context, index) {
            final item = navigationProvider.navigationItems[index];
            return _buildNavigationItem(context, item, navigationProvider);
          },
        );
      },
    );
  }

  /// Build individual navigation item
  Widget _buildNavigationItem(BuildContext context, NavigationItem item, NavigationProvider navigationProvider) {
    final isActive = item.isActive;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isActive ? AppColors.neonGreen.withValues(alpha: 0.1) : Colors.transparent,
        border: isActive ? Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3), width: 1) : null,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isActive ? AppColors.neonGreen.withValues(alpha: 0.2) : Colors.transparent,
          ),
          child: Center(child: Text(item.icon, style: const TextStyle(fontSize: 20))),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: isActive ? AppColors.neonGreen : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: () {
          navigationProvider.navigateToRoute(item.route);
          navigationProvider.closeDrawer();
          Navigator.of(context).pushReplacementNamed(item.route);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  /// Build drawer footer
  Widget _buildDrawerFooter(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Divider(color: isDark ? AppColors.dividerDark : AppColors.dividerLight, thickness: 0.5),
          const SizedBox(height: 8),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

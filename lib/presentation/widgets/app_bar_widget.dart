import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../providers/navigation_provider.dart';

/// Custom app bar widget following Apple design standards
/// Left: Hamburger menu, Center: Dynamic title, Right: Latest mood
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.navBackgroundDark
              : AppColors.navBackgroundLight,
          foregroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.navTitleDark
              : AppColors.navTitleLight,
          elevation: 0,
          centerTitle: true,

          // Left section: Hamburger menu
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              size: 24,
            ),
            onPressed: () {
              navigationProvider.toggleDrawer();
              Scaffold.of(context).openDrawer();
            },
            tooltip: 'Open menu',
          ),

          // Center section: Dynamic title
          title: Text(
            navigationProvider.currentPageTitle,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.navTitleDark : AppColors.navTitleLight,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),

          // Bottom border for visual separation
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 0.5,
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
        );
      },
    );
  }
}

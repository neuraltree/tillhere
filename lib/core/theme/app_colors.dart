import 'dart:ui';

/// App colors loaded from colors.yml
/// Following Clean Architecture principles - core utilities
class AppColors {
  // Primary Brand Colors
  static const Color cosmicBlue = Color(0xFF1a237e);
  static const Color cosmicBlueLight = Color(0xFF3949ab);
  static const Color cosmicBlueDark = Color(0xFF0d1421);
  
  static const Color neonGreen = Color(0xFF00ff88);
  static const Color neonGreenLight = Color(0xFF4dffaa);
  static const Color neonGreenDark = Color(0xFF00cc6a);
  
  static const Color solarOrange = Color(0xFFff8f00);
  static const Color solarOrangeLight = Color(0xFFffb74d);
  static const Color solarOrangeDark = Color(0xFFf57c00);

  // Background Colors - Light Mode
  static const Color backgroundPrimaryLight = Color(0xFFffffff);
  static const Color backgroundSecondaryLight = Color(0xFFf8f9fa);
  static const Color backgroundTertiaryLight = Color(0xFFe3f2fd);
  
  // Background Colors - Dark Mode
  static const Color backgroundPrimaryDark = Color(0xFF0a0e1a);
  static const Color backgroundSecondaryDark = Color(0xFF1a1f2e);
  static const Color backgroundTertiaryDark = Color(0xFF252a3a);

  // Text Colors - Light Mode
  static const Color textPrimaryLight = Color(0xFF1a1a1a);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color textTertiaryLight = Color(0xFF999999);
  
  // Text Colors - Dark Mode
  static const Color textPrimaryDark = Color(0xFFffffff);
  static const Color textSecondaryDark = Color(0xFFb3b3b3);
  static const Color textTertiaryDark = Color(0xFF808080);
  
  // Accent Text
  static const Color textNeonAccent = Color(0xFF00ff88);
  static const Color textSolarAccent = Color(0xFFff8f00);

  // Semantic Colors
  static const Color success = Color(0xFF00ff88);
  static const Color successLight = Color(0xFF4dffaa);
  static const Color successDark = Color(0xFF00cc6a);
  static const Color successBackground = Color(0xFF0d2818);
  
  static const Color warning = Color(0xFFff8f00);
  static const Color warningLight = Color(0xFFffb74d);
  static const Color warningDark = Color(0xFFf57c00);
  static const Color warningBackground = Color(0xFF2d1f0a);
  
  static const Color error = Color(0xFFff4444);
  static const Color errorLight = Color(0xFFff7777);
  static const Color errorDark = Color(0xFFcc0000);
  static const Color errorBackground = Color(0xFF2d0a0a);
  
  static const Color info = Color(0xFF3949ab);
  static const Color infoLight = Color(0xFF7986cb);
  static const Color infoDark = Color(0xFF1a237e);
  static const Color infoBackground = Color(0xFF0f1419);

  // Interactive Elements
  static const Color buttonPrimary = Color(0xFF00ff88);
  static const Color buttonPrimaryHover = Color(0xFF4dffaa);
  static const Color buttonPrimaryPressed = Color(0xFF00cc6a);
  static const Color buttonPrimaryDisabled = Color(0xFF4d7d66);
  
  static const Color buttonSecondaryBorder = Color(0xFF00ff88);
  static const Color buttonSecondaryHover = Color(0x3300ff88); // 20% opacity
  
  static const Color linkDefault = Color(0xFF00ff88);
  static const Color linkHover = Color(0xFF4dffaa);
  static const Color linkVisited = Color(0xFFb388ff);
  
  static const Color focusRing = Color(0xFF00ff88);

  // Surface Colors
  static const Color cardLight = Color(0xFFffffff);
  static const Color cardDark = Color(0xFF1a1f2e);
  static const Color cardElevatedLight = Color(0xFFffffff);
  static const Color cardElevatedDark = Color(0xFF252a3a);
  
  static const Color overlayLight = Color(0x80000000); // 50% opacity
  static const Color overlayDark = Color(0xB3000000); // 70% opacity
  static const Color modalBackdrop = Color(0xCC0a0e1a);
  
  static const Color borderLight = Color(0xFFe0e0e0);
  static const Color borderDark = Color(0xFF404040);
  static const Color borderAccent = Color(0xFF00ff88);
  static const Color dividerLight = Color(0xFFf0f0f0);
  static const Color dividerDark = Color(0xFF2a2a2a);

  // Navigation Colors
  static const Color tabActive = Color(0xFF00ff88);
  static const Color tabInactive = Color(0xFF808080);
  static const Color tabBackgroundLight = Color(0xFFffffff);
  static const Color tabBackgroundDark = Color(0xFF1a1f2e);
  
  static const Color navBackgroundLight = Color(0xFFffffff);
  static const Color navBackgroundDark = Color(0xFF0a0e1a);
  static const Color navTitleLight = Color(0xFF1a1a1a);
  static const Color navTitleDark = Color(0xFFffffff);

  // Chart Colors
  static const Color chartPrimary = Color(0xFF00ff88);
  static const Color chartSecondary = Color(0xFFff8f00);
  static const Color chartTertiary = Color(0xFF3949ab);
  static const Color chartQuaternary = Color(0xFFb388ff);
  static const Color chartGridLight = Color(0xFFf0f0f0);
  static const Color chartGridDark = Color(0xFF404040);

  // Shadow and Effects
  static const Color shadowLight = Color(0x20000000); // 12.5% opacity
  static const Color shadowDark = Color(0x60000000); // 37.5% opacity
  static const Color glowNeon = Color(0x60ff88); // 37.5% opacity
  static const Color glowSolar = Color(0x60ff8f00); // 37.5% opacity
}

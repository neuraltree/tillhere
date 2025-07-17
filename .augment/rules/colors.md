---
type: "agent_requested"
description: "TillHere App Color Palette"
---
# TillHere App Color Palette
# Cosmic/Space-themed colors inspired by the provided artwork
# Following Apple Design Standards with semantic color usage

# Primary Brand Colors
primary:
  cosmic_blue: "#1a237e"        # Deep space blue - primary brand color
  cosmic_blue_light: "#3949ab"  # Lighter variant for hover states
  cosmic_blue_dark: "#0d1421"   # Darker variant for depth

  neon_green: "#00ff88"         # Vibrant neon green - accent color
  neon_green_light: "#4dffaa"   # Lighter variant
  neon_green_dark: "#00cc6a"    # Darker variant

  solar_orange: "#ff8f00"       # Warm solar orange - secondary accent
  solar_orange_light: "#ffb74d" # Lighter variant
  solar_orange_dark: "#f57c00"  # Darker variant

# Background Colors
background:
  # Light Mode
  primary_light: "#ffffff"      # Pure white background
  secondary_light: "#f8f9fa"    # Light gray background
  tertiary_light: "#e3f2fd"     # Very light blue tint

  # Dark Mode (Space Theme)
  primary_dark: "#0a0e1a"       # Deep space black
  secondary_dark: "#1a1f2e"     # Elevated dark surface
  tertiary_dark: "#252a3a"      # Card/container background

  # Gradient Backgrounds
  cosmic_gradient_start: "#0a0e1a"
  cosmic_gradient_middle: "#1a237e"
  cosmic_gradient_end: "#3949ab"

# Text Colors
text:
  # Light Mode
  primary_light: "#1a1a1a"      # Primary text on light backgrounds
  secondary_light: "#666666"    # Secondary text on light backgrounds
  tertiary_light: "#999999"     # Tertiary text on light backgrounds

  # Dark Mode
  primary_dark: "#ffffff"       # Primary text on dark backgrounds
  secondary_dark: "#b3b3b3"     # Secondary text on dark backgrounds
  tertiary_dark: "#808080"      # Tertiary text on dark backgrounds

  # Accent Text
  neon_accent: "#00ff88"        # Neon green for highlights
  solar_accent: "#ff8f00"       # Solar orange for warnings/highlights

# Semantic Colors
semantic:
  # Success States
  success: "#00ff88"            # Neon green for success
  success_light: "#4dffaa"      # Light success variant
  success_dark: "#00cc6a"       # Dark success variant
  success_background: "#0d2818" # Success background (dark mode)

  # Warning States
  warning: "#ff8f00"            # Solar orange for warnings
  warning_light: "#ffb74d"      # Light warning variant
  warning_dark: "#f57c00"       # Dark warning variant
  warning_background: "#2d1f0a" # Warning background (dark mode)

  # Error States
  error: "#ff4444"              # Red for errors
  error_light: "#ff7777"        # Light error variant
  error_dark: "#cc0000"         # Dark error variant
  error_background: "#2d0a0a"   # Error background (dark mode)

  # Info States
  info: "#3949ab"               # Cosmic blue for info
  info_light: "#7986cb"         # Light info variant
  info_dark: "#1a237e"          # Dark info variant
  info_background: "#0f1419"    # Info background (dark mode)

# Interactive Elements
interactive:
  # Buttons
  button_primary: "#00ff88"     # Primary button background
  button_primary_hover: "#4dffaa" # Primary button hover state
  button_primary_pressed: "#00cc6a" # Primary button pressed state
  button_primary_disabled: "#4d7d66" # Primary button disabled state

  button_secondary: "transparent" # Secondary button background
  button_secondary_border: "#00ff88" # Secondary button border
  button_secondary_hover: "#00ff8820" # Secondary button hover (20% opacity)

  # Links
  link_default: "#00ff88"       # Default link color
  link_hover: "#4dffaa"         # Link hover state
  link_visited: "#b388ff"       # Visited link color

  # Focus States
  focus_ring: "#00ff88"         # Focus indicator color
  focus_ring_opacity: "40"      # Focus ring opacity (%)

# Surface Colors
surface:
  # Cards and Containers
  card_light: "#ffffff"         # Light mode card background
  card_dark: "#1a1f2e"          # Dark mode card background
  card_elevated_light: "#ffffff" # Elevated card (light mode)
  card_elevated_dark: "#252a3a"  # Elevated card (dark mode)

  # Overlays
  overlay_light: "#00000080"    # Light mode overlay (50% opacity)
  overlay_dark: "#000000b3"     # Dark mode overlay (70% opacity)
  modal_backdrop: "#0a0e1acc"   # Modal backdrop color

  # Borders
  border_light: "#e0e0e0"       # Light mode borders
  border_dark: "#404040"        # Dark mode borders
  border_accent: "#00ff88"      # Accent borders
  divider_light: "#f0f0f0"      # Light mode dividers
  divider_dark: "#2a2a2a"       # Dark mode dividers

# Special Effects
effects:
  # Shadows
  shadow_light: "#00000020"     # Light mode shadow
  shadow_dark: "#00000060"      # Dark mode shadow
  glow_neon: "#00ff8860"        # Neon green glow effect
  glow_solar: "#ff8f0060"       # Solar orange glow effect

  # Gradients
  neon_gradient_start: "#00ff88"
  neon_gradient_end: "#00cc6a"
  solar_gradient_start: "#ff8f00"
  solar_gradient_end: "#f57c00"
  cosmic_gradient_start: "#1a237e"
  cosmic_gradient_end: "#3949ab"

# Navigation
navigation:
  # Tab Bar
  tab_active: "#00ff88"         # Active tab indicator
  tab_inactive: "#808080"       # Inactive tab color
  tab_background_light: "#ffffff" # Tab bar background (light)
  tab_background_dark: "#1a1f2e"  # Tab bar background (dark)

  # Navigation Bar
  nav_background_light: "#ffffff" # Navigation bar background (light)
  nav_background_dark: "#0a0e1a"  # Navigation bar background (dark)
  nav_title_light: "#1a1a1a"     # Navigation title (light)
  nav_title_dark: "#ffffff"      # Navigation title (dark)

# Status Colors
status:
  online: "#00ff88"             # Online/active status
  offline: "#808080"            # Offline status
  away: "#ff8f00"               # Away status
  busy: "#ff4444"               # Busy/do not disturb status

# Chart/Data Visualization
chart:
  primary: "#00ff88"            # Primary data series
  secondary: "#ff8f00"          # Secondary data series
  tertiary: "#3949ab"           # Tertiary data series
  quaternary: "#b388ff"         # Fourth data series
  grid_light: "#f0f0f0"         # Chart grid lines (light)
  grid_dark: "#404040"          # Chart grid lines (dark)

# Opacity Values (for reference)
opacity:
  disabled: "40"                # 40% opacity for disabled states
  hover: "80"                   # 80% opacity for hover states
  pressed: "60"                 # 60% opacity for pressed states
  overlay: "50"                 # 50% opacity for overlays
  subtle: "20"                  # 20% opacity for subtle effects

# Usage Notes:
# - All colors support both light and dark mode variants
# - Neon green (#00ff88) is the primary accent color
# - Solar orange (#ff8f00) is used for warnings and secondary accents
# - Cosmic blue (#1a237e) represents the brand and info states
# - Always maintain proper contrast ratios (4.5:1 minimum)
# - Use semantic colors for their intended purposes
# - Test all colors in both light and dark modes
# - Consider accessibility when choosing color combinations

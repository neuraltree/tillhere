# TillHere - Mood Tracking App UI Design Specification

## 🎨 Design Philosophy

Following Apple's design standards with a cosmic/space theme, the app emphasizes:
- **Clarity**: Clean, readable interface with proper visual hierarchy
- **Deference**: Content-first approach with subtle, beautiful interactions
- **Depth**: Layered design with realistic shadows and smooth animations
- **Emotional Connection**: Beautiful, art-like aesthetics that create a calming, introspective experience

## 🌌 Visual Theme

**Cosmic Space Aesthetic**
- Deep space backgrounds with subtle gradients
- Neon green (#00ff88) as primary accent - representing growth and positivity
- Solar orange (#ff8f00) for warnings and secondary actions
- Cosmic blue (#1a237e) for brand identity and information
- Smooth, ethereal animations that feel weightless and calming

## 📱 Screen Architecture

### 1. Main Navigation Structure

**Bottom Tab Bar** (Always visible)
- **Home** (SF Symbol: house.fill) - Main mood tracking interface
- **Insights** (SF Symbol: chart.line.uptrend.xyaxis) - Analytics and trends
- **History** (SF Symbol: calendar) - Past mood entries
- **Settings** (SF Symbol: gearshape.fill) - App configuration

**Navigation Bar** (Top)
- Translucent background with blur effect
- App title "TillHere" in cosmic blue
- Filter button (top-right) for time range selection
- Profile/menu button (top-left) for side menu access

### 2. Side Menu (Slide-out Drawer)

**Design**
- Slides from left edge with smooth animation
- Dark cosmic background with subtle gradient
- Semi-transparent overlay on main content
- Width: 280pt (following Apple guidelines)

**Menu Items**
```
┌─────────────────────────────┐
│  👤 Profile                 │
│  📊 Analytics               │
│  📤 Export Data             │
│  📥 Import Data             │
│  🔒 Privacy & Security      │
│  🎨 Appearance              │
│  ℹ️  About                  │
│  ⚙️  Settings               │
└─────────────────────────────┘
```

**Visual Elements**
- User avatar/initials at top with neon green border
- Menu items with SF Symbols icons
- Subtle hover states with neon green glow
- Version info at bottom in tertiary text color

### 3. Home Screen - Main Mood Interface

**Layout Structure**
```
┌─────────────────────────────────────┐
│ [≡] TillHere            [Filter] │ ← Nav Bar
├─────────────────────────────────────┤
│                                     │
│        📊 Mood Heatmap              │ ← Heatmap Section
│     [Day] [Week] [Month]            │
│                                     │
│  ┌─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┐    │
│  │ │ │ │ │ │ │ │ │ │ │ │ │ │ │    │
│  └─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┘    │
│                                     │
│        Recent Entries               │ ← Recent Section
│  ┌─────────────────────────────┐    │
│  │ Today, 2:30 PM         😊 8 │    │
│  │ "Feeling great today!"      │    │
│  └─────────────────────────────┘    │
│                                     │
├─────────────────────────────────────┤
│     [Mood Input Bottom Sheet]      │ ← Input Area
└─────────────────────────────────────┘
```

#### Heatmap Component
- **Grid Layout**: 14 columns (2 weeks) x variable rows
- **Cell Design**:
  - Size: 24x24pt rounded squares (8pt corner radius)
  - Colors: Gradient from cosmic blue (low mood) to neon green (high mood)
  - Empty days: Subtle border with transparent fill
  - Hover/tap: Gentle scale animation (1.1x) with glow effect
- **Time Filter**: Segmented control with Day/Week/Month options
- **Data Consolidation**: Averages mood scores for selected time range
- **Local Time**: All timestamps use device timezone, not UTC

#### Recent Entries Section
- **Card Design**:
  - Background: Card surface color with subtle shadow
  - Corner radius: 12pt
  - Padding: 16pt
  - Margin: 8pt between cards
- **Content Layout**:
  - Timestamp (top-left, secondary text)
  - Mood score (top-right, large emoji + number)
  - Note preview (body text, 2 lines max with ellipsis)
  - Tags (if any, as small chips)

### 4. Mood Input Bottom Sheet

**Collapsed State** (Always visible at bottom)
```
┌─────────────────────────────────────┐
│  😐 ●●●●●○○○○○ 😊                   │ ← Mood Slider
│  ┌─────────────────────┐ [Send]     │ ← Text Input
│  │ How are you feeling?│            │
│  └─────────────────────┘            │
│              [Advanced]             │ ← Expand Button
└─────────────────────────────────────┘
```

**Design Details**
- **Height**: 120pt in collapsed state
- **Background**: Translucent card with blur effect
- **Corner Radius**: 16pt (top corners only)
- **Shadow**: Subtle upward shadow

**Mood Slider**
- **Range**: 1-10 scale with haptic feedback
- **Visual**: 10 circles, filled with neon green gradient
- **Emojis**: Sad face (left) to happy face (right)
- **Interaction**: Smooth drag with immediate visual feedback

**Text Input**
- **Style**: iMessage-like expandable text field
- **Placeholder**: "How are you feeling?" in tertiary text
- **Growth**: Expands vertically as user types (max 4 lines)
- **Background**: Secondary background color
- **Corner Radius**: 20pt (pill shape)
- **Padding**: 12pt horizontal, 8pt vertical

**Send Button**
- **Style**: Circular button with neon green background
- **Icon**: SF Symbol "arrow.up"
- **Size**: 36x36pt
- **Animation**: Gentle pulse when text is entered

#### Expanded State (Advanced Options)
```
┌─────────────────────────────────────┐
│  😐 ●●●●●○○○○○ 😊                   │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │ Expanded text area...           │ │
│  │                                 │ │
│  │                                 │ │
│  └─────────────────────────────────┘ │
│                                     │
│  📅 Date: Today, July 15            │
│  🕐 Time: 2:30 PM                   │
│                                     │
│  🏷️ Tags:                           │
│  [Work] [Happy] [Productive] [+]    │
│                                     │
│  ┌─────────────┐ ┌─────────────┐    │
│  │   Cancel    │ │    Save     │    │
│  └─────────────┘ └─────────────┘    │
└─────────────────────────────────────┘
```

**Expanded Features**
- **Height**: 400pt (covers ~60% of screen)
- **Date/Time Picker**: Allows editing timestamp
- **Tag System**:
  - Existing tags as chips with neon green border
  - Add new tag with "+" button
  - Popular tags suggested
- **Action Buttons**: Cancel (secondary) and Save (primary)

### 5. Filter Interface (Top-Right)

**Trigger**: Tap filter icon in navigation bar
**Presentation**: Dropdown menu or modal sheet

**Options**
- **Time Range**:
  - Today
  - This Week
  - This Month
  - Last 30 Days
  - All Time
  - Custom Range
- **Mood Range**: Slider for min/max mood scores
- **Tags**: Multi-select tag filter
- **Sort Options**: Date, Mood Score, Recently Added

## 🎨 Color Usage Guidelines

### Primary Colors
- **Neon Green (#00ff88)**: Primary actions, success states, high mood indicators
- **Solar Orange (#ff8f00)**: Warnings, secondary actions, medium mood indicators
- **Cosmic Blue (#1a237e)**: Brand elements, info states, low mood indicators

### Background Hierarchy
- **Primary**: Deep space black (#0a0e1a) for main background
- **Secondary**: Elevated surface (#1a1f2e) for cards and containers
- **Tertiary**: Higher elevation (#252a3a) for modals and sheets

### Text Hierarchy
- **Primary**: White (#ffffff) for main content
- **Secondary**: Light gray (#b3b3b3) for supporting text
- **Tertiary**: Medium gray (#808080) for metadata

## 🎭 Animation & Interactions

### Micro-Interactions
- **Mood Slider**: Smooth drag with haptic feedback at each step
- **Heatmap Cells**: Gentle scale (1.1x) and glow on hover/tap
- **Bottom Sheet**: Smooth expand/collapse with spring animation
- **Send Button**: Pulse animation when text is entered
- **Cards**: Subtle lift animation on tap

### Transitions
- **Screen Changes**: Slide transitions with 0.3s ease-out
- **Modal Presentation**: Slide up from bottom with backdrop fade
- **Side Menu**: Slide from left with content scale-down effect

### Loading States
- **Heatmap**: Skeleton loading with shimmer effect
- **Data Sync**: Subtle spinner with neon green accent
- **Save Actions**: Button transforms to loading indicator

## 📐 Spacing & Layout

**Grid System**: 8pt base unit
- **Screen Margins**: 16pt from safe area edges
- **Card Padding**: 16pt internal padding
- **Element Spacing**: 8pt between related items, 24pt between sections
- **Touch Targets**: Minimum 44x44pt for interactive elements

## ♿ Accessibility Features

- **Dynamic Type**: Support for system font scaling
- **Voice Over**: Comprehensive screen reader support
- **High Contrast**: Alternative color schemes for visibility
- **Reduced Motion**: Respect system animation preferences
- **Color Independence**: Don't rely solely on color for information

## 🌙 Dark Mode Support

All colors automatically adapt using semantic color system:
- Backgrounds become darker variants
- Text inverts appropriately
- Accent colors remain vibrant but slightly desaturated
- Shadows become more pronounced for depth

## 📊 Additional Screen Specifications

### 6. Insights/Analytics Screen

**Purpose**: Visualize mood patterns and trends over time

**Layout Structure**
```
┌─────────────────────────────────────┐
│ [←] Insights            [Share]    │ ← Nav Bar
├─────────────────────────────────────┤
│                                     │
│     📈 Mood Trends                  │
│  ┌─────────────────────────────┐    │
│  │     Line Chart              │    │
│  │  10 ┌─────────────────────  │    │
│  │   8 │     ●───●             │    │
│  │   6 │   ●─●     ●───●       │    │
│  │   4 │ ●─●         ●   ●─●   │    │
│  │   2 │                   ●   │    │
│  │   0 └─────────────────────  │    │
│  │     Mon Tue Wed Thu Fri     │    │
│  └─────────────────────────────┘    │
│                                     │
│     📊 Mood Distribution            │
│  ┌─────────────────────────────┐    │
│  │  [1][2][3][4][5][6][7][8][9][10]│
│  │   ●  ●  ●● ●●● ●●●● ●●● ●● ● │    │
│  └─────────────────────────────┘    │
│                                     │
│     🏷️ Top Tags                     │
│  [Happy] 45%  [Work] 32%  [Tired] 28%│
│                                     │
│     📅 Streak Counter               │
│  🔥 7 days in a row!                │
└─────────────────────────────────────┘
```

**Components**
- **Mood Trends Chart**: Interactive line chart with fl_chart package
- **Distribution Histogram**: Shows frequency of each mood score
- **Tag Analytics**: Most used tags with percentages
- **Streak Counter**: Gamification element with fire emoji
- **Time Range Selector**: Week/Month/Quarter/Year filters

### 7. History Screen

**Purpose**: Browse and search past mood entries

**Layout Structure**
```
┌─────────────────────────────────────┐
│ [←] History             [Search]   │ ← Nav Bar
├─────────────────────────────────────┤
│  🔍 Search moods...                 │ ← Search Bar
│                                     │
│  📅 July 2024                       │ ← Month Header
│  ┌─────────────────────────────┐    │
│  │ Mon 15  2:30 PM        😊 8 │    │ ← Entry Card
│  │ "Great productive day!"     │    │
│  │ [Work] [Happy] [Productive] │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ Sun 14  6:45 PM        😐 5 │    │
│  │ "Feeling neutral today"     │    │
│  │ [Tired] [Weekend]           │    │
│  └─────────────────────────────┘    │
│                                     │
│  📅 June 2024                       │
│  ┌─────────────────────────────┐    │
│  │ Fri 30  11:20 AM       😢 3 │    │
│  │ "Stressful day at work"     │    │
│  │ [Work] [Stress] [Deadline]  │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

**Features**
- **Search Functionality**: Search by note content, tags, or date
- **Infinite Scroll**: Load more entries as user scrolls
- **Month Grouping**: Entries grouped by month with headers
- **Swipe Actions**: Swipe left to edit/delete entries
- **Filter Options**: Filter by mood range, tags, or date range

### 8. Settings Screen

**Purpose**: App configuration and preferences

**Sections**
```
┌─────────────────────────────────────┐
│ [←] Settings                        │
├─────────────────────────────────────┤
│  👤 Profile                         │
│  ┌─────────────────────────────┐    │
│  │ [Avatar] John Doe           │    │
│  │ john.doe@email.com          │    │
│  └─────────────────────────────┘    │
│                                     │
│  🔔 Notifications                   │
│  Daily Reminder         [Toggle]    │
│  Reminder Time          3:00 PM     │
│  Streak Notifications   [Toggle]    │
│                                     │
│  🎨 Appearance                      │
│  Theme                  Auto        │
│  Heatmap Style          Gradient    │
│                                     │
│  🔒 Privacy & Security              │
│  Export Data                        │
│  Import Data                        │
│  Clear All Data                     │
│                                     │
│  ℹ️ About                           │
│  Version 1.0.0                      │
│  Privacy Policy                     │
│  Terms of Service                   │
└─────────────────────────────────────┘
```

## 🎯 Component Library

### 1. MoodSlider Component
```dart
// Custom slider with mood emojis and haptic feedback
MoodSlider(
  value: currentMood,
  onChanged: (value) => setState(() => currentMood = value),
  min: 1,
  max: 10,
  divisions: 9,
  activeColor: AppColors.neonGreen,
  inactiveColor: AppColors.tertiaryDark,
)
```

### 2. MoodHeatmap Component
```dart
// Interactive heatmap grid
MoodHeatmap(
  data: moodData,
  timeRange: TimeRange.week,
  onCellTap: (date, mood) => showMoodDetails(date, mood),
  cellSize: 24.0,
  cornerRadius: 8.0,
)
```

### 3. ExpandableBottomSheet Component
```dart
// Collapsible mood input interface
ExpandableBottomSheet(
  collapsed: MoodInputCollapsed(),
  expanded: MoodInputExpanded(),
  animationDuration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
)
```

### 4. TagChip Component
```dart
// Reusable tag display/input
TagChip(
  label: "Happy",
  isSelected: true,
  onTap: () => toggleTag("Happy"),
  backgroundColor: AppColors.neonGreen.withOpacity(0.2),
  borderColor: AppColors.neonGreen,
)
```

## 🔧 Technical Implementation Notes

### State Management
- **Provider Pattern**: For app-wide state management
- **Local State**: For UI-specific state (animations, form inputs)
- **Repository Pattern**: For data access abstraction

### Performance Optimizations
- **Lazy Loading**: Load mood entries on demand
- **Image Caching**: Cache user avatars and assets
- **Database Indexing**: Optimize queries with proper indexes
- **Widget Recycling**: Use ListView.builder for large lists

### Platform Integration
- **Haptic Feedback**: Use HapticFeedback.selectionClick() for slider
- **Share Functionality**: Native sharing for data export
- **Notifications**: Local notifications for daily reminders
- **Biometric Auth**: Optional biometric lock for privacy

This comprehensive design creates an immersive, calming experience that encourages regular mood tracking while maintaining Apple's high standards for beauty and usability.

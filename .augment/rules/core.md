---
type: "agent_requested"
description: "Core Rules & Guidelines"
---
# TillHere Core Rules & Guidelines

This is the central navigation guide for Augment Agent when working on the TillHere mood tracking app. Always consult this file first to understand which specific rules and guidelines to follow for different types of tasks.

## 🎯 Project Overview

TillHere is a Flutter-based mood tracking app with life expectancy visualization. The app follows Clean Architecture principles and Apple design standards, focusing on minimal, beautiful UI with cosmic/space theming.

## 📋 Rule Priority & Application

### 1. Architecture & Code Structure
**When to use**: Any code changes, new features, refactoring
**Rules to follow**:
- `architecture.md` - Clean Architecture (Uncle Bob) principles
- `platform_capabilities_summary.md` - Platform-specific constraints

### 2. UI/UX Design & Styling
**When to use**: UI components, styling, visual changes
**Rules to follow**:
- `apple_design_standards.md` - Apple design principles (ALWAYS follow)
- `UI_DESIGN_SPECIFICATION.md` - Component specifications and layout rules
- `colors.md` - Color palette and theming system

### 3. Feature Development
**When to use**: Adding/modifying mood tracking features
**Rules to follow**:
- `MOOD_TRACKING_README.md` - Feature specifications and requirements
- `architecture.md` - For data layer and business logic
- `UI_DESIGN_SPECIFICATION.md` - For UI components

### 4. Setup & Configuration
**When to use**: Project setup, deployment, platform configuration
**Rules to follow**:
- `icloud_setup_guide.md` - iCloud integration guidelines
- `platform_capabilities_summary.md` - Platform-specific setup

## 🔄 Development Workflow Rules

### Code Changes
1. **Always** check `architecture.md` for Clean Architecture compliance
2. **Always** check `apple_design_standards.md` for UI/UX changes
3. Use `colors.md` for any color-related decisions
4. Consult `UI_DESIGN_SPECIFICATION.md` for component specifications

### New Features
1. Start with `MOOD_TRACKING_README.md` for feature requirements
2. Apply `architecture.md` for code structure
3. Follow `UI_DESIGN_SPECIFICATION.md` for UI implementation
4. Use `apple_design_standards.md` for design decisions

### Bug Fixes
1. Check relevant feature rules in `MOOD_TRACKING_README.md`
2. Ensure fixes maintain `architecture.md` principles
3. Verify UI fixes follow `apple_design_standards.md`

## 🎨 Design System Hierarchy

1. **Apple Design Standards** (highest priority) - `apple_design_standards.md`
2. **TillHere UI Specifications** - `UI_DESIGN_SPECIFICATION.md`
3. **Color System** - `colors.md`
4. **Platform Constraints** - `platform_capabilities_summary.md`

## 🏗️ Architecture Hierarchy

1. **Clean Architecture Principles** - `architecture.md`
2. **Feature Requirements** - `MOOD_TRACKING_README.md`
3. **Platform Capabilities** - `platform_capabilities_summary.md`

## 🚨 Critical Rules (Never Violate)

1. **Always follow Apple design standards** - User explicitly requires this
2. **Use Clean Architecture (Uncle Bob)** - Core architectural principle
3. **Maintain cosmic/space theme** - Defined in color system
4. **Minimal UI design** - Remove unnecessary elements
5. **Flutter standards over pixels** - Use Flutter's responsive units
6. **Local phone time, not UTC** - For mood tracking timestamps

## 📱 Platform-Specific Guidance

### iOS Development
- Primary target platform
- Follow `apple_design_standards.md` strictly
- Check `platform_capabilities_summary.md` for iOS-specific features

### Android Development
- Secondary platform
- Adapt Apple standards appropriately
- Consult `platform_capabilities_summary.md` for Android constraints

## 🔧 Task-Specific Rule Selection

### UI Components
```
apple_design_standards.md → UI_DESIGN_SPECIFICATION.md → colors.md
```

### Data/Business Logic
```
architecture.md → MOOD_TRACKING_README.md → platform_capabilities_summary.md
```

### Styling/Theming
```
colors.md → apple_design_standards.md → UI_DESIGN_SPECIFICATION.md
```

### Setup/Configuration
```
icloud_setup_guide.md → platform_capabilities_summary.md → architecture.md
```

## 💡 Quick Decision Matrix

| Task Type | Primary Rules | Secondary Rules |
|-----------|---------------|-----------------|
| New UI Component | apple_design_standards.md | UI_DESIGN_SPECIFICATION.md, colors.md |
| Data Model | architecture.md | MOOD_TRACKING_README.md |
| Feature Logic | MOOD_TRACKING_README.md | architecture.md |
| Styling | colors.md | apple_design_standards.md |
| Platform Setup | platform_capabilities_summary.md | icloud_setup_guide.md |

## 🎯 User Preferences (Always Honor)

- **Clean Architecture (Uncle Bob)** for all code
- **Apple design standards** for all UI/UX
- **Minimal UI** - remove unnecessary elements
- **Flutter standards** over direct pixel usage
- **iOS simulator** for testing (never macOS)
- **Task management** for complex multi-step work
- **Hot reload** development workflow

## 📝 Notes for Augment Agent

- Always start with this `core.md` file to understand context
- Cross-reference multiple rule files when needed
- When in doubt, prioritize Apple design standards and Clean Architecture
- User values beautiful, minimal design over feature complexity
- Always suggest testing after code changes
- Use task management tools for complex work breakdown

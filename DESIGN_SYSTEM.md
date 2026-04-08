# Design System - AI Medicament Scanner

## 📖 Table of Contents
1. [Overview](#overview)
2. [Design Tokens](#design-tokens)
3. [Component Library](#component-library)
4. [Patterns & Best Practices](#patterns--best-practices)
5. [Accessibility Guidelines](#accessibility-guidelines)
6. [Implementation Guide](#implementation-guide)

---

## 🎯 Overview

The AI Medicament Scanner uses a modern, clean design language based on Material Design 3 principles. The system emphasizes clarity, accessibility, and professional healthcare aesthetics.

### Design Philosophy
- **Medical First**: Trust and clarity in medical UI
- **User-Centric**: Minimalist, intuitive interactions
- **Modern**: Contemporary design without sacrificing functionality
- **Accessible**: WCAG AA compliant throughout
- **Responsive**: Works seamlessly across all device sizes

---

## 🎨 Design Tokens

### Color System

#### Semantic Colors
```
Primary:      #2563EB (Blue) - Main actions, interactive elements
Secondary:   #0D9488 (Teal) - Supporting actions, accents
Success:     #10B981 (Green) - Completed, positive states
Warning:     #F97316 (Orange) - Alerts, pending states
Error:       #EF4444 (Red) - Critical alerts, errors
Info:        #3B82F6 (Light Blue) - Information, education
```

#### Neutral Colors
```
Light Theme:
  BG:         #F8FAFC (Off-white)
  Card:       #FFFFFF (White)
  Text:       #0F172A (Dark Slate)
  Disabled:   #CBD5E1 (Light Gray)
  Border:     #E2E8F0 (Very Light Gray)

Dark Theme:
  BG:         #0F172A (Dark Slate)
  Card:       #1E293B (Charcoal)
  Text:       #F8FAFC (Off-white)
  Disabled:   #64748B (Medium Gray)
  Border:     #334155 (Dark Gray)
```

#### Opacity Modifiers
- Hover: 0.8 opacity
- Disabled: 0.5 opacity
- Light overlay: 0.1 opacity
- Medium overlay: 0.2 opacity
- Dark overlay: 0.3+ opacity

### Typography

#### Font Family
**Primary**: Plus Jakarta Sans (via Google Fonts)
- Clean, modern, highly readable
- Excellent for medical contexts
- Available weights: 400, 500, 600, 700, 800

#### Type Scale
```
Display Large:   48px, weight 700, line-height 1.2
Display Medium:  36px, weight 700, line-height 1.2
Display Small:   28px, weight 700, line-height 1.3

Headline Large:  24px, weight 700, line-height 1.3
Headline Medium: 20px, weight 700, line-height 1.35
Headline Small:  18px, weight 700, line-height 1.4

Title Large:     16px, weight 700, line-height 1.4
Title Medium:    14px, weight 600, line-height 1.4
Title Small:     12px, weight 600, line-height 1.4

Body Large:      16px, weight 400, line-height 1.5
Body Medium:     14px, weight 400, line-height 1.5
Body Small:      12px, weight 400, line-height 1.5

Label Large:     14px, weight 700, line-height 1.4
Label Medium:    12px, weight 600, line-height 1.4
Label Small:     11px, weight 500, line-height 1.4
```

#### Letter Spacing
- Headlines: 0.5px
- Body: 0px (default)
- Buttons: 0.5px (emphasized)

### Spacing System

**Base Unit**: 8px

```
xs:   4px   (small gaps within components)
sm:   8px   (spacing between components)
md:   16px  (standard padding/margins)
lg:   24px  (major section spacing)
xl:   32px  (large section breaks)
2xl:  40px  (page-level spacing)
3xl:  48px  (full-width containers)
```

### Border Radius

```
xs:   4px    (subtle, small elements)
sm:   8px    (slight rounding, badges)
md:   12px   (form fields, medium components)
lg:   16px   (cards, large containers)
xl:   20px   (modal dialogs, large containers)
full: 50%    (perfect circles)
```

### Shadows

#### Elevation Levels
```
Shadow-1 (small, close):
  color: rgba(0, 0, 0, 0.08)
  blur: 8px
  offset: (0, 2px)
  use: subtle depth on cards

Shadow-2 (medium, mid):
  color: rgba(0, 0, 0, 0.12)
  blur: 12px
  offset: (0, 6px)
  use: prominent cards, buttons

Shadow-3 (large, far):
  color: rgba(0, 0, 0, 0.16)
  blur: 16px
  offset: (0, 12px)
  use: floating buttons, modals

Shadow-4 (large, far):
  color: rgba(0, 0, 0, 0.2)
  blur: 20px
  offset: (0, 16px)
  use: focus states, overlays
```

### Animation Tokens

```
Duration:
  fast:    300ms   (micro-interactions, hovers)
  normal:  600ms   (transitions, slides)
  slow:    800ms   (page transitions, fades)
  
Easing:
  ease-in-out:     Curves.easeInOut (default)
  ease-out:        Curves.easeOut (entries, appears)
  ease-in:         Curves.easeIn (exits, disappears)
  cubic:           Curves.linearToEaseInOut (modals)
```

---

## 🧩 Component Library

### Buttons

#### Primary Button
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue.shade500, Colors.blue.shade600],
    ),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.blue.withOpacity(0.4),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        child: Text(
          'Action',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    ),
  ),
)
```
**Usage**: Primary actions, main calls-to-action
**States**: Normal, Hover (0.9 opacity), Active (darken), Disabled (0.5 opacity)
**Minimum Target**: 48px height

#### Secondary Button
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade300, width: 1.5),
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        child: Text(
          'Action',
          style: TextStyle(
            color: Colors.blue.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    ),
  ),
)
```
**Usage**: Secondary actions, cancel buttons
**States**: Normal, Hover (light gray BG), Active, Disabled (0.5 opacity)

#### Icon Button
```dart
IconButton(
  onPressed: action,
  icon: const Icon(Icons.action),
  color: Colors.blue,
  iconSize: 24,
  padding: const EdgeInsets.all(12),
  tooltip: 'Action',
)
```
**Usage**: Compact interactive elements
**Minimum Target**: 48px diameter

### Input Fields

#### Text Input
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Label',
    prefixIcon: const Icon(Icons.icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.blue, width: 2),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  ),
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Required field';
    return null;
  },
)
```
**States**: Default, Focused (blue border, 2px), Error (red), Disabled (gray bg)
**Minimum Height**: 48px
**Label**: Always present for accessibility

#### Checkbox
```dart
Checkbox(
  value: isSelected,
  onChanged: (value) => setState(() => isSelected = value ?? false),
  fillColor: MaterialStateProperty.resolveWith<Color?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) return Colors.blue;
      return Colors.grey.shade300;
    },
  ),
)
```
**Size**: 24x24px
**Color**: Blue when selected, gray when unselected

### Cards

#### Standard Card
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: // Content
)
```
**Padding**: 16px
**Border Radius**: 16px
**Shadow**: Elevation-1

#### Glass Card (Premium)
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.8),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.5),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: // Content
    ),
  ),
)
```
**Use**: Premium sections, important information
**Effect**: Slight blur background with semi-transparent layering

### Alerts & Notifications

#### Success Alert
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.green.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.green.withOpacity(0.3)),
  ),
  child: Row(
    children: [
      const Icon(Icons.check_circle, color: Colors.green),
      const SizedBox(width: 12),
      Expanded(child: Text(message)),
    ],
  ),
)
```
**Colors**: Green (#10B981)
**Icon**: check_circle
**Use**: Confirmation messages, successes

#### Warning Alert
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.orange.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.orange.withOpacity(0.3)),
  ),
  child: Row(
    children: [
      const Icon(Icons.warning_amber, color: Colors.orange),
      const SizedBox(width: 12),
      Expanded(child: Text(message)),
    ],
  ),
)
```
**Colors**: Orange (#F97316)
**Icon**: warning_amber
**Use**: Cautions, pending status

#### Error Alert
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.red.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.red.withOpacity(0.3)),
  ),
  child: Row(
    children: [
      const Icon(Icons.error_outline, color: Colors.red),
      const SizedBox(width: 12),
      Expanded(child: Text(message)),
    ],
  ),
)
```
**Colors**: Red (#EF4444)
**Icon**: error_outline
**Use**: Errors, critical alerts

### Loading States

#### Circular Progress
```dart
const SizedCircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
  strokeWidth: 2.5,
)
```
**Color**: Primary blue
**Use**: Indeterminate loading

#### Linear Progress
```dart
LinearProgressIndicator(
  value: progress,
  backgroundColor: Colors.grey.shade200,
  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
  minHeight: 4,
)
```
**Height**: 4px
**Use**: Determinate progress, uploads

---

## 📐 Patterns & Best Practices

### Layout Patterns

#### Standard Page Layout
```
AppBar (56px height | 64px on web)
↓
ScrollView
├─ Padding (16px horizontal)
├─ Content
└─ Bottom padding (32px)

FloatingActionButton (bottom-right)
```

#### Card Grid Layout
```dart
GridView.count(
  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
  children: items.map((item) => buildCard(item)).toList(),
)
```

#### List Layout
```dart
ListView.separated(
  itemCount: items.length,
  separatorBuilder: (context, index) => const Divider(height: 1),
  itemBuilder: (context, index) => ListTile(
    leading: Icon(getIcon(items[index])),
    title: Text(items[index].name),
    subtitle: Text(items[index].description),
    trailing: Icon(Icons.chevron_right),
    onTap: () => navigate(items[index]),
  ),
)
```

### Navigation Patterns

#### Bottom Navigation
- 3-5 items maximum
- Icons + labels
- Active color: Primary blue
- Inactive color: Gray
- Height: 56px (+ safe area)

#### Tab Navigation
- Divider line at bottom
- Active indicator (blue underline)
- Icon + label combinations
- Smooth scroll between tabs

### Form Patterns

#### Form Layout
```
Title
Label + Required *
Input Field
Helper Text / Error Text
↓
Label + Required *
Input Field
Helper Text / Error Text
↓
Primary Button (Full Width)
↓
Secondary Link/Button
```

#### Validation States
- **Invalid**: Red border, error text below field
- **Valid**: Green checkmark indicator
- **Focus**: Blue border (2px)
- **Disabled**: Gray background, disabled cursor

### State Patterns

#### Empty State
```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(Icons.category, size: 64, color: Colors.grey.withOpacity(0.5)),
    SizedBox(height: 16),
    Text('No items found', style: headlineSmall),
    SizedBox(height: 8),
    Text('Create one to get started', style: bodyMedium),
  ],
)
```

#### Error State
```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(Icons.error_outline, size: 64, color: Colors.red),
    SizedBox(height: 16),
    Text('Something went wrong', style: headlineSmall),
    SizedBox(height: 8),
    Text('Please try again', style: bodyMedium),
    SizedBox(height: 24),
    ElevatedButton(onPressed: retry, child: Text('Retry')),
  ],
)
```

---

## ♿ Accessibility Guidelines

### Color Contrast
- **WCAG AA**: Minimum 4.5:1 for text, 3:1 for graphics
- **WCAG AAA**: Minimum 7:1 for text, 4.5:1 for graphics
- Test using: WebAIM Contrast Checker

### Touch Targets
- **Minimum**: 48x48px (iOS/Android standard)
- **Comfortable**: 56x56px
- **Spacing**: 8px minimum between targets

### Typography
- **Minimum Body**: 12px (12pt)
- **Recommended Body**: 14px-16px
- **Line Height**: 1.4-1.5x font size
- **Line Length**: 45-75 characters optimal

### Motion & Animation
- **Respect prefers-reduced-motion**: Provide non-animated alternatives
- **Animations**: Keep under 1 second (unless intentional)
- **Flashy effects**: Avoid anything flashing > 3 times/second

### Icons & Images
- **Always pair**: Icons with text labels
- **Descriptive**: Use clear, recognizable icons
- **Consistency**: Use Material Design icons throughout
- **Alt text**: Provide descriptions for important images

### Focus Management
- **Visible focus**: All interactive elements must show focus state
- **Focus order**: Logical navigation order (top-to-bottom, left-to-right)
- **Focus trap**: Modals should trap focus internally
- **Keyboard shortcuts**: Document all keyboard navigation

---

## 🛠️ Implementation Guide

### Setting Up Theme in New Screen

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MyNewScreen extends StatefulWidget {
  const MyNewScreen({super.key});

  @override
  State<MyNewScreen> createState() => _MyNewScreenState();
}

class _MyNewScreenState extends State<MyNewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Title'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.indigo.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content here
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### Using Custom Widgets

```dart
// Import custom widgets
import '../widgets/premium_widgets.dart';

// Use GlassCard
GlassCard(
  height: 200,
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      // Content
    ],
  ),
)

// Use GradientButton
GradientButton(
  text: 'Action',
  onPressed: () {
    // Handle action
  },
)
```

### Testing Themes

```dart
// In your test file
testWidgets('Widget displays with light theme', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme(),
      home: const MyNewScreen(),
    ),
  );
  
  expect(find.byType(MyNewScreen), findsOneWidget);
  // Add assertions
});

testWidgets('Widget displays with dark theme', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme(),
      home: const MyNewScreen(),
    ),
  );
  
  expect(find.byType(MyNewScreen), findsOneWidget);
  // Add assertions
});
```

---

## 📱 Responsive Breakpoints

```dart
// Desktop: > 1200px
if (MediaQuery.of(context).size.width > 1200) {
  // Multi-column layout
}

// Tablet: 600px - 1200px
else if (MediaQuery.of(context).size.width > 600) {
  // Two-column layout
}

// Mobile: < 600px
else {
  // Single column layout
}
```

---

## 🎯 Common Component Library

### Horizontal Feature Card
```dart
SizedBox(
  width: 140,
  child: GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  ),
)
```

### Profile Avatar
```dart
Container(
  padding: const EdgeInsets.all(3),
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
      color: isActive ? Colors.blue : Colors.transparent,
      width: 2,
    ),
  ),
  child: CircleAvatar(
    radius: 28,
    backgroundColor: Colors.blue.withOpacity(0.1),
    child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold)),
  ),
)
```

---

**Design System Version**: 1.0  
**Last Updated**: 2024  
**Framework**: Flutter

For questions or clarifications, refer to the implementation files or contact the design team.

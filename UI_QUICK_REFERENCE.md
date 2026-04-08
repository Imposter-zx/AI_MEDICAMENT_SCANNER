# 🎨 UI Design Quick Reference Card

## 🎯 Quick Links
- **Design System**: `DESIGN_SYSTEM.md`
- **Animations**: `ANIMATIONS_GUIDE.md`  
- **Checklist**: `UI_IMPLEMENTATION_CHECKLIST.md`
- **Overview**: `UI_IMPROVEMENTS.md`
- **Summary**: `UI_MODERNIZATION_SUMMARY.md`

---

## 🎨 Color Palette (Copy & Paste Ready)

### Primary Colors
```dart
// Primary Blue
Color.primary = #2563EB
Colors.blue.shade600
Color(0xFF2563EB)

// Secondary Teal
Color.secondary = #0D9488
Colors.teal.shade600
Color(0xFF0D9488)
```

### Status Colors
```dart
// Success Green
Colors.green.shade600 (#10B981)

// Warning Orange
Colors.orange.shade500 (#F97316)

// Error Red
Colors.red.shade500 (#EF4444)

// Info Blue
Colors.blue.shade400 (#3B82F6)
```

### Neutral Colors
```dart
// Light Theme
Background:    Colors.grey.shade50 (#F8FAFC)
Card:          Colors.white (#FFFFFF)
Text:          Colors.grey.shade900 (#0F172A)
Border:        Colors.grey.shade300 (#E2E8F0)

// Dark Theme
Background:    Color(0xFF0F172A)
Card:          Color(0xFF1E293B)
Text:          Colors.grey.shade50 (#F8FAFC)
Border:        Colors.grey.shade700 (#334155)
```

---

## 📐 Spacing Cheat Sheet

```dart
// Standard Spacing Values (use consistently)
const xs = 4.0;      // Small gaps
const sm = 8.0;      // Standard gaps
const md = 16.0;     // Normal padding
const lg = 24.0;     // Section breaks
const xl = 32.0;     // Major breaks

// Quick Examples
SizedBox(height: 8)         // Small gap
EdgeInsets.all(16)          // Standard padding
SizedBox(height: 24)        // Section break
Padding(padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16)) // Form field

// Grid/List Spacing
crossAxisSpacing: 16       // Between columns
mainAxisSpacing: 16        // Between rows
itemExtent: 80            // List item height minimum
```

---

## 🎭 Border Radius Guide

```dart
// Form Fields & Inputs
BorderRadius.circular(12)

// Cards & Containers
BorderRadius.circular(16)

// Large Containers
BorderRadius.circular(20)

// Perfect Circles
shape: BoxShape.circle

// Variable Radius
BorderRadius.only(
  topLeft: Radius.circular(20),
  topRight: Radius.circular(20),
  bottomLeft: Radius.circular(12),
  bottomRight: Radius.circular(12),
)
```

---

## 🎬 Animation Quick Reference

### Durations
```dart
Duration.fast = 300ms      // Button taps, hovers
Duration.normal = 600ms    // Card slides, transitions
Duration.slow = 800ms      // Page transitions, fades
Duration.slowest = 1200ms  // Complex animations
```

### Standard Curves
```dart
Curves.easeInOut     // Most animations (default)
Curves.easeOut       // Entries, appearing content
Curves.easeIn        // Exits, disappearing content
Curves.decelerate    // Smooth slowdown
Curves.elasticOut    // Bouncy effect
```

### Most Common Pattern
```dart
Tween<double>(begin: 0, end: 1).animate(
  CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  ),
)
```

---

## 🔳 Shadows (Elevation System)

```dart
// Shadow-1: Subtle (cards, small elevation)
BoxShadow(
  color: Colors.black.withOpacity(0.08),
  blurRadius: 8,
  offset: Offset(0, 2),
)

// Shadow-2: Medium (buttons, prominent cards)
BoxShadow(
  color: Colors.black.withOpacity(0.12),
  blurRadius: 12,
  offset: Offset(0, 6),
)

// Shadow-3: Large (floating buttons, modals)
BoxShadow(
  color: Colors.black.withOpacity(0.16),
  blurRadius: 16,
  offset: Offset(0, 12),
)

// Colored Shadow (theme-based)
BoxShadow(
  color: Colors.blue.withOpacity(0.4),
  blurRadius: 12,
  offset: Offset(0, 6),
)
```

---

## 🔘 Common Components (Copy Ready)

### Primary Button
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
        offset: Offset(0, 6),
      ),
    ],
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        child: Text('Button', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    ),
  ),
)
```

### Secondary Button
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
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        child: Text('Button', style: TextStyle(color: Colors.blue.shade600)),
      ),
    ),
  ),
)
```

### Card
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: // Content
)
```

### Form Field
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Label',
    prefixIcon: Icon(Icons.icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  ),
)
```

---

## 📝 Typography Quick Reference

### Font
```dart
// Already configured in theme
// Just use TextTheme styles:
Theme.of(context).textTheme.displayLarge      // 48px, 700
Theme.of(context).textTheme.headlineSmall     // 20px, 700
Theme.of(context).textTheme.bodyLarge         // 16px, 400
Theme.of(context).textTheme.bodyMedium        // 14px, 400
Theme.of(context).textTheme.labelSmall        // 11px, 500
```

### Manual Sizing
```dart
// Headlines
fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 0.5

// Body
fontSize: 14, fontWeight: FontWeight.w400

// Buttons
fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5

// Labels
fontSize: 12, fontWeight: FontWeight.w600
```

---

## 🎬 Animation Templates

### Fade In
```dart
FadeTransition(
  opacity: AnimationController(...),
  child: YourWidget(),
)
```

### Slide Up
```dart
SlideTransition(
  position: Tween<Offset>(
    begin: Offset(0, 0.3),
    end: Offset.zero,
  ).animate(_controller),
  child: YourWidget(),
)
```

### Scale
```dart
ScaleTransition(
  scale: Tween<double>(begin: 0.8, end: 1).animate(_controller),
  child: YourWidget(),
)
```

### Rotate
```dart
RotationTransition(
  turns: _controller,
  child: Icon(Icons.refresh),
)
```

---

## ✅ Implementation Checklist (TL;DR)

### Before You Start
- [ ] Read design system overview
- [ ] Copy component examples
- [ ] Know spacing rules: 8px base
- [ ] Memorize colors

### During Development
- [ ] Use gradient backgrounds
- [ ] Apply proper spacing (8px increments)
- [ ] Use 12px radius for forms, 16px for cards
- [ ] Add shadows for depth
- [ ] Implement animations (600ms default)

### Before Shipping
- [ ] Light & dark theme tested
- [ ] Mobile responsive (< 600px)
- [ ] Accessibility verified (contrast, focus, touch)
- [ ] Animations smooth (60 FPS)
- [ ] All states handled (loading, error, success)

---

## 🚨 DON'Ts (Avoid These)

```
❌ Using random colors
❌ Inconsistent spacing (5px, 10px, 15px)
❌ Varying border radius (8, 12, 18px)
❌ Animations longer than 1 second
❌ Small touch targets (< 48px)
❌ No focus states
❌ Text without proper contrast
❌ Physics scrolling instead of bouncing
❌ Forgetting dark mode
❌ No loading/error states
```

---

## 🎯 DO's (Follow These)

```
✅ Use AppTheme colors
✅ Spacing: 8px increments
✅ Border radius: 12px (forms) / 16px (cards)
✅ Animations: 300ms (fast) / 600ms (normal) / 800ms (slow)
✅ Touch targets: minimum 48x48px
✅ Visible focus states for keyboard
✅ Contrast ratio: 4.5:1 minimum
✅ BouncingScrollPhysics() on ScrollView
✅ Test both light and dark themes
✅ Implement all state variations
```

---

## 💾 Code Snippets

### Modern Screen Template
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Title')),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content with proper spacing
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
}
```

### Alert Container
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
      Icon(Icons.warning_amber, color: Colors.orange),
      SizedBox(width: 12),
      Expanded(child: Text('Message')),
    ],
  ),
)
```

---

## 📊 Size Reference

```
Mobile:          < 600px width
Tablet:          600px - 1200px width
Desktop:         > 1200px width

Button Height:   48px minimum
Touch Target:    48x48px minimum
Card Padding:    16px
Form Field:      48px height, 12px radius
Icon Size:       24px (standard), 32px (large)
AppBar Height:   56px (mobile), 64px (web)
```

---

## 🔗 File Locations

```
lib/screens/
├── auth_screen.dart          ← Modern example
├── home_screen.dart          ← Modern example
└── [new screens here]

lib/theme/
└── app_theme.dart            ← Theme config

lib/widgets/
└── premium_widgets.dart      ← Custom components

Root Documentation:
├── UI_IMPROVEMENTS.md              ← Start here
├── DESIGN_SYSTEM.md                ← Full reference
├── ANIMATIONS_GUIDE.md             ← Animation help
├── UI_IMPLEMENTATION_CHECKLIST.md  ← Dev standards
└── UI_MODERNIZATION_SUMMARY.md     ← Complete overview
```

---

## ⚡ Pro Tips

1. **Copy → Paste → Adapt**: Use code snippets as starting point
2. **Color Palette**: Keep bookmark to color reference
3. **Spacing**: Always use 8px increments (never random numbers)
4. **Animations**: Start with 600ms, adjust if needed
5. **Testing**: Always test light and dark modes
6. **Accessibility**: Use accessibility inspector in dev tools
7. **Performance**: Profile animations for 60fps
8. **Consistency**: When in doubt, check existing screens

---

## 📞 When Stuck

1. **Design question**: Check `DESIGN_SYSTEM.md`
2. **Animation help**: Check `ANIMATIONS_GUIDE.md`
3. **Implementation**: Check `UI_IMPLEMENTATION_CHECKLIST.md`
4. **Code example**: Review `auth_screen.dart` or `home_screen.dart`
5. **General**: Check `UI_IMPROVEMENTS.md`

---

## ⭐ Remember

The design system is **documentation first** - all code should follow the patterns already established. When creating new screens, start by reviewing similar existing screens and copying their structure.

---

**Last Updated**: 2024  
**Version**: 1.0  
**Status**: ✅ Ready to Use

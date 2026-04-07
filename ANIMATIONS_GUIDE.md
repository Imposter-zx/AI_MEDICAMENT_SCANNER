# Animations & Visual Effects Guide

## 📱 Animation System Overview

The AI Medicament Scanner uses carefully crafted animations to create a modern, responsive feel while maintaining medical app professionalism.

---

## 🎬 Animation Durations

```dart
final class AnimationDurations {
  // Micro-interactions (buttons, hovers, icon changes)
  static const fast = Duration(milliseconds: 300);
  
  // Standard transitions (cards appearing, fading content)
  static const normal = Duration(milliseconds: 600);
  
  // Page transitions, significant changes
  static const slow = Duration(milliseconds: 800);
  
  // Long transitions (complex animations)
  static const slowest = Duration(milliseconds: 1200);
}
```

---

## 🌊 Easing Functions (Curves)

### Common Curves in Flutter

```dart
// Smooth, natural feel (recommended for most)
Curves.easeInOut      // Accelerates then decelerates

// Entrance animations (appearing content)
Curves.easeOut        // Decelerates quickly
Curves.decelerate     // Slows down smoothly

// Exit animations (disappearing content)
Curves.easeIn         // Accelerates smoothly
Curves.preEaseInCubic // Pre-animation ease

// Special effects
Curves.elasticOut     // Elastic bounce effect
Curves.bounceOut      // Bouncy spring effect
Curves.linearToEaseInCubic  // Linear then easing
```

### Recommended Animation Pairings

```dart
// Page Entry
duration: const Duration(milliseconds: 600),
curve: Curves.easeOut,

// Card Slide
duration: const Duration(milliseconds: 600),
curve: Curves.easeInOut,

// Fade In
duration: const Duration(milliseconds: 800),
curve: Curves.easeOut,

// Button Tap
duration: const Duration(milliseconds: 300),
curve: Curves.easeInOut,
```

---

## 🔄 Common Animation Patterns

### 1. Fade In Animation

```dart
class FadeInScreen extends StatefulWidget {
  const FadeInScreen({super.key});

  @override
  State<FadeInScreen> createState() => _FadeInScreenState();
}

class _FadeInScreenState extends State<FadeInScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Your content
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 2. Slide Up Animation

```dart
class SlideUpWidget extends StatefulWidget {
  const SlideUpWidget({super.key});

  @override
  State<SlideUpWidget> createState() => _SlideUpWidgetState();
}

class _SlideUpWidgetState extends State<SlideUpWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
      ),
      child: FadeTransition(
        opacity: _slideController,
        child: Container(
          // Your widget
        ),
      ),
    );
  }
}
```

### 3. Scale Animation

```dart
class ScaleInWidget extends StatefulWidget {
  const ScaleInWidget({super.key});

  @override
  State<ScaleInWidget> createState() => _ScaleInWidgetState();
}

class _ScaleInWidgetState extends State<ScaleInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
      ),
      child: FadeTransition(
        opacity: _scaleController,
        child: Container(
          // Your widget
        ),
      ),
    );
  }
}
```

### 4. Rotation Animation

```dart
class RotatingWidget extends StatefulWidget {
  const RotatingWidget({super.key});

  @override
  State<RotatingWidget> createState() => _RotatingWidgetState();
}

class _RotatingWidgetState extends State<RotatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotateController.repeat(); // Continuous rotation
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotateController,
      child: Icon(Icons.refresh, size: 24),
    );
  }
}
```

### 5. Combined Animations (Staggered)

```dart
class StaggeredAnimation extends StatefulWidget {
  const StaggeredAnimation({super.key});

  @override
  State<StaggeredAnimation> createState() => _StaggeredAnimationState();
}

class _StaggeredAnimationState extends State<StaggeredAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First card: animates 0-400ms
        _buildStaggeredCard(0, 'Card 1'),
        
        // Second card: animates 200-600ms
        _buildStaggeredCard(200, 'Card 2'),
        
        // Third card: animates 400-800ms
        _buildStaggeredCard(400, 'Card 3'),
      ],
    );
  }

  Widget _buildStaggeredCard(int delay, String title) {
    final animation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              delay / 1200,
              (delay + 400) / 1200,
              curve: Curves.easeOut,
            ),
          ),
        );

    return SlideTransition(
      position: animation,
      child: FadeTransition(
        opacity: _controller,
        child: Card(
          child: ListTile(title: Text(title)),
        ),
      ),
    );
  }
}
```

---

## 🩸 Visual Effects

### Glassmorphism

```dart
Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Content
          ],
        ),
      ),
    ),
  ),
)
```

### Gradient Overlay

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.black.withValues(alpha: 0.6),
        Colors.transparent,
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ),
  ),
  child: // Your content
)
```

### Soft Shadow

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
        spreadRadius: 0,
      ),
    ],
  ),
  child: // Your content
)
```

### Glow Effect

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.blue,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: Colors.blue.withOpacity(0.6),
        blurRadius: 20,
        spreadRadius: 8,
        offset: Offset.zero,
      ),
      BoxShadow(
        color: Colors.blue.withOpacity(0.3),
        blurRadius: 40,
        spreadRadius: 16,
        offset: Offset.zero,
      ),
    ],
  ),
  child: Icon(Icons.favorite, color: Colors.white),
)
```

---

## 🎯 Specific Animation Examples

### Medication Reminder Card Animation

```dart
class ReminderCardAnimation extends StatefulWidget {
  final MedicationReminder reminder;

  const ReminderCardAnimation({
    required this.reminder,
    super.key,
  });

  @override
  State<ReminderCardAnimation> createState() => _ReminderCardAnimationState();
}

class _ReminderCardAnimationState extends State<ReminderCardAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: () {
            // Handle tap
          },
          child: Container(
            // Reminder card UI
          ),
        ),
      ),
    );
  }
}
```

### Button Tap Animation

```dart
class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;

  const AnimatedButton({
    required this.onPressed,
    required this.label,
    super.key,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(begin: 1, end: 0.95).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _handlePress,
        child: Container(
          // Button UI
        ),
      ),
    );
  }
}
```

### Loading Animation

```dart
class MedicationLoadingAnimation extends StatefulWidget {
  const MedicationLoadingAnimation({super.key});

  @override
  State<MedicationLoadingAnimation> createState() =>
      _MedicationLoadingAnimationState();
}

class _MedicationLoadingAnimationState extends State<MedicationLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _controller,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.local_pharmacy,
                  color: Colors.blue,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing medication...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
```

---

## 🎪 Page Transition Animations

### Custom Page Route

```dart
class CustomPageRoute<T> extends PageRoute<T> {
  CustomPageRoute({
    required this.child,
    required this.duration,
  });

  final Widget child;
  final Duration duration;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        // Slide from right
        return Transform.translate(
          offset: Offset(
            (1 - animation.value) * 300,
            0,
          ),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Duration get transitionDuration => duration;
}

// Usage
Navigator.push(
  context,
  CustomPageRoute(
    child: const NextScreen(),
    duration: const Duration(milliseconds: 300),
  ),
);
```

---

## 🎉 Celebration & Feedback Animations

### Confetti Animation

```dart
// Already imported: import 'package:confetti/confetti.dart';

late ConfettiController _confettiController;

@override
void initState() {
  super.initState();
  _confettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );
}

@override
void dispose() {
  _confettiController.dispose();
  super.dispose();
}

// Trigger celebration
void _celebrate() {
  _confettiController.play();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('All medications taken today!'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
    ),
  );
}

// Build confetti widget
Align(
  alignment: Alignment.topCenter,
  child: ConfettiWidget(
    confettiController: _confettiController,
    blastDirectionality: BlastDirectionality.explosive,
    shouldLoop: false,
    colors: const [
      Colors.green,
      Colors.blue,
      Colors.pink,
      Colors.orange,
      Colors.purple,
    ],
  ),
)
```

### Snackbar Animation

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.white),
        const SizedBox(width: 12),
        const Expanded(
          child: Text('Medication marked as taken!'),
        ),
      ],
    ),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: const Duration(seconds: 3),
  ),
);
```

---

## ⚡ Performance Optimization

### Animation Best Practices

1. **Use SingleTickerProviderStateMixin** for single animations
2. **Use TickerProviderStateMixin** for multiple animations
3. **Disable animations** in tests or low-performance scenarios
4. **Use AnimatedBuilder** to rebuild only affected widgets
5. **Dispose controllers** properly to prevent memory leaks

```dart
// Good: Only animate the container, not the entire build
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: child,
    );
  },
  child: const Card(/* static content */),
)

// Avoid: Full rebuild on every animation frame
AnimatedBuilder(
  animation: _controller,
  builder: (context, _) {
    return Scaffold(
      // Entire screen rebuilds - not efficient
      body: Container(),
    );
  },
)
```

---

## 🧪 Testing Animations

```dart
testWidgets('fadeIn animation completes', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: FadeInScreen(),
    ),
  );

  // Initial state should be faded out
  expect(
    find.byType(FadeTransition),
    findsWidgets,
  );

  // Advance animation
  await tester.pumpAndSettle(); // Wait for animation to complete

  // Verify animation completed
  expect(find.byType(YourWidget), findsOneWidget);
});
```

---

## 📊 Animation Checklist

- [ ] Animation duration appropriate (fast: 300ms, normal: 600ms, slow: 800ms)
- [ ] Proper easing curve selected (easeOut for entrance, easeIn for exit)
- [ ] AnimationController properly disposed
- [ ] Animations disabled on low-performance devices
- [ ] Animation doesn't distract from content
- [ ] All animations tested and smooth
- [ ] Loading states animated
- [ ] Success feedback animated (confetti, scale, etc.)
- [ ] Transitions feel natural and professional
- [ ] Respects motion preferences (prefers-reduced-motion)

---

**Last Updated**: 2024
**Version**: 1.0

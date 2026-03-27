# 🤝 Contributing to AI Medicament Scanner

Thank you for your interest in contributing! This document explains how to get involved.

---

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment. Be kind, constructive, and professional in all interactions.

---

## Ways to Contribute

- 🐛 **Bug reports** — Open a GitHub issue with steps to reproduce
- 💡 **Feature requests** — Describe the use case and expected behavior
- 🔧 **Code contributions** — Fix bugs, add features, improve tests
- 📖 **Documentation** — Improve guides, fix typos, add examples
- 🌍 **Translations** — Help localize the app

---

## Development Setup

```bash
# 1. Fork & clone the repo
git clone https://github.com/yourusername/ai_medicament_scanner.git
cd ai_medicament_scanner

# 2. Create a feature branch
git checkout -b feature/your-feature-name

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

---

## Branching Strategy

| Branch | Purpose |
|---|---|
| `main` | Stable, production-ready code |
| `develop` | Integration branch for new features |
| `feature/*` | New features (branch from `develop`) |
| `fix/*` | Bug fixes (branch from `main` for hotfixes) |
| `docs/*` | Documentation-only changes |

---

## Code Style

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Run `dart format .` before committing
- Run `flutter analyze` — zero warnings required
- Use descriptive variable names; avoid single-letter variables outside loops
- Add dartdoc comments (`///`) to all public classes and methods

```dart
/// Analyzes the extracted text from a medication label.
///
/// Returns a [Medication] object with full drug information.
/// Throws [Exception] if analysis fails.
Future<Medication> analyzeMedicationText(String text) async { ... }
```

---

## Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short description>

[optional body]
[optional footer]
```

**Types:**

| Type | Use for |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation changes |
| `refactor` | Code refactoring |
| `test` | Adding/fixing tests |
| `chore` | Build process, dependencies |

**Examples:**
```
feat(medication): add ibuprofen to local database
fix(ocr): handle null image path gracefully
docs(readme): update installation steps for Flutter 3.x
```

---

## Pull Request Process

1. **Ensure your branch is up to date** with `develop`
2. **Run the test suite**: `flutter test`
3. **Run the linter**: `flutter analyze`
4. **Format code**: `dart format .`
5. **Open a PR** against the `develop` branch
6. Fill in the PR template completely
7. Request a review from a maintainer
8. Address all review comments before merge

---

## Adding Medications to the Database

The local medication database is in `lib/services/medical_analyzer_service.dart`. To add a new entry:

```dart
'ibuprofen': Medication(
  name: 'Ibuprofen',
  activeIngredient: 'Ibuprofen',
  usedFor: ['Pain relief', 'Fever reduction', 'Anti-inflammatory'],
  whenToUse: ['For mild to moderate pain', 'Inflammation'],
  contraindications: ['Kidney disease', 'Stomach ulcers', 'Third trimester pregnancy'],
  dosage: 'Usually 200-400mg every 4-6 hours, max 1200mg daily',
  sideEffects: ['Stomach upset', 'Nausea', 'Dizziness'],
  simpleExplanation: 'Ibuprofen is a pain reliever and anti-inflammatory.',
  requiresPrescription: false,
),
```

> ⚠️ All medication data must be sourced from authoritative medical references (e.g., FDA, WHO, national pharmacopoeia). Include a source citation in your PR.

---

## Medical Data Guidelines

> **CRITICAL**: This app deals with health information. Inaccurate data can be harmful.

- All drug information must be verified against official sources
- Always include the standard disclaimer on new result types
- Never present AI analysis as a medical diagnosis
- Flag prescription drugs with `requiresPrescription: true`
- Include all known contraindications — do not omit for brevity

---

## Reporting Bugs

When filing a bug report, include:

- Flutter version (`flutter --version`)
- Device/emulator (model, OS version)
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots / logs if applicable

---

## Questions?

Open a [GitHub Discussion](https://github.com/yourusername/ai_medicament_scanner/discussions) or contact the maintainers via the issue tracker.

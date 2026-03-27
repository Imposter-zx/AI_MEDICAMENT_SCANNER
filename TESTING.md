# 🧪 Testing Guide — AI Medicament Scanner

This document explains how to test the application at different levels.

## 🧪 Unit Tests
Located in the `test/` directory. These test business logic in `services/` and `providers/`.

```bash
flutter test test/unit_test.dart
```

## 📱 Widget Tests
Test individual UI components in isolation.

```bash
flutter test test/widget_test.dart
```

## 🤖 Integration Tests (E2E)
Test full user flows on a real device.

```bash
flutter test integration_test/app_test.dart
```

## 📝 Manual Test Plan

| Step | Action | Expected Result |
|---|---|---|
| 1 | Launch App | Home screen appears with 3 feature cards |
| 2 | Click Medication Scan | Image picker opens |
| 3 | Select Image (Aspirin) | Analysis starts, then Results Screen shows Aspirin info |
| 4 | Click Clear | Return to Scanner screen |
| 5 | Upload Lab Report | Results Screen shows extracted lab values (e.g. Glucose) |

---

> 💡 **Tip**: Use mock images in `assets/test_images/` for automated regression testing.

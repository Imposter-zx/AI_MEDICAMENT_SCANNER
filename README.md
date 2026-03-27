# 🏥 AI Medicament Scanner

> **AI-powered mobile health assistant** — scan medications, analyze medical documents, and get insights from medical images. Built with Flutter.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Version](https://img.shields.io/badge/version-1.0.0-green?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)

> ⚠️ **Medical Disclaimer**: This application is for **educational purposes only**. It is NOT a substitute for professional medical advice, diagnosis, or treatment. Always consult a qualified healthcare provider.

---

## ✨ Features

| Feature | Description |
|---|---|
| 💊 **Medication Scanner** | Scan medication boxes via camera or gallery; get usage info, dosage, side effects & contraindications |
| 📄 **Document Analysis** | Upload prescriptions, lab reports, blood work; extracts key findings and abnormal values |
| 🩻 **Medical Imaging** | Analyze X-rays, CT scans, MRIs, and ultrasounds with guided educational insights |
| 📊 **Results Dashboard** | Unified results screen with structured, color-coded findings and medical disclaimers |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) `^3.11.3`
- Dart SDK `^3.11.3`
- Android Studio / Xcode (for mobile deployment)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/ai_medicament_scanner.git
cd ai_medicament_scanner

# 2. Install dependencies
flutter pub get

# 3. Run on device/emulator
flutter run
```

### Build

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web
```

---

## 🏗️ Project Structure

```
lib/
├── main.dart                        # App entry point & routing
├── screens/
│   ├── home_screen.dart             # Feature selection hub
│   ├── medication_scan_screen.dart  # Medication scanner UI
│   ├── document_analysis_screen.dart# Document upload & analysis UI
│   ├── medical_imaging_screen.dart  # Medical imaging UI
│   └── results_screen.dart         # Unified results display
├── models/
│   └── models.dart                 # Data models (Medication, MedicalDocument, MedicalImage)
├── providers/
│   └── medical_data_provider.dart  # State management (Provider pattern)
└── services/
    ├── medical_analyzer_service.dart# Core analysis logic
    └── ocr_service.dart            # OCR text extraction
```

---

## 🔬 How It Works

```
User captures image
        │
        ▼
  OCR Service extracts text
        │
        ▼
  MedicalAnalyzerService processes text
        │
        ├── Medication? → matches local DB + pattern analysis
        ├── Document?   → detects type, extracts findings, flags abnormals
        └── Imaging?    → detects imaging type + body part, provides context
        │
        ▼
  MedicalDataProvider (state)
        │
        ▼
  ResultsScreen displays structured output
```

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `flutter/material` | UI framework |
| `provider` | State management |
| `image_picker` | Camera & gallery access |
| `http` | API communication |
| `json_annotation` | JSON serialization |

---

## 🛡️ Permissions Required

| Platform | Permission | Reason |
|---|---|---|
| Android | `CAMERA` | Take medication photos |
| Android | `READ_EXTERNAL_STORAGE` | Select from gallery |
| iOS | `NSCameraUsageDescription` | Camera access |
| iOS | `NSPhotoLibraryUsageDescription` | Photo library access |

---

## 🗂️ Documentation

| Document | Description |
|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | System architecture & design decisions |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute to this project |
| [CHANGELOG.md](CHANGELOG.md) | Version history & release notes |
| [SECURITY.md](SECURITY.md) | Security policy & responsible disclosure |
| [TESTING.md](TESTING.md) | Testing strategy & how to run tests |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Deployment guide for Android, iOS & Web |

---

## 🤝 Contributing

We welcome contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting pull requests.

---

## 📄 License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

---

## ⚕️ Medical Disclaimer

This app provides information for **educational and informational purposes only**. The content is not intended to be a substitute for professional medical advice. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.

**In case of emergency, call 911 or your local emergency number immediately.**

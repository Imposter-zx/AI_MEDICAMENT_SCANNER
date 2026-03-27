# 📋 Changelog — AI Medicament Scanner

All notable changes to this project will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and [Semantic Versioning](https://semver.org/).

---

## [1.0.0] — 2026-03-27

### 🎉 Initial Release

#### Added
- **Home Screen** — Feature navigation hub with safety notice and usage disclaimer
- **Medication Scanner** — Camera/gallery capture, OCR-based medication identification
  - Local medication database: Aspirin, Paracetamol, Amoxicillin
  - Displays: usage, contraindications, dosage, side effects, simple explanation
  - Prescription flag indicator
- **Document Analysis** — Upload prescriptions, lab reports, medical documents
  - Auto-detect document type (prescription, lab test, medical report, invoice)
  - Regex extraction of: Hemoglobin, Glucose, Cholesterol, Blood Pressure
  - Flags abnormal values with color-coded indicators
  - Auto-generated recommendations
- **Medical Imaging Analysis** — Support for X-Ray, CT Scan, MRI, Ultrasound
  - Imaging type detection from filename heuristics
  - Body part identification
  - Confidence level display
- **Results Screen** — Unified display for all three analysis types
  - Color-coded key findings (normal = green, abnormal = red)
  - Medical disclaimer embedded in all results
- **State Management** — Provider pattern with `MedicalDataProvider`
- **Routing** — Flutter named routes for all screens
- **Cross-Platform Support** — Android, iOS, Web, Windows, macOS, Linux targets

#### Architecture
- Clean 4-layer architecture: UI → State → Service → Model
- JSON-serializable models using `json_annotation`
- OCR service abstraction ready for Google ML Kit / Cloud Vision integration
- REST API hooks ready in `MedicalAnalyzerService`

#### Safety
- Medical disclaimers on every results screen
- Emergency services reminder (911) on home screen
- Prescription medication flags throughout

---

## [Unreleased]

### Planned
- [ ] Expand local medication database (100+ entries)
- [ ] Google ML Kit on-device OCR integration
- [ ] Result history with local storage (Hive/SQLite)
- [ ] Dark mode support
- [ ] Localization (Arabic, French, Spanish)
- [ ] OpenAI/Gemini API integration for richer explanations
- [ ] Barcode/QR code scanning for medications
- [ ] Export results as PDF
- [ ] Doctor appointment booking integration

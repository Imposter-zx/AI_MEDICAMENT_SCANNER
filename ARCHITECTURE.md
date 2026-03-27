# 🏗️ Architecture — AI Medicament Scanner

## Overview

AI Medicament Scanner is a **cross-platform Flutter application** built using the **Provider** state management pattern and a clean layered architecture.

---

## Architecture Layers

```
┌─────────────────────────────────────────────┐
│                   UI Layer                  │
│  HomeScreen │ ScanScreen │ ResultsScreen    │
└────────────────────┬────────────────────────┘
                     │ reads / writes via
┌────────────────────▼────────────────────────┐
│              State Layer (Provider)          │
│           MedicalDataProvider               │
└────────────────────┬────────────────────────┘
                     │ calls
┌────────────────────▼────────────────────────┐
│              Service Layer                  │
│   OCRService  │  MedicalAnalyzerService     │
└────────────────────┬────────────────────────┘
                     │ acts on
┌────────────────────▼────────────────────────┐
│               Data / Model Layer            │
│  Medication │ MedicalDocument │ MedicalImage│
│            MedicalResult                   │
└─────────────────────────────────────────────┘
```

---

## Layer Responsibilities

### 1. UI Layer — `lib/screens/`

| Screen | Route | Responsibility |
|---|---|---|
| `HomeScreen` | `/` | Feature navigation hub |
| `MedicationScanScreen` | `/medication-scan` | Image capture for medication |
| `DocumentAnalysisScreen` | `/document-analysis` | Document upload UI |
| `MedicalImagingScreen` | `/medical-imaging` | Medical image upload UI |
| `ResultsScreen` | `/results` | Unified analysis output |

All screens are **statefully reactive** — they use `Consumer<MedicalDataProvider>` to automatically rebuild on state changes (loading, error, result ready).

### 2. State Layer — `lib/providers/`

**`MedicalDataProvider`** (extends `ChangeNotifier`) holds:

| Field | Type | Description |
|---|---|---|
| `currentMedication` | `Medication?` | Latest medication result |
| `currentDocument` | `MedicalDocument?` | Latest document result |
| `currentImagingResult` | `MedicalImage?` | Latest imaging result |
| `currentImagePath` | `String?` | Path to selected image |
| `isLoading` | `bool` | Loading state flag |
| `errorMessage` | `String?` | Error message (if any) |

**Flow inside provider methods:**
1. Set `isLoading = true` → notify listeners
2. Call `OCRService.extractTextFromImage()`
3. Call `MedicalAnalyzerService` with extracted text
4. Store result → Set `isLoading = false` → notify listeners
5. On error: set `errorMessage` → notify listeners

### 3. Service Layer — `lib/services/`

#### `OCRService`
- Extracts text from captured images using OCR (Google ML Kit or Cloud Vision API ready).
- Returns a plain `String` of detected text.

#### `MedicalAnalyzerService`
Core intelligence of the application:

| Method | Output | Description |
|---|---|---|
| `analyzeMedicationText(text)` | `Medication` | Pattern-match text against local medication DB; returns full drug profile |
| `analyzeDocument(text)` | `MedicalDocument` | Detects doc type, extracts lab values, flags abnormals, generates recommendations |
| `analyzeMedicalImage(imagePath)` | `MedicalImage` | Detects imaging type + body part from filename metadata, returns structured observation |

**Medication Database (embedded):**
Currently contains seeded entries for: `aspirin`, `paracetamol`, `amoxicillin`. Designed to be extended via a remote API (`https://api.example.com/medications`).

**Lab Value Parsing (Regex patterns):**
```
Hemoglobin   → /hemoglobin[\:\s]+(\d+\.?\d*)/i
Glucose      → /glucose[\:\s]+(\d+)/i
Cholesterol  → /cholesterol[\:\s]+(\d+)/i
Blood Pressure → /(?:blood pressure|bp)[\:\s]+(\d+)\/(\d+)/i
```

**Abnormal Value Thresholds (defaults):**

| Lab Value | Low | High |
|---|---|---|
| Hemoglobin | < 12 g/dL | > 16 g/dL |
| Glucose | < 70 mg/dL | > 100 mg/dL |
| Cholesterol | — | > 200 mg/dL |

### 4. Data Model Layer — `lib/models/`

All models use `json_annotation` for serialization.

```dart
Medication          // name, activeIngredient, manufacturer, usedFor, whenToUse,
                    // contraindications, dosage, sideEffects, simpleExplanation,
                    // requiresPrescription, imagePath

MedicalDocument     // documentType, extractedText, keyFindings[], abnormalValues[],
                    // recommendations[], dateCreated, imagePath

KeyFinding          // label, value, normalRange, isAbnormal, interpretation

MedicalImage        // imagingType, bodyPart, description, observedAreas[],
                    // areasOfInterest[], confidenceLevel, simpleExplanation,
                    // requiresUrgentReview, imagePath

MedicalResult       // resultType, timestamp, data (polymorphic), disclaimer
```

---

## Data Flow Diagram

```
User taps "Analyze"
        │
        ▼
[Screen] calls provider.analyzeMedication(imagePath)
        │
        ▼
[Provider] sets isLoading = true → notifyListeners()
        │
        ▼
[OCRService] extractTextFromImage(imagePath) → "Aspirin 500mg..."
        │
        ▼
[MedicalAnalyzerService] analyzeMedicationText("aspirin...")
        │  Pattern match → found "aspirin" key
        ▼
Returns Medication{name:"Aspirin", sideEffects:[...], ...}
        │
        ▼
[Provider] stores result, sets isLoading = false → notifyListeners()
        │
        ▼
[ResultsScreen] Consumer rebuilds with medication data
```

---

## Routing

Defined in `main.dart` using Flutter's named routes:

| Route | Widget |
|---|---|
| `/` (home) | `HomeScreen` |
| `/medication-scan` | `MedicationScanScreen` |
| `/document-analysis` | `DocumentAnalysisScreen` |
| `/medical-imaging` | `MedicalImagingScreen` |
| `/results` | `ResultsScreen` |

---

## Design Decisions

| Decision | Rationale |
|---|---|
| **Provider over Riverpod/Bloc** | Simpler for a single-developer app with linear state flows |
| **Embedded medication DB** | No backend dependency for MVP; extendable to REST API |
| **Regex-based lab parsing** | Fast, offline, deterministic; no AI latency for common patterns |
| **Image path detection for imaging type** | Heuristic fallback when DICOM metadata is unavailable |
| **Single ResultsScreen** | DRY principle — all three analysis types share one display screen with conditional rendering |

---

## Future Architecture Improvements

- [ ] Replace embedded medication DB with REST API (`http` client already wired)
- [ ] Integrate Google ML Kit for on-device OCR
- [ ] Add Hive / SQLite for local result history
- [ ] Migrate to Riverpod for better testability
- [ ] Add OpenAI/Gemini API for richer natural language explanations

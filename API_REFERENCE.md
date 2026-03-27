# 📡 API Reference — AI Medicament Scanner

## Overview

This document describes the internal APIs (services and providers) of the AI Medicament Scanner app. These are Dart APIs, not REST endpoints.

---

## `MedicalAnalyzerService`

**Location:** `lib/services/medical_analyzer_service.dart`

The core intelligence service. All methods are `async`.

---

### `analyzeMedicationText(String text)`

Analyzes extracted OCR text and returns medication information.

**Signature:**
```dart
Future<Medication> analyzeMedicationText(String text)
```

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `text` | `String` | Raw text extracted from a medication label image |

**Returns:** `Future<Medication>`

**Behavior:**
- Lowercases input text
- Searches against built-in medication database using key matching
- Returns `Medication` with full drug profile if found
- Returns `Medication` with name `"Unknown Medication"` if not found
- Throws `Exception` if analysis fails

**Example:**
```dart
final service = MedicalAnalyzerService();
final medication = await service.analyzeMedicationText('aspirin 500mg tablet');
print(medication.name); // "Aspirin"
print(medication.requiresPrescription); // false
```

---

### `analyzeDocument(String text)`

Analyzes extracted text from a medical document.

**Signature:**
```dart
Future<MedicalDocument> analyzeDocument(String text)
```

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `text` | `String` | Raw text extracted from a document image |

**Returns:** `Future<MedicalDocument>`

**Document Types Detected:**

| Keyword in Text | Detected Type |
|---|---|
| `rx`, `prescription` | `prescription` |
| `lab`, `test result` | `lab_test` |
| `diagnosis`, `report` | `medical_report` |
| `invoice`, `receipt` | `invoice` |
| *(none matched)* | `medical_document` |

**Lab Values Extracted (via Regex):**

| Label | Pattern |
|---|---|
| `hemoglobin` | `/hemoglobin[\:\s]+(\d+\.?\d*)\s*(g\/dL)?/i` |
| `glucose` | `/glucose[\:\s]+(\d+)\s*(mg\/dL)?/i` |
| `cholesterol` | `/cholesterol[\:\s]+(\d+)\s*mg\/dL?/i` |
| `blood pressure` | `/(?:blood pressure|bp)[\:\s]+(\d+)\/(\d+)/i` |

**Example:**
```dart
final doc = await service.analyzeDocument('Lab test: glucose: 150 mg/dL');
print(doc.documentType); // "lab_test"
print(doc.keyFindings.first.isAbnormal); // true (> 100 threshold)
```

---

### `analyzeMedicalImage(String imagePath)`

Analyzes a medical image file path and returns structured imaging information.

**Signature:**
```dart
Future<MedicalImage> analyzeMedicalImage(String imagePath)
```

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `imagePath` | `String` | File path to the medical image |

**Returns:** `Future<MedicalImage>`

**Imaging Type Detection (from filename):**

| Path Contains | Detected Type |
|---|---|
| `xray`, `x-ray` | `X-Ray` |
| `ct`, `scan` | `CT Scan` |
| `mri` | `MRI` |
| `ultrasound`, `ultra` | `Ultrasound` |
| *(none matched)* | `Medical Imaging` |

**Body Part Detection (from filename):**

| Path Contains | Detected Body Part |
|---|---|
| `chest` | Chest |
| `brain`, `head` | Brain |
| `spine`, `back` | Spine |
| `abdomen`, `belly` | Abdomen |
| `leg`, `knee` | Lower Extremity |
| `arm`, `shoulder` | Upper Extremity |
| *(none matched)* | Unknown |

---

## `OCRService`

**Location:** `lib/services/ocr_service.dart`

Abstracts text extraction from images.

### `extractTextFromImage(String imagePath)`

**Signature:**
```dart
Future<String> extractTextFromImage(String imagePath)
```

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `imagePath` | `String` | File path to the image |

**Returns:** `Future<String>` — extracted text

> **Note:** In the current version, this is a stub ready for Google ML Kit or Cloud Vision API integration.

---

## `MedicalDataProvider`

**Location:** `lib/providers/medical_data_provider.dart`

Flutter `ChangeNotifier` — manages global app state.

### State Fields

| Field | Type | Description |
|---|---|---|
| `currentMedication` | `Medication?` | Active medication analysis result |
| `currentDocument` | `MedicalDocument?` | Active document analysis result |
| `currentImagingResult` | `MedicalImage?` | Active imaging analysis result |
| `currentImagePath` | `String?` | Path to the currently selected image |
| `isLoading` | `bool` | `true` while analysis is in progress |
| `errorMessage` | `String?` | Error description, or `null` if no error |

### Methods

#### `analyzeMedication(String imagePath)`
```dart
Future<void> analyzeMedication(String imagePath)
```
Runs OCR → medication analysis → stores result → notifies listeners.

#### `analyzeDocument(String imagePath)`
```dart
Future<void> analyzeDocument(String imagePath)
```
Runs OCR → document analysis → stores result → notifies listeners.

#### `analyzeMedicalImage(String imagePath)`
```dart
Future<void> analyzeMedicalImage(String imagePath)
```
Runs imaging analysis → stores result → notifies listeners.

#### `clearAll()`
```dart
void clearAll()
```
Resets all state fields to `null`/`false` and notifies listeners.

---

## Data Models

### `Medication`

```dart
class Medication {
  final String name;
  final String? activeIngredient;
  final String? manufacturer;
  final List<String> usedFor;
  final List<String> whenToUse;
  final List<String> contraindications;
  final String? dosage;
  final List<String> sideEffects;
  final String simpleExplanation;
  final bool requiresPrescription;
  String? imagePath; // mutable — set by provider
}
```

### `MedicalDocument`

```dart
class MedicalDocument {
  final String documentType;
  final String extractedText;
  final List<KeyFinding> keyFindings;
  final List<String> abnormalValues;
  final List<String> recommendations;
  final DateTime? dateCreated;
  String? imagePath; // mutable — set by provider
}
```

### `KeyFinding`

```dart
class KeyFinding {
  final String label;        // e.g. "hemoglobin"
  final String value;        // e.g. "8.5"
  final String? normalRange; // e.g. "12-16 g/dL"
  final bool isAbnormal;
  final String? interpretation;
}
```

### `MedicalImage`

```dart
class MedicalImage {
  final String imagingType;        // "X-Ray" | "MRI" | "CT Scan" | "Ultrasound"
  final String bodyPart;
  final String description;
  final List<String> observedAreas;
  final List<String> areasOfInterest;
  final String confidenceLevel;   // "low" | "medium" | "high"
  final String simpleExplanation;
  final bool requiresUrgentReview;
  final String? imagePath;
}
```

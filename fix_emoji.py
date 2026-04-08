import re

files = [
    'lib/screens/medication_scan_screen.dart',
    'lib/screens/document_analysis_screen.dart',
    'lib/screens/medical_imaging_screen.dart'
]

for filepath in files:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace corrupted emoji with empty string
    content = content.replace('\u0192\u00c6\u00e8', 'Medication ')  # ƒÆè → "Medication "
    content = content.replace('\u0192\u00c6\u00e8', 'Document ')    # ƒÆè → "Document "
    content = content.replace('\u0192\u00c6\u00e8', 'Medical ')     # ƒÆè → "Medical "
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Fixed: {filepath}")

print("Done!")

# 🔧 Troubleshooting — AI Medicament Scanner

Common issues and how to fix them.

## 🛠️ Build Issues

### "Flutter command not found"
- **Cause**: Flutter SDK is not in your system PATH.
- **Fix**: [Add Flutter to your PATH](https://docs.flutter.dev/get-started/install/windows#update-your-path).

### "CocoaPods not installed" (macOS/iOS)
- **Fix**: Run `sudo gem install cocoapods` and then `pod install` in the `ios/` directory.

## 📸 Camera & Image Picker Issues

### "Camera permission denied"
- **Cause**: The user rejected the permission or it's missing from the manifest.
- **Fix**: Check `AndroidManifest.xml` (Android) and `Info.plist` (iOS). Users must grant permission in their device settings.

### "Image not loading"
- **Fix**: Ensure the path provided by `image_picker` is valid and the file exists on the filesystem.

## 📄 OCR & Analysis Issues

### "Text not recognized"
- **Cause**: Poor lighting, blurry photo, or unsupported font.
- **Fix**: Use high-quality images with clear, horizontal text. Ensure the `google_mlkit_text_recognition` package is correctly linked.

### "Medication not found in database"
- **Cause**: The medication is not in our local `medications` map.
- **Fix**: Check `lib/services/EXTENDED_MEDICATIONS_DATABASE.dart` to see supported drugs. More can be added manually.

## 🐛 Getting Help
If your issue isn't listed here:
1. Check the [logs](DEBUGGING.md) (if available).
2. Open a GitHub Issue (for non-security items).
3. Contact the team via email listed in [CONTRIBUTING.md](CONTRIBUTING.md).

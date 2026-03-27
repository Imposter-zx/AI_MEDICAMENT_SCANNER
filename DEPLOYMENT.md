# 🚀 Deployment — AI Medicament Scanner

Guidelines for building and releasing the application.

## 🤖 Android Release
1. Update `android/app/build.gradle` versioning.
2. Configure ProGuard/R8 rules if needed.
3. Build the App Bundle:
   ```bash
   flutter build appbundle --release
   ```
4. Upload to Google Play Console.

## 🍎 iOS Release
1. Update build version in Xcode.
2. Ensure `Info.plist` has all usage descriptions.
3. Build the archive:
   ```bash
   flutter build ipa --release
   ```
4. Upload via Transporter or Xcode to App Store Connect.

## 🌐 Web Deployment
1. Build for web:
   ```bash
   flutter build web --release
   ```
2. Deploy the `build/web/` folder to GitHub Pages, Firebase Hosting, or Netlify.

---

### Environmental Configuration
Use `--dart-define` for secrets:
```bash
flutter build apk --dart-define=API_KEY=your_secret
```

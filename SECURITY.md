# 🔒 Security Policy — AI Medicament Scanner

## Supported Versions

| Version | Supported |
|---|---|
| 1.0.x (latest) | ✅ Yes |
| < 1.0 | ❌ No |

---

## ⚠️ Medical Data Security — Critical Notice

This application handles **sensitive medical information**. Images of medications, prescriptions, lab reports, and medical scans are processed by this app. Protecting this data is paramount.

### What Data Is Processed

| Data Type | Where Processed | Stored? |
|---|---|---|
| Medication box images | On-device (local OCR) | No — in-memory only |
| Prescription images | On-device | No — in-memory only |
| Lab report images | On-device | No — in-memory only |
| Medical scan images | On-device | No — in-memory only |
| Extracted OCR text | In-memory | No |
| Analysis results | In-memory (per session) | No |

> **By default, no medical data is persisted to disk or sent to external servers** in the current version.

---

## Reporting a Vulnerability

If you discover a security vulnerability, **do NOT open a public GitHub issue**.

### How to Report

1. **Email**: security@yourdomain.com  
   Subject: `[SECURITY] AI Medicament Scanner — <brief description>`

2. **Include**:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (optional)

3. **Response Timeline**:
   - Acknowledgement: within **48 hours**
   - Initial assessment: within **5 business days**
   - Resolution / patch: within **30 days** for critical issues

4. **Responsible Disclosure**: Please allow us to patch and release a fix before public disclosure. We will credit you in the changelog.

---

## Security Best Practices for Developers

### API Keys
- Never commit API keys to source control
- Use environment variables or Flutter's `--dart-define` for API credentials:
  ```bash
  flutter run --dart-define=OPENAI_API_KEY=your_key_here
  ```
- Add `.env` files to `.gitignore`

### Image Handling
- Validate image file types before processing
- Set maximum image size limits
- Do not log image paths to crash reporting tools

### Network Security
- All API calls must use **HTTPS** only
- Enable certificate pinning for production medical API endpoints
- Validate all API responses before parsing

### Data Privacy
- Do not persist medical images without explicit user consent
- Implement results auto-clear on app background/close
- Follow HIPAA guidelines if deploying in the United States
- Follow GDPR guidelines if deploying in the European Union

---

## Known Security Considerations

| Area | Risk | Mitigation |
|---|---|---|
| OCR text extraction | Image data in memory | Cleared after analysis |
| Local medication DB | Outdated drug info | Regular DB updates required |
| Image picker | Gallery permissions | Request only when needed |
| Camera access | Privacy | Permission prompt before first use |

---

## Compliance Notes

> This app is intended for **educational use only**. If you deploy this app in a clinical or regulated environment, additional compliance measures are required:

- **HIPAA (USA)**: Requires Business Associate Agreement (BAA), audit logs, encrypted storage
- **GDPR (EU)**: Data minimization, user consent, right to deletion
- **MDR (EU)**: Medical Device Regulation may apply for AI-diagnostic tools
- **FDA (USA)**: FDA 510(k) clearance may be required for clinical decision support tools

**Consult legal counsel before deploying in regulated healthcare environments.**

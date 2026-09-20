# Quick Start Guide

Get your OS-integrated 2FA apps running in minutes!

## iOS - Quick Setup

### 1. Open in Xcode
```bash
cd iOS
open -a Xcode
```

### 2. Create New Project
- File → New → Project
- iOS → App
- Name: **SecureAuth**
- Interface: **SwiftUI**
- Language: **Swift**

### 3. Add Files
Drag all files from `SecureAuth/` folder into your Xcode project.

### 4. Add Extension
- File → New → Target
- Choose **Credential Provider Extension**
- Name: **SecureAuthExtension**
- Add `CredentialProviderViewController.swift`

### 5. Enable Capabilities
For BOTH targets (main app + extension):
- ✅ Keychain Sharing
- ✅ App Groups (create: `group.com.yourcompany.SecureAuth`)

### 6. Share Files Between Targets
Select these files and check BOTH targets in File Inspector:
- `TOTPAccount.swift`
- `TOTPGenerator.swift`
- `AccountManager.swift`
- `KeychainService.swift`

### 7. Run on Device
- Connect iPhone/iPad
- Select your device
- Press ⌘R

### 8. Enable AutoFill
On device: **Settings → Passwords → Password Options → AutoFill Passwords → Enable SecureAuth**

✅ **Done!** Your codes will now appear in the QuickType bar!

---

## Android - Quick Setup

### 1. Open in Android Studio
```bash
cd Android
studio .
```
(Or File → Open → select Android folder)

### 2. Sync Gradle
Android Studio will prompt to sync. Click **Sync Now**.

### 3. Build & Run
```bash
./gradlew installDebug
```
Or press the green ▶️ button in Android Studio.

### 4. Enable Autofill Service
On device: **Settings → System → Languages & input → Autofill service → SecureAuth**

✅ **Done!** Tap any 2FA field to see your codes!

---

## Testing Both Apps

### Add a Test Account

Use this test secret to add your first account:
```
Secret: JBSWY3DPEHPK3PXP
Issuer: Test
Account: test@example.com
```

This generates real TOTP codes you can verify at [totp.danhersam.com](https://totp.danhersam.com/)

### Test Autofill

**iOS:**
1. Open Safari
2. Go to a site with 2FA (or create a test HTML page)
3. Tap the 2FA input field
4. Your code appears above the keyboard
5. Tap to autofill

**Android:**
1. Open Chrome
2. Go to a site with 2FA
3. Tap the 2FA input field
4. Autofill dropdown shows your codes
5. Tap to fill

### Test QR Scanning

Generate a test QR code at [stefansundin.github.io/2fa-qr](https://stefansundin.github.io/2fa-qr/) or use one from a real service.

---

## Common Issues

### iOS: "AutoFill doesn't appear"
- ✅ Using physical device (not simulator)?
- ✅ Enabled in Settings → Passwords?
- ✅ Both targets share same App Group?

### Android: "Autofill doesn't work"
- ✅ Service enabled in Settings?
- ✅ Camera permission granted?
- ✅ Testing on real login form?

### Both: "Build errors"
**iOS:**
```bash
# In Xcode
Product → Clean Build Folder (Shift+Cmd+K)
```

**Android:**
```bash
./gradlew clean build
# Or in Android Studio: File → Invalidate Caches / Restart
```

---

## What's Next?

1. **Read Full Docs**: Check `IMPLEMENTATION_GUIDE.md` for details
2. **Customize**: Update bundle IDs, app icons, colors
3. **Test Thoroughly**: Try with multiple services
4. **Distribute**: Prepare for App Store/Play Store

---

## Quick Commands Reference

### iOS
```bash
# Open Xcode
open -a Xcode iOS/

# Build from command line (if you have Xcode CLI tools)
xcodebuild -project SecureAuth.xcodeproj -scheme SecureAuth build
```

### Android
```bash
# Build debug APK
./gradlew assembleDebug

# Install on connected device
./gradlew installDebug

# Run tests
./gradlew test

# Build release APK
./gradlew assembleRelease

# Clean build
./gradlew clean
```

---

## File Structure

```
iOS/SecureAuth/
├── SecureAuthApp.swift          # ← Start here
├── ContentView.swift            # Main UI
├── Models/TOTPAccount.swift     # Data model
├── Services/                    # Business logic
├── Views/                       # UI components
└── Info.plist                   # Permissions

Android/app/src/main/
├── AndroidManifest.xml          # ← Permissions & service
├── java/com/secureauth/
│   ├── MainActivity.kt          # Entry point
│   ├── models/                  # Data
│   ├── services/                # Business logic
│   ├── ui/                      # Compose UI
│   └── utils/                   # TOTP algorithm
└── res/                         # Resources
```

---

## Support

- 📖 **Full docs**: `IMPLEMENTATION_GUIDE.md`
- 🍎 **iOS details**: `iOS/README.md`
- 🤖 **Android details**: `Android/README.md`
- 🔗 **Original concept**: [github.com/Mattjhagen/OS-integrated-2FA](https://github.com/Mattjhagen/OS-integrated-2FA)

---

**You're all set! Start building and make 2FA seamless! 🚀**

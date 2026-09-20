# OS-Integrated 2FA Implementation Guide

This guide will help you build and deploy the iOS and Android apps that implement OS-integrated autofill for TOTP 2FA codes.

## Project Structure

```
OS-integrated-2FA/
├── iOS/
│   ├── SecureAuth/                    # Main iOS app
│   │   ├── SecureAuthApp.swift       # App entry point
│   │   ├── ContentView.swift         # Main view with auth gate
│   │   ├── Models/
│   │   │   └── TOTPAccount.swift     # Account data model
│   │   ├── Services/
│   │   │   ├── TOTPGenerator.swift   # TOTP generation logic
│   │   │   ├── AccountManager.swift  # Account management
│   │   │   └── KeychainService.swift # Secure storage
│   │   ├── Views/
│   │   │   ├── BiometricAuthView.swift    # FaceID/TouchID auth
│   │   │   ├── AddAccountView.swift       # Manual account entry
│   │   │   └── QRScannerView.swift        # QR code scanner
│   │   └── Info.plist
│   └── SecureAuthExtension/          # AutoFill Credential Provider Extension
│       ├── CredentialProviderViewController.swift
│       └── Info.plist
│
└── Android/
    ├── app/
    │   ├── build.gradle.kts
    │   ├── src/main/
    │   │   ├── AndroidManifest.xml
    │   │   ├── java/com/secureauth/
    │   │   │   ├── MainActivity.kt
    │   │   │   ├── models/
    │   │   │   │   └── TOTPAccount.kt
    │   │   │   ├── services/
    │   │   │   │   ├── AccountManager.kt
    │   │   │   │   └── SecureAuthAutofillService.kt
    │   │   │   ├── ui/
    │   │   │   │   ├── SecureAuthApp.kt
    │   │   │   │   ├── screens/
    │   │   │   │   │   ├── BiometricAuthScreen.kt
    │   │   │   │   │   ├── AccountListScreen.kt
    │   │   │   │   │   ├── AddAccountDialog.kt
    │   │   │   │   │   └── QRScannerScreen.kt
    │   │   │   │   └── theme/
    │   │   │   │       ├── Theme.kt
    │   │   │   │       └── Type.kt
    │   │   │   └── utils/
    │   │   │       └── TOTPGenerator.kt
    │   │   └── res/
    │   │       ├── values/strings.xml
    │   │       └── xml/
    │   │           ├── autofill_service_config.xml
    │   │           ├── backup_rules.xml
    │   │           └── data_extraction_rules.xml
    │   └── proguard-rules.pro
    ├── build.gradle.kts
    ├── settings.gradle.kts
    └── gradle.properties
```

## iOS Implementation

### Prerequisites
- macOS with Xcode 15 or later
- iOS 16.0+ deployment target
- Apple Developer Account (for testing on device)

### Building the iOS App

1. **Open Xcode and create a new project:**
   ```bash
   cd iOS
   open -a Xcode
   ```

2. **Create a new iOS App project:**
   - Product Name: `SecureAuth`
   - Interface: SwiftUI
   - Language: Swift
   - Bundle Identifier: `com.yourcompany.SecureAuth`

3. **Add all Swift files from the `SecureAuth/` directory to your project**

4. **Add the Credential Provider Extension:**
   - File → New → Target
   - Choose "Credential Provider Extension"
   - Product Name: `SecureAuthExtension`
   - Add the `CredentialProviderViewController.swift` file
   - Replace the extension's Info.plist with the provided one

5. **Enable Required Capabilities:**
   - Select your target → Signing & Capabilities
   - Add "Keychain Sharing"
   - Add App Groups (use: `group.com.yourcompany.SecureAuth`)
   - Update the Credential Provider Extension to use the same App Group

6. **Update Info.plist permissions:**
   - Already included in the provided Info.plist:
     - NSCameraUsageDescription
     - NSFaceIDUsageDescription

7. **Build and Run:**
   - Select a target device or simulator
   - Build the app (⌘R)

### Enabling AutoFill on iOS

1. After installing the app, go to **Settings → Passwords → Password Options**
2. Enable **AutoFill Passwords**
3. Select **SecureAuth** from the list
4. Your 2FA codes will now appear in the QuickType bar when iOS detects a 2FA field

## Android Implementation

### Prerequisites
- Android Studio Ladybug or later
- Minimum SDK: API 26 (Android 8.0)
- Target SDK: API 35 (Android 15)

### Building the Android App

1. **Open Android Studio:**
   ```bash
   cd Android
   studio .
   ```
   Or open Android Studio and select "Open" → navigate to the `Android` folder

2. **Sync Gradle:**
   - Android Studio should automatically sync Gradle
   - If not, click "Sync Project with Gradle Files"

3. **Build the app:**
   - Build → Make Project
   - Or run on device/emulator: Run → Run 'app'

4. **Grant Required Permissions:**
   - Camera permission (for QR scanning)
   - Biometric permission (automatically granted)

### Enabling Autofill on Android

1. After installing the app, go to **Settings → System → Languages & input → Autofill service**
2. Select **SecureAuth**
3. The app will now provide 2FA codes when Android detects a 2FA input field

## Key Features Implemented

### ✅ iOS App Features
- SwiftUI-based modern interface
- FaceID/TouchID biometric authentication
- QR code scanning for easy account setup
- Manual account entry
- Real-time TOTP code generation
- Countdown timer with visual progress indicator
- Secure Keychain storage for secrets
- AutoFill Credential Provider Extension
- QuickType bar integration

### ✅ Android App Features
- Jetpack Compose modern UI
- Biometric authentication (fingerprint/face)
- QR code scanning with ML Kit
- Manual account entry
- Real-time TOTP code generation
- Countdown timer with visual progress
- EncryptedSharedPreferences for secure storage
- Autofill Service implementation
- Automatic 2FA field detection

## Technical Implementation Details

### TOTP Algorithm
Both apps implement the standard TOTP (RFC 6238) algorithm:
- Time-based (30-second windows by default)
- HMAC-SHA1 (most common, can be extended to SHA256/SHA512)
- 6-digit codes (configurable)
- Base32 secret key decoding

### Security Features

#### iOS
- **Keychain Storage**: All TOTP secrets stored in iOS Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- **Biometric Auth**: FaceID/TouchID required before accessing codes
- **App Group**: Secure sharing between main app and extension
- **No Cloud Backup**: Secrets stay on device only

#### Android
- **EncryptedSharedPreferences**: Uses AES256-GCM encryption with Android Keystore
- **Biometric Prompt**: Required before providing codes via autofill
- **Backup Exclusion**: Encrypted preferences excluded from backup
- **Secure by Default**: All cryptographic operations use Android security best practices

### Autofill Integration

#### iOS Credential Provider
- Implements `ASCredentialProviderViewController`
- Registers as a credential provider for one-time codes
- Integrates with iOS AutoFill framework
- Appears in QuickType bar above keyboard
- Requires biometric auth before providing codes

#### Android Autofill Service
- Implements `AutofillService`
- Detects 2FA fields using multiple heuristics:
  - Autofill hints (`oneTimeCode`, `smsOTPCode`)
  - Input type patterns
  - Text/hint content analysis (looking for "code", "otp", "verification")
- Provides codes via dropdown suggestions
- Respects Android autofill lifecycle

## Testing the Apps

### iOS Testing
1. Build and run on a device (AutoFill doesn't work in simulator)
2. Enable the app in Settings → Passwords
3. Add a test account (use a test 2FA service or create one)
4. Open Safari and navigate to a site with 2FA
5. When you reach the 2FA field, tap the QuickType suggestion
6. Authenticate with FaceID/TouchID
7. The code auto-fills

### Android Testing
1. Install on device or emulator
2. Enable in Settings → Autofill service
3. Add a test account
4. Open Chrome or any app with 2FA login
5. When you tap the 2FA field, you'll see autofill suggestions
6. Tap a suggestion to fill the code

## Adding Test Accounts

### Using QR Code
1. Open the app
2. Tap "Scan QR Code" (camera icon)
3. Grant camera permission
4. Scan a QR code from a service (Google, GitHub, etc.)

### Manual Entry
1. Tap "Add Account" (+ button)
2. Enter issuer name (e.g., "Google")
3. Enter account name (e.g., "user@gmail.com")
4. Enter the Base32 secret key
5. Tap "Add"

### Test Secret
For testing, you can use this test secret:
```
JBSWY3DPEHPK3PXP
```
This will generate valid TOTP codes that change every 30 seconds.

## Troubleshooting

### iOS Issues

**"AutoFill doesn't appear"**
- Make sure you're testing on a physical device (not simulator)
- Verify the extension is enabled in Settings → Passwords
- Check that the website has proper `autocomplete="one-time-code"` attributes

**"Keychain errors"**
- Enable Keychain Sharing capability
- Add an App Group and use it in both targets

### Android Issues

**"Autofill suggestions don't appear"**
- Verify the service is enabled in Settings
- Make sure the app has Autofill permission
- Test with different apps/browsers

**"Build errors"**
- Run `./gradlew clean build`
- Invalidate caches: File → Invalidate Caches / Restart

## Next Steps & Enhancements

### Suggested Improvements
1. **Cloud Sync**: Add encrypted cloud backup via iCloud/Google Drive
2. **Wear OS/watchOS**: Extend to smartwatches
3. **Browser Extensions**: Chrome/Safari extensions for desktop
4. **Export/Import**: Account backup and restore
5. **Dark Mode**: Enhanced theme support
6. **Widgets**: Home screen widgets showing codes
7. **Search**: Better search and organization
8. **Folders**: Organize accounts into categories
9. **Icons**: Service-specific icons for accounts
10. **Notifications**: Optional notifications before codes expire

### Security Enhancements
1. **PIN Fallback**: Allow PIN as alternative to biometrics
2. **Auto-lock**: Lock app after inactivity
3. **Screenshot Protection**: Prevent screenshots of codes
4. **Jailbreak/Root Detection**: Warn on compromised devices
5. **Rate Limiting**: Prevent brute force attacks

## License & Distribution

Before distributing these apps:

1. **Update Bundle IDs**: Change from example IDs to your own
2. **Code Signing**: Set up proper development/distribution certificates
3. **Privacy Policy**: Create privacy policy for App Store/Play Store
4. **App Store Submission**: Follow Apple/Google guidelines
5. **Testing**: Extensive testing on multiple devices and OS versions

## Support & Resources

- [Apple Credential Provider Documentation](https://developer.apple.com/documentation/authenticationservices/ascredentialproviderviewcontroller)
- [Android Autofill Framework](https://developer.android.com/guide/topics/text/autofill-services)
- [RFC 6238 - TOTP Specification](https://datatracker.ietf.org/doc/html/rfc6238)
- [TOTP Key URI Format](https://github.com/google/google-authenticator/wiki/Key-Uri-Format)

---

**Built with ❤️ following the original concept at https://github.com/Mattjhagen/OS-integrated-2FA.git**

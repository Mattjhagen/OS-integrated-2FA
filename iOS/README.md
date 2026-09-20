# SecureAuth iOS App

A SwiftUI-based iOS app that provides seamless OS-integrated autofill for TOTP 2FA codes.

## Features

- 🔐 **Biometric Authentication**: FaceID/TouchID protection
- 📱 **SwiftUI Interface**: Modern, native iOS design
- 📷 **QR Code Scanning**: Quick account setup
- ⌨️ **AutoFill Integration**: Codes appear in QuickType bar
- 🔒 **Keychain Storage**: Secure, encrypted secret storage
- ⏱️ **Real-time Codes**: Live countdown and code generation
- 🎯 **Zero Friction**: No app switching needed

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Setup Instructions

### 1. Create Xcode Project

1. Open Xcode
2. File → New → Project
3. Choose "iOS App"
4. Product Name: `SecureAuth`
5. Interface: SwiftUI
6. Language: Swift

### 2. Add Files

Copy all files from this directory into your Xcode project:
- `SecureAuthApp.swift` → Replace the default App file
- `ContentView.swift` → Replace the default ContentView
- Add `Models/`, `Services/`, `Views/` folders and their contents

### 3. Add Credential Provider Extension

1. File → New → Target
2. Choose "Credential Provider Extension"
3. Product Name: `SecureAuthExtension`
4. Add the extension files:
   - `CredentialProviderViewController.swift`
   - `Info.plist`

### 4. Configure Capabilities

In your main app target:
1. Signing & Capabilities → + Capability
2. Add "Keychain Sharing"
3. Add "App Groups"
   - Group: `group.com.yourcompany.SecureAuth`

Do the same for the extension target.

### 5. Share Code Between Targets

The following files need to be added to BOTH targets:
- `Models/TOTPAccount.swift`
- `Services/TOTPGenerator.swift`
- `Services/AccountManager.swift`
- `Services/KeychainService.swift`

To do this:
1. Select each file in Xcode
2. Open File Inspector (right panel)
3. Check both "SecureAuth" and "SecureAuthExtension" under Target Membership

### 6. Update Info.plist

The provided `Info.plist` includes required permissions:
- `NSCameraUsageDescription`: "We need camera access to scan QR codes for adding 2FA accounts"
- `NSFaceIDUsageDescription`: "We use Face ID to secure your 2FA codes"

### 7. Build Configuration

Update your bundle identifiers:
- Main app: `com.yourcompany.SecureAuth`
- Extension: `com.yourcompany.SecureAuth.Extension`

## Usage

### For Users

1. **Install the App**
   - Build and install on your device (AutoFill requires a physical device)

2. **Enable AutoFill**
   - Open Settings → Passwords → Password Options
   - Turn on "AutoFill Passwords"
   - Select "SecureAuth"

3. **Add Accounts**
   - Open SecureAuth app
   - Authenticate with FaceID/TouchID
   - Tap + to add account
   - Scan QR code or enter manually

4. **Use AutoFill**
   - Navigate to a website/app with 2FA
   - Tap the 2FA code field
   - Your code appears in the QuickType bar above the keyboard
   - Tap to autofill

### For Developers

#### TOTP Generation

```swift
import Foundation

// Generate a code
let code = TOTPGenerator.generateCode(
    secret: "JBSWY3DPEHPK3PXP",
    time: Date(),
    digits: 6,
    period: 30
)
print(code) // "123456"

// Parse otpauth:// URL
if let account = TOTPGenerator.parseOTPAuthURL(qrCodeString) {
    accountManager.addAccount(account)
}
```

#### Account Management

```swift
// Access the shared instance
let manager = AccountManager.shared

// Add account
let account = TOTPAccount(
    issuer: "Google",
    accountName: "user@gmail.com",
    secret: "JBSWY3DPEHPK3PXP"
)
manager.addAccount(account)

// Get current code
if let code = manager.getCode(for: account.id) {
    print("Current code: \(code)")
}

// Delete account
manager.deleteAccount(account)
```

#### Keychain Storage

```swift
let keychain = KeychainService()

// Save data
let data = "secret".data(using: .utf8)!
keychain.save(key: "mySecret", data: data)

// Load data
if let loadedData = keychain.load(key: "mySecret") {
    let string = String(data: loadedData, encoding: .utf8)
}

// Delete data
keychain.delete(key: "mySecret")
```

## Architecture

### Main App
```
SecureAuthApp
├── ContentView (Auth Gate)
│   ├── BiometricAuthView
│   └── AccountListView
│       ├── AccountRowView (with live codes)
│       ├── AddAccountView
│       └── QRScannerView
```

### Extension
```
CredentialProviderViewController
├── Biometric Authentication
├── Account Lookup
└── Code Generation
```

### Data Flow
```
User adds account → Encrypted in Keychain
User logs into website → iOS detects 2FA field
iOS calls extension → Extension authenticates user
Extension generates code → Returns to iOS
iOS displays in QuickType → User taps to fill
```

## Security

- **Keychain**: All secrets stored with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- **Biometric**: Required for both app access and AutoFill
- **No Cloud**: Secrets never leave the device
- **App Group**: Secure sharing between app and extension

## Testing

### Unit Tests

```swift
import XCTest
@testable import SecureAuth

class TOTPTests: XCTestCase {
    func testTOTPGeneration() {
        let secret = "JBSWY3DPEHPK3PXP"
        let code = TOTPGenerator.generateCode(secret: secret)
        XCTAssertEqual(code.count, 6)
        XCTAssertTrue(code.allSatisfy { $0.isNumber })
    }
    
    func testBase32Decode() {
        let input = "JBSWY3DPEHPK3PXP"
        let data = TOTPGenerator.base32Decode(input)
        XCTAssertNotNil(data)
    }
}
```

### Manual Testing

1. Use test secret: `JBSWY3DPEHPK3PXP`
2. Compare codes with [this online generator](https://totp.danhersam.com/)
3. Test QR scanning with test QR codes
4. Test AutoFill on real websites

## Known Limitations

- Requires iOS 16.0+ for best AutoFill experience
- Only works on physical devices (not simulator)
- Some websites may not properly support AutoFill
- Extension has memory constraints (keep data access efficient)

## Troubleshooting

### AutoFill Not Appearing
1. Check Settings → Passwords → ensure SecureAuth is enabled
2. Verify website uses `autocomplete="one-time-code"`
3. Test on a physical device, not simulator

### Biometric Authentication Fails
1. Check Face ID/Touch ID is set up on device
2. Grant biometric permissions when prompted
3. Test with Settings app first

### Build Errors
1. Ensure all files are added to correct targets
2. Check bundle identifiers are unique
3. Verify App Group is configured for both targets
4. Clean build folder (Shift + Cmd + K)

## Future Enhancements

- [ ] iCloud Keychain sync
- [ ] Apple Watch companion app
- [ ] Home screen widgets
- [ ] Siri shortcuts
- [ ] Account folders/categories
- [ ] Service icons
- [ ] Export/Import functionality
- [ ] Dark mode refinements

## Resources

- [Apple's AutoFill Documentation](https://developer.apple.com/documentation/authenticationservices/ascredentialproviderviewcontroller)
- [TOTP RFC 6238](https://datatracker.ietf.org/doc/html/rfc6238)
- [Key URI Format](https://github.com/google/google-authenticator/wiki/Key-Uri-Format)

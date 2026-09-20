# SecureAuth Android App

A Kotlin/Jetpack Compose Android app that provides seamless OS-integrated autofill for TOTP 2FA codes.

## Features

- 🔐 **Biometric Authentication**: Fingerprint/face unlock
- 🎨 **Jetpack Compose UI**: Modern Material Design 3
- 📷 **ML Kit QR Scanner**: Fast and accurate scanning
- ⌨️ **Autofill Integration**: Automatic 2FA code detection
- 🔒 **Encrypted Storage**: EncryptedSharedPreferences
- ⏱️ **Real-time Codes**: Live countdown and generation
- 🌙 **Dynamic Theming**: Material You support

## Requirements

- Android Studio Ladybug or later
- Minimum SDK: API 26 (Android 8.0)
- Target SDK: API 35 (Android 15)
- Kotlin 2.1.0+

## Setup Instructions

### 1. Open in Android Studio

```bash
cd Android
# Open Android Studio and select this directory
# Or from command line:
studio .
```

### 2. Sync Gradle

Android Studio will automatically prompt to sync Gradle. If not:
- File → Sync Project with Gradle Files

### 3. Build the App

```bash
# From command line
./gradlew assembleDebug

# Or in Android Studio
Build → Make Project
```

### 4. Run on Device/Emulator

```bash
# From command line
./gradlew installDebug

# Or in Android Studio
Run → Run 'app'
```

## Project Structure

```
app/src/main/
├── AndroidManifest.xml
├── java/com/secureauth/
│   ├── MainActivity.kt
│   ├── models/
│   │   └── TOTPAccount.kt          # Data model
│   ├── services/
│   │   ├── AccountManager.kt        # Account management
│   │   └── SecureAuthAutofillService.kt  # Autofill service
│   ├── ui/
│   │   ├── SecureAuthApp.kt         # App entry point
│   │   ├── screens/
│   │   │   ├── BiometricAuthScreen.kt
│   │   │   ├── AccountListScreen.kt
│   │   │   ├── AddAccountDialog.kt
│   │   │   └── QRScannerScreen.kt
│   │   └── theme/
│   │       ├── Theme.kt             # Material 3 theme
│   │       └── Type.kt              # Typography
│   └── utils/
│       └── TOTPGenerator.kt         # TOTP algorithm
└── res/
    ├── values/strings.xml
    └── xml/
        ├── autofill_service_config.xml
        ├── backup_rules.xml
        └── data_extraction_rules.xml
```

## Usage

### For Users

1. **Install the App**
   ```bash
   ./gradlew installDebug
   ```

2. **Enable Autofill Service**
   - Open Settings → System → Languages & input → Autofill service
   - Select "SecureAuth"
   - Grant necessary permissions

3. **Add Accounts**
   - Open SecureAuth app
   - Authenticate with biometric
   - Tap + FAB to add account
   - Scan QR code or enter manually

4. **Use Autofill**
   - Open any app/browser with 2FA
   - Tap the 2FA code field
   - Select a code from the autofill dropdown
   - Code automatically fills

### For Developers

#### Dependencies

```kotlin
// Jetpack Compose
implementation("androidx.compose.ui:ui")
implementation("androidx.compose.material3:material3")
implementation("androidx.navigation:navigation-compose:2.8.5")

// Security
implementation("androidx.biometric:biometric:1.2.0-alpha05")
implementation("androidx.security:security-crypto:1.1.0-alpha06")

// Camera & ML Kit
implementation("com.google.mlkit:barcode-scanning:17.3.0")
implementation("androidx.camera:camera-camera2:1.4.1")
implementation("androidx.camera:camera-lifecycle:1.4.1")

// JSON
implementation("com.google.code.gson:gson:2.11.0")
```

#### TOTP Generation

```kotlin
import com.secureauth.utils.TOTPGenerator

// Generate a code
val code = TOTPGenerator.generateCode(
    secret = "JBSWY3DPEHPK3PXP",
    time = System.currentTimeMillis() / 1000,
    digits = 6,
    period = 30
)
println("Code: $code") // "123456"

// Parse otpauth:// URL from QR code
val account = TOTPGenerator.parseOTPAuthURL(qrCodeData)
if (account != null) {
    accountManager.addAccount(account)
}
```

#### Account Management

```kotlin
// Get singleton instance
val accountManager = AccountManager.getInstance(context)

// Observe accounts (Flow)
accountManager.accounts.collect { accounts ->
    // Update UI
}

// Add account
val account = TOTPAccount(
    issuer = "Google",
    accountName = "user@gmail.com",
    secret = "JBSWY3DPEHPK3PXP"
)
accountManager.addAccount(account)

// Get current code for account
val code = accountManager.getCode(account.id)

// Delete account
accountManager.deleteAccount(account)
```

#### Autofill Service

```kotlin
class SecureAuthAutofillService : AutofillService() {
    override fun onFillRequest(
        request: FillRequest,
        cancellationSignal: CancellationSignal,
        callback: FillCallback
    ) {
        // 1. Parse the screen structure
        val autofillFields = findAutofillFields(structure)
        
        // 2. Get TOTP codes
        val codes = accountManager.getAllCodes()
        
        // 3. Build autofill response
        val datasets = codes.map { (label, code) ->
            Dataset.Builder()
                .setValue(fieldId, AutofillValue.forText(code), remoteViews)
                .build()
        }
        
        // 4. Send to system
        callback.onSuccess(responseBuilder.build())
    }
}
```

## Architecture

### UI Layer (Compose)
```
SecureAuthApp
├── BiometricAuthScreen (Entry point)
└── AccountListScreen
    ├── EmptyAccountsView
    ├── AccountCard (with live TOTP)
    ├── AddAccountDialog
    └── QRScannerScreen
```

### Service Layer
```
AccountManager (Singleton)
├── Encrypted Storage (EncryptedSharedPreferences)
├── StateFlow<List<Account>>
└── TOTP Generation

SecureAuthAutofillService
├── Field Detection
├── Dataset Creation
└── Autofill Response
```

### Data Flow
```
User adds account → Encrypted in storage
User opens app with 2FA → Android detects field
System calls autofill service → Service retrieves accounts
Service generates codes → Returns datasets
User selects code → Auto-fills into field
```

## Security

### Storage
- **EncryptedSharedPreferences**: AES256-GCM encryption
- **Android Keystore**: Hardware-backed key storage
- **No Cloud Backup**: Encrypted prefs excluded from backup

### Authentication
- **Biometric Prompt**: Required before app access
- **Autofill Gating**: Codes only provided after auth
- **Device Lock**: Respects device security settings

### Permissions
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

## Testing

### Unit Tests

```kotlin
class TOTPGeneratorTest {
    @Test
    fun testCodeGeneration() {
        val secret = "JBSWY3DPEHPK3PXP"
        val code = TOTPGenerator.generateCode(secret)
        
        assertEquals(6, code.length)
        assertTrue(code.all { it.isDigit() })
    }
    
    @Test
    fun testBase32Decode() {
        val decoded = TOTPGenerator.base32Decode("JBSWY3DPEHPK3PXP")
        assertNotNull(decoded)
    }
    
    @Test
    fun testOTPAuthParsing() {
        val url = "otpauth://totp/Google:user@gmail.com?secret=JBSWY3DPEHPK3PXP&issuer=Google"
        val account = TOTPGenerator.parseOTPAuthURL(url)
        
        assertNotNull(account)
        assertEquals("Google", account?.issuer)
        assertEquals("user@gmail.com", account?.accountName)
    }
}
```

### Instrumented Tests

```kotlin
@RunWith(AndroidJUnit4::class)
class AccountManagerTest {
    @Test
    fun testAddAndRetrieveAccount() {
        val context = InstrumentationRegistry.getInstrumentation().targetContext
        val manager = AccountManager.getInstance(context)
        
        val account = TOTPAccount(
            issuer = "Test",
            accountName = "test@example.com",
            secret = "JBSWY3DPEHPK3PXP"
        )
        
        manager.addAccount(account)
        
        runBlocking {
            manager.accounts.first { it.isNotEmpty() }.let { accounts ->
                assertTrue(accounts.any { it.id == account.id })
            }
        }
    }
}
```

### Manual Testing

1. Use test secret: `JBSWY3DPEHPK3PXP`
2. Compare with [online TOTP generator](https://totp.danhersam.com/)
3. Test autofill with real apps (Chrome, etc.)
4. Test QR scanning with test codes

## Building Release APK

### 1. Generate Keystore

```bash
keytool -genkey -v -keystore secureauth-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias secureauth
```

### 2. Configure signing in `app/build.gradle.kts`

```kotlin
android {
    signingConfigs {
        create("release") {
            storeFile = file("../secureauth-release.jks")
            storePassword = "your_keystore_password"
            keyAlias = "secureauth"
            keyPassword = "your_key_password"
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

### 3. Build Release APK

```bash
./gradlew assembleRelease
```

APK will be in: `app/build/outputs/apk/release/app-release.apk`

## Troubleshooting

### Autofill Not Working
1. Verify service is enabled in Settings
2. Check permissions are granted
3. Test with different apps (Chrome, Twitter, etc.)
4. Look for autofill hints in the input fields

### Build Errors
```bash
# Clean and rebuild
./gradlew clean
./gradlew build

# Invalidate caches in Android Studio
File → Invalidate Caches / Restart
```

### Camera Not Working
1. Check `AndroidManifest.xml` has camera permission
2. Grant permission when prompted
3. Test on physical device (some emulators lack camera)

### Biometric Not Available
1. Ensure device has biometric hardware
2. Set up fingerprint/face in device Settings
3. Test with other biometric apps first

## Known Limitations

- Autofill detection depends on app/website properly using autofill hints
- Some apps may not trigger autofill for 2FA fields
- QR scanning requires good lighting and camera focus
- Emulators may have limited biometric simulation

## Future Enhancements

- [ ] Wear OS companion app
- [ ] Cloud backup (encrypted)
- [ ] Account folders/categories
- [ ] Service icons/logos
- [ ] Export/Import accounts
- [ ] Home screen widgets
- [ ] Quick settings tile
- [ ] Backup to Google Drive
- [ ] Account search improvements
- [ ] Multi-window support

## Resources

- [Android Autofill Framework](https://developer.android.com/guide/topics/text/autofill-services)
- [Jetpack Compose](https://developer.android.com/jetpack/compose)
- [ML Kit Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning)
- [TOTP RFC 6238](https://datatracker.ietf.org/doc/html/rfc6238)
- [EncryptedSharedPreferences](https://developer.android.com/reference/androidx/security/crypto/EncryptedSharedPreferences)

## License

See main repository LICENSE file.

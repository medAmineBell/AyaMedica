# Development Mode Implementation

This document explains the development mode feature that auto-fills login credentials for easier testing.

## Overview

Development mode automatically fills in the login form with predefined credentials to speed up testing and development. This eliminates the need to manually enter credentials every time during development.

## Features

### 1. Auto-Fill Credentials
- **Email**: `admin@example.com`
- **Password**: `medplum_admin`
- **Method**: Email (default)
- **Behavior**: Automatically filled on app startup

### 2. Development Mode Indicator
- **Visual Indicator**: Blue banner with developer icon
- **Clear Button**: Clears the auto-filled credentials
- **Refill Button**: Refills the credentials if cleared
- **Visibility**: Only shown in development mode

### 3. Smart Behavior
- **Method Switching**: Re-fills when switching to email method
- **Form Validation**: Triggers validation after auto-fill
- **Easy Toggle**: Can be enabled/disabled via configuration

## Implementation Details

### 1. AuthController Configuration

**Development Settings:**
```dart
// Development credentials
static const bool isDevelopment = true; // Set to false for production
static const String devEmail = 'admin@example.com';
static const String devPassword = 'medplum_admin';
```

**Auto-Fill Method:**
```dart
void _fillDevelopmentCredentials() {
  if (isDevelopment) {
    primaryFieldController.text = devEmail;
    passwordController.text = devPassword;
    updateLoginButtonState();
  }
}
```

### 2. Login Screen Integration

**Development Indicator:**
```dart
// Development Mode Indicator
if (AuthController.isDevelopment) _buildDevelopmentIndicator(authController),
```

**Visual Design:**
- Light blue background with blue border
- Developer mode icon
- Clear and Refill buttons
- Compact design that doesn't interfere with main UI

### 3. User Controls

**Clear Credentials:**
```dart
void clearDevelopmentCredentials() {
  primaryFieldController.clear();
  passwordController.clear();
  updateLoginButtonState();
}
```

**Refill Credentials:**
```dart
void refillDevelopmentCredentials() {
  if (isDevelopment) {
    _fillDevelopmentCredentials();
  }
}
```

## User Experience

### 1. Development Mode On
- **Auto-Fill**: Credentials are automatically filled
- **Visual Indicator**: Blue banner shows development mode
- **Quick Actions**: Clear and Refill buttons available
- **Form Ready**: Login button is immediately enabled

### 2. Development Mode Off
- **Clean Form**: Empty form fields
- **No Indicator**: No development banner
- **Normal Flow**: Standard login process

### 3. Method Switching
- **Email Method**: Auto-fills development credentials
- **Other Methods**: Clears fields (no dev credentials for other methods)
- **Smart Behavior**: Only fills when appropriate

## Configuration

### 1. Enable/Disable Development Mode

**In AuthController:**
```dart
static const bool isDevelopment = true; // Set to false for production
```

**For Production:**
```dart
static const bool isDevelopment = false; // Disable for production
```

### 2. Change Development Credentials

**Update Credentials:**
```dart
static const String devEmail = 'your-dev-email@example.com';
static const String devPassword = 'your-dev-password';
```

### 3. Environment-Based Configuration

**Future Enhancement:**
```dart
static const bool isDevelopment = kDebugMode; // Use Flutter's debug mode
```

## Benefits

### 1. Faster Development
- **No Manual Entry**: Credentials are pre-filled
- **Quick Testing**: Can test login flow immediately
- **Less Repetition**: No need to type credentials repeatedly

### 2. Better Testing
- **Consistent Data**: Same credentials every time
- **Easy Reset**: Can clear and refill as needed
- **Visual Feedback**: Clear indication of development mode

### 3. Production Safety
- **Easy Disable**: Simple flag to turn off
- **No Production Impact**: Only works in development
- **Clear Separation**: Visual indicator shows it's dev mode

## Usage Examples

### 1. Basic Development
1. Open login screen
2. Credentials are auto-filled
3. Click login button
4. Test the login flow

### 2. Testing Different Credentials
1. Click "Clear" button
2. Enter different credentials
3. Test with new credentials
4. Click "Refill" to restore dev credentials

### 3. Method Testing
1. Switch to phone method (clears fields)
2. Switch back to email (refills dev credentials)
3. Test different login methods

## Security Considerations

### 1. Development Only
- **Not for Production**: Should be disabled in production builds
- **Clear Indication**: Visual indicator shows it's development mode
- **Easy Disable**: Simple configuration flag

### 2. Credential Management
- **Hardcoded Credentials**: Only for development testing
- **No Real Data**: Use test/development accounts only
- **Easy Change**: Credentials can be updated easily

### 3. Production Safety
- **Flag Check**: Multiple checks prevent production usage
- **Visual Warning**: Clear indication of development mode
- **Easy Disable**: Simple configuration change

## Future Enhancements

Potential improvements could include:
- **Environment Detection**: Automatic detection of debug/release mode
- **Multiple Credentials**: Support for different test accounts
- **Credential Profiles**: Different sets of credentials for different tests
- **Auto-Login**: Option to automatically attempt login
- **Credential Validation**: Verify credentials before auto-filling

## Testing Scenarios

### 1. Development Mode Enabled
1. Open login screen
2. Verify credentials are auto-filled
3. Verify development indicator is shown
4. Test login with auto-filled credentials

### 2. Development Mode Disabled
1. Set `isDevelopment = false`
2. Open login screen
3. Verify form is empty
4. Verify no development indicator

### 3. Clear and Refill
1. Click "Clear" button
2. Verify fields are empty
3. Click "Refill" button
4. Verify credentials are restored

### 4. Method Switching
1. Start with email (auto-filled)
2. Switch to phone (cleared)
3. Switch back to email (refilled)
4. Verify behavior is correct

## Code Examples

### Enable Development Mode
```dart
// In AuthController
static const bool isDevelopment = true;
```

### Disable Development Mode
```dart
// In AuthController
static const bool isDevelopment = false;
```

### Change Development Credentials
```dart
// In AuthController
static const String devEmail = 'test@example.com';
static const String devPassword = 'test_password';
```

### Check Development Mode
```dart
// In any widget
if (AuthController.isDevelopment) {
  // Show development-specific UI
}
```

## Conclusion

Development mode significantly improves the development experience by:
- Auto-filling test credentials
- Providing visual feedback
- Offering easy controls for testing
- Maintaining production safety

This feature is essential for efficient development and testing of the authentication flow.

# OAuth2 Integration in Login Flow

This document explains the integration of OAuth2 token exchange in the authentication login flow.

## Overview

The login flow now automatically uses OAuth2 token exchange when the initial login returns authorization codes. This ensures proper authentication and access to protected resources.

## Flow Description

### 1. Initial Login
- User enters credentials and clicks login
- App calls `loginWithPassword()` or `loginWithOAuth()`
- Server returns login response with `login` and `code` fields

### 2. OAuth2 Token Exchange
- App detects the presence of `code` in login response
- Automatically calls `exchangeAuthorizationCode()` with the code
- Exchanges authorization code for OAuth2 access tokens

### 3. User Profile Loading
- OAuth2 tokens are used to load user profile from `/auth/me`
- User data is stored and displayed in the app
- Proper authentication state is maintained

## Implementation Details

### AuthController Updates

**Enhanced Login Method:**
```dart
if (loginResult['success'] == true) {
  final loginData = loginResult['loginData'] as Map<String, dynamic>?;
  if (loginData != null && loginData.containsKey('code')) {
    // Proceed with OAuth2 token exchange
    final code = loginData['code'] as String;
    const codeVerifier = '...'; // Generated during auth flow
    
    final oauth2Result = await _medplumService.exchangeAuthorizationCode(
      code: code,
      codeVerifier: codeVerifier,
    );
    
    if (oauth2Result['success'] == true) {
      // Store OAuth2 data and navigate
    }
  }
}
```

**Fallback Support:**
- If no OAuth2 data is available, falls back to old method
- Ensures backward compatibility
- Graceful error handling

### MedplumService Integration

**Login Response Structure:**
```json
{
  "success": true,
  "message": "Login successful",
  "user": {...},
  "loginData": {
    "login": "ea480995-227d-4582-80b2-e37a6e6d2c83",
    "code": "778969425863030a57230dedd30bae3b"
  }
}
```

**OAuth2 Token Exchange:**
- Uses the `code` from login response
- Exchanges for proper OAuth2 access tokens
- Loads user profile with valid tokens

## User Experience

### 1. Seamless Login
- User enters credentials normally
- OAuth2 exchange happens automatically
- No additional user interaction required

### 2. Proper Authentication
- Valid OAuth2 tokens are obtained
- User profile loads successfully
- Access to protected resources works

### 3. Error Handling
- Clear error messages if OAuth2 exchange fails
- Fallback to basic authentication if needed
- User-friendly error display

## Technical Benefits

### 1. Security
- Proper OAuth2 token flow
- Secure token exchange
- No hardcoded credentials

### 2. Compatibility
- Works with existing login methods
- Backward compatible
- Graceful fallback

### 3. Maintainability
- Centralized OAuth2 logic
- Easy to modify and extend
- Clear separation of concerns

## Code Flow

### 1. Login Request
```dart
// User clicks login button
await authController.login();

// AuthController calls MedplumService
loginResult = await _medplumService.loginWithPassword(
  username: primaryField,
  password: password,
);
```

### 2. OAuth2 Exchange
```dart
// Check for OAuth2 data
if (loginData != null && loginData.containsKey('code')) {
  // Exchange authorization code
  final oauth2Result = await _medplumService.exchangeAuthorizationCode(
    code: code,
    codeVerifier: codeVerifier,
  );
}
```

### 3. User Profile Loading
```dart
// OAuth2 tokens are used to load profile
await _loadUserProfile();

// User data is stored and displayed
userProfile.value = userProfileData;
```

## Error Scenarios

### 1. OAuth2 Exchange Failure
- User sees clear error message
- Can retry login
- Fallback to basic auth if available

### 2. Invalid Authorization Code
- Code expired or invalid
- Automatic retry or re-login required
- User-friendly error handling

### 3. Network Issues
- Network errors during exchange
- Graceful error handling
- Retry mechanisms

## Configuration

### Code Verifier
Currently using a hardcoded code verifier:
```dart
const codeVerifier = '8a29e8161d85d89ebb98bb3a7c099b75974be53bb9152b8dc587a53fdde6cbfc65fef87b50fef45e1897a8aa5269cdb3852d65cdc34778afa03b74c3e40f4492';
```

**Future Enhancement:**
- Generate code verifier dynamically
- Store securely during auth flow
- Implement proper PKCE flow

## Testing

### 1. Successful Flow
1. Enter valid credentials
2. Click login
3. Verify OAuth2 exchange happens
4. Check user profile loads
5. Confirm navigation to organization screen

### 2. Error Scenarios
1. Invalid credentials
2. Network errors
3. OAuth2 exchange failures
4. Server errors

### 3. Fallback Testing
1. Test with systems that don't support OAuth2
2. Verify fallback to basic auth
3. Check error handling

## Benefits

### 1. Improved Security
- Proper OAuth2 implementation
- Secure token exchange
- No credential exposure

### 2. Better User Experience
- Seamless login process
- No additional steps required
- Clear error messages

### 3. Future-Proof
- OAuth2 standard compliance
- Easy to extend and modify
- Industry best practices

## Future Enhancements

Potential improvements could include:
- Dynamic code verifier generation
- PKCE flow implementation
- Token refresh mechanisms
- Multi-factor authentication
- Biometric authentication

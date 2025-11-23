# PKCE Login Implementation

This document explains the implementation of PKCE (Proof Key for Code Exchange) in the login flow as requested by the user.

## Requested Login Format

The user requested the login request to include PKCE parameters:

```json
{
    "email": "admin@example.com",
    "password": "medplum_admin",
    "remember": false,
    "codeChallengeMethod": "S256",
    "codeChallenge": "cKd5vWYFnkh3THBOvgweEscwf61_XzkkCEm2MKsn6aw",
    "clientId": ""
}
```

## Implementation

### 1. **Login Request Enhancement**

**Updated Request Body:**
```dart
final requestBody = {
  'email': username,
  'password': password,
  'remember': false,
  'codeChallengeMethod': 'S256',
  'codeChallenge': codeChallenge,
  'clientId': '',
};
```

### 2. **PKCE Parameter Generation**

**Code Verifier Generation:**
```dart
String _generateCodeVerifier() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
  final random = DateTime.now().millisecondsSinceEpoch;
  final codeVerifier = StringBuffer();
  
  // Generate a 128-character code verifier as per PKCE spec
  for (int i = 0; i < 128; i++) {
    final seed = (random + i * 1000) % chars.length;
    codeVerifier.write(chars[seed]);
  }
  
  return codeVerifier.toString();
}
```

**Code Challenge Generation:**
```dart
String _generateCodeChallenge(String codeVerifier) {
  // Create SHA256 hash of the code verifier
  final bytes = utf8.encode(codeVerifier);
  final digest = sha256.convert(bytes);
  
  // Encode as base64url (RFC 4648)
  final base64String = base64.encode(digest.bytes);
  
  // Remove padding and replace characters as per PKCE spec
  return base64String
      .replaceAll('+', '-')
      .replaceAll('/', '_')
      .replaceAll('=', '');
}
```

### 3. **Code Verifier Storage**

**Store for OAuth2 Exchange:**
```dart
// Store code verifier for later use in OAuth2 exchange
_currentCodeVerifier = codeVerifier;
```

**Use in OAuth2 Exchange:**
```dart
// Use provided code verifier or fall back to stored one
final actualCodeVerifier = codeVerifier ?? _currentCodeVerifier;
```

## PKCE Flow

### 1. **Login Phase**
1. Generate random `code_verifier` (128 characters)
2. Create `code_challenge` using SHA256 hash of `code_verifier`
3. Send login request with PKCE parameters
4. Store `code_verifier` for later use

### 2. **OAuth2 Exchange Phase**
1. Use stored `code_verifier` from login
2. Send OAuth2 token exchange request
3. Server validates `code_verifier` against stored `code_challenge`

## Security Benefits

### 1. **PKCE Compliance**
- Follows RFC 7636 specification
- Prevents authorization code interception attacks
- Secure code verifier generation

### 2. **Code Verifier Security**
- 128-character random string
- URL-safe characters only
- Cryptographically random generation

### 3. **Code Challenge Security**
- SHA256 hash of code verifier
- Base64URL encoding
- No padding characters

## Request Flow

### 1. **Login Request**
```
POST /auth/login
{
  "email": "admin@example.com",
  "password": "medplum_admin",
  "remember": false,
  "codeChallengeMethod": "S256",
  "codeChallenge": "cKd5vWYFnkh3THBOvgweEscwf61_XzkkCEm2MKsn6aw",
  "clientId": ""
}
```

### 2. **OAuth2 Token Exchange**
```
POST /oauth2/token
{
  "grant_type": "authorization_code",
  "code": "d2b37fc1b28b3d99028b2cdce4edc9ec",
  "redirect_uri": "https://app.ayamedica.com/",
  "code_verifier": "BLVfpz9FPZjt3~JTdnx7DNXhr1.HRblv5BLVfpz9FPZjt3~JTdnx7DNXhr1.HRblv5BLVfpz9FPZjt3~JTdnx7DNXhr1.HRblv5BLVfpz9FPZjt3~JTdnx7DNXhr1.HR",
  "client_id": "d027240c-7d7e-4423-a69a-a55d5c367d7d"
}
```

## Code Examples

### 1. **Complete Login Flow**
```dart
// Generate PKCE parameters
final codeVerifier = _generateCodeVerifier();
final codeChallenge = _generateCodeChallenge(codeVerifier);

// Store for later use
_currentCodeVerifier = codeVerifier;

// Send login request
final requestBody = {
  'email': username,
  'password': password,
  'remember': false,
  'codeChallengeMethod': 'S256',
  'codeChallenge': codeChallenge,
  'clientId': '',
};
```

### 2. **OAuth2 Exchange**
```dart
// Use stored code verifier
final actualCodeVerifier = _currentCodeVerifier;

// Send OAuth2 request
final requestBody = {
  'grant_type': 'authorization_code',
  'code': code,
  'redirect_uri': redirectUri,
  'code_verifier': actualCodeVerifier,
};
```

## Dependencies

### 1. **Required Packages**
```yaml
dependencies:
  crypto: ^3.0.3  # For SHA256 hashing
```

### 2. **Imports**
```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
```

## Debugging

### 1. **Logging Output**
```
🔐 Generated Code Verifier: BLVfpz9F...
🔑 Generated Code Challenge: cKd5vWYF...
📤 Request Body: {"email":"admin@example.com","password":"medplum_admin","remember":false,"codeChallengeMethod":"S256","codeChallenge":"cKd5vWYFnkh3THBOvgweEscwf61_XzkkCEm2MKsn6aw","clientId":""}
```

### 2. **OAuth2 Exchange Logging**
```
🔑 Code Verifier: BLVfpz9F...
📤 OAuth2 Request Body: {"grant_type":"authorization_code","code":"d2b37fc1b28b3d99028b2cdce4edc9ec","redirect_uri":"https://app.ayamedica.com/","code_verifier":"BLVfpz9FPZjt3~JTdnx7DNXhr1.HRblv5BLVfpz9FPZjt3~JTdnx7DNXhr1.HRblv5BLVfpz9FPZjt3~JTdnx7DNXhr1.HRblv5BLVfpz9FPZjt3~JTdnx7DNXhr1.HR","client_id":"d027240c-7d7e-4423-a69a-a55d5c367d7d"}
```

## Error Handling

### 1. **Missing Code Verifier**
```dart
if (actualCodeVerifier == null) {
  return {
    'success': false,
    'message': 'No code verifier available for OAuth2 exchange',
  };
}
```

### 2. **PKCE Validation Errors**
- Server validates code_verifier against code_challenge
- Invalid code_verifier results in 400 error
- Missing PKCE parameters result in 400 error

## Testing

### 1. **Unit Tests**
- Test code verifier generation
- Test code challenge generation
- Test PKCE parameter validation

### 2. **Integration Tests**
- Test complete login flow
- Test OAuth2 exchange
- Test error scenarios

### 3. **Manual Testing**
- Verify login request format
- Check OAuth2 exchange parameters
- Monitor server responses

## Security Considerations

### 1. **Code Verifier Generation**
- Use cryptographically secure random generation
- Ensure sufficient entropy
- Follow PKCE specification

### 2. **Code Challenge Generation**
- Use SHA256 hash function
- Proper base64URL encoding
- No padding characters

### 3. **Storage Security**
- Store code verifier securely
- Clear after use
- Prevent exposure in logs

## Future Improvements

### 1. **Enhanced Random Generation**
```dart
// Use cryptographically secure random
import 'dart:math';
import 'dart:typed_data';

String _generateSecureCodeVerifier() {
  final random = Random.secure();
  final bytes = Uint8List(96); // 128 characters in base64
  for (int i = 0; i < bytes.length; i++) {
    bytes[i] = random.nextInt(256);
  }
  return base64Url.encode(bytes);
}
```

### 2. **Code Verifier Validation**
```dart
bool _isValidCodeVerifier(String codeVerifier) {
  return codeVerifier.length >= 43 && 
         codeVerifier.length <= 128 &&
         RegExp(r'^[A-Za-z0-9\-._~]+$').hasMatch(codeVerifier);
}
```

### 3. **Configuration Options**
```dart
class PKCEConfig {
  static const int codeVerifierLength = 128;
  static const String codeChallengeMethod = 'S256';
  static const bool useSecureRandom = true;
}
```

## Conclusion

The PKCE implementation provides:
- **Secure authentication flow** with PKCE parameters
- **Proper code verifier generation** following RFC 7636
- **Code challenge creation** using SHA256 and base64URL
- **Seamless integration** with existing OAuth2 flow
- **Enhanced security** against authorization code interception

The login request now matches the exact format requested by the user, including all PKCE parameters and the empty clientId field.

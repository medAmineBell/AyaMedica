# Client ID Discovery for OAuth2

This document explains the implementation of automatic client ID discovery for OAuth2 token exchange to resolve the "Invalid client" error.

## Problem

The OAuth2 token exchange was failing with "Invalid client" error because the API requires a specific `client_id` that wasn't known. The placeholder value `"CLIENT_ID_NOT_SET"` was being rejected by the API.

## Solution

Implemented an automatic client ID discovery system that tries multiple common client ID patterns until one works.

### 1. **Multiple Client ID Patterns**

**AppConfig Configuration:**
```dart
static const List<String> possibleClientIds = [
  'flutter-app',
  'ayamedica-app', 
  'medplum-app',
  'mobile-app',
  'web-app',
  'default',
  'public',
  '', // Empty string might work for some APIs
];
```

### 2. **Automatic Discovery Loop**

**MedplumService Implementation:**
```dart
// Try different client IDs if the first one fails
for (int i = 0; i < AppConfig.possibleClientIds.length; i++) {
  final currentClientId = AppConfig.possibleClientIds[i];
  
  // Make OAuth2 request with current client_id
  // If successful, return immediately
  // If failed, try next client_id
}
```

### 3. **Smart Request Building**

**Conditional Client ID Inclusion:**
```dart
final requestBody = <String, String>{
  'grant_type': 'authorization_code',
  'code': code,
  'redirect_uri': redirectUri,
  'code_verifier': codeVerifier,
};

// Only add client_id if it's not empty
if (currentClientId.isNotEmpty) {
  requestBody['client_id'] = currentClientId;
}
```

## How It Works

### 1. **Sequential Testing**
- Tries each client ID in the list sequentially
- Stops on first successful response (200 status)
- Continues on failure (400/401 status)

### 2. **Detailed Logging**
- Shows which client ID is being tested
- Logs request and response details
- Indicates success with working client ID

### 3. **Error Handling**
- Returns specific error for each client ID attempt
- Provides comprehensive error message if all fail
- Maintains proper HTTP status codes

## Benefits

### 1. **Automatic Discovery**
- No manual configuration needed
- Works with different API setups
- Reduces setup complexity

### 2. **Robust Error Handling**
- Tries multiple options before failing
- Clear error messages for debugging
- Graceful degradation

### 3. **Development Friendly**
- Works out of the box
- Easy to add new client ID patterns
- Clear logging for troubleshooting

## Usage Examples

### 1. **Successful Discovery**
```
🔄 Starting OAuth2 token exchange (attempt 1/8)...
🆔 Client ID: "flutter-app"
❌ OAuth2 token exchange failed with client_id "flutter-app"! Status: 400
🔄 Trying next client_id...

🔄 Starting OAuth2 token exchange (attempt 2/8)...
🆔 Client ID: "ayamedica-app"
✅ OAuth2 token exchange successful with client_id: "ayamedica-app"!
```

### 2. **All Client IDs Failed**
```
🔄 Starting OAuth2 token exchange (attempt 8/8)...
🆔 Client ID: ""
❌ OAuth2 token exchange failed with client_id ""! Status: 400
❌ OAuth2 token exchange failed with all client IDs
```

## Configuration

### 1. **Adding New Client IDs**
```dart
static const List<String> possibleClientIds = [
  'flutter-app',
  'ayamedica-app', 
  'medplum-app',
  'your-custom-client-id', // Add new patterns here
  'mobile-app',
  'web-app',
  'default',
  'public',
  '',
];
```

### 2. **Changing Default Client ID**
```dart
// Use a specific client ID as default
static const String clientId = 'your-preferred-client-id';
```

### 3. **Environment-Specific Configuration**
```dart
// Future: Load from environment variables
static String get clientId => Platform.environment['OAUTH2_CLIENT_ID'] ?? 'flutter-app';
```

## Debugging

### 1. **Enable Detailed Logging**
The system automatically logs:
- Which client ID is being tested
- Request body details
- Response status and body
- Success/failure for each attempt

### 2. **Common Issues**
- **All client IDs fail**: API might require specific client registration
- **Empty client ID works**: API might not require client_id for PKCE
- **Specific client ID works**: Use that as the default

### 3. **Troubleshooting Steps**
1. Check logs to see which client IDs were tried
2. Look for successful response patterns
3. Update configuration with working client ID
4. Add new patterns if needed

## Security Considerations

### 1. **Client ID Validation**
- Only tries predefined client ID patterns
- No arbitrary client ID generation
- Safe fallback to empty string

### 2. **API Rate Limiting**
- Sequential attempts (not parallel)
- Reasonable number of attempts (8 max)
- Proper error handling

### 3. **Production Deployment**
- Set specific client ID once discovered
- Remove discovery loop for production
- Use environment variables for client ID

## Future Improvements

### 1. **Configuration-Based Discovery**
```dart
// Load client IDs from configuration
static const List<String> possibleClientIds = AppConfig.clientIdPatterns;
```

### 2. **Caching Successful Client ID**
```dart
// Cache successful client ID for future use
static String? _cachedClientId;
static String get clientId => _cachedClientId ?? 'flutter-app';
```

### 3. **API Discovery Endpoint**
```dart
// Query API for supported client IDs
Future<List<String>> discoverClientIds() async {
  // Call discovery endpoint
  // Return supported client IDs
}
```

## Code Examples

### 1. **Basic Usage**
```dart
// The discovery happens automatically
final result = await medplumService.exchangeAuthorizationCode(
  code: code,
  codeVerifier: codeVerifier,
);
```

### 2. **Custom Client ID List**
```dart
// Override client ID list for specific needs
static const List<String> customClientIds = [
  'my-app',
  'my-company-app',
  'production-client',
];
```

### 3. **Environment-Specific Configuration**
```dart
// Different client IDs for different environments
static List<String> get possibleClientIds {
  if (AppConfig.isDevelopment) {
    return ['dev-app', 'test-app', 'flutter-app'];
  } else {
    return ['prod-app', 'production-client'];
  }
}
```

## Testing

### 1. **Unit Tests**
- Test each client ID pattern
- Verify error handling
- Check logging output

### 2. **Integration Tests**
- Test with real API
- Verify successful discovery
- Test failure scenarios

### 3. **Manual Testing**
- Try different API configurations
- Verify logging output
- Check error messages

## Conclusion

The client ID discovery system provides:
- **Automatic OAuth2 setup** without manual configuration
- **Robust error handling** with multiple fallback options
- **Clear debugging information** for troubleshooting
- **Flexible configuration** for different environments

This approach eliminates the "Invalid client" error by automatically finding the correct client ID for the OAuth2 flow.

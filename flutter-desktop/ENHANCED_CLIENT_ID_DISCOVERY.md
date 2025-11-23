# Enhanced Client ID Discovery

This document explains the enhanced client ID discovery system that now includes login ID extraction and additional client ID patterns.

## Problem Analysis

From the terminal output, we can see that:
1. All standard client ID patterns failed with "Invalid client"
2. Empty client ID failed with "Missing verification context"
3. The login response contains a `login` field that might be the required client ID

## Enhanced Solution

### 1. **Login ID Integration**

**Extract Login ID from Response:**
```dart
// In AuthController
final loginId = loginData['login'] as String?;
print('🔍 AuthController: Login ID from response: $loginId');
```

**Use Login ID as Primary Client ID:**
```dart
// In MedplumService
if (loginId != null && loginId.isNotEmpty) {
  allPossibleClientIds.insert(0, loginId); // Try login ID first
  print('🔍 Added login ID as potential client_id: $loginId');
}
```

### 2. **Expanded Client ID Patterns**

**Additional Patterns Added:**
```dart
static const List<String> possibleClientIds = [
  // Original patterns
  'flutter-app', 'ayamedica-app', 'medplum-app',
  'mobile-app', 'web-app', 'default', 'public',
  
  // New patterns
  'app', 'client', 'oauth2-client', 'medplum-client',
  'ayamedica-client', 'flutter-client', 'mobile-client',
  'web-client', 'test-client', 'demo-client',
  'dev-client', 'prod-client',
  
  // Simplified patterns
  'medplum', 'ayamedica', 'flutter',
  'app-client', 'oauth-client', 'pkce-client',
  'authorization-code-client',
  
  '', // Empty string for APIs that don't require client_id
];
```

### 3. **Priority Order**

**Discovery Priority:**
1. **Login ID** (from login response) - Highest priority
2. **Standard patterns** (flutter-app, ayamedica-app, etc.)
3. **Generic patterns** (app, client, oauth2-client, etc.)
4. **Simplified patterns** (medplum, ayamedica, flutter)
5. **Empty string** (for APIs that don't require client_id)

## How It Works

### 1. **Login ID Extraction**
```
Login Response: {"login":"d027240c-7d7e-4423-a69a-a55d5c367d7d","code":"d2b37fc1..."}
Extracted Login ID: d027240c-7d7e-4423-a69a-a55d5c367d7d
```

### 2. **Enhanced Discovery Loop**
```
Attempt 1: "d027240c-7d7e-4423-a69a-a55d5c367d7d" (Login ID)
Attempt 2: "flutter-app"
Attempt 3: "ayamedica-app"
...
Attempt 20: "" (Empty string)
```

### 3. **Detailed Logging**
```
🔍 AuthController: Login ID from response: d027240c-7d7e-4423-a69a-a55d5c367d7d
🔍 Added login ID as potential client_id: d027240c-7d7e-4423-a69a-a55d5c367d7d
🔄 Starting OAuth2 token exchange (attempt 1/20)...
🆔 Client ID: "d027240c-7d7e-4423-a69a-a55d5c367d7d"
```

## Expected Behavior

### 1. **Login ID Success**
If the login ID works as client_id:
```
✅ OAuth2 token exchange successful with client_id: "d027240c-7d7e-4423-a69a-a55d5c367d7d"!
```

### 2. **Pattern Success**
If a standard pattern works:
```
✅ OAuth2 token exchange successful with client_id: "ayamedica-app"!
```

### 3. **All Patterns Fail**
If no pattern works:
```
❌ OAuth2 token exchange failed with all client IDs
```

## Benefits

### 1. **Higher Success Rate**
- Login ID is most likely to work
- More patterns to try
- Better coverage of API requirements

### 2. **API-Specific Discovery**
- Uses actual login response data
- Adapts to different API implementations
- Reduces guesswork

### 3. **Comprehensive Coverage**
- 20 different client ID patterns
- Covers common naming conventions
- Includes edge cases

## Debugging Information

### 1. **Login ID Extraction**
```
🔍 AuthController: Login ID from response: d027240c-7d7e-4423-a69a-a55d5c367d7d
```

### 2. **Client ID Addition**
```
🔍 Added login ID as potential client_id: d027240c-7d7e-4423-a69a-a55d5c367d7d
```

### 3. **Attempt Logging**
```
🔄 Starting OAuth2 token exchange (attempt 1/20)...
🆔 Client ID: "d027240c-7d7e-4423-a69a-a55d5c367d7d"
```

## Configuration

### 1. **Adding More Patterns**
```dart
static const List<String> possibleClientIds = [
  // Existing patterns...
  'your-custom-pattern',
  'api-specific-client',
  'another-pattern',
];
```

### 2. **Changing Priority**
```dart
// Move specific pattern to front
allPossibleClientIds.insert(0, 'your-preferred-client-id');
```

### 3. **Disabling Login ID**
```dart
// Don't use login ID as client_id
// Comment out or remove the login ID insertion
```

## Testing Scenarios

### 1. **Login ID Works**
- Should succeed on first attempt
- Login ID becomes the client_id
- Fastest resolution

### 2. **Standard Pattern Works**
- Should succeed on second or later attempt
- Standard pattern becomes the client_id
- Good fallback

### 3. **All Patterns Fail**
- Should try all 20 patterns
- Return comprehensive error
- Indicates API configuration issue

## Error Handling

### 1. **Invalid Client Error**
```
❌ OAuth2 token exchange failed with client_id "pattern"! Status: 400
🔄 Trying next client_id...
```

### 2. **Missing Verification Context**
```
❌ OAuth2 token exchange failed with client_id ""! Status: 400
❌ OAuth2 token exchange failed with all client IDs
```

### 3. **Network Errors**
```
💥 Exception during OAuth2 token exchange: [error details]
```

## Future Improvements

### 1. **API Discovery**
```dart
// Query API for supported client IDs
Future<List<String>> discoverSupportedClientIds() async {
  // Call discovery endpoint
  // Return supported client IDs
}
```

### 2. **Caching**
```dart
// Cache successful client ID
static String? _cachedClientId;
static String get clientId => _cachedClientId ?? 'flutter-app';
```

### 3. **Configuration File**
```dart
// Load client IDs from configuration file
static List<String> get possibleClientIds => 
  loadClientIdsFromConfig() ?? defaultClientIds;
```

## Conclusion

The enhanced client ID discovery system provides:
- **Higher success rate** with login ID integration
- **Comprehensive coverage** with 20+ patterns
- **Better debugging** with detailed logging
- **API-specific adaptation** using actual response data

This should resolve the OAuth2 client ID issues by trying the most likely candidates first and providing comprehensive fallback options.

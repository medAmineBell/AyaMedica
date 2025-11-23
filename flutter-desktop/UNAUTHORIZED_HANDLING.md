# Unauthorized (401) Handling Implementation

This document explains the implementation of automatic logout and dialog display when the API returns a 401 Unauthorized response.

## Overview

The app now automatically handles 401 Unauthorized responses by:
1. Detecting 401 status codes from API calls
2. Automatically logging out the user
3. Clearing all authentication data
4. Showing a user-friendly dialog explaining the session expiration
5. Redirecting to the login screen

## Implementation Details

### 1. MedplumService Updates

**New Methods Added:**
- `_handleUnauthorized()` - Handles the 401 response
- `_showUnauthorizedDialog()` - Shows the session expired dialog

**API Methods Updated:**
- `_loadUserProfile()` - Now handles 401 responses
- `_loadCurrentUser()` - Now handles 401 responses  
- `exchangeAuthorizationCode()` - Now handles 401 responses

### 2. 401 Detection

The service now checks for 401 status codes in all API responses:

```dart
if (response.statusCode == 200) {
  // Handle success
} else if (response.statusCode == 401) {
  print('🔒 Unauthorized (401) - Token expired or invalid');
  await _handleUnauthorized();
} else {
  // Handle other errors
}
```

### 3. Automatic Logout

When a 401 is detected:
1. All authentication data is cleared
2. User session is invalidated
3. Access tokens are removed
4. User profile data is cleared

### 4. User Dialog

A professional dialog is shown to inform the user:

**Dialog Features:**
- **Title**: "Session Expired" with security icon
- **Message**: Clear explanation of what happened
- **Action**: "Login Again" button
- **Styling**: Consistent with app design
- **Behavior**: Non-dismissible (user must click button)

## User Experience

### 1. Session Expiration Detection
- User is using the app normally
- API call returns 401 (token expired)
- App automatically detects the 401

### 2. Automatic Logout
- All user data is cleared
- Authentication state is reset
- User is logged out silently

### 3. Dialog Display
- Professional dialog appears
- Clear explanation of session expiration
- Single action button to login again

### 4. Navigation
- User clicks "Login Again"
- Dialog closes
- User is redirected to login screen
- Fresh login required

## Technical Details

### Dialog Implementation

```dart
void _showUnauthorizedDialog() {
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE6E6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.security,
              color: Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Session Expired'),
        ],
      ),
      content: const Text(
        'Your session has expired. Please log in again to continue.',
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back();
            Get.offAllNamed(Routes.LOGIN);
          },
          child: const Text('Login Again'),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}
```

### Error Handling

**Comprehensive Coverage:**
- User profile loading
- Current user data fetching
- OAuth2 token exchange
- Any future API calls

**Graceful Degradation:**
- Errors are logged for debugging
- User experience remains smooth
- No app crashes or freezes

## Security Benefits

### 1. Automatic Session Management
- Expired tokens are immediately detected
- User data is automatically cleared
- No stale authentication data remains

### 2. User Awareness
- Clear communication about session status
- No confusion about why login is required
- Professional error handling

### 3. Data Protection
- Sensitive data is cleared on 401
- Prevents unauthorized access attempts
- Maintains security best practices

## Error Scenarios Handled

### 1. Token Expiration
- Access token expires during app usage
- API calls return 401
- Automatic logout and dialog

### 2. Invalid Tokens
- Corrupted or invalid access tokens
- Server rejects the token
- User is prompted to login again

### 3. Server Authentication Issues
- Server-side authentication problems
- Temporary authentication failures
- Graceful error handling

## Testing Scenarios

### 1. Token Expiration
1. Login to the app
2. Wait for token to expire (or manually expire)
3. Perform any action that calls API
4. Verify 401 handling and dialog

### 2. Invalid Token
1. Manually corrupt the stored token
2. Perform any action that calls API
3. Verify 401 handling and dialog

### 3. Network Issues
1. Simulate network problems
2. Verify error handling
3. Ensure app doesn't crash

## Future Enhancements

Potential improvements could include:
- Token refresh mechanism
- Background token validation
- Proactive session management
- Custom retry logic
- Offline mode handling

## Benefits

### 1. Improved Security
- Automatic detection of expired sessions
- Immediate cleanup of sensitive data
- Prevention of unauthorized access

### 2. Better User Experience
- Clear communication about session status
- Professional error handling
- Smooth transition to login

### 3. Robust Error Handling
- Comprehensive 401 detection
- Graceful degradation
- No app crashes or freezes

### 4. Maintainability
- Centralized error handling
- Consistent user experience
- Easy to extend and modify

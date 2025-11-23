# UserCard Update - Real User Data Integration

This document explains the updates made to the UserCard to display real user information from the authentication system.

## Overview

The UserCard has been updated to display actual user data from the MedplumService instead of hardcoded values. The card now shows the authenticated user's name, email, and initials dynamically.

## Changes Made

### 1. BranchSelectionController Updates

**New Imports:**
- `MedplumService` - For accessing user profile data
- `UserProfile` model - For type-safe user data handling

**New Properties:**
- `isLoadingUser` - Observable boolean for loading state
- `_medplumService` - Service instance for data access

**New Methods:**
- `_loadUserData()` - Loads user data from MedplumService
- `_getUserName()` - Extracts full name from user profile
- `_getInitials()` - Generates initials from user name

### 2. UserCard Widget Updates

**Loading States:**
- Added loading skeleton for user info
- Added loading spinner for user avatar
- Smooth transition from loading to loaded state

**Data Display:**
- **Name**: Extracted from user profile (given + family name)
- **Email**: User's email address as identifier
- **Initials**: Auto-generated from user's name

## User Data Flow

### 1. Initialization
```dart
@override
void onInit() {
  super.onInit();
  _loadUserData(); // Load user data on controller init
}
```

### 2. Data Loading
```dart
Future<void> _loadUserData() async {
  try {
    isLoadingUser.value = true;
    final userProfile = await _medplumService.getCurrentUserProfile();
    
    if (userProfile != null) {
      // Extract and set user data
      final userName = _getUserName(userProfile);
      final userEmail = userProfile.user.email;
      final initials = _getInitials(userName);
      
      user.value = UserModel(
        name: userName,
        aid: userEmail,
        initials: initials,
      );
    }
  } finally {
    isLoadingUser.value = false;
  }
}
```

### 3. UI Updates
- **Loading State**: Shows skeleton placeholders and spinner
- **Loaded State**: Displays actual user information
- **Error State**: Falls back to default values

## Data Sources

### User Profile Structure
The user data comes from the `/auth/me` endpoint response:

```json
{
  "user": {
    "email": "admin@example.com"
  },
  "profile": {
    "name": [
      {
        "given": ["Medplum"],
        "family": "Admin"
      }
    ]
  }
}
```

### Data Extraction
- **Full Name**: `profile.name[0].given.join(' ') + ' ' + profile.name[0].family`
- **Email**: `user.email`
- **Initials**: First letter of first two words in name

## UI Features

### Loading States
- **Avatar**: Circular progress indicator
- **Name**: Skeleton placeholder (120px width)
- **Email**: Skeleton placeholder (80px width)

### Visual Design
- Maintains existing blue color scheme
- Smooth loading transitions
- Consistent typography (IBM Plex Sans Arabic)
- Responsive layout

## Error Handling

### Fallback Values
If user data cannot be loaded:
- **Name**: "User"
- **Email**: "Error loading profile" or "No profile available"
- **Initials**: "U"

### Error Scenarios
1. **No Authentication**: Shows default values
2. **API Error**: Shows error message in email field
3. **Network Error**: Graceful fallback to defaults

## Benefits

### 1. Dynamic Data
- Real user information instead of hardcoded values
- Updates automatically when user profile changes
- Consistent with authentication state

### 2. Better UX
- Loading states provide visual feedback
- Smooth transitions between states
- Clear error handling

### 3. Maintainability
- Centralized user data management
- Type-safe data handling
- Easy to extend with additional user fields

## Future Enhancements

Potential improvements could include:
- User profile picture support
- Role-based information display
- Real-time profile updates
- User preferences integration
- Multi-language support for names

## Testing

The updated UserCard can be tested by:
1. Logging in with valid credentials
2. Navigating to BranchSelectionScreen
3. Verifying user data loads correctly
4. Testing loading states
5. Testing error scenarios (no internet, invalid auth)

## Code Examples

### Accessing User Data
```dart
// Get current user data
final userData = controller.user.value;
print('Name: ${userData.name}');
print('Email: ${userData.aid}');
print('Initials: ${userData.initials}');
```

### Checking Loading State
```dart
// Check if user data is loading
if (controller.isLoadingUser.value) {
  // Show loading UI
} else {
  // Show user data
}
```

### Manual Refresh
```dart
// Reload user data
await controller._loadUserData();
```

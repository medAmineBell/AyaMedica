# Branch Selection Flow Implementation

This document explains the implementation of the branch selection flow that prevents users from accessing the home screen without selecting a branch first.

## Overview

The app now enforces branch selection as a mandatory step after login. Users must select a branch before they can access the home screen. This ensures proper organization context for all subsequent operations.

## Flow Logic

### 1. Splash Screen Navigation
After the splash screen, the app checks:
1. **Onboarding Status** → Navigate to onboarding if not completed
2. **Location Permission** → Navigate to location permission if not granted
3. **Notification Permission** → Navigate to notification permission if not granted
4. **Login Status** → Navigate to login if not authenticated
5. **Branch Selection** → Navigate to branch selection if not selected
6. **Home Screen** → Navigate to home if all conditions are met

### 2. Login Flow
After successful login (both regular and OAuth2):
- User is redirected to **BranchSelectionScreen** (not home)
- User must select a branch to proceed
- Only after branch selection can user access home screen

### 3. Branch Selection
When user selects a branch:
- Branch data is saved to storage
- Branch selection status is marked as true
- User is redirected to home screen
- Success message is shown

### 4. Logout Flow
When user logs out:
- Branch selection data is cleared
- User is redirected to login screen
- Next login will require branch selection again

## Implementation Details

### Storage Service Updates

**New Methods Added:**
```dart
// Branch Selection Status
bool getBranchSelectedStatus() => _box.read('branchSelected') ?? false;
Future<void> saveBranchSelectedStatus(bool status) => _box.write('branchSelected', status);
Future<void> clearBranchSelectedStatus() => _box.remove('branchSelected');

// Selected Branch Data
Map<String, dynamic>? getSelectedBranchData() => _box.read('selectedBranchData');
Future<void> saveSelectedBranchData(Map<String, dynamic> branchData) => _box.write('selectedBranchData', branchData);
Future<void> clearSelectedBranchData() => _box.remove('selectedBranchData');
```

### Splash Controller Updates

**Navigation Logic:**
```dart
if (isLoggedIn) {
  final bool branchSelected = _storageService.getBranchSelectedStatus();
  
  if (branchSelected) {
    Get.offAllNamed(Routes.HOME);
  } else {
    Get.offAllNamed(Routes.ORGANISATION);
  }
} else {
  Get.offAllNamed(Routes.LOGIN);
}
```

### Branch Selection Controller Updates

**Branch Selection Method:**
```dart
void selectBranch(BranchModel branch) async {
  // Save branch selection
  await _storageService.saveBranchSelectedStatus(true);
  await _storageService.saveSelectedBranchData({
    'name': branch.name,
    'role': branch.role,
    'icon': branch.icon,
    'selected_at': DateTime.now().toIso8601String(),
  });
  
  // Navigate to home
  Get.offAllNamed(Routes.HOME);
}
```

**Logout Method:**
```dart
Future<void> logout() async {
  // Clear branch selection data
  await _storageService.clearBranchSelectedStatus();
  await _storageService.clearSelectedBranchData();
  
  // Call auth controller logout
  await authController.logout();
}
```

### Auth Controller Updates

**Login Navigation:**
- Both regular login and OAuth2 login now navigate to `Routes.ORGANISATION`
- Users must select a branch before accessing home screen

## User Experience

### 1. First Time Login
1. User logs in successfully
2. Redirected to BranchSelectionScreen
3. User selects a branch
4. Redirected to home screen
5. Future app launches go directly to home

### 2. Subsequent Launches
1. App checks if user is logged in
2. If logged in, checks if branch is selected
3. If branch selected → Home screen
4. If no branch selected → BranchSelectionScreen

### 3. Logout and Re-login
1. User logs out (clears branch selection)
2. User logs in again
3. Must select branch again
4. Then can access home screen

## Data Persistence

### Branch Selection Data
```json
{
  "branchSelected": true,
  "selectedBranchData": {
    "name": "Riyadh School | Clinic",
    "role": "Branch Admin",
    "icon": "clinic",
    "selected_at": "2025-01-17T10:30:00.000Z"
  }
}
```

### Storage Keys
- `branchSelected` - Boolean indicating if branch is selected
- `selectedBranchData` - Object containing branch details
- `isLoggedIn` - Boolean indicating login status

## Error Handling

### Branch Selection Errors
- API errors during branch selection
- Storage errors when saving branch data
- Navigation errors

### Fallback Behavior
- If branch selection fails, user stays on BranchSelectionScreen
- Error message is displayed to user
- User can retry branch selection

## Benefits

### 1. Enforced Organization Context
- Users must select their working branch
- All operations are performed in correct organizational context
- Prevents data confusion across branches

### 2. Better User Experience
- Clear flow from login to branch selection to home
- Visual feedback during branch selection
- Success messages confirm actions

### 3. Data Integrity
- Branch selection is persisted across app sessions
- Logout clears branch selection for security
- Re-login requires fresh branch selection

## Testing Scenarios

### 1. Fresh Install
1. Install app
2. Complete onboarding
3. Grant permissions
4. Login
5. Select branch
6. Access home screen

### 2. App Restart
1. Login and select branch
2. Close app
3. Reopen app
4. Should go directly to home screen

### 3. Logout and Re-login
1. Login and select branch
2. Logout
3. Login again
4. Must select branch again

### 4. Error Scenarios
1. Network error during branch selection
2. Storage error when saving branch data
3. Navigation error after branch selection

## Future Enhancements

Potential improvements could include:
- Branch switching without logout
- Multiple branch support
- Branch-specific user preferences
- Branch selection validation
- Offline branch selection support

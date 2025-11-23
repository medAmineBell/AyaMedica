# Logout Implementation for BranchSelectionScreen

This document explains the logout functionality added to the BranchSelectionScreen.

## Overview

The logout functionality has been added to the BranchSelectionScreen to allow users to sign out of their account. The logout button is integrated into the user card widget for easy access.

## Implementation Details

### Files Modified

1. **`lib/controllers/branch_selection_controller.dart`**
   - Added import for `AuthController`
   - Added `logout()` method that calls the auth controller's logout method
   - Added proper error handling with user feedback

2. **`lib/screens/organisation/widgets/user_card.dart`**
   - Added logout button to the user card
   - Added confirmation dialog for logout action
   - Added tooltip for better UX
   - Styled the logout button to match the design

### Features

#### Logout Button
- **Location**: Right side of the user card
- **Design**: Circular button with logout icon
- **Color**: Semi-transparent white background with white icon
- **Tooltip**: Shows "Logout" on hover
- **Size**: 32x32 pixels

#### Confirmation Dialog
- **Title**: "Logout" with logout icon
- **Content**: Clear explanation of what will happen
- **Actions**: 
  - Cancel button (grey text)
  - Logout button (red background)
- **Styling**: Rounded corners, proper spacing, consistent typography

#### Error Handling
- Catches and displays any errors during logout
- Shows error message in a snackbar
- Uses red background for error messages

## Usage

### User Flow
1. User clicks the logout button in the user card
2. Confirmation dialog appears
3. User can either:
   - Click "Cancel" to dismiss the dialog
   - Click "Logout" to proceed with logout
4. If logout is successful, user is redirected to login screen
5. If logout fails, error message is displayed

### Code Usage
```dart
// The logout functionality is automatically available in BranchSelectionScreen
// No additional code is needed - just click the logout button in the user card
```

## Technical Details

### Controller Integration
```dart
// BranchSelectionController.logout()
Future<void> logout() async {
  try {
    final AuthController authController = Get.find<AuthController>();
    await authController.logout();
  } catch (e) {
    // Error handling with user feedback
  }
}
```

### UI Components
- **Logout Button**: `_buildLogoutButton()` method
- **Confirmation Dialog**: `_showLogoutDialog()` method
- **Tooltip**: Added for better accessibility

### Styling
- Uses IBM Plex Sans Arabic font family
- Consistent with existing design system
- Proper color scheme (red for logout actions)
- Responsive design with proper spacing

## Security Considerations

- Confirmation dialog prevents accidental logouts
- Proper error handling prevents app crashes
- Logout clears all authentication data
- User is redirected to login screen after logout

## Testing

The logout functionality can be tested by:
1. Navigating to the BranchSelectionScreen
2. Clicking the logout button in the user card
3. Verifying the confirmation dialog appears
4. Testing both cancel and logout actions
5. Verifying redirect to login screen after logout

## Future Enhancements

Potential improvements could include:
- Loading state during logout process
- Remember me functionality
- Session timeout handling
- Multiple device logout
- Logout confirmation with password

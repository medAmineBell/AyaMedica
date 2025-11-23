# OAuth2 Implementation for Ayamedica API

This document explains the OAuth2 implementation for the Ayamedica API integration in the Flutter desktop application.

## Overview

The implementation includes:
- OAuth2 token exchange using authorization code
- User profile retrieval from `/auth/me` endpoint
- Proper error handling and logging
- Data models for OAuth2 response and user profile

## Files Added/Modified

### New Files
- `lib/models/oauth2_response.dart` - OAuth2 response data model
- `lib/models/user_profile.dart` - User profile data model
- `lib/screens/auth/oauth2_test_screen.dart` - Test screen for OAuth2 flow

### Modified Files
- `lib/utils/medplum_service.dart` - Added OAuth2 methods
- `lib/controllers/auth_controller.dart` - Added OAuth2 token exchange method
- `lib/routes/app_pages.dart` - Added OAuth2 test route
- `lib/routes/app_routes.dart` - Added OAuth2 test route constant

## API Endpoints

### OAuth2 Token Exchange
- **URL**: `https://api.ayamedica.com/oauth2/token`
- **Method**: POST
- **Content-Type**: `application/x-www-form-urlencoded`

**Request Body:**
```
grant_type=authorization_code
code=e352fe0b46d842b5b1c9c98ab314d99a
client_id=your-client-id
redirect_uri=https://app.ayamedica.com/
code_verifier=8a29e8161d85d89ebb98bb3a7c099b75974be53bb9152b8dc587a53fdde6cbfc65fef87b50fef45e1897a8aa5269cdb3852d65cdc34778afa03b74c3e40f4492
```

**Response:**
```json
{
    "token_type": "Bearer",
    "expires_in": 3600,
    "scope": "openid",
    "id_token": "...",
    "access_token": "...",
    "project": {
        "reference": "Project/14dc5772-42c9-4217-9261-2578b0a0d911",
        "display": "Super Admin"
    },
    "profile": {
        "reference": "Practitioner/8c4830cf-4e87-448b-980d-cdc200698b71",
        "display": "Medplum Admin"
    },
    "smart_style_url": "https://api.ayamedica.comfhir/R4/.well-known/smart-styles.json",
    "need_patient_banner": false
}
```

### User Profile
- **URL**: `https://api.ayamedica.com/auth/me`
- **Method**: GET
- **Headers**: `Authorization: Bearer {access_token}`

**Response:**
```json
{
    "user": {
        "resourceType": "User",
        "id": "9efa16bb-1c0b-4861-8b42-14a0a03e211f",
        "email": "admin@example.com"
    },
    "project": {
        "resourceType": "Project",
        "id": "14dc5772-42c9-4217-9261-2578b0a0d911",
        "name": "Super Admin",
        "strictMode": true,
        "superAdmin": true
    },
    "membership": {
        "resourceType": "ProjectMembership",
        "id": "0b2d8dd6-e2d7-4aac-a316-9c8a4f69556f",
        "user": {
            "reference": "User/9efa16bb-1c0b-4861-8b42-14a0a03e211f",
            "display": "admin@example.com"
        },
        "profile": {
            "reference": "Practitioner/8c4830cf-4e87-448b-980d-cdc200698b71",
            "display": "Medplum Admin"
        },
        "admin": true
    },
    "profile": {
        "resourceType": "Practitioner",
        "meta": {
            "project": "14dc5772-42c9-4217-9261-2578b0a0d911",
            "versionId": "f7744fd2-d958-409e-b70a-27ec6f7bcd45",
            "lastUpdated": "2025-09-14T17:58:10.135Z",
            "author": {
                "reference": "system"
            },
            "compartment": [
                {
                    "reference": "Project/14dc5772-42c9-4217-9261-2578b0a0d911"
                }
            ]
        },
        "name": [
            {
                "given": [
                    "Medplum"
                ],
                "family": "Admin"
            }
        ],
        "telecom": [
            {
                "system": "email",
                "use": "work",
                "value": "admin@example.com"
            }
        ],
        "id": "8c4830cf-4e87-448b-980d-cdc200698b71"
    },
    "config": {
        "resourceType": "UserConfiguration",
        "menu": [...]
    },
    "accessPolicy": {
        "resourceType": "AccessPolicy",
        "basedOn": [],
        "resource": [...]
    },
    "security": {
        "mfaEnrolled": false,
        "sessions": [...]
    }
}
```

## Usage

### 1. OAuth2 Token Exchange

```dart
// Get the AuthController
final AuthController authController = Get.find<AuthController>();

// Exchange authorization code for OAuth2 tokens
await authController.exchangeOAuth2Token(
  code: 'e352fe0b46d842b5b1c9c98ab314d99a',
  codeVerifier: '8a29e8161d85d89ebb98bb3a7c099b75974be53bb9152b8dc587a53fdde6cbfc65fef87b50fef45e1897a8aa5269cdb3852d65cdc34778afa03b74c3e40f4492',
);
```

### 2. Using MedplumService Directly

```dart
// Get the MedplumService
final MedplumService medplumService = Get.find<MedplumService>();

// Exchange authorization code
final result = await medplumService.exchangeAuthorizationCode(
  code: 'e352fe0b46d842b5b1c9c98ab314d99a',
  codeVerifier: '8a29e8161d85d89ebb98bb3a7c099b75974be53bb9152b8dc587a53fdde6cbfc65fef87b50fef45e1897a8aa5269cdb3852d65cdc34778afa03b74c3e40f4492',
);

if (result['success'] == true) {
  // OAuth2 token exchange successful
  final oauth2Response = result['oauth2Response'] as OAuth2Response;
  final userProfile = result['userProfile'] as UserProfile;
  
  // Use the data
  print('Access Token: ${oauth2Response.accessToken}');
  print('User Email: ${userProfile.user.email}');
  print('Project Name: ${userProfile.project.name}');
}
```

### 3. Test Screen

Navigate to `/oauth2-test` to access the test screen that demonstrates the OAuth2 flow with the provided data.

## Configuration

Update the following constants in `lib/utils/medplum_service.dart`:

```dart
static const String clientId = 'your-actual-client-id';
static const String clientSecret = 'your-actual-client-secret';
```

## Error Handling

The implementation includes comprehensive error handling:
- Network errors
- HTTP status code errors
- JSON parsing errors
- OAuth2 specific errors

All errors are logged with detailed information for debugging.

## Data Storage

The OAuth2 response and user profile data are stored in the app's storage service:
- Access token is stored securely
- OAuth2 response is stored for future use
- User profile data is cached for quick access

## Security Notes

- Access tokens are stored securely using the app's storage service
- Code verifiers are handled securely during the OAuth2 flow
- All API requests use HTTPS
- Sensitive data is not logged in production

## Testing

Use the test screen at `/oauth2-test` to test the OAuth2 flow with the provided sample data. The screen includes:
- Display of test data
- Buttons to trigger OAuth2 flow
- Expected flow explanation
- Error handling demonstration

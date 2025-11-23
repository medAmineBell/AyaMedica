# Branch Selection Server Integration

This document explains the server integration for the BranchSelectionController using the FHIR Organization API.

## Overview

The BranchSelectionController has been updated to fetch organizations from the Ayamedica FHIR API instead of using hardcoded data.

## API Integration

### 1. **FHIR Organization Endpoint**
```
GET https://api.ayamedica.com/fhir/R4/Organization
```

**Query Parameters:**
- `_count`: 20 (number of results)
- `_sort`: -_lastUpdated (sort by last updated, newest first)
- `_total`: accurate (include total count)

**Headers:**
```
Authorization: Bearer {access_token}
Accept: application/json
Content-Type: application/json
```

### 2. **API Response Structure**
```json
{
  "resourceType": "Bundle",
  "type": "searchset",
  "entry": [
    {
      "fullUrl": "https://api.ayamedica.com/fhir/R4/Organization/2cddf900-96e6-4703-8664-0a317ddc23e5",
      "search": {
        "mode": "match"
      },
      "resource": {
        "resourceType": "Organization",
        "active": true,
        "type": [
          {
            "coding": [
              {
                "system": "http://terminology.hl7.org/CodeSystem/organization-type",
                "code": "edu",
                "display": "Educational Institute"
              }
            ]
          },
          {
            "coding": [
              {
                "code": "Branch",
                "display": "Branch"
              }
            ]
          }
        ],
        "name": "Test School First Branch",
        "partOf": {
          "reference": "Organization/1b091cd6-e882-4ca8-ade5-e457181f763e",
          "display": "School Test"
        },
        "id": "2cddf900-96e6-4703-8664-0a317ddc23e5",
        "meta": {
          "versionId": "0abcc97b-482e-4814-a148-00a83e8196f6",
          "lastUpdated": "2025-09-17T19:33:00.733Z",
          "author": {
            "reference": "Practitioner/8c4830cf-4e87-448b-980d-cdc200698b71",
            "display": "Medplum Admin"
          },
          "project": "14dc5772-42c9-4217-9261-2578b0a0d911",
          "compartment": [
            {
              "reference": "Project/14dc5772-42c9-4217-9261-2578b0a0d911"
            }
          ]
        }
      }
    }
  ],
  "total": 4
}
```

## Implementation Details

### 1. **FHIR Models** (`lib/models/fhir_organization.dart`)

**Created comprehensive FHIR models:**
- `FhirBundle` - Main response container
- `FhirEntry` - Individual organization entry
- `FhirOrganization` - Organization resource
- `FhirOrganizationType` - Organization type information
- `FhirCoding` - Coding system values
- `FhirReference` - Reference to other resources
- `FhirMeta` - Metadata information
- `FhirTelecom` - Contact information
- `FhirAddress` - Address information
- `FhirLink` - Pagination links

### 2. **MedplumService Integration** (`lib/utils/medplum_service.dart`)

**Added fetchOrganizations method:**
```dart
Future<Map<String, dynamic>> fetchOrganizations({
  int count = 20,
  String sort = '-_lastUpdated',
  String total = 'accurate',
}) async {
  // Build query parameters
  final queryParams = {
    '_count': count.toString(),
    '_sort': sort,
    '_total': total,
  };
  
  final uri = Uri.parse('$baseUrl/fhir/R4/Organization').replace(
    queryParameters: queryParams,
  );
  
  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer ${accessToken.value}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );
  
  // Parse response and return organizations
}
```

**Added organizations observable:**
```dart
final Rx<List<FhirOrganization>> organizations = Rx<List<FhirOrganization>>([]);
```

### 3. **BranchModel Enhancement** (`lib/models/branch_model.dart`)

**Added factory method to convert FHIR Organization to BranchModel:**
```dart
factory BranchModel.fromFhirOrganization(dynamic fhirOrg) {
  // Extract organization type/role
  String role = 'Organization';
  if (fhirOrg.type != null && fhirOrg.type.isNotEmpty) {
    for (var orgType in fhirOrg.type) {
      if (orgType.coding.isNotEmpty) {
        for (var coding in orgType.coding) {
          if (coding.code == 'Branch') {
            role = 'Branch';
            break;
          } else if (coding.display.isNotEmpty) {
            role = coding.display;
          }
        }
      }
    }
  }

  // Extract contact information
  String? phone;
  String? email;
  if (fhirOrg.telecom != null) {
    for (var telecom in fhirOrg.telecom) {
      if (telecom.system == 'phone') {
        phone = telecom.value;
      } else if (telecom.system == 'email') {
        email = telecom.value;
      }
    }
  }

  // Extract address
  String? address;
  if (fhirOrg.address != null && fhirOrg.address.isNotEmpty) {
    final addr = fhirOrg.address.first;
    if (addr.line.isNotEmpty) {
      address = addr.line.join(', ');
    }
  }

  // Determine icon based on organization type
  String icon = 'organization';
  if (role.toLowerCase().contains('branch')) {
    icon = 'clinic';
  } else if (role.toLowerCase().contains('school') || role.toLowerCase().contains('educational')) {
    icon = 'school';
  }

  return BranchModel(
    id: fhirOrg.id,
    name: fhirOrg.name,
    role: role,
    icon: icon,
    address: address,
    phone: phone,
    email: email,
    status: fhirOrg.active ? 'active' : 'inactive',
    createdAt: fhirOrg.meta.lastUpdated != null 
        ? DateTime.tryParse(fhirOrg.meta.lastUpdated) 
        : null,
    updatedAt: fhirOrg.meta.lastUpdated != null 
        ? DateTime.tryParse(fhirOrg.meta.lastUpdated) 
        : null,
  );
}
```

### 4. **BranchSelectionController Updates** (`lib/controllers/branch_selection_controller.dart`)

**Updated initialization:**
```dart
@override
void onInit() {
  super.onInit();
  _loadUserData();
  _loadBranches(); // Load from server
}
```

**Added server data loading:**
```dart
Future<void> _loadBranches() async {
  try {
    isLoadingBranches.value = true;
    
    // Fetch organizations from MedplumService
    final result = await _medplumService.fetchOrganizations();
    
    if (result['success'] == true) {
      final organizations = result['organizations'] as List<FhirOrganization>;
      
      // Convert FHIR organizations to BranchModel
      final branchList = organizations.map((org) => BranchModel.fromFhirOrganization(org)).toList();
      
      // Update branches observable
      branches.value = branchList;
      
      // Show success message
      Get.snackbar(
        'Success',
        'Loaded ${branchList.length} organizations',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      // Handle error
      branches.value = [];
    }
  } catch (e) {
    // Handle exception
    branches.value = [];
  } finally {
    isLoadingBranches.value = false;
  }
}
```

**Added refresh functionality:**
```dart
Future<void> refreshBranches() async {
  await _loadBranches();
}
```

### 5. **UI Updates** (`lib/screens/organisation/branch_selection_screen.dart`)

**Added loading states:**
```dart
Widget _buildBranchTree(BranchSelectionController controller) {
  return Obx(() {
    if (controller.isLoadingBranches.value) {
      return Padding(
        padding: const EdgeInsets.only(left: 50, top: 0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'loading_branches'.tr,
              style: const TextStyle(/* ... */),
            ),
          ],
        ),
      );
    }
    
    if (controller.branches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 50, top: 0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.business,
              size: 48,
              color: Color(0xFF858789),
            ),
            const SizedBox(height: 16),
            Text(
              'no_branches_available'.tr,
              style: const TextStyle(/* ... */),
            ),
          ],
        ),
      );
    }
    
    // Show branches
    return Padding(/* ... */);
  });
}
```

## Data Flow

### 1. **Initialization Flow**
```
BranchSelectionController.onInit()
  ↓
_loadUserData() (loads user profile)
  ↓
_loadBranches() (loads organizations from server)
  ↓
MedplumService.fetchOrganizations()
  ↓
FHIR API call
  ↓
Parse response to FhirBundle
  ↓
Convert FhirOrganization to BranchModel
  ↓
Update branches observable
  ↓
UI updates with server data
```

### 2. **Organization Selection Flow**
```
User taps organization
  ↓
BranchSelectionController.selectBranch()
  ↓
Save organization data to storage
  ↓
Show success message
  ↓
Navigate to home screen
```

## Error Handling

### 1. **API Errors**
- **401 Unauthorized**: Automatic logout and redirect to login
- **Network errors**: Show error message, keep empty list
- **Parse errors**: Show error message, keep empty list

### 2. **UI States**
- **Loading**: Show spinner with "Loading branches..." message
- **Empty**: Show business icon with "No branches available" message
- **Error**: Show error message in snackbar
- **Success**: Show organizations list

## Features

### 1. **Dynamic Data Loading**
- Fetches real organizations from server
- Supports pagination parameters
- Handles different organization types

### 2. **Smart Organization Mapping**
- Maps FHIR organization types to display roles
- Extracts contact information (phone, email)
- Extracts address information
- Determines appropriate icons based on type

### 3. **Loading States**
- Shows loading spinner during fetch
- Displays empty state when no organizations
- Handles error states gracefully

### 4. **Refresh Capability**
- `refreshBranches()` method for manual refresh
- Can be called from UI or programmatically

## Configuration

### 1. **API Parameters**
- `_count`: Number of organizations to fetch (default: 20)
- `_sort`: Sort order (default: -_lastUpdated)
- `_total`: Include total count (default: accurate)

### 2. **Organization Type Mapping**
- `Branch` → Role: "Branch", Icon: "clinic"
- `Educational Institute` → Role: "Educational Institute", Icon: "school"
- Default → Role: "Organization", Icon: "organization"

### 3. **Contact Information Extraction**
- Phone: `telecom` with `system: "phone"`
- Email: `telecom` with `system: "email"`
- Address: `address.line` joined with commas

## Benefits

### 1. **Real-time Data**
- Always shows current organizations
- No hardcoded data
- Supports dynamic organization management

### 2. **Scalable Architecture**
- FHIR standard compliance
- Supports complex organization hierarchies
- Extensible for future requirements

### 3. **User Experience**
- Loading states provide feedback
- Error handling prevents crashes
- Empty states guide user actions

### 4. **Maintainability**
- Clean separation of concerns
- Reusable FHIR models
- Centralized API management

## Future Enhancements

### 1. **Pagination Support**
- Load more organizations on scroll
- Implement infinite scrolling
- Add page navigation

### 2. **Search and Filtering**
- Search organizations by name
- Filter by organization type
- Sort by different criteria

### 3. **Caching**
- Cache organizations locally
- Implement offline support
- Sync when online

### 4. **Real-time Updates**
- WebSocket integration
- Push notifications for changes
- Auto-refresh on data changes

## Conclusion

The BranchSelectionController now successfully integrates with the Ayamedica FHIR API to provide:
- **Dynamic organization loading** from server
- **Comprehensive error handling** for all scenarios
- **Smart data mapping** from FHIR to UI models
- **Loading states** for better user experience
- **Scalable architecture** for future enhancements

The implementation follows FHIR standards and provides a robust foundation for organization management in the application.

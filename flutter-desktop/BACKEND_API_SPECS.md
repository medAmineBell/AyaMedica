# Backend API Specifications for Ayamedica Desktop App

## Overview
This document contains all the data models, field types, and API specifications needed for the backend development of the Ayamedica Desktop application. The app is a school medical management system that handles students, appointments, medical records, and organizational management.

## Data Models

### 1. Student Model
**Table: students**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String (UUID) | Yes | Unique identifier |
| name | String | Yes | Full name of student |
| imageUrl | String (URL) | No | Profile image URL |
| avatarColor | Integer | Yes | Color value for avatar (hex color) |
| dateOfBirth | DateTime | No | Student's birth date |
| bloodType | String | No | Blood type (A+, B-, O+, etc.) |
| weightKg | Double | No | Weight in kilograms |
| heightCm | Double | No | Height in centimeters |
| goToHospital | String | No | Hospital preference |
| firstGuardianName | String | No | Primary guardian's name |
| firstGuardianPhone | String | No | Primary guardian's phone |
| firstGuardianEmail | String | No | Primary guardian's email |
| firstGuardianStatus | String | No | Primary guardian's status |
| secondGuardianName | String | No | Secondary guardian's name |
| secondGuardianPhone | String | No | Secondary guardian's phone |
| secondGuardianEmail | String | No | Secondary guardian's email |
| secondGuardianStatus | String | No | Secondary guardian's status |
| city | String | No | City of residence |
| street | String | No | Street address |
| zipCode | String | No | Postal/ZIP code |
| province | String | No | Province/State |
| insuranceCompany | String | No | Insurance provider |
| policyNumber | String | No | Insurance policy number |
| passportIdNumber | String | No | Passport ID |
| nationality | String | No | Nationality |
| nationalId | String | No | National ID number |
| gender | String | No | Gender (Male/Female/Other) |
| phoneNumber | String | No | Student's phone number |
| email | String | No | Student's email |
| studentId | String | No | School student ID |
| aid | String | No | Additional ID |
| grade | String | No | Academic grade |
| className | String | No | Class name |
| lastAppointmentDate | DateTime | No | Date of last appointment |
| lastAppointmentType | String | No | Type of last appointment |
| emrNumber | Integer | No | Electronic Medical Record number |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

**Relationships:**
- Has many MedicalRecords
- Has many Appointments (through selectedStudents)

### 2. Appointment Model
**Table: appointments**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String (UUID) | No | Unique identifier |
| type | String | Yes | Appointment type |
| allStudents | Boolean | Yes | Whether appointment is for all students |
| date | DateTime | Yes | Appointment date |
| time | String | Yes | Appointment time |
| disease | String | Yes | Disease/condition |
| diseaseType | String | Yes | Type of disease |
| grade | String | Yes | Target grade level |
| className | String | Yes | Target class |
| doctor | String | Yes | Doctor's name |
| selectedStudents | Array[Student] | Yes | List of selected students |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

**Relationships:**
- Belongs to many Students (many-to-many)

### 3. Medical Record Model
**Table: medical_records**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String (UUID) | Yes | Unique identifier |
| studentId | String (UUID) | Yes | Reference to student |
| date | DateTime | Yes | Medical record date |
| complaint | String | Yes | Student's complaint |
| suspectedDiseases | String | Yes | Suspected diseases |
| sickLeaveDays | Integer | Yes | Number of sick leave days |
| sickLeaveStartDate | DateTime | Yes | Start date of sick leave |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

**Relationships:**
- Belongs to Student

### 4. User Model
**Table: users**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String (UUID) | Yes | Unique identifier |
| name | String | Yes | User's full name |
| email | String | Yes | User's email address |
| type | String | Yes | User type (Admin, Doctor, Teacher, etc.) |
| city | String | Yes | User's city |
| governorate | String | Yes | User's governorate/province |
| role | String | Yes | User's role in system |
| status | String | Yes | User status (active, inactive, pending) |
| avatarUrl | String (URL) | Yes | Profile image URL |
| aid | String | No | Additional ID |
| initials | String | No | User's initials |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

### 5. Branch Model
**Table: branches**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String (UUID) | Yes | Unique identifier |
| name | String | Yes | Branch name |
| role | String | Yes | Branch role |
| icon | String | Yes | Icon identifier |
| address | String | No | Branch address |
| phone | String | No | Branch phone number |
| email | String | No | Branch email |
| principalName | String | No | Principal's name |
| studentCount | Integer | No | Number of students |
| teacherCount | Integer | No | Number of teachers |
| status | String | Yes | Status (active, inactive, pending) |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

### 6. Organization Model
**Table: organizations**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String (UUID) | Yes | Unique identifier |
| accountType | String | Yes | Account type (School, University, etc.) |
| organizationName | String | Yes | Organization name |
| role | String | Yes | Role (Doctor, Teacher, etc.) |
| educationType | String | Yes | Education type (British, American, etc.) |
| headquarters | String | No | Headquarters location |
| streetAddress | String | No | Street address |
| country | String | Yes | Country (default: Egypt) |
| governorate | String | Yes | Governorate (default: Alexandria) |
| city | String | Yes | City (default: Alexandria) |
| area | String | Yes | Area (default: Alexandria) |
| acceptTerms | Boolean | Yes | Terms acceptance status |
| userId | String (UUID) | No | Reference to user |
| logoPath | String | No | Logo file path |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

**Relationships:**
- Belongs to User

### 7. Message Model
**Table: messages**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String (UUID) | Yes | Unique identifier |
| studentIds | Array[String] | Yes | Array of student IDs |
| subject | String | Yes | Message subject |
| messageBody | String | Yes | Message content |
| fileUrls | Array[String] | Yes | Array of file URLs |
| examination | String | Yes | Examination type |
| from | String | Yes | Sender (default: School Admin) |
| dateTime | DateTime | No | Message timestamp |
| status | String | No | Message status |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

**Relationships:**
- Belongs to many Students (many-to-many)

### 8. Grades/Classes Model
**Table: grades**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String (UUID) | Yes | Unique identifier |
| name | String | Yes | Grade name |
| NumClasses | Integer | Yes | Number of classes |
| MaxCapacity | Integer | Yes | Maximum class capacity |
| ClassName | String | Yes | Class name |
| ActualCapacity | Integer | Yes | Current class capacity |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

### 9. Feedback Model
**Table: feedback**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String (UUID) | Yes | Unique identifier |
| title | String | Yes | Feedback title |
| branch | String | Yes | Branch name |
| launchDate | DateTime | Yes | Launch date |
| status | String | Yes | Feedback status |
| rating | Double | Yes | Average rating |
| currentResponses | Integer | Yes | Current response count |
| totalResponses | Integer | Yes | Total expected responses |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

## API Endpoints

### Authentication
```
POST /api/auth/login
POST /api/auth/logout
POST /api/auth/forgot-password
POST /api/auth/reset-password
POST /api/auth/change-password
POST /api/auth/verify-otp
```

### Students
```
GET    /api/students              # List all students
GET    /api/students/:id          # Get student by ID
POST   /api/students              # Create new student
PUT    /api/students/:id          # Update student
DELETE /api/students/:id          # Delete student
GET    /api/students/search       # Search students
GET    /api/students/grade/:grade # Get students by grade
```

### Appointments
```
GET    /api/appointments                    # List all appointments
GET    /api/appointments/:id                # Get appointment by ID
POST   /api/appointments                    # Create new appointment
PUT    /api/appointments/:id                # Update appointment
DELETE /api/appointments/:id                # Delete appointment
GET    /api/appointments/date/:date         # Get appointments by date
GET    /api/appointments/student/:studentId # Get appointments by student
```

### Medical Records
```
GET    /api/medical-records                 # List all medical records
GET    /api/medical-records/:id             # Get medical record by ID
POST   /api/medical-records                 # Create new medical record
PUT    /api/medical-records/:id             # Update medical record
DELETE /api/medical-records/:id             # Delete medical record
GET    /api/medical-records/student/:studentId # Get records by student
```

### Users
```
GET    /api/users              # List all users
GET    /api/users/:id          # Get user by ID
POST   /api/users              # Create new user
PUT    /api/users/:id          # Update user
DELETE /api/users/:id          # Delete user
GET    /api/users/role/:role   # Get users by role
```

### Branches
```
GET    /api/branches           # List all branches
GET    /api/branches/:id       # Get branch by ID
POST   /api/branches           # Create new branch
PUT    /api/branches/:id       # Update branch
DELETE /api/branches/:id       # Delete branch
```

### Organizations
```
GET    /api/organizations           # List all organizations
GET    /api/organizations/:id       # Get organization by ID
POST   /api/organizations           # Create new organization
PUT    /api/organizations/:id       # Update organization
DELETE /api/organizations/:id       # Delete organization
```

### Messages
```
GET    /api/messages              # List all messages
GET    /api/messages/:id          # Get message by ID
POST   /api/messages              # Create new message
PUT    /api/messages/:id          # Update message
DELETE /api/messages/:id          # Delete message
GET    /api/messages/student/:studentId # Get messages by student
```

### Grades
```
GET    /api/grades              # List all grades
GET    /api/grades/:id          # Get grade by ID
POST   /api/grades              # Create new grade
PUT    /api/grades/:id          # Update grade
DELETE /api/grades/:id          # Delete grade
```

### Feedback
```
GET    /api/feedback              # List all feedback
GET    /api/feedback/:id          # Get feedback by ID
POST   /api/feedback              # Create new feedback
PUT    /api/feedback/:id          # Update feedback
DELETE /api/feedback/:id          # Delete feedback
```

## Data Types Reference

### Primitive Types
- **String**: Text data (UTF-8)
- **Integer**: Whole numbers (32-bit or 64-bit)
- **Double**: Decimal numbers (64-bit floating point)
- **Boolean**: True/False values
- **DateTime**: ISO 8601 formatted date-time strings
- **UUID**: Unique identifier strings

### Complex Types
- **Array**: Ordered collections of values
- **Object**: Key-value pairs (JSON objects)
- **Nullable**: Fields that can be null/undefined

### Special Formats
- **Email**: Valid email format validation
- **Phone**: International phone number format
- **URL**: Valid URL format for images and files
- **Color**: Integer representation of hex colors
- **Date**: ISO 8601 format (YYYY-MM-DDTHH:mm:ss.sssZ)

## Database Schema Recommendations

### Primary Keys
- Use UUID (v4) for all primary keys
- Ensure uniqueness across all tables

### Foreign Keys
- Implement proper foreign key constraints
- Use UUID references for consistency

### Indexes
- Index frequently queried fields (name, email, date fields)
- Composite indexes for complex queries
- Full-text search indexes for search functionality

### Constraints
- NOT NULL for required fields
- UNIQUE constraints for emails, phone numbers, IDs
- CHECK constraints for valid data ranges

## Security Considerations

### Authentication
- JWT tokens for session management
- Secure password hashing (bcrypt)
- Rate limiting for login attempts

### Authorization
- Role-based access control (RBAC)
- Resource-level permissions
- API key management for external integrations

### Data Protection
- Encrypt sensitive data (PII)
- Implement audit logging
- GDPR compliance for data handling

## API Response Format

### Success Response
```json
{
  "success": true,
  "data": {...},
  "message": "Operation completed successfully",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [...]
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Pagination Response
```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "pages": 5
  }
}
```

## Testing Recommendations

### API Testing
- Unit tests for all endpoints
- Integration tests for data flow
- Load testing for performance
- Security testing for vulnerabilities

### Data Validation
- Test all field types and constraints
- Validate business logic rules
- Test edge cases and error conditions

This specification provides a comprehensive foundation for backend development. The backend developer should implement these models, endpoints, and data structures to ensure compatibility with the Flutter frontend application.

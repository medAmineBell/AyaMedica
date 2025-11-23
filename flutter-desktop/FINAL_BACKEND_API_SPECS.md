# Ayamedica Unified Backend API Specifications

## Overview
This document contains the complete data models, field types, and API specifications needed for the backend development of both the Ayamedica Desktop and Mobile applications. The system is a comprehensive school medical management platform that handles students, appointments, medical records, organizational management, and mobile user interactions.

## Table of Contents
1. [Core Data Models](#core-data-models)
2. [Mobile App Specific Models](#mobile-app-specific-models)
3. [API Endpoints](#api-endpoints)
4. [Data Types Reference](#data-types-reference)
5. [Database Schema](#database-schema)
6. [Security & Authentication](#security--authentication)
7. [Implementation Guidelines](#implementation-guidelines)

---

## Core Data Models

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
| allergies | Array[String] | No | List of allergies |
| riskLevel | String | No | Risk level (high/medium/low) |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

**Relationships:**
- Has many MedicalRecords
- Has many Appointments (through selectedStudents)
- Belongs to Organization/Branch

### 2. Appointment Model
**Table: appointments**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String (UUID) | Yes | Unique identifier |
| type | String | Yes | Appointment type |
| allStudents | Boolean | Yes | Whether appointment is for all students |
| date | DateTime | Yes | Appointment date |
| time | String | Yes | Appointment time |
| disease | String | Yes | Disease/condition |
| diseaseType | String | Yes | Type of disease |
| grade | String | Yes | Target grade level |
| className | String | Yes | Target class |
| doctor | String | Yes | Doctor's name |
| doctorId | String (UUID) | No | Reference to doctor |
| selectedStudents | Array[Student] | Yes | List of selected students |
| status | String | Yes | Status (Pending/Approved/Cancelled/Completed) |
| notes | String | No | Additional notes |
| attachments | Array[String] | No | File attachments |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

**Relationships:**
- Belongs to many Students (many-to-many)
- Belongs to Doctor
- Belongs to Organization/Branch

### 3. Medical Record Model
**Table: medical_records**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String (UUID) | Yes | Unique identifier |
| studentId | String (UUID) | Yes | Reference to student |
| title | String | Yes | Record title |
| description | String | Yes | Medical description |
| type | String | Yes | Record type |
| date | DateTime | Yes | Medical record date |
| complaint | String | Yes | Student's complaint |
| suspectedDiseases | String | Yes | Suspected diseases |
| sickLeaveDays | Integer | Yes | Number of sick leave days |
| sickLeaveStartDate | DateTime | Yes | Start date of sick leave |
| doctorName | String | Yes | Doctor's name |
| address | String | No | Medical facility address |
| doctorImage | String | No | Doctor's image URL |
| notes | String | No | Additional notes |
| attachments | Array[String] | No | File attachments |
| riskLevel | String | No | Risk level assessment |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

**Relationships:**
- Belongs to Student
- Belongs to Organization/Branch

### 4. User Model
**Table: users**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String (UUID) | Yes | Unique identifier |
| name | String | Yes | User's full name |
| email | String | Yes | User's email address |
| phone | String | No | User's phone number |
| passwordHash | String | Yes | Hashed password |
| type | String | Yes | User type (Admin, Doctor, Teacher, Parent) |
| city | String | Yes | User's city |
| governorate | String | Yes | User's governorate/province |
| role | String | Yes | User's role in system |
| status | String | Yes | User status (active, inactive, pending) |
| avatarUrl | String (URL) | Yes | Profile image URL |
| aid | String | No | Additional ID |
| initials | String | No | User's initials |
| passportNumber | String | No | Passport number |
| government | String | No | Government/Country |
| organizationId | String (UUID) | No | Reference to organization |
| branchId | String (UUID) | No | Reference to branch |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

**Relationships:**
- Belongs to Organization
- Belongs to Branch
- Has many FamilyMembers (for mobile users)
- Has many Appointments (for mobile users)

### 5. Doctor Model
**Table: doctors**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String (UUID) | Yes | Unique identifier |
| userId | String (UUID) | Yes | Reference to user |
| name | String | Yes | Doctor's full name |
| imageUrl | String (URL) | Yes | Profile image URL |
| rating | Double | No | Doctor rating (0.0-5.0) |
| specialization | String | No | Medical specialization |
| experience | Integer | No | Years of experience |
| location | String | No | Practice location |
| availableSlots | Array[String] | No | Available time slots |
| organizationId | String (UUID) | Yes | Reference to organization |
| branchId | String (UUID) | No | Reference to branch |
| status | String | Yes | Status (active, inactive, pending) |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

**Relationships:**
- Belongs to User
- Belongs to Organization
- Belongs to Branch
- Has many Appointments

### 6. Branch Model
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
| organizationId | String (UUID) | Yes | Reference to organization |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

**Relationships:**
- Belongs to Organization
- Has many Students
- Has many Users
- Has many Doctors

### 7. Organization Model
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
| logoPath | String | No | Logo file path |
| status | String | Yes | Status (active, inactive, pending) |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

**Relationships:**
- Has many Users
- Has many Branches
- Has many Students
- Has many Doctors

### 8. Message Model
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
| organizationId | String (UUID) | Yes | Reference to organization |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

**Relationships:**
- Belongs to many Students (many-to-many)
- Belongs to Organization

### 9. Grades/Classes Model
**Table: grades**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String (UUID) | Yes | Unique identifier |
| name | String | Yes | Grade name |
| NumClasses | Integer | Yes | Number of classes |
| MaxCapacity | Integer | Yes | Maximum class capacity |
| ClassName | String | Yes | Class name |
| ActualCapacity | Integer | Yes | Current class capacity |
| organizationId | String (UUID) | Yes | Reference to organization |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

**Relationships:**
- Belongs to Organization

### 10. Feedback Model
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
| organizationId | String (UUID) | Yes | Reference to organization |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

**Relationships:**
- Belongs to Organization

---

## Mobile App Specific Models

### 11. Family Member Model
**Table: family_members**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String (UUID) | Yes | Unique identifier |
| userId | String (UUID) | Yes | Reference to user |
| name | String | Yes | Family member name |
| relation | String | Yes | Relationship to user |
| image | String (URL) | No | Profile image URL |
| dateOfBirth | DateTime | No | Date of birth |
| bloodType | String | No | Blood type |
| allergies | Array[String] | No | List of allergies |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Record last update timestamp |

**Relationships:**
- Belongs to User (Parent)
- Has many MedicalRecords

### 12. Chat Model
**Table: chat_messages**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String (UUID) | Yes | Unique identifier |
| conversationId | String (UUID) | Yes | Chat conversation ID |
| userId | String (UUID) | Yes | Reference to user |
| text | String | No | Message text |
| doctors | Array[Doctor] | No | Suggested doctors |
| isUser | Boolean | Yes | Whether message is from user |
| messageType | String | Yes | Type (text, doctor_suggestion, file) |
| timestamp | DateTime | Yes | Message timestamp |
| createdAt | DateTime | Yes | Record creation timestamp |

**Relationships:**
- Belongs to User
- Belongs to Conversation

---

## API Endpoints

### Authentication
```
POST /api/auth/login              # User login (phone/email)
POST /api/auth/register           # User registration
POST /api/auth/logout             # User logout
POST /api/auth/forgot-password    # Forgot password
POST /api/auth/reset-password     # Reset password
POST /api/auth/change-password    # Change password
POST /api/auth/verify-otp         # OTP verification
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
GET    /api/students/branch/:branchId # Get students by branch
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
PUT    /api/appointments/:id/status         # Update appointment status
GET    /api/appointments/doctor/:doctorId   # Get appointments by doctor
```

### Medical Records
```
GET    /api/medical-records                 # List all medical records
GET    /api/medical-records/:id             # Get medical record by ID
POST   /api/medical-records                 # Create new medical record
PUT    /api/medical-records/:id             # Update medical record
DELETE /api/medical-records/:id             # Delete medical record
GET    /api/medical-records/student/:studentId # Get records by student
GET    /api/medical-records/family/:familyMemberId # Get records by family member
```

### Users
```
GET    /api/users              # List all users
GET    /api/users/:id          # Get user by ID
POST   /api/users              # Create new user
PUT    /api/users/:id          # Update user
DELETE /api/users/:id          # Delete user
GET    /api/users/role/:role   # Get users by role
GET    /api/users/organization/:orgId # Get users by organization
```

### Doctors
```
GET    /api/doctors                    # List all doctors
GET    /api/doctors/:id                # Get doctor by ID
POST   /api/doctors                    # Create new doctor
PUT    /api/doctors/:id                # Update doctor
DELETE /api/doctors/:id                # Delete doctor
GET    /api/doctors/search             # Search doctors
GET    /api/doctors/specialization/:specialization # Get by specialization
GET    /api/doctors/organization/:orgId # Get by organization
```

### Branches
```
GET    /api/branches           # List all branches
GET    /api/branches/:id       # Get branch by ID
POST   /api/branches           # Create new branch
PUT    /api/branches/:id       # Update branch
DELETE /api/branches/:id       # Delete branch
GET    /api/branches/organization/:orgId # Get by organization
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
GET    /api/grades/organization/:orgId # Get by organization
```

### Feedback
```
GET    /api/feedback              # List all feedback
GET    /api/feedback/:id          # Get feedback by ID
POST   /api/feedback              # Create new feedback
PUT    /api/feedback/:id          # Update feedback
DELETE /api/feedback/:id          # Delete feedback
```

### Mobile App Specific Endpoints

#### Family Members
```
GET    /api/user/family-members              # Get family members
POST   /api/user/family-members              # Add family member
PUT    /api/user/family-members/:id          # Update family member
DELETE /api/user/family-members/:id          # Remove family member
```

#### Chat
```
GET    /api/chat/conversations               # Get chat conversations
GET    /api/chat/messages/:conversationId    # Get chat messages
POST   /api/chat/messages                    # Send message
POST   /api/chat/start-conversation          # Start new conversation
```

#### Location Data
```
GET    /api/locations/nationalities          # Get all nationalities
GET    /api/locations/governorates/:country  # Get governorates by country
GET    /api/locations/cities/:governorate    # Get cities by governorate
```

---

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

### Enums
```typescript
enum LoginMethod {
  phone = "phone",
  email = "email"
}

enum RiskLevel {
  high = "high",
  medium = "medium",
  low = "low"
}

enum AppointmentStatus {
  pending = "Pending",
  approved = "Approved",
  cancelled = "Cancelled",
  completed = "Completed"
}

enum UserType {
  admin = "Admin",
  doctor = "Doctor",
  teacher = "Teacher",
  parent = "Parent"
}
```

---

## Database Schema

### Core Tables
```sql
-- Users table (unified for both apps)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20) UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  type VARCHAR(50) NOT NULL,
  city VARCHAR(100) NOT NULL,
  governorate VARCHAR(100) NOT NULL,
  role VARCHAR(50) NOT NULL,
  status VARCHAR(50) DEFAULT 'active',
  avatar_url VARCHAR(255),
  aid VARCHAR(100),
  initials VARCHAR(10),
  passport_number VARCHAR(50),
  government VARCHAR(100),
  organization_id UUID REFERENCES organizations(id),
  branch_id UUID REFERENCES branches(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Students table
CREATE TABLE students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  image_url VARCHAR(255),
  avatar_color INTEGER NOT NULL,
  date_of_birth DATE,
  blood_type VARCHAR(10),
  weight_kg DECIMAL(5,2),
  height_cm DECIMAL(5,2),
  go_to_hospital VARCHAR(255),
  first_guardian_name VARCHAR(255),
  first_guardian_phone VARCHAR(20),
  first_guardian_email VARCHAR(255),
  first_guardian_status VARCHAR(50),
  second_guardian_name VARCHAR(255),
  second_guardian_phone VARCHAR(20),
  second_guardian_email VARCHAR(255),
  second_guardian_status VARCHAR(50),
  city VARCHAR(100),
  street VARCHAR(255),
  zip_code VARCHAR(20),
  province VARCHAR(100),
  insurance_company VARCHAR(255),
  policy_number VARCHAR(100),
  passport_id_number VARCHAR(100),
  nationality VARCHAR(100),
  national_id VARCHAR(100),
  gender VARCHAR(20),
  phone_number VARCHAR(20),
  email VARCHAR(255),
  student_id VARCHAR(100),
  aid VARCHAR(100),
  grade VARCHAR(50),
  class_name VARCHAR(100),
  last_appointment_date TIMESTAMP,
  last_appointment_type VARCHAR(100),
  emr_number INTEGER,
  allergies TEXT[],
  risk_level VARCHAR(20),
  organization_id UUID REFERENCES organizations(id) NOT NULL,
  branch_id UUID REFERENCES branches(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Appointments table
CREATE TABLE appointments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type VARCHAR(100) NOT NULL,
  all_students BOOLEAN NOT NULL,
  date DATE NOT NULL,
  time VARCHAR(20) NOT NULL,
  disease VARCHAR(255) NOT NULL,
  disease_type VARCHAR(100) NOT NULL,
  grade VARCHAR(50) NOT NULL,
  class_name VARCHAR(100) NOT NULL,
  doctor VARCHAR(255) NOT NULL,
  doctor_id UUID REFERENCES doctors(id),
  status VARCHAR(50) DEFAULT 'Pending',
  notes TEXT,
  attachments TEXT[],
  organization_id UUID REFERENCES organizations(id) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Medical Records table
CREATE TABLE medical_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES students(id) NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  type VARCHAR(100) NOT NULL,
  date TIMESTAMP NOT NULL,
  complaint TEXT NOT NULL,
  suspected_diseases TEXT NOT NULL,
  sick_leave_days INTEGER NOT NULL,
  sick_leave_start_date DATE NOT NULL,
  doctor_name VARCHAR(255) NOT NULL,
  address TEXT,
  doctor_image VARCHAR(255),
  notes TEXT,
  attachments TEXT[],
  risk_level VARCHAR(20),
  organization_id UUID REFERENCES organizations(id) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Organizations table
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_type VARCHAR(100) NOT NULL,
  organization_name VARCHAR(255) NOT NULL,
  role VARCHAR(100) NOT NULL,
  education_type VARCHAR(100) NOT NULL,
  headquarters VARCHAR(255),
  street_address TEXT,
  country VARCHAR(100) NOT NULL DEFAULT 'Egypt',
  governorate VARCHAR(100) NOT NULL DEFAULT 'Alexandria',
  city VARCHAR(100) NOT NULL DEFAULT 'Alexandria',
  area VARCHAR(100) NOT NULL DEFAULT 'Alexandria',
  accept_terms BOOLEAN NOT NULL DEFAULT false,
  logo_path VARCHAR(255),
  status VARCHAR(50) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Branches table
CREATE TABLE branches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  role VARCHAR(100) NOT NULL,
  icon VARCHAR(100) NOT NULL,
  address TEXT,
  phone VARCHAR(20),
  email VARCHAR(255),
  principal_name VARCHAR(255),
  student_count INTEGER DEFAULT 0,
  teacher_count INTEGER DEFAULT 0,
  status VARCHAR(50) DEFAULT 'active',
  organization_id UUID REFERENCES organizations(id) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Doctors table
CREATE TABLE doctors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) NOT NULL,
  name VARCHAR(255) NOT NULL,
  image_url VARCHAR(255) NOT NULL,
  rating DECIMAL(3,2) DEFAULT 0.0,
  specialization VARCHAR(100),
  experience INTEGER,
  location VARCHAR(255),
  available_slots TEXT[],
  organization_id UUID REFERENCES organizations(id) NOT NULL,
  branch_id UUID REFERENCES branches(id),
  status VARCHAR(50) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Family Members table (mobile app)
CREATE TABLE family_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) NOT NULL,
  name VARCHAR(255) NOT NULL,
  relation VARCHAR(50) NOT NULL,
  image VARCHAR(255),
  date_of_birth DATE,
  blood_type VARCHAR(10),
  allergies TEXT[],
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Chat Messages table (mobile app)
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL,
  user_id UUID REFERENCES users(id) NOT NULL,
  text TEXT,
  message_type VARCHAR(50) NOT NULL,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Junction Tables
CREATE TABLE appointment_students (
  appointment_id UUID REFERENCES appointments(id) ON DELETE CASCADE,
  student_id UUID REFERENCES students(id) ON DELETE CASCADE,
  PRIMARY KEY (appointment_id, student_id)
);

CREATE TABLE message_students (
  message_id UUID REFERENCES messages(id) ON DELETE CASCADE,
  student_id UUID REFERENCES students(id) ON DELETE CASCADE,
  PRIMARY KEY (message_id, student_id)
);
```

---

## Security & Authentication

### Authentication
- **JWT tokens** for session management
- **Secure password hashing** (bcrypt with salt)
- **Rate limiting** for login attempts
- **Session timeout** management

### Authorization
- **Role-based access control** (RBAC)
- **Resource-level permissions**
- **Organization/branch isolation**
- **API key management** for external integrations

### Data Protection
- **Encrypt sensitive data** (PII, medical records)
- **Implement audit logging** for all operations
- **GDPR compliance** for data handling
- **Data retention policies**

---

## Implementation Guidelines

### API Response Format

#### Success Response
```json
{
  "success": true,
  "data": {},
  "message": "Operation completed successfully",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

#### Error Response
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

#### Paginated Response
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

### Database Recommendations

#### Primary Keys
- Use **UUID (v4)** for all primary keys
- Ensure uniqueness across all tables

#### Foreign Keys
- Implement proper foreign key constraints
- Use UUID references for consistency

#### Indexes
- Index frequently queried fields (name, email, date fields)
- Composite indexes for complex queries
- Full-text search indexes for search functionality

#### Constraints
- NOT NULL for required fields
- UNIQUE constraints for emails, phone numbers, IDs
- CHECK constraints for valid data ranges

### Testing Strategy

#### API Testing
- Unit tests for all endpoints
- Integration tests for data flow
- Load testing for performance
- Security testing for vulnerabilities

#### Data Validation
- Test all field types and constraints
- Validate business logic rules
- Test edge cases and error conditions

### Performance Considerations

#### Caching
- Implement Redis for session management
- Cache frequently accessed data
- Use CDN for static assets

#### Database Optimization
- Proper indexing strategy
- Query optimization
- Connection pooling
- Read replicas for heavy read operations

### Monitoring & Logging

#### Application Monitoring
- Request/response logging
- Error tracking and alerting
- Performance metrics
- User activity analytics

#### Security Monitoring
- Failed authentication attempts
- Suspicious API usage patterns
- Data access audit trails
- Security incident response

---

## Notes for Backend Implementation

1. **Multi-tenancy**: Implement organization/branch isolation for data security
2. **File Uploads**: Support for profile images, medical record attachments, and documents
3. **Real-time Features**: Consider WebSocket implementation for chat and notifications
4. **Search**: Implement full-text search for students, doctors, and medical records
5. **Pagination**: Implement pagination for all list endpoints
6. **Validation**: Implement comprehensive input validation for all endpoints
7. **Error Handling**: Standardize error response format across all endpoints
8. **Logging**: Implement comprehensive logging for debugging and monitoring
9. **Security**: Implement rate limiting, input sanitization, and CORS policies
10. **Testing**: Include unit tests, integration tests, and API documentation
11. **Mobile Optimization**: Ensure API responses are optimized for mobile consumption
12. **Backup & Recovery**: Implement automated backup and disaster recovery procedures

This unified specification provides a comprehensive foundation for backend development that will serve both the desktop and mobile applications seamlessly. The backend developer should implement these models, endpoints, and data structures to ensure compatibility and consistency across all platforms.

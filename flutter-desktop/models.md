# Ayamedica Flutter App - Backend API Specifications

This document contains all the data models, enums, and data structures used in the Ayamedica Flutter application. Use this as a reference to implement the backend API endpoints and database schemas.

## Table of Contents
1. [Authentication Models](#authentication-models)
2. [User Profile Models](#user-profile-models)
3. [Medical Records Models](#medical-records-models)
4. [Appointment Models](#appointment-models)
5. [Doctor Models](#doctor-models)
6. [Chat Models](#chat-models)
7. [Location Data](#location-data)
8. [Enums](#enums)
9. [API Endpoints Structure](#api-endpoints-structure)

## Authentication Models

### Login Request
```json
{
  "loginMethod": "phone" | "email",
  "identifier": "string", // phone number or email
  "password": "string"
}
```

### Login Response
```json
{
  "success": true,
  "token": "string",
  "user": {
    "id": "string",
    "name": "string",
    "email": "string",
    "phone": "string"
  }
}
```

### User Data Structure
```json
{
  "id": "string",
  "profile_image": "string",
  "passport_number": "string",
  "first_name": "string",
  "last_name": "string",
  "government": "string",
  "city": "string"
}
```

## User Profile Models

### Family Member
```json
{
  "id": "string",
  "name": "string",
  "relation": "string",
  "image": "string?",
  "dateOfBirth": "string? (ISO 8601)",
  "bloodType": "string?",
  "allergies": ["string"]?
}
```

## Medical Records Models

### Record
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "createdAt": "string (ISO 8601)",
  "type": "string",
  "doctorName": "string",
  "address": "string",
  "doctorImage": "string?",
  "attachments": ["string"]?,
  "notes": "string?"
}
```

### Child (with Records)
```json
{
  "id": "string",
  "name": "string",
  "relation": "string",
  "image": "string?",
  "records": [Record],
  "dateOfBirth": "string? (ISO 8601)",
  "bloodType": "string?",
  "allergies": ["string"]?
}
```

## Appointment Models

### Appointment
```json
{
  "id": "string",
  "type": "string",
  "doctor": {
    "name": "string",
    "imageUrl": "string",
    "rating": "number"
  },
  "dateTime": "string (ISO 8601)",
  "status": "string"
}
```

### Appointment Status Values
- "Pending"
- "Approved"
- "Cancelled"
- "Completed"

## Doctor Models

### Doctor
```json
{
  "id": "string",
  "name": "string",
  "imageUrl": "string",
  "rating": "number",
  "specialization": "string?",
  "experience": "number?",
  "location": "string?",
  "availableSlots": ["string"]?
}
```

## Chat Models

### Chat Message
```json
{
  "id": "string",
  "text": "string?",
  "doctors": [Doctor]?,
  "isUser": "boolean",
  "timestamp": "string (ISO 8601)",
  "messageType": "text" | "doctor_suggestion" | "file"
}
```

## Location Data

### Nationalities
```json
[
  "Saudi Arabia",
  "Egypt"
]
```

### Governorates by Country
```json
{
  "Saudi Arabia": [
    "Riyadh",
    "Makkah",
    "Madinah",
    "Eastern Province",
    "Al-Qassim",
    "Ha'il",
    "Tabuk",
    "Al-Jouf",
    "Jizan",
    "Asir",
    "Al-Baha",
    "Najran",
    "Northern Borders"
  ],
  "Egypt": [
    "Cairo",
    "Alexandria",
    "Giza",
    "Qalyubia",
    "Gharbia",
    "Menoufia",
    "Beheira",
    "Damietta",
    "Dakahlia",
    "Sharqia",
    "Port Said",
    "Ismailia",
    "Suez"
  ]
}
```

### Cities by Governorate
```json
{
  "Riyadh": ["Riyadh City", "Al-Kharj", "Al-Diriyah", "Al-Majmaah"],
  "Eastern Province": ["Dammam", "Al-Khobar", "Dhahran", "Al-Qatif", "Al-Ahsa"],
  "Makkah": ["Makkah City", "Jeddah", "Taif", "Rabigh"],
  "Cairo": ["Nasr City", "Maadi", "Heliopolis", "Downtown"],
  "Alexandria": ["Miami", "Montaza", "Sidi Gaber", "Agami"],
  "Giza": ["Dokki", "6th of October", "Sheikh Zayed", "Haram"]
}
```

## Enums

### Login Method
```typescript
enum LoginMethod {
  phone = "phone",
  email = "email"
}
```

### Risk Level
```typescript
enum RiskLevel {
  high = "high",
  medium = "medium",
  low = "low"
}
```

## API Endpoints Structure

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `POST /api/auth/forgot-password` - Forgot password
- `POST /api/auth/reset-password` - Reset password
- `POST /api/auth/change-password` - Change password
- `POST /api/auth/verify-otp` - OTP verification
- `POST /api/auth/logout` - User logout

### User Profile
- `GET /api/user/profile` - Get user profile
- `PUT /api/user/profile` - Update user profile
- `GET /api/user/family-members` - Get family members
- `POST /api/user/family-members` - Add family member
- `PUT /api/user/family-members/{id}` - Update family member
- `DELETE /api/user/family-members/{id}` - Remove family member

### Medical Records
- `GET /api/records` - Get all records
- `GET /api/records/{id}` - Get specific record
- `POST /api/records` - Create new record
- `PUT /api/records/{id}` - Update record
- `DELETE /api/records/{id}` - Delete record
- `GET /api/records/child/{childId}` - Get records for specific child

### Appointments
- `GET /api/appointments` - Get all appointments
- `GET /api/appointments/{id}` - Get specific appointment
- `POST /api/appointments` - Create new appointment
- `PUT /api/appointments/{id}` - Update appointment
- `DELETE /api/appointments/{id}` - Cancel appointment
- `PUT /api/appointments/{id}/status` - Update appointment status

### Doctors
- `GET /api/doctors` - Get all doctors
- `GET /api/doctors/{id}` - Get specific doctor
- `GET /api/doctors/search` - Search doctors
- `GET /api/doctors/specialization/{specialization}` - Get doctors by specialization

### Chat
- `GET /api/chat/conversations` - Get chat conversations
- `GET /api/chat/messages/{conversationId}` - Get chat messages
- `POST /api/chat/messages` - Send message
- `POST /api/chat/start-conversation` - Start new conversation

### Location Data
- `GET /api/locations/nationalities` - Get all nationalities
- `GET /api/locations/governorates/{country}` - Get governorates by country
- `GET /api/locations/cities/{governorate}` - Get cities by governorate

## Database Schema Recommendations

### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE,
  phone VARCHAR(20) UNIQUE,
  password_hash VARCHAR(255),
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  passport_number VARCHAR(50),
  government VARCHAR(100),
  city VARCHAR(100),
  profile_image VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Family Members Table
```sql
CREATE TABLE family_members (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  name VARCHAR(100),
  relation VARCHAR(50),
  image VARCHAR(255),
  date_of_birth DATE,
  blood_type VARCHAR(10),
  allergies TEXT[],
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Medical Records Table
```sql
CREATE TABLE medical_records (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  family_member_id UUID REFERENCES family_members(id),
  title VARCHAR(255),
  description TEXT,
  type VARCHAR(100),
  doctor_name VARCHAR(100),
  address TEXT,
  doctor_image VARCHAR(255),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Appointments Table
```sql
CREATE TABLE appointments (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  doctor_id UUID REFERENCES doctors(id),
  type VARCHAR(100),
  date_time TIMESTAMP,
  status VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Doctors Table
```sql
CREATE TABLE doctors (
  id UUID PRIMARY KEY,
  name VARCHAR(100),
  image_url VARCHAR(255),
  rating DECIMAL(3,2),
  specialization VARCHAR(100),
  experience INTEGER,
  location VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Chat Messages Table
```sql
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY,
  conversation_id UUID,
  user_id UUID REFERENCES users(id),
  text TEXT,
  message_type VARCHAR(50),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Notes for Backend Implementation

1. **Authentication**: Implement JWT token-based authentication
2. **File Uploads**: Support for profile images, medical record attachments
3. **Real-time Chat**: Consider WebSocket implementation for chat functionality
4. **Search**: Implement full-text search for doctors and medical records
5. **Pagination**: Implement pagination for lists (records, appointments, doctors)
6. **Validation**: Implement proper input validation for all endpoints
7. **Error Handling**: Standardize error response format
8. **Logging**: Implement comprehensive logging for debugging
9. **Security**: Implement rate limiting and input sanitization
10. **Testing**: Include unit tests and integration tests

## Response Format Standards

### Success Response
```json
{
  "success": true,
  "data": {},
  "message": "string"
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "string",
    "message": "string",
    "details": {}
  }
}
```

### Paginated Response
```json
{
  "success": true,
  "data": [],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 100,
    "totalPages": 10
  }
}
```

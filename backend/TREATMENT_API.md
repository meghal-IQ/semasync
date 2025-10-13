# Treatment/Shot Tracking API Documentation

## Overview
This API provides comprehensive endpoints for logging and tracking GLP-1 medication injections, calculating medication levels, and monitoring treatment adherence.

## Base URL
```
http://localhost:8080/api/treatments
```

## Authentication
All endpoints require authentication. Include the JWT token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

---

## Endpoints

### 1. Log a New Shot
**POST** `/shots`

Log a new GLP-1 injection with details about the shot, injection site, and any side effects.

**Request Body:**
```json
{
  "date": "2024-01-15T10:30:00Z",  // Optional, defaults to now
  "medication": "Ozempic®",
  "dosage": "0.5mg",
  "injectionSite": "Left Thigh",
  "painLevel": 3,                   // 0-10 scale
  "sideEffects": ["None"],          // Array of side effects
  "notes": "Injection went smoothly",
  "photoUrl": "https://..."         // Optional
}
```

**Response:**
```json
{
  "success": true,
  "message": "Shot logged successfully",
  "data": {
    "shotLog": {
      "id": "65abc123...",
      "userId": "65xyz789...",
      "date": "2024-01-15T10:30:00Z",
      "medication": "Ozempic®",
      "dosage": "0.5mg",
      "injectionSite": "Left Thigh",
      "painLevel": 3,
      "sideEffects": ["None"],
      "notes": "Injection went smoothly",
      "nextDueDate": "2024-01-22T10:30:00Z",
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    },
    "nextDueDate": "2024-01-22T10:30:00Z",
    "countdown": "7d 0h"
  }
}
```

---

### 2. Get Shot History
**GET** `/shots?startDate=2024-01-01&endDate=2024-01-31&limit=50&page=1`

Retrieve shot history with optional date filters and pagination.

**Query Parameters:**
- `startDate` (optional): ISO date string
- `endDate` (optional): ISO date string
- `limit` (optional): Number of results per page (1-100, default: 50)
- `page` (optional): Page number (default: 1)

**Response:**
```json
{
  "success": true,
  "data": {
    "shots": [
      {
        "id": "65abc123...",
        "date": "2024-01-15T10:30:00Z",
        "medication": "Ozempic®",
        "dosage": "0.5mg",
        "injectionSite": "Left Thigh",
        "painLevel": 3,
        "sideEffects": ["None"],
        "nextDueDate": "2024-01-22T10:30:00Z"
      }
    ],
    "pagination": {
      "total": 15,
      "page": 1,
      "limit": 50,
      "pages": 1
    }
  }
}
```

---

### 3. Get Latest Shot
**GET** `/shots/latest`

Get the most recent shot with medication level calculations.

**Response:**
```json
{
  "success": true,
  "data": {
    "shot": {
      "id": "65abc123...",
      "date": "2024-01-15T10:30:00Z",
      "medication": "Ozempic®",
      "dosage": "0.5mg",
      "injectionSite": "Left Thigh",
      "nextDueDate": "2024-01-22T10:30:00Z"
    },
    "medicationLevel": {
      "currentLevel": 85.3,
      "percentageOfPeak": 85.3,
      "daysUntilNextDose": 5.2,
      "hoursUntilNextDose": 124.8,
      "isOverdue": false,
      "status": "optimal"
    },
    "countdown": "5d 4h"
  }
}
```

---

### 4. Get Next Shot Due
**GET** `/shots/next`

Calculate when the next shot is due.

**Response:**
```json
{
  "success": true,
  "data": {
    "hasShots": true,
    "nextDueDate": "2024-01-22T10:30:00Z",
    "countdown": "5d 4h",
    "isOverdue": false,
    "hoursUntilNext": 124.8,
    "daysUntilNext": 5.2
  }
}
```

---

### 5. Get Medication Level
**GET** `/medication-level`

Calculate current medication level in bloodstream based on pharmacokinetics.

**Response:**
```json
{
  "success": true,
  "data": {
    "hasShots": true,
    "currentLevel": 85.3,
    "percentageOfPeak": 85.3,
    "daysUntilNextDose": 5.2,
    "hoursUntilNextDose": 124.8,
    "isOverdue": false,
    "status": "optimal",
    "medication": "Ozempic®",
    "dosage": "0.5mg",
    "lastShotDate": "2024-01-15T10:30:00Z"
  }
}
```

**Medication Levels Explained:**
- `currentLevel`: Percentage of peak medication level (0-100%)
- `status`: 
  - `optimal`: 60-100% (medication at therapeutic levels)
  - `declining`: 30-60% (medication declining but still effective)
  - `low`: 0-30% (medication below therapeutic levels)
  - `overdue`: Next dose is past due

---

### 6. Get Injection Site Recommendations
**GET** `/injection-sites/recommend`

Get recommended injection sites based on rotation pattern.

**Response:**
```json
{
  "success": true,
  "data": {
    "recommendedSites": [
      "Right Abdomen",
      "Left Arm",
      "Right Arm"
    ],
    "recentSites": [
      "Left Thigh",
      "Right Thigh",
      "Left Abdomen"
    ],
    "message": "Rotate injection sites to minimize irritation and improve absorption"
  }
}
```

---

### 7. Get Treatment Statistics
**GET** `/stats`

Get comprehensive treatment statistics and adherence metrics.

**Response:**
```json
{
  "success": true,
  "data": {
    "totalShots": 24,
    "expectedShots": 26,
    "adherenceRate": 92,
    "daysSinceStart": 182,
    "firstShotDate": "2023-07-15T10:00:00Z",
    "latestShotDate": "2024-01-15T10:30:00Z",
    "currentDose": "1.0mg",
    "startingDose": "0.25mg",
    "averagePainLevel": 2.3,
    "mostUsedInjectionSite": "Left Thigh",
    "commonSideEffects": [
      { "effect": "Nausea", "count": 8 },
      { "effect": "Fatigue", "count": 5 },
      { "effect": "Headache", "count": 3 }
    ]
  }
}
```

---

### 8. Update a Shot Log
**PUT** `/shots/:id`

Update an existing shot log entry.

**Request Body:** (All fields optional)
```json
{
  "date": "2024-01-15T10:30:00Z",
  "medication": "Ozempic®",
  "dosage": "0.5mg",
  "injectionSite": "Right Thigh",
  "painLevel": 2,
  "sideEffects": ["Nausea"],
  "notes": "Updated notes"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Shot log updated successfully",
  "data": {
    // Updated shot log object
  }
}
```

---

### 9. Delete a Shot Log
**DELETE** `/shots/:id`

Delete a shot log entry.

**Response:**
```json
{
  "success": true,
  "message": "Shot log deleted successfully"
}
```

---

## Data Models

### Medication Options
```
- Zepbound®
- Mounjaro®
- Ozempic®
- Wegovy®
- Trulicity®
- Compounded Semaglutide
- Compounded Tirzepatide
```

### Dosage Options
```
- 0.25mg
- 0.5mg
- 0.7mg
- 1.0mg
- 1.5mg
- 1.7mg
- 2.0mg
- 2.4mg
- 2.5mg
- 5mg
- 7.5mg
- 10mg
- 12.5mg
- 15mg
```

### Injection Sites
```
- Left Thigh
- Right Thigh
- Left Arm
- Right Arm
- Left Abdomen
- Right Abdomen
- Left Buttock
- Right Buttock
```

### Side Effects
```
- None
- Nausea
- Vomiting
- Diarrhea
- Constipation
- Fatigue
- Headache
- Dizziness
- Abdominal Pain
- Decreased Appetite
- Injection Site Reaction
- Other
```

---

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "dosage",
      "message": "Invalid dosage"
    }
  ]
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Authentication required"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Shot log not found"
}
```

### 500 Server Error
```json
{
  "success": false,
  "message": "Internal server error"
}
```

---

## Testing with cURL

### Log a Shot
```bash
curl -X POST http://localhost:8080/api/treatments/shots \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "medication": "Ozempic®",
    "dosage": "0.5mg",
    "injectionSite": "Left Thigh",
    "painLevel": 3,
    "sideEffects": ["None"]
  }'
```

### Get Shot History
```bash
curl -X GET "http://localhost:8080/api/treatments/shots?limit=10" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Medication Level
```bash
curl -X GET http://localhost:8080/api/treatments/medication-level \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Statistics
```bash
curl -X GET http://localhost:8080/api/treatments/stats \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Medication Level Calculation

The API uses pharmacokinetic principles to calculate medication levels:

### Half-Life Values
- **Semaglutide** (Ozempic®, Wegovy®): ~7 days (168 hours)
- **Tirzepatide** (Mounjaro®, Zepbound®): ~5 days (120 hours)
- **Dulaglutide** (Trulicity®): ~5 days (120 hours)

### Formula
```
Current Level = 100 × (0.5)^(hours_since_shot / half_life)
```

This provides a real-time estimate of medication concentration in the bloodstream.

---

## Next Steps

1. **Test the API** using Postman or cURL
2. **Integrate with Flutter app** using the shot logging screens
3. **Add dashboard integration** to show medication levels
4. **Implement notifications** for upcoming shots

---

## Support

For issues or questions, refer to the main API documentation at:
```
http://localhost:8080/api-docs
```

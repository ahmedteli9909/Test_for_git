# D-HAWK API Endpoints Documentation

This document lists all the API endpoints that need to be implemented for the D-HAWK Security app.

## Base URL
```
https://api.dhawk.com/v1
```

## Authentication Endpoints

### POST /auth/login
Login user with email and password.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "User Name",
    "phone": "+1234567890",
    "avatar": "https://example.com/avatar.jpg",
    "created_at": "2024-01-01T00:00:00Z",
    "is_email_verified": true
  }
}
```

### POST /auth/register
Register a new user.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "User Name"
}
```

**Response:** Same as login response.

### POST /auth/forgot-password
Send password reset email.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "message": "Password reset email sent"
}
```

### POST /auth/reset-password
Reset password with token.

**Request Body:**
```json
{
  "token": "reset_token",
  "password": "new_password123"
}
```

**Response:**
```json
{
  "message": "Password reset successful"
}
```

### POST /auth/refresh-token
Refresh authentication token.

**Response:**
```json
{
  "token": "new_jwt_token_here"
}
```

### POST /auth/logout
Logout user.

**Response:**
```json
{
  "message": "Logged out successfully"
}
```

## User Endpoints

### GET /user/profile
Get current user profile.

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
{
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "User Name",
    "phone": "+1234567890",
    "avatar": "https://example.com/avatar.jpg",
    "created_at": "2024-01-01T00:00:00Z",
    "is_email_verified": true
  }
}
```

### PUT /user/profile
Update user profile.

**Request Body:**
```json
{
  "name": "Updated Name",
  "phone": "+1234567890"
}
```

**Response:** Same as GET /user/profile

### POST /user/change-password
Change user password.

**Request Body:**
```json
{
  "current_password": "old_password",
  "new_password": "new_password123"
}
```

**Response:**
```json
{
  "message": "Password changed successfully"
}
```

## Security Endpoints

### GET /security/threats
Get list of security threats.

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)

**Response:**
```json
{
  "threats": [
    {
      "id": "threat_id",
      "title": "Malware Detected",
      "description": "A malicious file was detected in the system",
      "level": "high",
      "status": "active",
      "detected_at": "2024-01-01T00:00:00Z",
      "resolved_at": null,
      "source": "File System",
      "category": "Malware"
    }
  ],
  "total": 50,
  "page": 1,
  "limit": 20
}
```

### GET /security/threats/{id}
Get threat details by ID.

**Response:**
```json
{
  "id": "threat_id",
  "title": "Malware Detected",
  "description": "A malicious file was detected in the system",
  "level": "high",
  "status": "active",
  "detected_at": "2024-01-01T00:00:00Z",
  "resolved_at": null,
  "source": "File System",
  "category": "Malware"
}
```

### GET /security/status
Get overall security status.

**Response:**
```json
{
  "overall_status": "safe",
  "total_threats": 10,
  "active_threats": 2,
  "resolved_threats": 8,
  "security_score": 85.5,
  "last_scan": "2024-01-01T00:00:00Z",
  "threats_by_level": {
    "low": 5,
    "medium": 3,
    "high": 2,
    "critical": 0
  },
  "recommendations": [
    "Update your system software",
    "Run a full system scan"
  ]
}
```

### GET /security/alerts
Get security alerts.

**Query Parameters:**
- `page` (optional): Page number
- `limit` (optional): Items per page

**Response:** Same format as /security/threats

### GET /security/reports
Get security reports.

**Query Parameters:**
- `start_date` (optional): Start date (ISO 8601)
- `end_date` (optional): End date (ISO 8601)

**Response:**
```json
{
  "reports": [
    {
      "id": "report_id",
      "title": "Weekly Security Report",
      "type": "weekly",
      "created_at": "2024-01-01T00:00:00Z",
      "summary": "Report summary here"
    }
  ]
}
```

### GET /security/analytics
Get security analytics data.

**Response:**
```json
{
  "threats_over_time": [],
  "threats_by_category": {},
  "security_trends": []
}
```

### POST /security/scan
Start a system scan.

**Response:**
```json
{
  "scan_id": "scan_id",
  "status": "started",
  "message": "Scan initiated successfully"
}
```

### GET /security/scan-history
Get scan history.

**Query Parameters:**
- `page` (optional): Page number
- `limit` (optional): Items per page

**Response:**
```json
{
  "scans": [
    {
      "id": "scan_id",
      "status": "completed",
      "threats_found": 5,
      "started_at": "2024-01-01T00:00:00Z",
      "completed_at": "2024-01-01T00:05:00Z"
    }
  ]
}
```

## Monitoring Endpoints

### GET /monitoring/data
Get real-time monitoring data.

**Response:**
```json
{
  "active_connections": 10,
  "network_activity": [],
  "system_resources": {}
}
```

### GET /monitoring/stats
Get monitoring statistics.

**Response:**
```json
{
  "total_alerts": 50,
  "active_threats": 5,
  "resolved_threats": 45
}
```

### GET /monitoring/active-threats
Get currently active threats.

**Response:** Same format as /security/threats

## Settings Endpoints

### GET /settings
Get user settings.

**Response:**
```json
{
  "auto_scan": false,
  "scan_frequency": "daily",
  "notification_preferences": {}
}
```

### PUT /settings
Update user settings.

**Request Body:**
```json
{
  "auto_scan": true,
  "scan_frequency": "weekly"
}
```

**Response:** Same as GET /settings

### GET /settings/notifications
Get notification settings.

**Response:**
```json
{
  "email_alerts": true,
  "push_notifications": true,
  "alert_levels": ["high", "critical"]
}
```

### PUT /settings/notifications
Update notification settings.

**Request Body:**
```json
{
  "email_alerts": true,
  "push_notifications": false,
  "alert_levels": ["high", "critical"]
}
```

**Response:** Same as GET /settings/notifications

## Error Responses

All endpoints may return error responses in the following format:

```json
{
  "error": "Error message",
  "code": "ERROR_CODE"
}
```

Common HTTP status codes:
- `400`: Bad Request
- `401`: Unauthorized
- `403`: Forbidden
- `404`: Not Found
- `500`: Internal Server Error




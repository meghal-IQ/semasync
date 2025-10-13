# SemaSync Backend API

A comprehensive health tracking backend API built with Node.js, Express, TypeScript, and MongoDB.

## Features

- 🔐 **Authentication System**
  - User registration and login
  - JWT-based authentication
  - Email verification
  - Password reset functionality
  - Rate limiting and security

- 📊 **Health Tracking Modules**
  - Activity & Fitness tracking
  - Nutrition & Diet logging
  - Medical treatment management
  - Weight and body metrics
  - AI-powered food recognition

## Tech Stack

- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Language**: TypeScript
- **Database**: MongoDB
- **Cache**: Redis
- **Authentication**: JWT
- **Email**: Nodemailer
- **Security**: Helmet, bcryptjs
- **Validation**: express-validator

## Prerequisites

- Node.js 18+ 
- MongoDB 7.0+
- Redis 7+
- Docker (optional)

## Quick Start

### Using Docker (Recommended)

1. Clone the repository
2. Copy environment variables:
   ```bash
   cp env.example .env
   ```
3. Update `.env` with your configuration
4. Start services:
   ```bash
   docker-compose up -d
   ```

### Manual Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Set up environment variables:
   ```bash
   cp env.example .env
   # Edit .env with your configuration
   ```

3. Start MongoDB and Redis

4. Run in development:
   ```bash
   npm run dev
   ```

5. Build and run in production:
   ```bash
   npm run build
   npm start
   ```

## Environment Variables

```env
# Database
MONGODB_URI=mongodb://localhost:27017/semasync
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=your-super-secret-jwt-key-here
JWT_REFRESH_SECRET=your-super-secret-refresh-key-here
JWT_EXPIRE=24h
JWT_REFRESH_EXPIRE=7d

# Email Configuration
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password

# App Configuration
NODE_ENV=development
PORT=5000
CLIENT_URL=http://localhost:3000
```

## API Endpoints

### Authentication

- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `POST /api/auth/refresh` - Refresh access token
- `GET /api/auth/me` - Get current user
- `POST /api/auth/verify-email` - Verify email address
- `POST /api/auth/resend-verification` - Resend verification email
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/reset-password` - Reset password
- `POST /api/auth/change-password` - Change password

### Health Check

- `GET /health` - API health status

## API Documentation

### Register User (Comprehensive)

```bash
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe",
  "dateOfBirth": "1990-01-01",
  "gender": "male",
  "height": 175,
  "weight": 70,
  "preferredUnits": {
    "weight": "kg",
    "height": "cm", 
    "distance": "km"
  },
  "glp1Journey": {
    "medication": "Ozempic®",
    "startingDose": "0.25mg",
    "frequency": "Every 7 days (most common)",
    "injectionDays": ["Monday"],
    "startDate": "2024-01-15",
    "currentDose": "0.25mg"
  },
  "motivation": "I want to feel more confident in my own skin.",
  "concerns": ["Nausea", "Fatigue", "Injection Anxiety"],
  "goals": {
    "targetWeight": 60,
    "targetDate": "2024-12-31",
    "primaryGoal": "Weight loss",
    "secondaryGoals": ["Improved energy", "Better mood"]
  }
}
```

**Available Options:**

**Medications:**
- Zepbound®, Mounjaro®, Ozempic®, Wegovy®, Trulicity®, Compounded Semaglutide, Compounded Tirzepatide

**Starting Doses:**
- 0.25mg, 0.5mg, 1.0mg, 1.7mg, 2.4mg

**Frequency Options:**
- Every day
- Every 7 days (most common)
- Every 14 days
- Custom
- Not sure, still figuring it out

**Motivation Options:**
- I want to feel more confident in my own skin.
- I'm just ready for a fresh start.
- I want to boost my energy and strength.
- To improve my health and manage PCOS.
- I want to show up for the people I love.
- I have a special event or milestone coming up.
- To feel good wearing the clothes I love again.

**Concerns (Side Effects):**
- Nausea, Fatigue, Hair Loss, Muscle Loss, Injection Anxiety, Loose Skin

### Login User

```bash
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

### Get Current User

```bash
GET /api/auth/me
Authorization: Bearer <access_token>
```

## Database Schema

### User Model (Comprehensive)

```typescript
{
  // Basic Authentication
  email: string;
  password: string;
  username?: string;
  phoneNumber?: string;
  isEmailVerified: boolean;
  isPhoneVerified: boolean;
  accountStatus: 'active' | 'suspended' | 'deleted';
  
  // Profile Information
  firstName: string;
  lastName: string;
  dateOfBirth: Date;
  gender: 'male' | 'female' | 'other';
  
  // Physical Measurements
  height: number;
  weight: number;
  preferredUnits: {
    weight: 'kg' | 'lbs';
    height: 'cm' | 'ft';
    distance: 'km' | 'miles';
  };
  
  // GLP-1 Journey Information
  glp1Journey: {
    medication: string;
    startingDose: string;
    frequency: string;
    injectionDays?: string[];
    startDate?: Date;
    currentDose?: string;
    isActive: boolean;
  };
  
  // Motivation and Goals
  motivation: string;
  concerns: string[];
  goals: {
    targetWeight?: number;
    targetDate?: Date;
    primaryGoal: string;
    secondaryGoals?: string[];
  };
  
  // Security
  refreshToken?: string;
  passwordResetToken?: string;
  passwordResetExpires?: Date;
  twoFactorEnabled: boolean;
}
```

## Security Features

- Password hashing with bcrypt
- JWT-based authentication
- Rate limiting
- CORS protection
- Input validation and sanitization
- Helmet security headers
- Account lockout after failed attempts

## Development

### Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm start` - Start production server
- `npm test` - Run tests

### Project Structure

```
src/
├── config/          # Configuration files
├── middleware/      # Custom middleware
├── models/          # Database models
├── routes/          # API routes
├── utils/           # Utility functions
└── index.ts         # Application entry point
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

MIT License - see LICENSE file for details

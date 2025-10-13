import request from 'supertest';
import express from 'express';
import mongoose from 'mongoose';
import User from '../src/models/User';
import authRoutes from '../src/routes/auth';
import { generateTokens } from '../src/utils/auth';

// Create test app
const app = express();
app.use(express.json());
app.use('/api/auth', authRoutes);

describe('Authentication API Tests', () => {
  let testUser: any;
  let accessToken: string;
  let refreshToken: string;

  const validUserData = {
    email: 'test@example.com',
    password: 'password123',
    firstName: 'John',
    lastName: 'Doe',
    dateOfBirth: '1990-01-01',
    gender: 'male',
    height: 175,
    weight: 70,
    preferredUnits: {
      weight: 'kg',
      height: 'cm',
      distance: 'km'
    },
    glp1Journey: {
      medication: 'Ozempic®',
      startingDose: '0.25mg',
      frequency: 'Every 7 days (most common)',
      injectionDays: ['Monday'],
      startDate: '2024-01-15'
    },
    motivation: 'I want to feel more confident in my own skin.',
    concerns: ['Nausea', 'Fatigue'],
    goals: {
      targetWeight: 60,
      targetDate: '2024-12-31',
      primaryGoal: 'Weight loss',
      secondaryGoals: ['Improved energy']
    }
  };

  describe('POST /api/auth/register', () => {
    it('should register a new user successfully', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send(validUserData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('User registered successfully');
      expect(response.body.data.user.email).toBe(validUserData.email);
      expect(response.body.data.user.firstName).toBe(validUserData.firstName);
      expect(response.body.data.user.glp1Journey.medication).toBe(validUserData.glp1Journey.medication);
      expect(response.body.data.user.motivation).toBe(validUserData.motivation);
      expect(response.body.data.user.concerns).toEqual(validUserData.concerns);
      expect(response.body.data.tokens.accessToken).toBeDefined();
      expect(response.body.data.tokens.refreshToken).toBeDefined();

      // Store user data for other tests
      testUser = response.body.data.user;
      accessToken = response.body.data.tokens.accessToken;
      refreshToken = response.body.data.tokens.refreshToken;
    });

    it('should not register user with existing email', async () => {
      // First registration should succeed
      await request(app)
        .post('/api/auth/register')
        .send(validUserData)
        .expect(201);

      // Second registration with same email should fail
      const response = await request(app)
        .post('/api/auth/register')
        .send(validUserData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toBe('User already exists with this email');
    });

    it('should validate required fields', async () => {
      const invalidData = {
        email: 'invalid-email',
        password: '123',
        firstName: '',
        dateOfBirth: 'invalid-date',
        gender: 'invalid',
        height: 10,
        weight: 5
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(invalidData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toBe('Validation failed');
      expect(response.body.errors).toBeDefined();
      expect(response.body.errors.length).toBeGreaterThan(0);
    });

    it('should validate GLP-1 journey data', async () => {
      const invalidGlp1Data = {
        ...validUserData,
        email: 'test2@example.com',
        glp1Journey: {
          medication: 'Invalid Medication',
          startingDose: 'Invalid Dose',
          frequency: 'Invalid Frequency'
        }
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(invalidGlp1Data)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });

    it('should validate motivation options', async () => {
      const invalidMotivationData = {
        ...validUserData,
        email: 'test3@example.com',
        motivation: 'Invalid motivation'
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(invalidMotivationData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });

    it('should validate concerns array', async () => {
      const invalidConcernsData = {
        ...validUserData,
        email: 'test4@example.com',
        concerns: ['Invalid Concern', 'Nausea']
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(invalidConcernsData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });
  });

  describe('POST /api/auth/login', () => {
    beforeEach(async () => {
      // Create a user for login tests
      const user = new User(validUserData);
      await user.save();
      testUser = user;
    });

    it('should login with valid credentials', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: validUserData.email,
          password: validUserData.password
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('Login successful');
      expect(response.body.data.user.email).toBe(validUserData.email);
      expect(response.body.data.tokens.accessToken).toBeDefined();
      expect(response.body.data.tokens.refreshToken).toBeDefined();
      expect(response.body.data.user.lastLogin).toBeDefined();

      accessToken = response.body.data.tokens.accessToken;
      refreshToken = response.body.data.tokens.refreshToken;
    });

    it('should not login with invalid email', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'nonexistent@example.com',
          password: validUserData.password
        })
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toBe('Invalid credentials');
    });

    it('should not login with invalid password', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: validUserData.email,
          password: 'wrongpassword'
        })
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toBe('Invalid credentials');
    });

    it('should validate login input', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'invalid-email',
          password: ''
        })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toBe('Validation failed');
    });
  });

  describe('GET /api/auth/me', () => {
    beforeEach(async () => {
      // Create a user and get tokens
      const user = new User(validUserData);
      await user.save();
      const tokens = generateTokens(user);
      accessToken = tokens.accessToken;
    });

    it('should get current user with valid token', async () => {
      const response = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.user.email).toBe(validUserData.email);
      expect(response.body.data.user.firstName).toBe(validUserData.firstName);
    });

    it('should not get user without token', async () => {
      const response = await request(app)
        .get('/api/auth/me')
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toBe('Access denied. No token provided.');
    });

    it('should not get user with invalid token', async () => {
      const response = await request(app)
        .get('/api/auth/me')
        .set('Authorization', 'Bearer invalid-token')
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toBe('Invalid token.');
    });
  });

  describe('POST /api/auth/refresh', () => {
    beforeEach(async () => {
      // Create a user and get tokens
      const user = new User(validUserData);
      user.refreshToken = 'test-refresh-token';
      await user.save();
      testUser = user;
      refreshToken = 'test-refresh-token';
    });

    it('should refresh tokens with valid refresh token', async () => {
      // Mock the verifyRefreshToken function
      jest.spyOn(require('../src/utils/auth'), 'verifyRefreshToken').mockReturnValue({
        userId: testUser._id.toString(),
        email: testUser.email
      });

      const response = await request(app)
        .post('/api/auth/refresh')
        .send({ refreshToken })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.tokens.accessToken).toBeDefined();
      expect(response.body.data.tokens.refreshToken).toBeDefined();
    });

    it('should not refresh with invalid refresh token', async () => {
      const response = await request(app)
        .post('/api/auth/refresh')
        .send({ refreshToken: 'invalid-refresh-token' })
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toBe('Invalid refresh token');
    });
  });

  describe('POST /api/auth/logout', () => {
    beforeEach(async () => {
      // Create a user and get tokens
      const user = new User(validUserData);
      await user.save();
      const tokens = generateTokens(user);
      accessToken = tokens.accessToken;
    });

    it('should logout successfully', async () => {
      const response = await request(app)
        .post('/api/auth/logout')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('Logged out successfully');
    });

    it('should not logout without token', async () => {
      const response = await request(app)
        .post('/api/auth/logout')
        .expect(401);

      expect(response.body.success).toBe(false);
    });
  });

  describe('POST /api/auth/forgot-password', () => {
    beforeEach(async () => {
      const user = new User(validUserData);
      await user.save();
    });

    it('should send password reset email for existing user', async () => {
      const response = await request(app)
        .post('/api/auth/forgot-password')
        .send({ email: validUserData.email })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toContain('password reset link');
    });

    it('should return same message for non-existent user (security)', async () => {
      const response = await request(app)
        .post('/api/auth/forgot-password')
        .send({ email: 'nonexistent@example.com' })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toContain('password reset link');
    });

    it('should require email input', async () => {
      const response = await request(app)
        .post('/api/auth/forgot-password')
        .send({})
        .expect(400);

      expect(response.body.success).toBe(false);
    });
  });

  describe('POST /api/auth/verify-email', () => {
    it('should verify email with valid token', async () => {
      // Create user
      const user = new User(validUserData);
      await user.save();

      // Mock JWT verification
      jest.spyOn(require('jsonwebtoken'), 'verify').mockReturnValue({
        userId: user._id.toString(),
        type: 'email_verification'
      });

      const response = await request(app)
        .post('/api/auth/verify-email')
        .send({ token: 'valid-token' })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('Email verified successfully');

      // Check if user is verified
      const updatedUser = await User.findById(user._id);
      expect(updatedUser?.isEmailVerified).toBe(true);
    });

    it('should not verify with invalid token', async () => {
      // Mock JWT verification to throw error
      jest.spyOn(require('jsonwebtoken'), 'verify').mockImplementation(() => {
        throw new Error('Invalid token');
      });

      const response = await request(app)
        .post('/api/auth/verify-email')
        .send({ token: 'invalid-token' })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toBe('Invalid or expired token');
    });
  });

  describe('User Model Tests', () => {
    it('should hash password before saving', async () => {
      const user = new User(validUserData);
      await user.save();

      expect(user.password).not.toBe(validUserData.password);
      expect(user.password.length).toBeGreaterThan(50); // bcrypt hash length
    });

    it('should compare password correctly', async () => {
      const user = new User(validUserData);
      await user.save();

      const isMatch = await user.comparePassword(validUserData.password);
      expect(isMatch).toBe(true);

      const isNotMatch = await user.comparePassword('wrongpassword');
      expect(isNotMatch).toBe(false);
    });

    it('should generate password reset token', async () => {
      const user = new User(validUserData);
      await user.save();

      const resetToken = user.generatePasswordResetToken();
      expect(resetToken).toBeDefined();
      expect(resetToken.length).toBe(64); // hex string length
      expect(user.passwordResetToken).toBeDefined();
      expect(user.passwordResetExpires).toBeDefined();
    });

    it('should transform user object correctly', async () => {
      const user = new User(validUserData);
      await user.save();

      const userObj = user.toJSON();
      expect(userObj.password).toBeUndefined();
      expect(userObj.refreshToken).toBeUndefined();
      expect(userObj.passwordResetToken).toBeUndefined();
      expect(userObj.passwordResetExpires).toBeUndefined();
      expect(userObj.twoFactorSecret).toBeUndefined();
    });
  });
});

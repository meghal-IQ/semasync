import request from 'supertest';
import express from 'express';
import mongoose from 'mongoose';
import authRoutes from '../src/routes/auth';
import { createTestUser, createTestTokens, validUserData } from './utils/testUtils';

// Create test app
const app = express();
app.use(express.json());
app.use('/api/auth', authRoutes);

describe('Integration Tests', () => {
  let testUser: any;
  let accessToken: string;
  let refreshToken: string;

  describe('Complete Authentication Flow', () => {
    it('should complete full user journey', async () => {
      // Step 1: Register user
      const registerResponse = await request(app)
        .post('/api/auth/register')
        .send(validUserData)
        .expect(201);

      expect(registerResponse.body.success).toBe(true);
      expect(registerResponse.body.data.user.email).toBe(validUserData.email);
      
      testUser = registerResponse.body.data.user;
      accessToken = registerResponse.body.data.tokens.accessToken;
      refreshToken = registerResponse.body.data.tokens.refreshToken;

      // Step 2: Get current user
      const meResponse = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(meResponse.body.success).toBe(true);
      expect(meResponse.body.data.user.email).toBe(validUserData.email);

      // Step 3: Refresh token
      const refreshResponse = await request(app)
        .post('/api/auth/refresh')
        .send({ refreshToken })
        .expect(200);

      expect(refreshResponse.body.success).toBe(true);
      expect(refreshResponse.body.data.tokens.accessToken).toBeDefined();

      // Update tokens
      accessToken = refreshResponse.body.data.tokens.accessToken;
      refreshToken = refreshResponse.body.data.tokens.refreshToken;

      // Step 4: Verify new token works
      const meResponse2 = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(meResponse2.body.success).toBe(true);

      // Step 5: Logout
      const logoutResponse = await request(app)
        .post('/api/auth/logout')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(logoutResponse.body.success).toBe(true);
    });
  });

  describe('User Data Integrity', () => {
    it('should maintain data consistency across operations', async () => {
      // Register user with comprehensive data
      const userData = {
        ...validUserData,
        email: 'integrity@example.com',
        concerns: ['Nausea', 'Fatigue', 'Injection Anxiety'],
        goals: {
          targetWeight: 65,
          targetDate: '2024-12-31',
          primaryGoal: 'Weight loss',
          secondaryGoals: ['Improved energy', 'Better mood', 'Increased strength']
        }
      };

      const registerResponse = await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(201);

      const user = registerResponse.body.data.user;
      expect(user.concerns.length).toBe(3);
      expect(user.goals.secondaryGoals.length).toBe(3);
      expect(user.glp1Journey.medication).toBe('Ozempic®');
      expect(user.motivation).toBe(userData.motivation);

      // Login and verify data consistency
      const loginResponse = await request(app)
        .post('/api/auth/login')
        .send({
          email: userData.email,
          password: userData.password
        })
        .expect(200);

      const loggedInUser = loginResponse.body.data.user;
      expect(loggedInUser.concerns).toEqual(user.concerns);
      expect(loggedInUser.goals).toEqual(user.goals);
      expect(loggedInUser.glp1Journey).toEqual(user.glp1Journey);
      expect(loggedInUser.motivation).toEqual(user.motivation);
    });
  });

  describe('Error Handling', () => {
    it('should handle multiple registration attempts gracefully', async () => {
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

    it('should handle invalid authentication gracefully', async () => {
      // Try to access protected route without token
      const response = await request(app)
        .get('/api/auth/me')
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toBe('Access denied. No token provided.');
    });
  });

  describe('Data Validation Edge Cases', () => {
    it('should handle empty concerns array', async () => {
      const userData = {
        ...validUserData,
        email: 'empty-concerns@example.com',
        concerns: []
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(201);

      expect(response.body.data.user.concerns).toEqual([]);
    });

    it('should handle optional goal fields', async () => {
      const userData = {
        ...validUserData,
        email: 'minimal-goals@example.com',
        goals: {
          primaryGoal: 'Weight loss'
        }
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(201);

      expect(response.body.data.user.goals.primaryGoal).toBe('Weight loss');
      expect(response.body.data.user.goals.targetWeight).toBeUndefined();
      expect(response.body.data.user.goals.targetDate).toBeUndefined();
    });
  });
});

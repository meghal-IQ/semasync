/**
 * @swagger
 * components:
 *   tags:
 *     - name: Authentication
 *       description: User authentication and management endpoints
 */

import express from 'express';
import { body, validationResult } from 'express-validator';
import User, { IUser } from '../models/User';
import { generateTokens, verifyRefreshToken, generateEmailVerificationToken } from '../utils/auth';
import { authenticate, AuthRequest } from '../middleware/auth';
import { sendEmail } from '../utils/email';
import jwt from 'jsonwebtoken';

const router = express.Router();

// Validation rules
const registerValidation = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long'),
  body('firstName')
    .trim()
    .isLength({ min: 1, max: 50 })
    .withMessage('First name is required and must be less than 50 characters'),
  body('lastName')
    .trim()
    .isLength({ min: 1, max: 50 })
    .withMessage('Last name is required and must be less than 50 characters'),
  body('dateOfBirth')
    .isISO8601()
    .withMessage('Please provide a valid date of birth'),
  body('gender')
    .isIn(['male', 'female', 'other'])
    .withMessage('Gender must be male, female, or other'),
  body('height')
    .isFloat({ min: 50, max: 300 })
    .withMessage('Height must be between 50 and 300 cm'),
  body('weight')
    .isFloat({ min: 20, max: 500 })
    .withMessage('Weight must be between 20 and 500 kg'),
  body('preferredUnits.weight')
    .optional()
    .isIn(['kg', 'lbs'])
    .withMessage('Weight unit must be kg or lbs'),
  body('preferredUnits.height')
    .optional()
    .isIn(['cm', 'ft'])
    .withMessage('Height unit must be cm or ft'),
  body('preferredUnits.distance')
    .optional()
    .isIn(['km', 'miles'])
    .withMessage('Distance unit must be km or miles'),
  body('glp1Journey.medication')
    .isIn([
      'Zepbound®',
      'Mounjaro®', 
      'Ozempic®',
      'Wegovy®',
      'Trulicity®',
      'Compounded Semaglutide',
      'Compounded Tirzepatide'
    ])
    .withMessage('Please select a valid medication'),
  body('glp1Journey.startingDose')
    .isIn(['0.25mg', '0.5mg', '1.0mg', '1.7mg', '2.4mg'])
    .withMessage('Please select a valid starting dose'),
  body('glp1Journey.frequency')
    .isIn([
      'Every day',
      'Every 7 days (most common)',
      'Every 14 days',
      'Custom',
      'Not sure, still figuring it out'
    ])
    .withMessage('Please select a valid frequency'),
  body('glp1Journey.startDate')
    .optional()
    .isISO8601()
    .withMessage('Start date must be a valid date'),
  body('motivation')
    .isIn([
      'I want to feel more confident in my own skin.',
      'I\'m just ready for a fresh start.',
      'I want to boost my energy and strength.',
      'To improve my health and manage PCOS.',
      'I want to show up for the people I love.',
      'I have a special event or milestone coming up.',
      'To feel good wearing the clothes I love again.'
    ])
    .withMessage('Please select a valid motivation'),
  body('concerns')
    .isArray()
    .withMessage('Concerns must be an array'),
  body('concerns.*')
    .isIn([
      'Nausea',
      'Fatigue', 
      'Hair Loss',
      'Muscle Loss',
      'Injection Anxiety',
      'Loose Skin'
    ])
    .withMessage('Each concern must be from the valid list'),
  body('goals.targetWeight')
    .optional()
    .isFloat({ min: 20, max: 500 })
    .withMessage('Target weight must be between 20 and 500 kg'),
  body('goals.targetDate')
    .optional()
    .isISO8601()
    .withMessage('Target date must be a valid date'),
  body('goals.primaryGoal')
    .optional()
    .isString()
    .withMessage('Primary goal must be a string'),
  body('goals.secondaryGoals')
    .optional()
    .isArray()
    .withMessage('Secondary goals must be an array')
];

const loginValidation = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email'),
  body('password')
    .notEmpty()
    .withMessage('Password is required')
];

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     summary: Register a new user
 *     description: Create a new user account with comprehensive health tracking data including GLP-1 journey details, physical measurements, motivation, concerns, and health goals.
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/RegisterRequest'
 *           example:
 *             email: "user@example.com"
 *             password: "password123"
 *             firstName: "John"
 *             lastName: "Doe"
 *             dateOfBirth: "1990-01-01"
 *             gender: "male"
 *             height: 175
 *             weight: 70
 *             preferredUnits:
 *               weight: "kg"
 *               height: "cm"
 *               distance: "km"
 *             glp1Journey:
 *               medication: "Ozempic®"
 *               startingDose: "0.25mg"
 *               frequency: "Every 7 days (most common)"
 *               injectionDays: ["Monday"]
 *               startDate: "2024-01-15"
 *             motivation: "I want to feel more confident in my own skin."
 *             concerns: ["Nausea", "Fatigue"]
 *             goals:
 *               targetWeight: 60
 *               targetDate: "2024-12-31"
 *               primaryGoal: "Weight loss"
 *               secondaryGoals: ["Improved energy"]
 *     responses:
 *       201:
 *         description: User registered successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/AuthResponse'
 *       400:
 *         description: Validation failed or user already exists
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ValidationError'
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ApiResponse'
 */
// Register
router.post('/register', registerValidation, async (req: express.Request, res: express.Response) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { 
      email, 
      password, 
      firstName, 
      lastName, 
      dateOfBirth, 
      gender, 
      height, 
      weight,
      preferredUnits,
      glp1Journey,
      motivation,
      concerns,
      goals
    } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'User already exists with this email'
      });
    }

    // Create new user with comprehensive data
    const user = new User({
      email,
      password,
      firstName,
      lastName,
      dateOfBirth: new Date(dateOfBirth),
      gender,
      height,
      weight,
      preferredUnits: preferredUnits || {
        weight: 'lbs',
        height: 'ft',
        distance: 'miles'
      },
      glp1Journey: {
        medication: glp1Journey.medication,
        startingDose: glp1Journey.startingDose,
        frequency: glp1Journey.frequency,
        injectionDays: glp1Journey.injectionDays || [],
        startDate: glp1Journey.startDate ? new Date(glp1Journey.startDate) : undefined,
        currentDose: glp1Journey.currentDose || glp1Journey.startingDose,
        isActive: true
      },
      motivation,
      concerns: concerns || [],
      goals: {
        targetWeight: goals?.targetWeight,
        targetDate: goals?.targetDate ? new Date(goals.targetDate) : undefined,
        primaryGoal: goals?.primaryGoal || 'Weight loss',
        secondaryGoals: goals?.secondaryGoals || []
      }
    });

    await user.save();

    // Generate tokens
    const { accessToken, refreshToken } = generateTokens(user);

    // Update user with refresh token
    user.refreshToken = refreshToken;
    await user.save();

    // Send verification email
    try {
      const verificationToken = generateEmailVerificationToken(user._id.toString());
      await sendEmail({
        to: user.email,
        subject: 'Verify your SemaSync account',
        html: `
          <h2>Welcome to SemaSync!</h2>
          <p>Please click the link below to verify your email address:</p>
          <a href="${process.env.CLIENT_URL}/verify-email?token=${verificationToken}">
            Verify Email
          </a>
          <p>This link will expire in 24 hours.</p>
        `
      });
    } catch (emailError) {
      console.error('Email sending failed:', emailError);
      // Don't fail registration if email fails
    }

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        user: user.toJSON(),
        tokens: {
          accessToken,
          refreshToken
        }
      }
    });
  } catch (error: any) {
    console.error('Registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: Login user
 *     description: Authenticate user with email and password, returns access and refresh tokens.
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/LoginRequest'
 *           example:
 *             email: "user@example.com"
 *             password: "password123"
 *     responses:
 *       200:
 *         description: Login successful
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/AuthResponse'
 *       400:
 *         description: Validation failed
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ValidationError'
 *       401:
 *         description: Invalid credentials
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ApiResponse'
 */
// Login
router.post('/login', loginValidation, async (req: express.Request, res: express.Response) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { email, password } = req.body;

    // Find user and include password
    const user = await User.findOne({ email }).select('+password');
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Check account status
    if (user.accountStatus !== 'active') {
      return res.status(401).json({
        success: false,
        message: 'Account is not active'
      });
    }

    // Check failed login attempts
    if (user.failedLoginAttempts >= 5) {
      return res.status(401).json({
        success: false,
        message: 'Too many failed login attempts. Please try again later.'
      });
    }

    // Verify password
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      user.failedLoginAttempts += 1;
      await user.save();
      
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Reset failed login attempts and update last login
    user.failedLoginAttempts = 0;
    user.lastLogin = new Date();
    
    // Generate tokens
    const { accessToken, refreshToken } = generateTokens(user);
    user.refreshToken = refreshToken;
    
    await user.save();

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        user: user.toJSON(),
        tokens: {
          accessToken,
          refreshToken
        }
      }
    });
  } catch (error: any) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Refresh token
router.post('/refresh', async (req: express.Request, res: express.Response) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(401).json({
        success: false,
        message: 'Refresh token is required'
      });
    }

    // Verify refresh token
    const decoded = verifyRefreshToken(refreshToken);
    
    // Find user with refresh token
    const user = await User.findOne({ 
      _id: decoded.userId, 
      refreshToken 
    });

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid refresh token'
      });
    }

    // Generate new tokens
    const { accessToken, refreshToken: newRefreshToken } = generateTokens(user);
    
    // Update refresh token
    user.refreshToken = newRefreshToken;
    await user.save();

    res.json({
      success: true,
      data: {
        tokens: {
          accessToken,
          refreshToken: newRefreshToken
        }
      }
    });
  } catch (error: any) {
    console.error('Refresh token error:', error);
    res.status(401).json({
      success: false,
      message: 'Invalid refresh token'
    });
  }
});

// Logout
router.post('/logout', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const user = req.user!;
    
    // Remove refresh token
    user.refreshToken = undefined;
    await user.save();

    res.json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (error: any) {
    console.error('Logout error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

/**
 * @swagger
 * /api/auth/me:
 *   get:
 *     summary: Get current user profile
 *     description: Retrieve the authenticated user's profile information.
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User profile retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "User profile retrieved successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     user:
 *                       $ref: '#/components/schemas/User'
 *       401:
 *         description: Unauthorized - Invalid or missing token
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ApiResponse'
 */
// Get current user
router.get('/me', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    res.json({
      success: true,
      data: {
        user: req.user!.toJSON()
      }
    });
  } catch (error: any) {
    console.error('Get user error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Verify email
router.post('/verify-email', async (req: express.Request, res: express.Response) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        message: 'Verification token is required'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as { userId: string; type: string };
    
    if (decoded.type !== 'email_verification') {
      return res.status(400).json({
        success: false,
        message: 'Invalid token type'
      });
    }

    const user = await User.findById(decoded.userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    if (user.isEmailVerified) {
      return res.json({
        success: true,
        message: 'Email already verified'
      });
    }

    user.isEmailVerified = true;
    await user.save();

    res.json({
      success: true,
      message: 'Email verified successfully'
    });
  } catch (error: any) {
    console.error('Email verification error:', error);
    res.status(400).json({
      success: false,
      message: 'Invalid or expired token'
    });
  }
});

// Resend verification email
router.post('/resend-verification', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const user = req.user!;

    if (user.isEmailVerified) {
      return res.status(400).json({
        success: false,
        message: 'Email already verified'
      });
    }

    const verificationToken = generateEmailVerificationToken(user._id.toString());
    
    await sendEmail({
      to: user.email,
      subject: 'Verify your SemaSync account',
      html: `
        <h2>Verify your email address</h2>
        <p>Please click the link below to verify your email address:</p>
        <a href="${process.env.CLIENT_URL}/verify-email?token=${verificationToken}">
          Verify Email
        </a>
        <p>This link will expire in 24 hours.</p>
      `
    });

    res.json({
      success: true,
      message: 'Verification email sent'
    });
  } catch (error: any) {
    console.error('Resend verification error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send verification email'
    });
  }
});

// Forgot password
router.post('/forgot-password', async (req: express.Request, res: express.Response) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email is required'
      });
    }

    // Basic email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        success: false,
        message: 'Please provide a valid email'
      });
    }

    const user = await User.findOne({ email });
    if (!user) {
      // Don't reveal if user exists or not
      return res.json({
        success: true,
        message: 'If an account with that email exists, we have sent a password reset link.'
      });
    }

    const resetToken = user.generatePasswordResetToken();
    await user.save();

    try {
      await sendEmail({
        to: user.email,
        subject: 'Reset your SemaSync password',
        html: `
          <h2>Password Reset Request</h2>
          <p>You requested a password reset. Click the link below to reset your password:</p>
          <a href="${process.env.CLIENT_URL}/reset-password?token=${resetToken}">
            Reset Password
          </a>
          <p>This link will expire in 10 minutes.</p>
          <p>If you didn't request this, please ignore this email.</p>
        `
      });
    } catch (emailError) {
      user.passwordResetToken = undefined;
      user.passwordResetExpires = undefined;
      await user.save();
      throw emailError;
    }

    res.json({
      success: true,
      message: 'If an account with that email exists, we have sent a password reset link.'
    });
  } catch (error: any) {
    console.error('Forgot password error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Reset password
router.post('/reset-password', async (req: express.Request, res: express.Response) => {
  try {
    const { token, newPassword } = req.body;

    if (!token || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Token and new password are required'
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters long'
      });
    }

    const crypto = require('crypto');
    const hashedToken = crypto
      .createHash('sha256')
      .update(token)
      .digest('hex');

    const user = await User.findOne({
      passwordResetToken: hashedToken,
      passwordResetExpires: { $gt: Date.now() }
    }).select('+passwordResetToken +passwordResetExpires');

    if (!user) {
      return res.status(400).json({
        success: false,
        message: 'Invalid or expired token'
      });
    }

    user.password = newPassword;
    user.passwordResetToken = undefined;
    user.passwordResetExpires = undefined;
    user.failedLoginAttempts = 0;
    
    await user.save();

    res.json({
      success: true,
      message: 'Password reset successfully'
    });
  } catch (error: any) {
    console.error('Reset password error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Change password
router.post('/change-password', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Current password and new password are required'
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'New password must be at least 6 characters long'
      });
    }

    const user = await User.findById(req.user!._id).select('+password');
    
    const isCurrentPasswordValid = await user!.comparePassword(currentPassword);
    if (!isCurrentPasswordValid) {
      return res.status(400).json({
        success: false,
        message: 'Current password is incorrect'
      });
    }

    user!.password = newPassword;
    await user!.save();

    res.json({
      success: true,
      message: 'Password changed successfully'
    });
  } catch (error: any) {
    console.error('Change password error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

/**
 * @route   PUT /api/auth/profile
 * @desc    Update user profile
 * @access  Private
 */
router.put('/profile', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const updates = req.body;

    // Find and update user
    const user = await User.findByIdAndUpdate(
      userId,
      { $set: updates },
      { new: true, runValidators: true }
    ).select('-password -refreshToken');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: user
    });
  } catch (error: any) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update profile',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

export default router;

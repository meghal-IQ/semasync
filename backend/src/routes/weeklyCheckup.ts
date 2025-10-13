/**
 * Weekly Checkup Routes
 * 
 * Endpoints for weekly checkup functionality with Bayesian dosing recommendations
 */

import express from 'express';
import { body, query, validationResult } from 'express-validator';
import WeeklyCheckup from '../models/WeeklyCheckup';
import WeightLog from '../models/WeightLog';
import ShotLog from '../models/ShotLog';
import SideEffectLog from '../models/SideEffectLog';
import { authenticate, AuthRequest } from '../middleware/auth';

const router = express.Router();

// ============================================================================
// WEEKLY CHECKUP MANAGEMENT
// ============================================================================

/**
 * @route   POST /api/treatments/weekly-checkup
 * @desc    Create a new weekly checkup with dosage recommendation
 * @access  Private
 */
router.post('/', authenticate, [
  body('date').optional().isISO8601(),
  body('currentWeight').isFloat({ min: 20, max: 500 }),
  body('weightUnit').isIn(['kg', 'lbs']),
  body('sideEffects').isArray(),
  body('overallSideEffectSeverity').isFloat({ min: 0, max: 10 }),
  body('notes').optional().isLength({ max: 500 }),
  body('dosageRecommendation').optional().isString(),
  body('recommendationReason').optional().isString(),
  body('bayesianFactors').optional().isObject(),
  body('weightChange').optional().isFloat(),
  body('weightChangePercent').optional().isFloat(),
], async (req: AuthRequest, res: express.Response) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const userId = req.user!._id;
    const {
      date,
      currentWeight,
      weightUnit,
      sideEffects,
      overallSideEffectSeverity,
      notes,
      dosageRecommendation,
      recommendationReason,
      bayesianFactors,
      weightChange,
      weightChangePercent
    } = req.body;

    const weeklyCheckup = new WeeklyCheckup({
      userId,
      date: date ? new Date(date) : new Date(),
      currentWeight,
      weightUnit,
      weightChange,
      weightChangePercent,
      sideEffects,
      overallSideEffectSeverity,
      dosageRecommendation: dosageRecommendation || 'continueCurrent',
      recommendationReason: recommendationReason || 'No specific reason provided',
      bayesianFactors: bayesianFactors || {},
      notes
    });

    await weeklyCheckup.save();

    res.status(201).json({
      success: true,
      message: 'Weekly checkup created successfully',
      data: weeklyCheckup
    });
  } catch (error: any) {
    console.error('Create weekly checkup error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create weekly checkup',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/treatments/weekly-checkup
 * @desc    Get weekly checkup history
 * @access  Private
 */
router.get('/', authenticate, [
  query('startDate').optional().isISO8601(),
  query('endDate').optional().isISO8601(),
  query('limit').optional().isInt({ min: 1, max: 100 }),
  query('page').optional().isInt({ min: 1 })
], async (req: AuthRequest, res: express.Response) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const userId = req.user!._id;
    const {
      startDate,
      endDate,
      limit = 50,
      page = 1
    } = req.query;

    // Build query
    const query: any = { userId };
    
    if (startDate || endDate) {
      query.date = {};
      if (startDate) query.date.$gte = new Date(startDate as string);
      if (endDate) query.date.$lte = new Date(endDate as string);
    }

    // Execute query with pagination
    const skip = (Number(page) - 1) * Number(limit);
    const checkups = await WeeklyCheckup.find(query)
      .sort({ date: -1 })
      .limit(Number(limit))
      .skip(skip);

    const total = await WeeklyCheckup.countDocuments(query);

    res.json({
      success: true,
      data: {
        checkups,
        pagination: {
          total,
          page: Number(page),
          limit: Number(limit),
          pages: Math.ceil(total / Number(limit))
        }
      }
    });
  } catch (error: any) {
    console.error('Get weekly checkups error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get weekly checkups',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/treatments/weekly-checkup/latest
 * @desc    Get the latest weekly checkup
 * @access  Private
 */
router.get('/latest', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;

    const latestCheckup = await WeeklyCheckup.findOne({ userId })
      .sort({ date: -1 });

    res.json({
      success: true,
      data: latestCheckup
    });
  } catch (error: any) {
    console.error('Get latest weekly checkup error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get latest weekly checkup',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/treatments/weekly-checkup/analytics
 * @desc    Get weekly checkup analytics and trends
 * @access  Private
 */
router.get('/analytics', authenticate, [
  query('weeks').optional().isInt({ min: 1, max: 52 })
], async (req: AuthRequest, res: express.Response) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const userId = req.user!._id;
    const weeks = parseInt(req.query.weeks as string) || 12;

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - (weeks * 7));

    const checkups = await WeeklyCheckup.find({
      userId,
      date: { $gte: startDate }
    }).sort({ date: 1 });

    // Calculate analytics
    const totalCheckups = checkups.length;
    const averageWeightChange = checkups
      .filter(c => c.weightChange != null)
      .reduce((sum, c) => sum + (c.weightChange || 0), 0) / 
      checkups.filter(c => c.weightChange != null).length || 0;

    const averageSideEffectSeverity = checkups
      .reduce((sum, c) => sum + c.overallSideEffectSeverity, 0) / totalCheckups || 0;

    // Recommendation distribution
    const recommendationDistribution = checkups.reduce((acc, checkup) => {
      const rec = checkup.dosageRecommendation;
      acc[rec] = (acc[rec] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    // Weight trend
    const weightTrend = checkups.map(c => ({
      date: c.date,
      weight: c.currentWeight,
      change: c.weightChange || 0
    }));

    // Side effect trend
    const sideEffectTrend = checkups.map(c => ({
      date: c.date,
      severity: c.overallSideEffectSeverity,
      count: c.sideEffects.length
    }));

    // Bayesian confidence trends
    const confidenceTrend = checkups.map(c => ({
      date: c.date,
      confidence: c.bayesianFactors.confidenceLevel || 'unknown',
      posteriorProbability: c.bayesianFactors.posteriorProbability || 0
    }));

    res.json({
      success: true,
      data: {
        totalCheckups,
        averageWeightChange,
        averageSideEffectSeverity,
        recommendationDistribution,
        weightTrend,
        sideEffectTrend,
        confidenceTrend,
        period: {
          weeks,
          startDate,
          endDate: new Date()
        }
      }
    });
  } catch (error: any) {
    console.error('Get weekly checkup analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get weekly checkup analytics',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   PUT /api/treatments/weekly-checkup/:id
 * @desc    Update a weekly checkup
 * @access  Private
 */
router.put('/:id', authenticate, [
  body('date').optional().isISO8601(),
  body('currentWeight').optional().isFloat({ min: 20, max: 500 }),
  body('weightUnit').optional().isIn(['kg', 'lbs']),
  body('sideEffects').optional().isArray(),
  body('overallSideEffectSeverity').optional().isFloat({ min: 0, max: 10 }),
  body('notes').optional().isLength({ max: 500 }),
  body('dosageRecommendation').optional().isString(),
  body('recommendationReason').optional().isString(),
  body('bayesianFactors').optional().isObject(),
  body('weightChange').optional().isFloat(),
  body('weightChangePercent').optional().isFloat(),
], async (req: AuthRequest, res: express.Response) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const userId = req.user!._id;
    const checkupId = req.params.id;

    const checkup = await WeeklyCheckup.findOne({ _id: checkupId, userId });
    if (!checkup) {
      return res.status(404).json({
        success: false,
        message: 'Weekly checkup not found'
      });
    }

    // Update fields
    const updateData = req.body;
    Object.assign(checkup, updateData);
    await checkup.save();

    res.json({
      success: true,
      message: 'Weekly checkup updated successfully',
      data: checkup
    });
  } catch (error: any) {
    console.error('Update weekly checkup error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update weekly checkup',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   DELETE /api/treatments/weekly-checkup/:id
 * @desc    Delete a weekly checkup
 * @access  Private
 */
router.delete('/:id', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const checkupId = req.params.id;

    const checkup = await WeeklyCheckup.findOneAndDelete({ _id: checkupId, userId });
    if (!checkup) {
      return res.status(404).json({
        success: false,
        message: 'Weekly checkup not found'
      });
    }

    res.json({
      success: true,
      message: 'Weekly checkup deleted successfully'
    });
  } catch (error: any) {
    console.error('Delete weekly checkup error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete weekly checkup',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

export default router;

/**
 * Health Tracking Routes
 * 
 * Endpoints for weight, side effects, and photo progress logging
 */

import express from 'express';
import { body, query, validationResult } from 'express-validator';
import WeightLog from '../models/WeightLog';
import SideEffectLog from '../models/SideEffectLog';
import PhotoLog from '../models/PhotoLog';
import { authenticate, AuthRequest } from '../middleware/auth';

const router = express.Router();

// ============================================================================
// WEIGHT TRACKING
// ============================================================================

/**
 * @route   POST /api/health/weight
 * @desc    Log weight entry
 * @access  Private
 */
router.post('/weight', authenticate, [
  body('date').optional().isISO8601(),
  body('weight').isFloat({ min: 20, max: 500 }),
  body('unit').isIn(['kg', 'lbs']),
  body('bodyFat').optional().isFloat({ min: 0, max: 100 }),
  body('muscleMass').optional().isFloat({ min: 0 }),
  body('notes').optional().isLength({ max: 500 })
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
    const { date, weight, unit, bodyFat, muscleMass, notes, photoUrl } = req.body;

    const weightLog = new WeightLog({
      userId,
      date: date ? new Date(date) : new Date(),
      weight,
      unit,
      bodyFat,
      muscleMass,
      notes,
      photoUrl
    });

    await weightLog.save();

    res.status(201).json({
      success: true,
      message: 'Weight logged successfully',
      data: weightLog
    });
  } catch (error: any) {
    console.error('Log weight error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to log weight',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/health/weight
 * @desc    Get weight history
 * @access  Private
 */
router.get('/weight', authenticate, [
  query('startDate').optional().isISO8601(),
  query('endDate').optional().isISO8601(),
  query('limit').optional().isInt({ min: 1, max: 100 }),
  query('page').optional().isInt({ min: 1 })
], async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const { startDate, endDate, limit = 50, page = 1 } = req.query;

    const query: any = { userId };
    
    if (startDate || endDate) {
      query.date = {};
      if (startDate) query.date.$gte = new Date(startDate as string);
      if (endDate) query.date.$lte = new Date(endDate as string);
    }

    const skip = (Number(page) - 1) * Number(limit);
    const weights = await WeightLog.find(query)
      .sort({ date: -1 })
      .limit(Number(limit))
      .skip(skip);

    const total = await WeightLog.countDocuments(query);

    res.json({
      success: true,
      data: {
        weights,
        pagination: {
          total,
          page: Number(page),
          limit: Number(limit),
          pages: Math.ceil(total / Number(limit))
        }
      }
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve weight history',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/health/weight/stats
 * @desc    Get weight statistics and trends
 * @access  Private
 */
router.get('/weight/stats', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;

    const weights = await WeightLog.find({ userId }).sort({ date: 1 });

    if (weights.length === 0) {
      return res.json({
        success: true,
        data: {
          totalEntries: 0,
          message: 'No weight entries yet'
        }
      });
    }

    const firstWeight = weights[0];
    const latestWeight = weights[weights.length - 1];
    const weightChange = latestWeight.weight - firstWeight.weight;
    const percentChange = ((weightChange / firstWeight.weight) * 100);

    // Calculate 7-day and 30-day trends
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const lastWeekWeights = weights.filter(w => w.date >= sevenDaysAgo);
    const lastMonthWeights = weights.filter(w => w.date >= thirtyDaysAgo);

    const weekChange = lastWeekWeights.length >= 2 
      ? lastWeekWeights[lastWeekWeights.length - 1].weight - lastWeekWeights[0].weight
      : 0;

    const monthChange = lastMonthWeights.length >= 2
      ? lastMonthWeights[lastMonthWeights.length - 1].weight - lastMonthWeights[0].weight
      : 0;

    res.json({
      success: true,
      data: {
        totalEntries: weights.length,
        startingWeight: firstWeight.weight,
        currentWeight: latestWeight.weight,
        unit: latestWeight.unit,
        totalChange: Math.round(weightChange * 10) / 10,
        percentChange: Math.round(percentChange * 10) / 10,
        weekChange: Math.round(weekChange * 10) / 10,
        monthChange: Math.round(monthChange * 10) / 10,
        firstEntryDate: firstWeight.date,
        latestEntryDate: latestWeight.date,
        averageBodyFat: weights.filter(w => w.bodyFat).length > 0
          ? Math.round(weights.filter(w => w.bodyFat).reduce((sum, w) => sum + (w.bodyFat || 0), 0) / weights.filter(w => w.bodyFat).length * 10) / 10
          : null
      }
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Failed to calculate statistics',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   DELETE /api/health/weight/:id
 * @desc    Delete weight entry
 * @access  Private
 */
router.delete('/weight/:id', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const { id } = req.params;

    const weightLog = await WeightLog.findOneAndDelete({ _id: id, userId });

    if (!weightLog) {
      return res.status(404).json({
        success: false,
        message: 'Weight entry not found'
      });
    }

    res.json({
      success: true,
      message: 'Weight entry deleted successfully'
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Failed to delete weight entry',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// ============================================================================
// SIDE EFFECTS TRACKING
// ============================================================================

/**
 * @route   POST /api/health/side-effects
 * @desc    Log side effects
 * @access  Private
 */
router.post('/side-effects', authenticate, [
  body('date').optional().isISO8601(),
  body('effects').isArray(),
  body('effects.*.name').isString(),
  body('effects.*.severity').isFloat({ min: 0, max: 10 }),
  body('overallSeverity').isFloat({ min: 0, max: 10 }),
  body('relatedToShot').optional().isBoolean(),
  body('daysSinceShot').optional().isInt({ min: 0 }),
  body('notes').optional().isLength({ max: 500 })
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
    const { date, effects, overallSeverity, relatedToShot, daysSinceShot, notes } = req.body;

    const sideEffectLog = new SideEffectLog({
      userId,
      date: date ? new Date(date) : new Date(),
      effects,
      overallSeverity,
      relatedToShot,
      daysSinceShot,
      notes
    });

    await sideEffectLog.save();

    res.status(201).json({
      success: true,
      message: 'Side effects logged successfully',
      data: sideEffectLog
    });
  } catch (error: any) {
    console.error('Log side effects error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to log side effects',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/health/side-effects
 * @desc    Get side effects history
 * @access  Private
 */
router.get('/side-effects', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const { limit = 50, page = 1 } = req.query;

    const skip = (Number(page) - 1) * Number(limit);
    const sideEffects = await SideEffectLog.find({ userId })
      .sort({ date: -1 })
      .limit(Number(limit))
      .skip(skip);

    const total = await SideEffectLog.countDocuments({ userId });

    res.json({
      success: true,
      data: {
        sideEffects,
        pagination: {
          total,
          page: Number(page),
          limit: Number(limit),
          pages: Math.ceil(total / Number(limit))
        }
      }
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve side effects',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/health/side-effects/trends
 * @desc    Analyze side effect patterns
 * @access  Private
 */
router.get('/side-effects/trends', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;

    const sideEffects = await SideEffectLog.find({ userId }).sort({ date: 1 });

    if (sideEffects.length === 0) {
      return res.json({
        success: true,
        data: {
          totalLogs: 0,
          message: 'No side effects logged yet'
        }
      });
    }

    // Count frequency of each side effect
    const effectCounts: { [key: string]: number } = {};
    sideEffects.forEach(log => {
      log.effects.forEach(effect => {
        effectCounts[effect.name] = (effectCounts[effect.name] || 0) + 1;
      });
    });

    const mostCommon = Object.entries(effectCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([effect, count]) => ({ effect, count }));

    const avgSeverity = sideEffects.reduce((sum, log) => sum + log.overallSeverity, 0) / sideEffects.length;

    res.json({
      success: true,
      data: {
        totalLogs: sideEffects.length,
        mostCommonEffects: mostCommon,
        averageSeverity: Math.round(avgSeverity * 10) / 10,
        shotRelatedPercentage: Math.round((sideEffects.filter(s => s.relatedToShot).length / sideEffects.length) * 100)
      }
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Failed to analyze trends',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// ============================================================================
// PROGRESS PHOTOS
// ============================================================================

/**
 * @route   POST /api/health/photos
 * @desc    Upload progress photo
 * @access  Private
 */
router.post('/photos', authenticate, [
  body('date').optional().isISO8601(),
  body('photoUrls').isArray(),
  body('weight').optional().isFloat({ min: 20, max: 500 }),
  body('tags').optional().isArray(),
  body('notes').optional().isLength({ max: 500 })
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
    const { date, photoUrls, weight, tags, notes, visibility } = req.body;

    const photoLog = new PhotoLog({
      userId,
      date: date ? new Date(date) : new Date(),
      photoUrls,
      weight,
      tags: tags || [],
      notes,
      visibility: visibility || 'private'
    });

    await photoLog.save();

    res.status(201).json({
      success: true,
      message: 'Photo logged successfully',
      data: photoLog
    });
  } catch (error: any) {
    console.error('Log photo error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to log photo',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/health/photos
 * @desc    Get progress photos
 * @access  Private
 */
router.get('/photos', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const { limit = 20, page = 1 } = req.query;

    const skip = (Number(page) - 1) * Number(limit);
    const photos = await PhotoLog.find({ userId })
      .sort({ date: -1 })
      .limit(Number(limit))
      .skip(skip);

    const total = await PhotoLog.countDocuments({ userId });

    res.json({
      success: true,
      data: {
        photos,
        pagination: {
          total,
          page: Number(page),
          limit: Number(limit),
          pages: Math.ceil(total / Number(limit))
        }
      }
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve photos',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

export default router;

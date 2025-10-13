/**
 * Side Effect Monitoring Routes
 * 
 * Enhanced side effect tracking with severity monitoring,
 * trend analysis, and detailed logging
 */

import express from 'express';
import { body, query, validationResult } from 'express-validator';
import SideEffectLog from '../models/SideEffectLog';
import ShotLog from '../models/ShotLog';
import User from '../models/User';
import { authenticate, AuthRequest } from '../middleware/auth';

const router = express.Router();

// Validation rules for side effect logging
const createSideEffectValidation = [
  body('date')
    .optional()
    .isISO8601()
    .withMessage('Please provide a valid date'),
  body('effects')
    .isArray({ min: 1 })
    .withMessage('At least one side effect is required'),
  body('effects.*.name')
    .isIn([
      'Injection Anxiety',
      'Loose Skin',
      'Constipation',
      'Bloating',
      'Sulfur Burps',
      'Heartburn',
      'Food Noise',
      'Nausea',
      'Vomiting',
      'Diarrhea',
      'Fatigue',
      'Headache',
      'Dizziness',
      'Abdominal Pain',
      'Decreased Appetite',
      'Injection Site Reaction',
      'Hair Loss',
      'Muscle Loss',
      'Low Blood Sugar',
      'Mood Changes',
      'Sleep Disturbances',
      'Dry Mouth',
    ])
    .withMessage('Invalid side effect name'),
  body('effects.*.severity')
    .isFloat({ min: 0, max: 10 })
    .withMessage('Severity must be between 0 and 10'),
  body('effects.*.description')
    .optional()
    .isLength({ max: 200 })
    .withMessage('Description cannot exceed 200 characters'),
  body('effects.*.duration')
    .optional()
    .isFloat({ min: 0 })
    .withMessage('Duration must be a positive number'),
  body('effects.*.triggers')
    .optional()
    .isArray()
    .withMessage('Triggers must be an array'),
  body('effects.*.remedies')
    .optional()
    .isArray()
    .withMessage('Remedies must be an array'),
  body('overallSeverity')
    .isFloat({ min: 0, max: 10 })
    .withMessage('Overall severity must be between 0 and 10'),
  body('notes')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Notes cannot exceed 500 characters'),
  body('relatedToShot')
    .optional()
    .isBoolean()
    .withMessage('Related to shot must be a boolean'),
  body('shotId')
    .optional()
    .isMongoId()
    .withMessage('Invalid shot ID')
];

/**
 * @route   POST /api/treatments/side-effects
 * @desc    Log side effects with enhanced tracking
 * @access  Private
 */
router.post('/', authenticate, createSideEffectValidation, async (req: AuthRequest, res: express.Response) => {
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
      effects,
      overallSeverity,
      notes,
      relatedToShot,
      shotId
    } = req.body;

    // Validate shot ID if provided
    if (shotId) {
      const shot = await ShotLog.findOne({ _id: shotId, userId });
      if (!shot) {
        return res.status(404).json({
          success: false,
          message: 'Shot not found'
        });
      }
    }

    // Calculate days since last shot if related to shot
    let daysSinceShot: number | undefined;
    if (relatedToShot || shotId) {
      const latestShot = await ShotLog.findOne({ userId }).sort({ date: -1 });
      if (latestShot) {
        const sideEffectDate = date ? new Date(date) : new Date();
        const timeDiff = sideEffectDate.getTime() - latestShot.date.getTime();
        daysSinceShot = Math.max(0, Math.floor(timeDiff / (1000 * 60 * 60 * 24)));
      }
    }

    // Create side effect log
    const sideEffectLog = new SideEffectLog({
      userId,
      date: date ? new Date(date) : new Date(),
      effects,
      overallSeverity,
      notes,
      relatedToShot: relatedToShot || false,
      shotId,
      daysSinceShot,
      isActive: true
    });

    await sideEffectLog.save();

    res.status(201).json({
      success: true,
      message: 'Side effects logged successfully',
      data: sideEffectLog
    });
  } catch (error: any) {
    console.error('Create side effect log error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to log side effects',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/treatments/side-effects
 * @desc    Get side effect history with filters and analytics
 * @access  Private
 */
router.get('/', authenticate, [
  query('startDate').optional().isISO8601(),
  query('endDate').optional().isISO8601(),
  query('limit').optional().isInt({ min: 1, max: 100 }),
  query('page').optional().isInt({ min: 1 }),
  query('severity').optional().isInt({ min: 0, max: 10 }),
  query('active').optional().isBoolean(),
  query('relatedToShot').optional().isBoolean()
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
      page = 1,
      severity,
      active,
      relatedToShot
    } = req.query;

    // Build query
    const query: any = { userId };
    
    if (startDate || endDate) {
      query.date = {};
      if (startDate) query.date.$gte = new Date(startDate as string);
      if (endDate) query.date.$lte = new Date(endDate as string);
    }

    if (severity !== undefined) {
      query.overallSeverity = { $gte: parseInt(severity as string) };
    }

    if (active !== undefined) {
      query.isActive = active === 'true';
    }

    if (relatedToShot !== undefined) {
      query.relatedToShot = relatedToShot === 'true';
    }

    // Execute query with pagination
    const skip = (Number(page) - 1) * Number(limit);
    const sideEffects = await SideEffectLog.find(query)
      .populate('shotId', 'date medication dosage injectionSite')
      .sort({ date: -1 })
      .limit(Number(limit))
      .skip(skip);

    const total = await SideEffectLog.countDocuments(query);

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
    console.error('Get side effects error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve side effects',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/treatments/side-effects/analytics
 * @desc    Get side effect analytics and trends
 * @access  Private
 */
router.get('/analytics', authenticate, [
  query('days').optional().isInt({ min: 1, max: 365 }),
  query('groupBy').optional().isIn(['day', 'week', 'month'])
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
    const days = parseInt(req.query.days as string) || 30;
    const groupBy = req.query.groupBy as string || 'day';

    // Calculate date range
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    // Get side effects in date range
    const sideEffects = await SideEffectLog.find({
      userId,
      date: { $gte: startDate, $lte: endDate }
    }).sort({ date: 1 });

    // Calculate analytics
    const analytics = {
      totalEntries: sideEffects.length,
      averageSeverity: 0,
      mostCommonEffects: [] as Array<{ name: string; count: number; avgSeverity: number }>,
      severityTrends: [] as Array<{ date: string; avgSeverity: number; count: number }>,
      activeEffects: 0,
      resolvedEffects: 0,
      effectsBySeverity: {
        mild: 0,    // 0-3
        moderate: 0, // 4-6
        severe: 0    // 7-10
      }
    };

    if (sideEffects.length > 0) {
      // Calculate average severity
      const totalSeverity = sideEffects.reduce((sum, log) => sum + log.overallSeverity, 0);
      analytics.averageSeverity = totalSeverity / sideEffects.length;

      // Count active vs resolved
      analytics.activeEffects = sideEffects.filter(log => log.isActive).length;
      analytics.resolvedEffects = sideEffects.filter(log => !log.isActive).length;

      // Severity distribution
      sideEffects.forEach(log => {
        if (log.overallSeverity <= 3) analytics.effectsBySeverity.mild++;
        else if (log.overallSeverity <= 6) analytics.effectsBySeverity.moderate++;
        else analytics.effectsBySeverity.severe++;
      });

      // Most common effects
      const effectCounts: { [key: string]: { count: number; totalSeverity: number } } = {};
      sideEffects.forEach(log => {
        log.effects.forEach(effect => {
          if (!effectCounts[effect.name]) {
            effectCounts[effect.name] = { count: 0, totalSeverity: 0 };
          }
          effectCounts[effect.name].count++;
          effectCounts[effect.name].totalSeverity += effect.severity;
        });
      });

      analytics.mostCommonEffects = Object.entries(effectCounts)
        .map(([name, data]) => ({
          name,
          count: data.count,
          avgSeverity: data.totalSeverity / data.count
        }))
        .sort((a, b) => b.count - a.count)
        .slice(0, 5);

      // Severity trends over time
      const trends: { [key: string]: { totalSeverity: number; count: number } } = {};
      sideEffects.forEach(log => {
        const dateKey = groupBy === 'day' 
          ? log.date.toISOString().split('T')[0]
          : groupBy === 'week'
          ? getWeekKey(log.date)
          : `${log.date.getFullYear()}-${String(log.date.getMonth() + 1).padStart(2, '0')}`;

        if (!trends[dateKey]) {
          trends[dateKey] = { totalSeverity: 0, count: 0 };
        }
        trends[dateKey].totalSeverity += log.overallSeverity;
        trends[dateKey].count++;
      });

      analytics.severityTrends = Object.entries(trends)
        .map(([date, data]) => ({
          date,
          avgSeverity: data.totalSeverity / data.count,
          count: data.count
        }))
        .sort((a, b) => a.date.localeCompare(b.date));
    }

    res.json({
      success: true,
      data: analytics
    });
  } catch (error: any) {
    console.error('Get side effect analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to calculate analytics',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/treatments/side-effects/current
 * @desc    Get current active side effects
 * @access  Private
 */
router.get('/current', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;

    const activeSideEffects = await SideEffectLog.find({
      userId,
      isActive: true
    })
    .populate('shotId', 'date medication dosage injectionSite')
    .sort({ date: -1 })
    .limit(10);

    // Calculate days since each side effect started
    const now = new Date();
    const currentEffects = activeSideEffects.map(log => {
      const daysSinceStart = Math.floor((now.getTime() - log.date.getTime()) / (1000 * 60 * 60 * 24));
      return {
        ...log.toObject(),
        daysSinceStart
      };
    });

    res.json({
      success: true,
      data: {
        activeSideEffects: currentEffects,
        totalActive: currentEffects.length
      }
    });
  } catch (error: any) {
    console.error('Get current side effects error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve current side effects',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   PUT /api/treatments/side-effects/:id
 * @desc    Update side effect log entry
 * @access  Private
 */
router.put('/:id', authenticate, createSideEffectValidation, async (req: AuthRequest, res: express.Response) => {
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
    const { id } = req.params;

    const sideEffectLog = await SideEffectLog.findOne({ _id: id, userId });

    if (!sideEffectLog) {
      return res.status(404).json({
        success: false,
        message: 'Side effect log not found'
      });
    }

    // Update fields
    const {
      date,
      effects,
      overallSeverity,
      notes,
      relatedToShot,
      shotId,
      isActive
    } = req.body;

    if (date) sideEffectLog.date = new Date(date);
    if (effects) sideEffectLog.effects = effects;
    if (overallSeverity !== undefined) sideEffectLog.overallSeverity = overallSeverity;
    if (notes !== undefined) sideEffectLog.notes = notes;
    if (relatedToShot !== undefined) sideEffectLog.relatedToShot = relatedToShot;
    if (shotId !== undefined) sideEffectLog.shotId = shotId;
    if (isActive !== undefined) {
      sideEffectLog.isActive = isActive;
      if (!isActive && sideEffectLog.isActive) {
        sideEffectLog.resolvedAt = new Date();
      }
    }

    await sideEffectLog.save();

    res.json({
      success: true,
      message: 'Side effect log updated successfully',
      data: sideEffectLog
    });
  } catch (error: any) {
    console.error('Update side effect log error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update side effect log',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   DELETE /api/treatments/side-effects/:id
 * @desc    Delete side effect log entry
 * @access  Private
 */
router.delete('/:id', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const { id } = req.params;

    const sideEffectLog = await SideEffectLog.findOneAndDelete({ _id: id, userId });

    if (!sideEffectLog) {
      return res.status(404).json({
        success: false,
        message: 'Side effect log not found'
      });
    }

    res.json({
      success: true,
      message: 'Side effect log deleted successfully'
    });
  } catch (error: any) {
    console.error('Delete side effect log error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete side effect log',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * Helper function to get week key for grouping
 */
function getWeekKey(date: Date): string {
  const year = date.getFullYear();
  const week = getWeekNumber(date);
  return `${year}-W${String(week).padStart(2, '0')}`;
}

/**
 * Helper function to get week number
 */
function getWeekNumber(date: Date): number {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const dayNum = d.getUTCDay() || 7;
  d.setUTCDate(d.getUTCDate() + 4 - dayNum);
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  return Math.ceil((((d.getTime() - yearStart.getTime()) / 86400000) + 1) / 7);
}

export default router;

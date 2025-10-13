/**
 * Activity Tracking Routes
 * 
 * Endpoints for steps and workout logging
 */

import express from 'express';
import { body, query, validationResult } from 'express-validator';
import { StepLog, WorkoutLog } from '../models/ActivityLog';
import { authenticate, AuthRequest } from '../middleware/auth';

const router = express.Router();

// ============================================================================
// STEPS TRACKING
// ============================================================================

/**
 * @route   POST /api/activity/steps
 * @desc    Log daily steps
 * @access  Private
 */
router.post('/steps', authenticate, [
  body('date').optional().isISO8601(),
  body('steps').isInt({ min: 0, max: 100000 }),
  body('goal').optional().isInt({ min: 0 }),
  body('distance').optional().isFloat({ min: 0 }),
  body('caloriesBurned').optional().isFloat({ min: 0 }),
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
    const { date, steps, goal, distance, caloriesBurned, notes } = req.body;

    const stepLog = new StepLog({
      userId,
      date: date ? new Date(date) : new Date(),
      steps,
      goal: goal || 10000,
      distance,
      caloriesBurned,
      notes
    });

    await stepLog.save();

    res.status(201).json({
      success: true,
      message: 'Steps logged successfully',
      data: stepLog
    });
  } catch (error: any) {
    console.error('Log steps error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to log steps',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/activity/steps
 * @desc    Get steps history
 * @access  Private
 */
router.get('/steps', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const { limit = 30, page = 1 } = req.query;

    const skip = (Number(page) - 1) * Number(limit);
    const steps = await StepLog.find({ userId })
      .sort({ date: -1 })
      .limit(Number(limit))
      .skip(skip);

    const total = await StepLog.countDocuments({ userId });

    res.json({
      success: true,
      data: {
        steps,
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
      message: 'Failed to retrieve steps',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/activity/steps/stats
 * @desc    Get steps statistics
 * @access  Private
 */
router.get('/steps/stats', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;

    const steps = await StepLog.find({ userId }).sort({ date: 1 });

    if (steps.length === 0) {
      return res.json({
        success: true,
        data: {
          totalDays: 0,
          message: 'No steps logged yet'
        }
      });
    }

    const totalSteps = steps.reduce((sum, log) => sum + log.steps, 0);
    const avgSteps = Math.round(totalSteps / steps.length);
    const goalsReached = steps.filter(log => log.steps >= log.goal).length;
    const achievementRate = Math.round((goalsReached / steps.length) * 100);

    res.json({
      success: true,
      data: {
        totalDays: steps.length,
        totalSteps,
        averageSteps: avgSteps,
        goalsReached,
        achievementRate,
        currentGoal: steps[steps.length - 1].goal
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

// ============================================================================
// WORKOUT TRACKING
// ============================================================================

/**
 * @route   POST /api/activity/workouts
 * @desc    Log workout session
 * @access  Private
 */
router.post('/workouts', authenticate, [
  body('date').optional().isISO8601(),
  body('type').isIn(['Cardio', 'Strength Training', 'Yoga', 'Swimming', 'Cycling', 'Running', 'Walking', 'HIIT', 'Pilates', 'Sports', 'Other']),
  body('duration').isInt({ min: 1, max: 600 }),
  body('intensity').isInt({ min: 1, max: 10 }),
  body('caloriesBurned').isFloat({ min: 0 }),
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
    const { date, type, duration, intensity, caloriesBurned, notes } = req.body;

    const workoutLog = new WorkoutLog({
      userId,
      date: date ? new Date(date) : new Date(),
      type,
      duration,
      intensity,
      caloriesBurned,
      notes
    });

    await workoutLog.save();

    res.status(201).json({
      success: true,
      message: 'Workout logged successfully',
      data: workoutLog
    });
  } catch (error: any) {
    console.error('Log workout error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to log workout',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/activity/workouts
 * @desc    Get workout history
 * @access  Private
 */
router.get('/workouts', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const { limit = 30, page = 1 } = req.query;

    const skip = (Number(page) - 1) * Number(limit);
    const workouts = await WorkoutLog.find({ userId })
      .sort({ date: -1 })
      .limit(Number(limit))
      .skip(skip);

    const total = await WorkoutLog.countDocuments({ userId });

    res.json({
      success: true,
      data: {
        workouts,
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
      message: 'Failed to retrieve workouts',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/activity/workouts/stats
 * @desc    Get workout statistics
 * @access  Private
 */
router.get('/workouts/stats', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;

    const workouts = await WorkoutLog.find({ userId }).sort({ date: 1 });

    if (workouts.length === 0) {
      return res.json({
        success: true,
        data: {
          totalWorkouts: 0,
          message: 'No workouts logged yet'
        }
      });
    }

    const totalDuration = workouts.reduce((sum, w) => sum + w.duration, 0);
    const totalCalories = workouts.reduce((sum, w) => sum + w.caloriesBurned, 0);
    const avgIntensity = workouts.reduce((sum, w) => sum + w.intensity, 0) / workouts.length;

    // Count workout types
    const typeCounts: { [key: string]: number } = {};
    workouts.forEach(w => {
      typeCounts[w.type] = (typeCounts[w.type] || 0) + 1;
    });

    const favoriteType = Object.entries(typeCounts)
      .sort((a, b) => b[1] - a[1])[0];

    res.json({
      success: true,
      data: {
        totalWorkouts: workouts.length,
        totalDuration,
        totalCalories: Math.round(totalCalories),
        averageIntensity: Math.round(avgIntensity * 10) / 10,
        favoriteWorkoutType: favoriteType ? favoriteType[0] : null,
        workoutTypeBreakdown: typeCounts
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
 * @route   GET /api/activity/summary
 * @desc    Get combined activity summary
 * @access  Private
 */
router.get('/summary', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;

    // Get latest step log
    const latestSteps = await StepLog.findOne({ userId }).sort({ date: -1 });
    
    // Get workouts from last 7 days
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    
    const recentWorkouts = await WorkoutLog.find({
      userId,
      date: { $gte: sevenDaysAgo }
    }).sort({ date: -1 });

    const weeklyWorkouts = recentWorkouts.length;
    const weeklyCalories = recentWorkouts.reduce((sum, w) => sum + w.caloriesBurned, 0);

    res.json({
      success: true,
      data: {
        todaySteps: latestSteps ? latestSteps.steps : 0,
        stepsGoal: latestSteps ? latestSteps.goal : 10000,
        weeklyWorkouts,
        weeklyCalories: Math.round(weeklyCalories)
      }
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Failed to get activity summary',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

export default router;

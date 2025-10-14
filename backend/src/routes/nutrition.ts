/**
 * Nutrition Tracking Routes
 * 
 * Endpoints for meal and water logging
 */

import express from 'express';
import { body, validationResult } from 'express-validator';
import { MealLog, WaterLog } from '../models/NutritionLog';
import ShotLog from '../models/ShotLog';
import WeightLog from '../models/WeightLog';
import { StepLog, WorkoutLog } from '../models/ActivityLog';
import SideEffectLog from '../models/SideEffectLog';
import PhotoLog from '../models/PhotoLog';
import { authenticate, AuthRequest } from '../middleware/auth';

const router = express.Router();

// ============================================================================
// MEAL TRACKING
// ============================================================================

/**
 * @route   POST /api/nutrition/meals
 * @desc    Log a meal (updates existing daily entry or creates new one)
 * @access  Private
 */
router.post('/meals', authenticate, [
  body('date').optional().isISO8601(),
  body('mealType').isIn(['breakfast', 'lunch', 'dinner', 'snack']),
  body('foods').isArray(),
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
    const { date, mealType, foods, notes, photoUrl } = req.body;

    const logDate = date ? new Date(date) : new Date();
    const startOfDay = new Date(logDate);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(logDate);
    endOfDay.setHours(23, 59, 59, 999);

    // Check if meal log exists for today and same meal type
    let mealLog = await MealLog.findOne({
      userId,
      mealType,
      date: { $gte: startOfDay, $lte: endOfDay }
    });

    if (mealLog) {
      // Update existing entry - add new foods to existing ones
      mealLog.foods.push(...foods);
      mealLog.notes = notes || mealLog.notes;
      mealLog.photoUrl = photoUrl || mealLog.photoUrl;
      await mealLog.save();
    } else {
      // Create new entry
      mealLog = new MealLog({
        userId,
        date: logDate,
        mealType,
        foods,
        notes,
        photoUrl
      });
      await mealLog.save();
    }

    res.status(201).json({
      success: true,
      message: 'Meal logged successfully',
      data: mealLog
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Failed to log meal',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/nutrition/meals
 * @desc    Get meal history
 * @access  Private
 */
router.get('/meals', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const { limit = 30, page = 1 } = req.query;

    const skip = (Number(page) - 1) * Number(limit);
    const meals = await MealLog.find({ userId })
      .sort({ date: -1 })
      .limit(Number(limit))
      .skip(skip);

    const total = await MealLog.countDocuments({ userId });

    res.json({
      success: true,
      data: {
        meals,
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
      message: 'Failed to retrieve meals',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/nutrition/daily-summary
 * @desc    Get daily nutrition summary
 * @access  Private
 */
router.get('/daily-summary', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const { date = new Date().toISOString().split('T')[0] } = req.query;

    const startDate = new Date(date as string);
    startDate.setHours(0, 0, 0, 0);
    const endDate = new Date(date as string);
    endDate.setHours(23, 59, 59, 999);

    const meals = await MealLog.find({
      userId,
      date: { $gte: startDate, $lte: endDate }
    });

    // Get ALL water logs for the day (not just one)
    const waterLogs = await WaterLog.find({
      userId,
      date: { $gte: startDate, $lte: endDate }
    });

    const totalCalories = Math.max(0, meals.reduce((sum, m) => sum + m.totalCalories, 0));
    const totalProtein = Math.max(0, meals.reduce((sum, m) => sum + m.totalProtein, 0));
    const totalCarbs = Math.max(0, meals.reduce((sum, m) => sum + m.totalCarbs, 0));
    const totalFat = Math.max(0, meals.reduce((sum, m) => sum + m.totalFat, 0));
    const totalFiber = Math.max(0, meals.reduce((sum, m) => sum + m.totalFiber, 0));
    
    // Aggregate all water entries for the day (ensure non-negative)
    const totalWater = Math.max(0, waterLogs.reduce((sum, w) => sum + w.amount, 0));
    const waterGoal = waterLogs.length > 0 ? waterLogs[0].goal : 2500; // Use goal from first entry

    res.json({
      success: true,
      data: {
        date,
        totalMeals: meals.length,
        calories: Math.round(totalCalories),
        protein: Math.round(totalProtein),
        carbs: Math.round(totalCarbs),
        fat: Math.round(totalFat),
        fiber: Math.round(totalFiber),
        water: Math.round(totalWater),
        waterGoal: waterGoal
      }
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Failed to get daily summary',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// ============================================================================
// WATER TRACKING
// ============================================================================

/**
 * @route   POST /api/nutrition/water
 * @desc    Log water intake (updates existing daily entry or creates new one)
 * @access  Private
 */
router.post('/water', authenticate, [
  body('date').optional().isISO8601(),
  body('entries').isArray(),
  body('goal').optional().isInt({ min: 0 }),
  body('notes').optional().isLength({ max: 500 })
], async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const { date, entries, goal, notes } = req.body;

    const logDate = date ? new Date(date) : new Date();
    const startOfDay = new Date(logDate);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(logDate);
    endOfDay.setHours(23, 59, 59, 999);

    // Check if water log exists for today
    let waterLog = await WaterLog.findOne({
      userId,
      date: { $gte: startOfDay, $lte: endOfDay }
    });

    console.log(`Water API: Found existing log: ${waterLog ? 'Yes' : 'No'}`);
    console.log(`Water API: Date range: ${startOfDay} to ${endOfDay}`);
    console.log(`Water API: New entries: ${entries.length}`);

    if (waterLog) {
      // Update existing entry - add new entries to existing ones
      console.log(`Water API: Updating existing log with ${waterLog.entries.length} existing entries`);
      waterLog.entries.push(...entries);
      waterLog.goal = goal || waterLog.goal;
      waterLog.notes = notes || waterLog.notes;
      await waterLog.save();
      console.log(`Water API: Updated log now has ${waterLog.entries.length} entries`);
    } else {
      // Create new entry
      console.log(`Water API: Creating new water log`);
      waterLog = new WaterLog({
        userId,
        date: logDate,
        entries,
        goal: goal || 2500,
        notes
      });
      await waterLog.save();
      console.log(`Water API: Created new log with ${waterLog.entries.length} entries`);
    }

    res.status(201).json({
      success: true,
      message: 'Water intake logged successfully',
      data: waterLog
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Failed to log water',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/nutrition/water
 * @desc    Get water history
 * @access  Private
 */
router.get('/water', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const { limit = 30, page = 1 } = req.query;

    const skip = (Number(page) - 1) * Number(limit);
    const water = await WaterLog.find({ userId })
      .sort({ date: -1 })
      .limit(Number(limit))
      .skip(skip);

    const total = await WaterLog.countDocuments({ userId });

    res.json({
      success: true,
      data: {
        water,
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
      message: 'Failed to retrieve water logs',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// ============================================================================
// TODAY'S LOG
// ============================================================================

/**
 * @route   GET /api/nutrition/todays-log
 * @desc    Get all log entries for today or a specific date (meals, water, shots, weight, activity, side effects, photos)
 * @access  Private
 */
router.get('/todays-log', authenticate, async (req: AuthRequest, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'User not authenticated'
      });
    }

    // Get date from query parameter or default to today
    const dateParam = req.query.date as string;
    let targetDate: Date;
    
    if (dateParam) {
      targetDate = new Date(dateParam);
      if (isNaN(targetDate.getTime())) {
        return res.status(400).json({
          success: false,
          message: 'Invalid date format. Use YYYY-MM-DD'
        });
      }
    } else {
      targetDate = new Date();
    }

    // Get date range for the target date
    const startOfDay = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate());
    const endOfDay = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate(), 23, 59, 59, 999);

    console.log(`Log API: Fetching logs for ${startOfDay} to ${endOfDay}`);

    // Fetch all types of logs for today
    const [mealLogs, waterLogs, shotLogs, weightLogs, stepLogs, workoutLogs, sideEffectLogs, photoLogs] = await Promise.all([
      MealLog.find({
        userId,
        date: { $gte: startOfDay, $lte: endOfDay }
      }).sort({ createdAt: -1 }),
      
      WaterLog.find({
        userId,
        date: { $gte: startOfDay, $lte: endOfDay }
      }).sort({ createdAt: -1 }),
      
      ShotLog.find({
        userId,
        date: { $gte: startOfDay, $lte: endOfDay }
      }).sort({ createdAt: -1 }),
      
      WeightLog.find({
        userId,
        date: { $gte: startOfDay, $lte: endOfDay }
      }).sort({ createdAt: -1 }),
      
      StepLog.find({
        userId,
        date: { $gte: startOfDay, $lte: endOfDay }
      }).sort({ createdAt: -1 }),
      
      WorkoutLog.find({
        userId,
        date: { $gte: startOfDay, $lte: endOfDay }
      }).sort({ createdAt: -1 }),
      
      SideEffectLog.find({
        userId,
        date: { $gte: startOfDay, $lte: endOfDay }
      }).sort({ createdAt: -1 }),
      
      PhotoLog.find({
        userId,
        date: { $gte: startOfDay, $lte: endOfDay }
      }).sort({ createdAt: -1 })
    ]);

    // Transform logs into exactly 3 standard entries: Water, Protein, Fiber
    const todaysLogs: any[] = [];

    // Aggregate water entries
    let totalWater = 0;
    let waterEntryCount = 0;
    let latestWaterTime: Date | null = null;
    
    waterLogs.forEach((water: any) => {
      water.entries.forEach((entry: any) => {
        totalWater += entry.amount;
        waterEntryCount++;
        if (!latestWaterTime || water.createdAt > latestWaterTime) {
          latestWaterTime = water.createdAt;
        }
      });
    });
    
    // Ensure water total is never negative
    totalWater = Math.max(0, totalWater);

    // Aggregate protein entries
    let totalProtein = 0;
    let proteinEntryCount = 0;
    let latestProteinTime: Date | null = null;
    
    mealLogs.forEach((meal: any) => {
      meal.foods.forEach((food: any) => {
        const proteinValue = parseFloat(food.protein) || 0;
        // Only include positive protein values to avoid negative entries
        if (proteinValue > 0 && !isNaN(proteinValue)) {
          totalProtein += proteinValue;
          proteinEntryCount++;
          if (!latestProteinTime || meal.createdAt > latestProteinTime) {
            latestProteinTime = meal.createdAt;
          }
        }
      });
    });
    
    // Ensure protein total is never negative
    totalProtein = Math.max(0, totalProtein);

    // Aggregate fiber entries
    let totalFiber = 0;
    let fiberEntryCount = 0;
    let latestFiberTime: Date | null = null;
    
    mealLogs.forEach((meal: any) => {
      meal.foods.forEach((food: any) => {
        const fiberValue = parseFloat(food.fiber) || 0;
        // Only include positive fiber values to avoid negative entries
        if (fiberValue > 0 && !isNaN(fiberValue)) {
          totalFiber += fiberValue;
          fiberEntryCount++;
          if (!latestFiberTime || meal.createdAt > latestFiberTime) {
            latestFiberTime = meal.createdAt;
          }
        }
      });
    });
    
    // Ensure fiber total is never negative
    totalFiber = Math.max(0, totalFiber);

    // Add exactly 3 entries with standard names
    if (waterEntryCount > 0) {
      todaysLogs.push({
        id: 'water',
        type: 'water',
        category: 'hydration',
        title: 'Water',
        subtitle: `${totalWater}ml`,
        time: latestWaterTime,
        icon: '💧',
        data: {
          totalAmount: totalWater,
          entryCount: waterEntryCount
        }
      });
    }

    if (proteinEntryCount > 0) {
      todaysLogs.push({
        id: 'protein',
        type: 'protein',
        category: 'nutrition',
        title: 'Protein',
        subtitle: `${Math.round(totalProtein * 100) / 100}g`,
        time: latestProteinTime,
        icon: '🍽️',
        data: {
          totalAmount: Math.round(totalProtein * 100) / 100,
          entryCount: proteinEntryCount
        }
      });
    }

    if (fiberEntryCount > 0) {
      todaysLogs.push({
        id: 'fiber',
        type: 'fiber',
        category: 'nutrition',
        title: 'Fiber',
        subtitle: `${Math.round(totalFiber * 100) / 100}g`,
        time: latestFiberTime,
        icon: '🍽️',
        data: {
          totalAmount: Math.round(totalFiber * 100) / 100,
          entryCount: fiberEntryCount
        }
      });
    }

    // Only show Water, Protein, Fiber - no other entry types

    // Sort all entries by time (most recent first)
    todaysLogs.sort((a, b) => new Date(b.time).getTime() - new Date(a.time).getTime());

    console.log(`Today's Log API: Found ${todaysLogs.length} total entries`);

    res.json({
      success: true,
      message: `Log entries retrieved successfully for ${targetDate.toISOString().split('T')[0]}`,
      data: {
        logs: todaysLogs,
        summary: {
          totalEntries: todaysLogs.length,
          mealEntries: todaysLogs.filter(log => log.type === 'meal').length,
          waterEntries: todaysLogs.filter(log => log.type === 'water').length,
          shotEntries: todaysLogs.filter(log => log.type === 'shot').length,
          weightEntries: todaysLogs.filter(log => log.type === 'weight').length,
          activityEntries: todaysLogs.filter(log => log.type === 'steps' || log.type === 'workout').length,
          sideEffectEntries: todaysLogs.filter(log => log.type === 'side_effect').length,
          photoEntries: todaysLogs.filter(log => log.type === 'photo').length
        }
      }
    });

  } catch (error: any) {
    console.error('Today\'s Log API Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve today\'s log',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

export default router;

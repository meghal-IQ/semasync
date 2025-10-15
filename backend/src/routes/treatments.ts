/**
 * Treatment/Shot Tracking Routes
 * 
 * Endpoints for logging and managing GLP-1 medication injections
 */

import express from 'express';
import { body, query, validationResult } from 'express-validator';
import ShotLog from '../models/ShotLog';
import User from '../models/User';
import MedicationLevelHistory from '../models/MedicationLevelHistory';
import { authenticate, AuthRequest } from '../middleware/auth';
import {
  calculateMedicationLevel,
  calculateNextDueDate,
  formatCountdown,
  getRecommendedInjectionSite
} from '../utils/medicationCalculations';

const router = express.Router();

// Validation rules
const createShotValidation = [
  body('date')
    .optional()
    .isISO8601()
    .withMessage('Please provide a valid date'),
  body('medication')
    .isIn([
      'Zepbound®',
      'Mounjaro®',
      'Ozempic®',
      'Wegovy®',
      'Trulicity®',
      'Compounded Semaglutide',
      'Compounded Tirzepatide'
    ])
    .withMessage('Invalid medication'),
  body('dosage')
    .isIn(['0.25mg', '0.5mg', '0.7mg', '1.0mg', '1.5mg', '1.7mg', '2.0mg', '2.4mg'])
    .withMessage('Invalid dosage'),
  body('injectionSite')
    .isIn([
      'Left Thigh',
      'Right Thigh',
      'Left Arm',
      'Right Arm',
      'Left Abdomen',
      'Right Abdomen',
      'Left Buttock',
      'Right Buttock'
    ])
    .withMessage('Invalid injection site'),
  body('painLevel')
    .isFloat({ min: 0, max: 10 })
    .withMessage('Pain level must be between 0 and 10'),
  body('sideEffects')
    .optional()
    .isArray()
    .withMessage('Side effects must be an array'),
  body('notes')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Notes cannot exceed 500 characters')
];

/**
 * @route   POST /api/treatments/shots
 * @desc    Log a new shot/injection
 * @access  Private
 */
router.post('/shots', authenticate, createShotValidation, async (req: AuthRequest, res: express.Response) => {
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
      medication,
      dosage,
      injectionSite,
      painLevel,
      sideEffects,
      notes,
      photoUrl
    } = req.body;

    // Get user's frequency settings
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Calculate next due date based on user's frequency
    const shotDate = date ? new Date(date) : new Date();
    const nextDueDate = calculateNextDueDate(shotDate, user.glp1Journey.frequency);

    // Create shot log
    const shotLog = new ShotLog({
      userId,
      date: shotDate,
      medication,
      dosage,
      injectionSite,
      painLevel,
      sideEffects: sideEffects || ['None'],
      notes,
      photoUrl,
      nextDueDate
    });

    await shotLog.save();

    // Update user's current dose if different
    if (user.glp1Journey.currentDose !== dosage) {
      user.glp1Journey.currentDose = dosage;
      await user.save();
    }

    // Automatically calculate and store medication level after logging shot
    try {
      console.log('🧮 Calculating medication level for shot:', {
        medication,
        dosage,
        shotDate,
        nextDueDate
      });
      
      const medicationLevel = calculateMedicationLevel(
        medication,
        dosage,
        shotDate,
        nextDueDate
      );
      
      console.log('📊 Calculated medication level:', medicationLevel);
      
      const medicationLevelEntry = new MedicationLevelHistory({
        userId,
        date: shotDate,
        medication,
        dosage,
        calculatedLevel: medicationLevel.currentLevel,
        percentageOfPeak: medicationLevel.percentageOfPeak,
        shotId: shotLog._id,
        daysSinceLastShot: 0,
        hoursSinceLastShot: 0,
        nextDueDate,
        status: medicationLevel.status
      });
      
      await medicationLevelEntry.save();
      console.log('✅ Medication level entry saved successfully');
    } catch (medLevelError) {
      console.error('❌ Failed to calculate medication level:', medLevelError);
      // Don't fail the shot logging if medication level calculation fails
    }

    res.status(201).json({
      success: true,
      message: 'Shot logged successfully',
      data: {
        shotLog,
        nextDueDate,
        countdown: formatCountdown((nextDueDate.getTime() - new Date().getTime()) / (1000 * 60 * 60))
      }
    });
  } catch (error: any) {
    console.error('Create shot log error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to log shot',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/treatments/shots
 * @desc    Get shot history with optional filters
 * @access  Private
 */
router.get('/shots', authenticate, [
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
    const shots = await ShotLog.find(query)
      .sort({ date: -1 })
      .limit(Number(limit))
      .skip(skip);

    const total = await ShotLog.countDocuments(query);

    res.json({
      success: true,
      data: {
        shots,
        pagination: {
          total,
          page: Number(page),
          limit: Number(limit),
          pages: Math.ceil(total / Number(limit))
        }
      }
    });
  } catch (error: any) {
    console.error('Get shots error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve shot history',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/treatments/shots/latest
 * @desc    Get the most recent shot
 * @access  Private
 */
router.get('/shots/latest', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;

    const latestShot = await ShotLog.findOne({ userId })
      .sort({ date: -1 });

    if (!latestShot) {
      return res.status(404).json({
        success: false,
        message: 'No shots logged yet'
      });
    }

    // Calculate medication level
    const medicationLevel = calculateMedicationLevel(
      latestShot.medication,
      latestShot.dosage,
      latestShot.date,
      latestShot.nextDueDate!
    );

    res.json({
      success: true,
      data: {
        shot: latestShot,
        medicationLevel,
        countdown: formatCountdown(medicationLevel.hoursUntilNextDose)
      }
    });
  } catch (error: any) {
    console.error('Get latest shot error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve latest shot',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/treatments/shots/next
 * @desc    Get next shot due date and countdown
 * @access  Private
 */
router.get('/shots/next', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;

    const latestShot = await ShotLog.findOne({ userId })
      .sort({ date: -1 });

    if (!latestShot) {
      return res.json({
        success: true,
        data: {
          hasShots: false,
          message: 'No shots logged yet. Log your first shot to start tracking!'
        }
      });
    }

    const now = new Date();
    const hoursUntilNext = (latestShot.nextDueDate!.getTime() - now.getTime()) / (1000 * 60 * 60);

    res.json({
      success: true,
      data: {
        hasShots: true,
        nextDueDate: latestShot.nextDueDate,
        countdown: formatCountdown(hoursUntilNext),
        isOverdue: hoursUntilNext < 0,
        hoursUntilNext: Math.max(0, hoursUntilNext),
        daysUntilNext: Math.max(0, hoursUntilNext / 24)
      }
    });
  } catch (error: any) {
    console.error('Get next shot error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to calculate next shot',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/treatments/medication-level
 * @desc    Get current medication level in bloodstream
 * @access  Private
 */
router.get('/medication-level', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;

    const latestShot = await ShotLog.findOne({ userId })
      .sort({ date: -1 });

    if (!latestShot) {
      return res.json({
        success: true,
        data: {
          hasShots: false,
          currentLevel: 0,
          status: 'no_data'
        }
      });
    }

    const medicationLevel = calculateMedicationLevel(
      latestShot.medication,
      latestShot.dosage,
      latestShot.date,
      latestShot.nextDueDate!
    );

    res.json({
      success: true,
      data: {
        hasShots: true,
        ...medicationLevel,
        medication: latestShot.medication,
        dosage: latestShot.dosage,
        lastShotDate: latestShot.date
      }
    });
  } catch (error: any) {
    console.error('Get medication level error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to calculate medication level',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/treatments/medication-level/date
 * @desc    Get medication level for a specific date
 * @access  Private
 */
router.get('/medication-level/date', authenticate, [
  query('date').optional().isISO8601()
], async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const { date } = req.query;

    // Parse the target date or use today
    const targetDate = date ? new Date(date as string) : new Date();
    targetDate.setHours(23, 59, 59, 999); // End of day

    // Find the most recent shot before or on the target date
    const latestShot = await ShotLog.findOne({
      userId,
      date: { $lte: targetDate }
    }).sort({ date: -1 });

    if (!latestShot) {
      return res.json({
        success: true,
        data: {
          hasShots: false,
          currentLevel: 0,
          status: 'no_data',
          date: targetDate
        }
      });
    }

    // Calculate medication level as of the target date
    const medicationLevel = calculateMedicationLevel(
      latestShot.medication,
      latestShot.dosage,
      latestShot.date,
      latestShot.nextDueDate || calculateNextDueDate(latestShot.date, 'weekly')
    );

    // Adjust the level based on time elapsed to target date
    const hoursSinceShot = (targetDate.getTime() - latestShot.date.getTime()) / (1000 * 60 * 60);
    const halfLife = getHalfLife(latestShot.medication);
    const levelAtTargetDate = 100 * Math.pow(0.5, hoursSinceShot / halfLife);

    res.json({
      success: true,
      data: {
        hasShots: true,
        currentLevel: Math.max(0, levelAtTargetDate),
        percentageOfPeak: Math.max(0, levelAtTargetDate),
        status: levelAtTargetDate > 50 ? 'optimal' : levelAtTargetDate > 25 ? 'moderate' : 'low',
        medication: latestShot.medication,
        dosage: latestShot.dosage,
        lastShotDate: latestShot.date,
        targetDate: targetDate,
        hoursSinceShot: hoursSinceShot
      }
    });
  } catch (error: any) {
    console.error('Get historical medication level error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to calculate historical medication level',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/treatments/injection-sites/recommend
 * @desc    Get recommended injection sites based on rotation
 * @access  Private
 */
router.get('/injection-sites/recommend', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;

    // Get last 5 shots to analyze site rotation
    const recentShots = await ShotLog.find({ userId })
      .sort({ date: -1 })
      .limit(5)
      .select('injectionSite');

    const lastSites = recentShots.map(shot => shot.injectionSite);
    const recommendedSites = getRecommendedInjectionSite(lastSites);

    res.json({
      success: true,
      data: {
        recommendedSites,
        recentSites: lastSites,
        message: 'Rotate injection sites to minimize irritation and improve absorption'
      }
    });
  } catch (error: any) {
    console.error('Get injection site recommendations error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get recommendations',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/treatments/stats
 * @desc    Get treatment statistics and adherence
 * @access  Private
 */
router.get('/stats', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Get all shots
    const allShots = await ShotLog.find({ userId }).sort({ date: 1 });

    if (allShots.length === 0) {
      return res.json({
        success: true,
        data: {
          totalShots: 0,
          message: 'No shots logged yet'
        }
      });
    }

    // Calculate statistics
    const firstShot = allShots[0];
    const latestShot = allShots[allShots.length - 1];
    const daysSinceStart = Math.floor((new Date().getTime() - firstShot.date.getTime()) / (1000 * 60 * 60 * 24));
    
    // Calculate expected shots based on frequency
    let expectedShots = 0;
    switch (user.glp1Journey.frequency) {
      case 'Every day':
        expectedShots = daysSinceStart;
        break;
      case 'Every 7 days (most common)':
        expectedShots = Math.floor(daysSinceStart / 7);
        break;
      case 'Every 14 days':
        expectedShots = Math.floor(daysSinceStart / 14);
        break;
      default:
        expectedShots = Math.floor(daysSinceStart / 7);
    }

    const adherenceRate = expectedShots > 0 
      ? Math.min(100, (allShots.length / expectedShots) * 100)
      : 100;

    // Analyze pain levels
    const avgPainLevel = allShots.reduce((sum, shot) => sum + shot.painLevel, 0) / allShots.length;

    // Most used injection sites
    const siteCounts: { [key: string]: number } = {};
    allShots.forEach(shot => {
      siteCounts[shot.injectionSite] = (siteCounts[shot.injectionSite] || 0) + 1;
    });
    const mostUsedSite = Object.entries(siteCounts).sort((a, b) => b[1] - a[1])[0];

    // Side effects frequency
    const sideEffectCounts: { [key: string]: number } = {};
    allShots.forEach(shot => {
      shot.sideEffects.forEach(effect => {
        if (effect !== 'None') {
          sideEffectCounts[effect] = (sideEffectCounts[effect] || 0) + 1;
        }
      });
    });

    res.json({
      success: true,
      data: {
        totalShots: allShots.length,
        expectedShots,
        adherenceRate: Math.round(adherenceRate),
        daysSinceStart,
        firstShotDate: firstShot.date,
        latestShotDate: latestShot.date,
        currentDose: latestShot.dosage,
        startingDose: user.glp1Journey.startingDose,
        averagePainLevel: Math.round(avgPainLevel * 10) / 10,
        mostUsedInjectionSite: mostUsedSite ? mostUsedSite[0] : null,
        commonSideEffects: Object.entries(sideEffectCounts)
          .sort((a, b) => b[1] - a[1])
          .slice(0, 3)
          .map(([effect, count]) => ({ effect, count }))
      }
    });
  } catch (error: any) {
    console.error('Get stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to calculate statistics',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   PUT /api/treatments/shots/:id
 * @desc    Update a shot log entry
 * @access  Private
 */
router.put('/shots/:id', authenticate, createShotValidation, async (req: AuthRequest, res: express.Response) => {
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

    const shotLog = await ShotLog.findOne({ _id: id, userId });

    if (!shotLog) {
      return res.status(404).json({
        success: false,
        message: 'Shot log not found'
      });
    }

    // Update fields
    const {
      date,
      medication,
      dosage,
      injectionSite,
      painLevel,
      sideEffects,
      notes,
      photoUrl
    } = req.body;

    if (date) shotLog.date = new Date(date);
    if (medication) shotLog.medication = medication;
    if (dosage) shotLog.dosage = dosage;
    if (injectionSite) shotLog.injectionSite = injectionSite;
    if (painLevel !== undefined) shotLog.painLevel = painLevel;
    if (sideEffects) shotLog.sideEffects = sideEffects;
    if (notes !== undefined) shotLog.notes = notes;
    if (photoUrl !== undefined) shotLog.photoUrl = photoUrl;

    await shotLog.save();

    res.json({
      success: true,
      message: 'Shot log updated successfully',
      data: shotLog
    });
  } catch (error: any) {
    console.error('Update shot log error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update shot log',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   DELETE /api/treatments/shots/:id
 * @desc    Delete a shot log entry
 * @access  Private
 */
router.delete('/shots/:id', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const { id } = req.params;

    const shotLog = await ShotLog.findOneAndDelete({ _id: id, userId });

    if (!shotLog) {
      return res.status(404).json({
        success: false,
        message: 'Shot log not found'
      });
    }

    res.json({
      success: true,
      message: 'Shot log deleted successfully'
    });
  } catch (error: any) {
    console.error('Delete shot log error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete shot log',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/treatments/medication-level/history
 * @desc    Get historical medication level data for visualization
 * @access  Private
 */
router.get('/medication-level/history', authenticate, [
  query('days').optional().isInt({ min: 1, max: 365 }),
  query('groupBy').optional().isIn(['hour', 'day', 'week']),
  query('includePredictions').optional().isBoolean()
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
    const includePredictions = req.query.includePredictions === 'true';

    // Calculate date range
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    // Get historical data
    const historyData = await MedicationLevelHistory.find({
      userId,
      date: { $gte: startDate, $lte: endDate }
    })
    .populate('shotId', 'date medication dosage injectionSite')
    .sort({ date: 1 });

    // Get shots in the same period for context
    const shots = await ShotLog.find({
      userId,
      date: { $gte: startDate, $lte: endDate }
    }).sort({ date: 1 });

    // Process data for visualization
    const processedData: any = {
      historicalLevels: historyData.map(entry => ({
        date: entry.date,
        level: entry.calculatedLevel,
        percentage: entry.percentageOfPeak,
        status: entry.status,
        medication: entry.medication,
        dosage: entry.dosage,
        daysSinceShot: entry.daysSinceLastShot,
        hoursSinceShot: entry.hoursSinceLastShot
      })),
      shotEvents: shots.map(shot => ({
        date: shot.date,
        medication: shot.medication,
        dosage: shot.dosage,
        injectionSite: shot.injectionSite,
        type: 'shot'
      })),
      predictions: includePredictions ? [] : undefined
    };

    // Add predictions if requested
    if (includePredictions && shots.length > 0) {
      const latestShot = shots[shots.length - 1];
      const user = await User.findById(userId);
      
      if (user) {
        const predictions: any[] = [];
        const currentLevel = calculateMedicationLevel(
          latestShot.medication,
          latestShot.dosage,
          latestShot.date,
          calculateNextDueDate(latestShot.date, user.glp1Journey.frequency)
        );

        // Generate predictions for next 7 days
        for (let i = 1; i <= 7; i++) {
          const futureDate = new Date();
          futureDate.setDate(futureDate.getDate() + i);
          
          const hoursSinceShot = (futureDate.getTime() - latestShot.date.getTime()) / (1000 * 60 * 60);
          const halfLife = getHalfLife(latestShot.medication);
          const predictedLevel = 100 * Math.pow(0.5, hoursSinceShot / halfLife);
          
          predictions.push({
            date: futureDate,
            level: Math.max(0, predictedLevel),
            percentage: Math.max(0, predictedLevel),
            type: 'prediction'
          });
        }
        
        processedData.predictions = predictions;
      }
    }

    res.json({
      success: true,
      data: processedData
    });
  } catch (error: any) {
    console.error('Get medication level history error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve medication level history',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/treatments/medication-level/trends
 * @desc    Get medication level trends and analytics
 * @access  Private
 */
router.get('/medication-level/trends', authenticate, [
  query('days').optional().isInt({ min: 7, max: 365 }),
  query('medication').optional().isString()
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
    const medication = req.query.medication as string;

    // Calculate date range
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    // Build query
    const query: any = {
      userId,
      date: { $gte: startDate, $lte: endDate }
    };

    if (medication) {
      query.medication = medication;
    }

    // Get trend data
    const trendData = await MedicationLevelHistory.find(query)
      .sort({ date: 1 });

    // Calculate analytics
    const analytics = {
      averageLevel: 0,
      minLevel: 100,
      maxLevel: 0,
      timeInOptimal: 0,
      timeInDeclining: 0,
      timeInLow: 0,
      timeOverdue: 0,
      levelStability: 0,
      trendDirection: 'stable', // 'increasing', 'decreasing', 'stable'
      weeklyAverages: [] as Array<{ week: string; average: number }>,
      statusDistribution: {
        optimal: 0,
        declining: 0,
        low: 0,
        overdue: 0
      }
    };

    if (trendData.length > 0) {
      // Calculate basic statistics
      const totalLevel = trendData.reduce((sum, entry) => sum + entry.calculatedLevel, 0);
      analytics.averageLevel = totalLevel / trendData.length;
      analytics.minLevel = Math.min(...trendData.map(entry => entry.calculatedLevel));
      analytics.maxLevel = Math.max(...trendData.map(entry => entry.calculatedLevel));

      // Calculate time in each status
      trendData.forEach(entry => {
        analytics.statusDistribution[entry.status]++;
      });

      // Calculate weekly averages
      const weeklyData: { [key: string]: { total: number; count: number } } = {};
      trendData.forEach(entry => {
        const weekKey = getWeekKey(entry.date);
        if (!weeklyData[weekKey]) {
          weeklyData[weekKey] = { total: 0, count: 0 };
        }
        weeklyData[weekKey].total += entry.calculatedLevel;
        weeklyData[weekKey].count++;
      });

      analytics.weeklyAverages = Object.entries(weeklyData).map(([week, data]) => ({
        week,
        average: data.total / data.count
      })).sort((a, b) => a.week.localeCompare(b.week));

      // Calculate trend direction
      if (analytics.weeklyAverages.length >= 2) {
        const firstWeek = analytics.weeklyAverages[0].average;
        const lastWeek = analytics.weeklyAverages[analytics.weeklyAverages.length - 1].average;
        const difference = lastWeek - firstWeek;
        
        if (Math.abs(difference) < 5) {
          analytics.trendDirection = 'stable';
        } else if (difference > 0) {
          analytics.trendDirection = 'increasing';
        } else {
          analytics.trendDirection = 'decreasing';
        }
      }

      // Calculate level stability (standard deviation)
      const variance = trendData.reduce((sum, entry) => {
        const diff = entry.calculatedLevel - analytics.averageLevel;
        return sum + (diff * diff);
      }, 0) / trendData.length;
      
      analytics.levelStability = Math.sqrt(variance);
    }

    res.json({
      success: true,
      data: {
        analytics,
        rawData: trendData.map(entry => ({
          date: entry.date,
          level: entry.calculatedLevel,
          status: entry.status,
          medication: entry.medication,
          dosage: entry.dosage
        }))
      }
    });
  } catch (error: any) {
    console.error('Get medication level trends error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve medication level trends',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   POST /api/treatments/medication-level/calculate
 * @desc    Calculate and store current medication level
 * @access  Private
 */
router.post('/medication-level/calculate', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;

    // Get latest shot
    const latestShot = await ShotLog.findOne({ userId })
      .sort({ date: -1 });

    if (!latestShot) {
      return res.status(404).json({
        success: false,
        message: 'No shots found. Log your first shot to start tracking medication levels.'
      });
    }

    // Get user info
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Calculate current medication level
    const medicationLevel = calculateMedicationLevel(
      latestShot.medication,
      latestShot.dosage,
      latestShot.date,
      latestShot.nextDueDate!
    );

    // Store in history
    const historyEntry = new MedicationLevelHistory({
      userId,
      date: new Date(),
      medication: latestShot.medication,
      dosage: latestShot.dosage,
      calculatedLevel: medicationLevel.currentLevel,
      percentageOfPeak: medicationLevel.percentageOfPeak,
      shotId: latestShot._id,
      daysSinceLastShot: Math.floor(medicationLevel.daysUntilNextDose),
      hoursSinceLastShot: medicationLevel.hoursUntilNextDose,
      nextDueDate: latestShot.nextDueDate,
      status: medicationLevel.status
    });

    await historyEntry.save();

    res.json({
      success: true,
      message: 'Medication level calculated and stored',
      data: {
        currentLevel: medicationLevel.currentLevel,
        percentageOfPeak: medicationLevel.percentageOfPeak,
        status: medicationLevel.status,
        daysUntilNextDose: medicationLevel.daysUntilNextDose,
        hoursUntilNextDose: medicationLevel.hoursUntilNextDose,
        isOverdue: medicationLevel.isOverdue,
        countdown: formatCountdown(medicationLevel.hoursUntilNextDose),
        historyEntry
      }
    });
  } catch (error: any) {
    console.error('Calculate medication level error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to calculate medication level',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * Helper function to get half-life for medication
 */
function getHalfLife(medication: string): number {
  const halfLives: { [key: string]: number } = {
    'Ozempic®': 168, // ~7 days (Semaglutide)
    'Wegovy®': 168, // ~7 days (Semaglutide)
    'Compounded Semaglutide': 168, // ~7 days
    'Mounjaro®': 120, // ~5 days (Tirzepatide)
    'Zepbound®': 120, // ~5 days (Tirzepatide)
    'Compounded Tirzepatide': 120, // ~5 days
    'Trulicity®': 120, // ~5 days (Dulaglutide)
  };
  
  return halfLives[medication] || 168; // Default to 7 days
}

// Helper function to determine medication status based on percentage
function getMedicationStatus(percentage: number): string {
  if (percentage >= 80) return 'optimal';
  if (percentage >= 50) return 'declining';
  if (percentage >= 20) return 'low';
  return 'overdue';
}

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

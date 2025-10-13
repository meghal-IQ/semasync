import express from 'express';
import { body, param, query, validationResult } from 'express-validator';
import TreatmentSchedule from '../models/TreatmentSchedule';
import ShotLog from '../models/ShotLog';
import User from '../models/User';
import { authenticate, AuthRequest } from '../middleware/auth';
import { calculateNextDueDate } from '../utils/medicationCalculations';

const router = express.Router();

/**
 * @route   POST /api/treatment-schedule
 * @desc    Create or update treatment schedule
 * @access  Private
 */
router.post('/', authenticate, [
  body('medication').notEmpty().withMessage('Medication is required'),
  body('dosage').notEmpty().withMessage('Dosage is required'),
  body('frequency').notEmpty().withMessage('Frequency is required'),
  body('preferredTime').optional().isIn(['Morning', 'Afternoon', 'Evening', 'Night', 'Any time']),
  body('specificTime').optional().matches(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/),
  body('customInterval').optional().isInt({ min: 1 }),
  body('reminders.enabled').optional().isBoolean(),
  body('reminders.preDoseHours').optional().isArray(),
  body('reminders.postDoseHours').optional().isArray(),
  body('reminders.missedDoseHours').optional().isArray(),
  body('reminders.escalationEnabled').optional().isBoolean()
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
      medication,
      dosage,
      frequency,
      preferredTime,
      specificTime,
      customInterval,
      reminders
    } = req.body;

    // Check if user already has an active schedule
    const existingSchedule = await TreatmentSchedule.findOne({
      userId,
      isActive: true
    });

    let schedule;
    if (existingSchedule) {
      // Update existing schedule
      existingSchedule.medication = medication;
      existingSchedule.dosage = dosage;
      existingSchedule.frequency = frequency;
      existingSchedule.preferredTime = preferredTime || 'Any time';
      existingSchedule.specificTime = specificTime;
      existingSchedule.customInterval = customInterval;
      
      if (reminders) {
        existingSchedule.reminders = {
          ...existingSchedule.reminders,
          ...reminders
        };
      }

      // Add adjustment record
      existingSchedule.adjustments.push({
        date: new Date(),
        reason: 'manual_adjustment',
        oldValue: {
          medication: existingSchedule.medication,
          dosage: existingSchedule.dosage,
          frequency: existingSchedule.frequency
        },
        newValue: { medication, dosage, frequency }
      });

      await existingSchedule.save();
      schedule = existingSchedule;
    } else {
      // Create new schedule
      schedule = new TreatmentSchedule({
        userId,
        medication,
        dosage,
        frequency,
        preferredTime: preferredTime || 'Any time',
        specificTime,
        customInterval,
        timeZone: req.body.timeZone || 'UTC',
        reminders: reminders || {
          enabled: true,
          preDoseHours: [24, 2],
          postDoseHours: [2],
          missedDoseHours: [24, 72],
          escalationEnabled: false
        }
      });

      await schedule.save();
    }

    res.status(201).json({
      success: true,
      message: 'Treatment schedule saved successfully',
      data: schedule
    });
  } catch (error: any) {
    console.error('Create/update schedule error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to save treatment schedule',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/treatment-schedule
 * @desc    Get current treatment schedule
 * @access  Private
 */
router.get('/', authenticate, async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;

    const schedule = await TreatmentSchedule.findOne({
      userId,
      isActive: true
    });

    if (!schedule) {
      return res.json({
        success: true,
        data: null,
        message: 'No active treatment schedule found'
      });
    }

    // Calculate next due date
    const latestShot = await ShotLog.findOne({ userId }).sort({ date: -1 });
    let nextDueDate = null;
    
    if (latestShot) {
      const user = await User.findById(userId);
      if (user) {
        nextDueDate = calculateNextDueDate(latestShot.date, schedule.frequency);
      }
    }

    res.json({
      success: true,
      data: {
        schedule,
        nextDueDate,
        hasShots: !!latestShot
      }
    });
  } catch (error: any) {
    console.error('Get schedule error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get treatment schedule',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   PUT /api/treatment-schedule/:id
 * @desc    Update specific treatment schedule
 * @access  Private
 */
router.put('/:id', authenticate, [
  param('id').isMongoId().withMessage('Invalid schedule ID'),
  body('medication').optional().notEmpty(),
  body('dosage').optional().notEmpty(),
  body('frequency').optional().notEmpty(),
  body('preferredTime').optional().isIn(['Morning', 'Afternoon', 'Evening', 'Night', 'Any time']),
  body('specificTime').optional().matches(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/),
  body('customInterval').optional().isInt({ min: 1 }),
  body('isActive').optional().isBoolean()
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
    const scheduleId = req.params.id;

    const schedule = await TreatmentSchedule.findOne({
      _id: scheduleId,
      userId
    });

    if (!schedule) {
      return res.status(404).json({
        success: false,
        message: 'Treatment schedule not found'
      });
    }

    // Update fields
    const updateFields = req.body;
    Object.keys(updateFields).forEach(key => {
      if (updateFields[key] !== undefined) {
        (schedule as any)[key] = updateFields[key];
      }
    });

    // Add adjustment record for significant changes
    if (updateFields.medication || updateFields.dosage || updateFields.frequency) {
      schedule.adjustments.push({
        date: new Date(),
        reason: 'manual_adjustment',
        oldValue: {
          medication: schedule.medication,
          dosage: schedule.dosage,
          frequency: schedule.frequency
        },
        newValue: {
          medication: updateFields.medication || schedule.medication,
          dosage: updateFields.dosage || schedule.dosage,
          frequency: updateFields.frequency || schedule.frequency
        }
      });
    }

    await schedule.save();

    res.json({
      success: true,
      message: 'Treatment schedule updated successfully',
      data: schedule
    });
  } catch (error: any) {
    console.error('Update schedule error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update treatment schedule',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/treatment-schedule/adherence
 * @desc    Get adherence analytics
 * @access  Private
 */
router.get('/adherence', authenticate, [
  query('days').optional().isInt({ min: 7, max: 365 })
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

    const schedule = await TreatmentSchedule.findOne({
      userId,
      isActive: true
    });

    if (!schedule) {
      return res.status(404).json({
        success: false,
        message: 'No active treatment schedule found'
      });
    }

    // Calculate date range
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(endDate.getDate() - days);

    // Get shots in the period
    const shots = await ShotLog.find({
      userId,
      date: { $gte: startDate, $lte: endDate }
    }).sort({ date: 1 });

    // Calculate expected doses based on frequency
    let expectedDoses = 0;
    const currentDate = new Date(startDate);
    
    while (currentDate <= endDate) {
      if (schedule.frequency === 'Every day') {
        expectedDoses++;
        currentDate.setDate(currentDate.getDate() + 1);
      } else if (schedule.frequency === 'Every 7 days (most common)') {
        expectedDoses++;
        currentDate.setDate(currentDate.getDate() + 7);
      } else if (schedule.frequency === 'Every 14 days') {
        expectedDoses++;
        currentDate.setDate(currentDate.getDate() + 14);
      } else if (schedule.frequency === 'Custom' && schedule.customInterval) {
        expectedDoses++;
        currentDate.setDate(currentDate.getDate() + schedule.customInterval);
      } else {
        break;
      }
    }

    // Calculate adherence metrics
    const actualDoses = shots.length;
    const missedDoses = Math.max(0, expectedDoses - actualDoses);
    const adherencePercentage = expectedDoses > 0 ? Math.round((actualDoses / expectedDoses) * 100) : 100;

    // Calculate streaks
    let currentStreak = 0;
    let longestStreak = 0;
    let tempStreak = 0;
    
    const sortedShots = shots.sort((a, b) => b.date.getTime() - a.date.getTime());
    
    for (let i = 0; i < sortedShots.length; i++) {
      const shot = sortedShots[i];
      const expectedDate = new Date(shot.date);
      
      // Check if this shot was on time (within 1 day of expected)
      const daysDiff = Math.abs((new Date().getTime() - expectedDate.getTime()) / (1000 * 60 * 60 * 24));
      
      if (daysDiff <= 1) {
        if (i === 0) currentStreak = 1;
        else currentStreak++;
        tempStreak++;
      } else {
        longestStreak = Math.max(longestStreak, tempStreak);
        tempStreak = 0;
      }
    }
    
    longestStreak = Math.max(longestStreak, tempStreak);

    // Weekly adherence breakdown
    const weeklyAdherence = [];
    const weekStart = new Date(startDate);
    
    while (weekStart <= endDate) {
      const weekEnd = new Date(weekStart);
      weekEnd.setDate(weekStart.getDate() + 7);
      
      const weekShots = shots.filter(shot => 
        shot.date >= weekStart && shot.date < weekEnd
      );
      
      // Calculate expected doses for this week
      let weekExpected = 0;
      if (schedule.frequency === 'Every day') {
        weekExpected = 7;
      } else if (schedule.frequency === 'Every 7 days (most common)') {
        weekExpected = 1;
      } else if (schedule.frequency === 'Every 14 days') {
        weekExpected = 0.5;
      } else if (schedule.frequency === 'Custom' && schedule.customInterval) {
        weekExpected = 7 / schedule.customInterval;
      }
      
      const weekAdherence = weekExpected > 0 ? Math.round((weekShots.length / weekExpected) * 100) : 100;
      
      weeklyAdherence.push({
        week: weekStart.toISOString().split('T')[0],
        expected: Math.round(weekExpected),
        actual: weekShots.length,
        adherence: weekAdherence
      });
      
      weekStart.setDate(weekStart.getDate() + 7);
    }

    // Update schedule with calculated adherence
    schedule.adherence = {
      totalScheduledDoses: expectedDoses,
      totalTakenDoses: actualDoses,
      totalMissedDoses: missedDoses,
      currentStreak,
      longestStreak,
      adherencePercentage,
      lastCalculated: new Date()
    };
    
    await schedule.save();

    res.json({
      success: true,
      data: {
        adherence: schedule.adherence,
        weeklyBreakdown: weeklyAdherence,
        shotsInPeriod: shots.length,
        period: {
          startDate,
          endDate,
          days
        }
      }
    });
  } catch (error: any) {
    console.error('Get adherence error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get adherence analytics',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/treatment-schedule/calendar
 * @desc    Get treatment schedule calendar view
 * @access  Private
 */
router.get('/calendar', authenticate, [
  query('month').optional().isInt({ min: 1, max: 12 }),
  query('year').optional().isInt({ min: 2020, max: 2030 })
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
    const month = parseInt(req.query.month as string) || new Date().getMonth() + 1;
    const year = parseInt(req.query.year as string) || new Date().getFullYear();

    const schedule = await TreatmentSchedule.findOne({
      userId,
      isActive: true
    });

    if (!schedule) {
      return res.status(404).json({
        success: false,
        message: 'No active treatment schedule found'
      });
    }

    // Get shots for the month
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0);
    
    const shots = await ShotLog.find({
      userId,
      date: { $gte: startDate, $lte: endDate }
    }).sort({ date: 1 });

    // Generate expected dose dates
    const expectedDoses = [];
    const currentDate = new Date(startDate);
    
    while (currentDate <= endDate) {
      let nextDoseDate: Date;
      
      if (schedule.frequency === 'Every day') {
        nextDoseDate = new Date(currentDate);
        currentDate.setDate(currentDate.getDate() + 1);
      } else if (schedule.frequency === 'Every 7 days (most common)') {
        nextDoseDate = new Date(currentDate);
        currentDate.setDate(currentDate.getDate() + 7);
      } else if (schedule.frequency === 'Every 14 days') {
        nextDoseDate = new Date(currentDate);
        currentDate.setDate(currentDate.getDate() + 14);
      } else if (schedule.frequency === 'Custom' && schedule.customInterval) {
        nextDoseDate = new Date(currentDate);
        currentDate.setDate(currentDate.getDate() + schedule.customInterval);
      } else {
        break;
      }
      
      if (nextDoseDate <= endDate) {
        expectedDoses.push({
          date: nextDoseDate,
          medication: schedule.medication,
          dosage: schedule.dosage,
          status: 'scheduled'
        });
      }
    }

    // Match actual shots with expected doses
    const calendarData = expectedDoses.map(expected => {
      const actualShot = shots.find(shot => {
        const shotDate = new Date(shot.date);
        const expectedDate = new Date(expected.date);
        const dayDiff = Math.abs((shotDate.getTime() - expectedDate.getTime()) / (1000 * 60 * 60 * 24));
        return dayDiff <= 1; // Within 1 day
      });

      if (actualShot) {
        return {
          date: expected.date,
          medication: expected.medication,
          dosage: expected.dosage,
          status: 'taken',
          shotId: actualShot._id,
          actualDate: actualShot.date,
          injectionSite: actualShot.injectionSite,
          sideEffects: actualShot.sideEffects
        };
      } else {
        const now = new Date();
        const isOverdue = expected.date < now;
        
        return {
          date: expected.date,
          medication: expected.medication,
          dosage: expected.dosage,
          status: isOverdue ? 'overdue' : 'scheduled'
        };
      }
    });

    res.json({
      success: true,
      data: {
        calendar: calendarData,
        month,
        year,
        schedule: {
          medication: schedule.medication,
          dosage: schedule.dosage,
          frequency: schedule.frequency,
          preferredTime: schedule.preferredTime
        }
      }
    });
  } catch (error: any) {
    console.error('Get calendar error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get calendar data',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   POST /api/treatment-schedule/reminders/test
 * @desc    Test reminder functionality
 * @access  Private
 */
router.post('/reminders/test', authenticate, [
  body('type').isIn(['pre-dose', 'post-dose', 'missed-dose']).withMessage('Invalid reminder type'),
  body('hours').isInt({ min: 0 }).withMessage('Hours must be a positive integer')
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
    const { type, hours } = req.body;

    const schedule = await TreatmentSchedule.findOne({
      userId,
      isActive: true
    });

    if (!schedule) {
      return res.status(404).json({
        success: false,
        message: 'No active treatment schedule found'
      });
    }

    // In a real implementation, this would trigger the actual reminder system
    // For now, we'll just return a success message
    res.json({
      success: true,
      message: `Test ${type} reminder scheduled for ${hours} hours`,
      data: {
        type,
        hours,
        scheduleId: schedule._id,
        reminderTime: new Date(Date.now() + hours * 60 * 60 * 1000)
      }
    });
  } catch (error: any) {
    console.error('Test reminder error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to test reminder',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

export default router;

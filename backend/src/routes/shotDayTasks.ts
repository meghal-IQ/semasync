import express from 'express';
import { body, query } from 'express-validator';
import ShotDayTask from '../models/ShotDayTask';
import { authenticate, AuthRequest } from '../middleware/auth';

const router = express.Router();

// Get shot day tasks for a specific date
router.get('/', authenticate, [
  query('date').optional().isISO8601()
], async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const { date } = req.query;

    // Parse the target date or use today
    const targetDate = date ? new Date(date as string) : new Date();
    targetDate.setHours(0, 0, 0, 0); // Start of day

    // Find tasks for the specific date
    let shotDayTask = await ShotDayTask.findOne({
      userId,
      date: targetDate
    });

    // If no tasks exist for this date, create default tasks
    if (!shotDayTask) {
      const defaultTasks = [
        {
          title: 'High-Protein Meal/Drink',
          time: '7:00 PM',
          completed: false,
        },
        {
          title: 'Drink lots of Water (+electrolytes)',
          time: '7:00 PM',
          completed: false,
        },
        {
          title: 'Load Syringe and let come to room temp',
          time: '7:15 PM',
          completed: false,
        },
        {
          title: 'Take Shot',
          time: '8:00 PM',
          completed: false,
          isMainTask: true,
        },
        {
          title: 'Another High Protein Meal/Drink',
          time: '9:00 PM',
          completed: false,
        },
      ];

      shotDayTask = new ShotDayTask({
        userId,
        date: targetDate,
        tasks: defaultTasks,
        selectedDays: []
      });

      await shotDayTask.save();
    }

    res.json({
      success: true,
      data: shotDayTask
    });
  } catch (error: any) {
    console.error('Get shot day tasks error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve shot day tasks',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Update shot day tasks
router.put('/', authenticate, [
  body('date').isISO8601(),
  body('tasks').isArray(),
  body('tasks.*.title').isString(),
  body('tasks.*.time').isString(),
  body('tasks.*.completed').isBoolean(),
  body('selectedDays').optional().isArray()
], async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const { date, tasks, selectedDays } = req.body;

    const targetDate = new Date(date);
    targetDate.setHours(0, 0, 0, 0);

    // Update or create shot day task
    let shotDayTask = await ShotDayTask.findOne({
      userId,
      date: targetDate
    });

    if (shotDayTask) {
      shotDayTask.tasks = tasks;
      if (selectedDays !== undefined) {
        shotDayTask.selectedDays = selectedDays;
      }
      await shotDayTask.save();
    } else {
      shotDayTask = new ShotDayTask({
        userId,
        date: targetDate,
        tasks,
        selectedDays: selectedDays || []
      });
      await shotDayTask.save();
    }

    res.json({
      success: true,
      message: 'Shot day tasks updated successfully',
      data: shotDayTask
    });
  } catch (error: any) {
    console.error('Update shot day tasks error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update shot day tasks',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Update selected shot days (days of week)
router.put('/selected-days', authenticate, [
  body('selectedDays').isArray()
], async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const { selectedDays } = req.body;

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Update today's record with selected days
    let shotDayTask = await ShotDayTask.findOne({
      userId,
      date: today
    });

    if (shotDayTask) {
      shotDayTask.selectedDays = selectedDays;
      await shotDayTask.save();
    } else {
      // Create a new record with default tasks
      const defaultTasks = [
        {
          title: 'High-Protein Meal/Drink',
          time: '7:00 PM',
          completed: false,
        },
        {
          title: 'Drink lots of Water (+electrolytes)',
          time: '7:00 PM',
          completed: false,
        },
        {
          title: 'Load Syringe and let come to room temp',
          time: '7:15 PM',
          completed: false,
        },
        {
          title: 'Take Shot',
          time: '8:00 PM',
          completed: false,
          isMainTask: true,
        },
        {
          title: 'Another High Protein Meal/Drink',
          time: '9:00 PM',
          completed: false,
        },
      ];

      shotDayTask = new ShotDayTask({
        userId,
        date: today,
        tasks: defaultTasks,
        selectedDays
      });
      await shotDayTask.save();
    }

    res.json({
      success: true,
      message: 'Selected shot days updated successfully',
      data: shotDayTask
    });
  } catch (error: any) {
    console.error('Update selected days error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update selected days',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Toggle a specific task
router.patch('/toggle-task', authenticate, [
  body('date').isISO8601(),
  body('taskIndex').isInt({ min: 0 })
], async (req: AuthRequest, res: express.Response) => {
  try {
    const userId = req.user!._id;
    const { date, taskIndex } = req.body;

    const targetDate = new Date(date);
    targetDate.setHours(0, 0, 0, 0);

    const shotDayTask = await ShotDayTask.findOne({
      userId,
      date: targetDate
    });

    if (!shotDayTask) {
      return res.status(404).json({
        success: false,
        message: 'Shot day tasks not found'
      });
    }

    if (taskIndex >= shotDayTask.tasks.length) {
      return res.status(400).json({
        success: false,
        message: 'Invalid task index'
      });
    }

    // Toggle the task
    shotDayTask.tasks[taskIndex].completed = !shotDayTask.tasks[taskIndex].completed;
    await shotDayTask.save();

    res.json({
      success: true,
      message: 'Task toggled successfully',
      data: shotDayTask
    });
  } catch (error: any) {
    console.error('Toggle task error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to toggle task',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

export default router;


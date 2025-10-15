import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import swaggerUi from 'swagger-ui-express';
import 'express-async-errors';
import dotenv from 'dotenv';

import connectDB from './config/database';
import { swaggerSpec } from './config/swagger';
import authRoutes from './routes/auth';
import treatmentRoutes from './routes/treatments';
import sideEffectRoutes from './routes/sideEffects';
import treatmentScheduleRoutes from './routes/treatmentSchedule';
import healthRoutes from './routes/health';
import activityRoutes from './routes/activity';
import nutritionRoutes from './routes/nutrition';
import weeklyCheckupRoutes from './routes/weeklyCheckup';
import foodRecognitionRoutes from './routes/foodRecognition';
import shotDayTasksRoutes from './routes/shotDayTasks';

// Load environment variables
dotenv.config();

const app = express();
const PORT = parseInt(process.env.PORT || '8080');

// Security middleware
app.use(helmet());

// Rate limiting - completely disabled in development
if (process.env.NODE_ENV === 'production') {
  const limiter = rateLimit({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'), // 15 minutes
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
    message: {
      success: false,
      message: 'Too many requests from this IP, please try again later.'
    },
    standardHeaders: true,
    legacyHeaders: false,
  });

  app.use(limiter);

  const authLimiter = rateLimit({
    windowMs: parseInt(process.env.AUTH_RATE_LIMIT_WINDOW_MS || '900000'),
    max: parseInt(process.env.AUTH_RATE_LIMIT_MAX_REQUESTS || '50'),
    message: {
      success: false,
      message: 'Too many authentication requests from this IP, please try again later.'
    },
    standardHeaders: true,
    legacyHeaders: false,
  });

  app.use('/api/auth', authLimiter);
  
  console.log('⚠️  Rate limiting enabled for production');
} else {
  console.log('✅ Rate limiting disabled for development');
}

// CORS configuration
app.use(cors({
  origin: [
    process.env.CLIENT_URL || 'http://localhost:3000',
    'http://localhost:*',
    'http://192.168.1.*',
    'http://10.0.2.2:*', // Android emulator
    'http://127.0.0.1:*'
  ],
  credentials: true
}));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'SemaSync API is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV
  });
});

// Swagger documentation
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  explorer: true,
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'SemaSync API Documentation'
}));

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/treatments', treatmentRoutes);
app.use('/api/treatments/side-effects', sideEffectRoutes);
app.use('/api/treatments/weekly-checkup', weeklyCheckupRoutes);
app.use('/api/treatment-schedule', treatmentScheduleRoutes);
app.use('/api/health', healthRoutes);
app.use('/api/activity', activityRoutes);
app.use('/api/nutrition', nutritionRoutes);
app.use('/api/food-recognition', foodRecognitionRoutes);
app.use('/api/shot-day-tasks', shotDayTasksRoutes);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Global error handler
app.use((error: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Global error handler:', error);
  
  res.status(error.status || 500).json({
    success: false,
    message: error.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
  });
});

// Start server
const startServer = async () => {
  try {
    // Connect to database
    await connectDB();
    
    // Start server
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Server is running on port ${PORT}`);
      console.log(`Environment: ${process.env.NODE_ENV}`);
      console.log(`Health check: http://localhost:${PORT}/health`);
      console.log(`API Documentation: http://localhost:${PORT}/api-docs`);
      console.log(`Network access: http://192.168.1.36:${PORT}/health`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();

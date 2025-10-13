import mongoose, { Document, Schema } from 'mongoose';

// Steps Log
export interface IStepLog extends Document {
  userId: mongoose.Types.ObjectId;
  date: Date;
  steps: number;
  goal: number;
  distance?: number; // in km or miles
  caloriesBurned?: number;
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

const stepLogSchema = new Schema<IStepLog>({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required'],
    index: true
  },
  date: {
    type: Date,
    required: [true, 'Date is required'],
    default: Date.now,
    index: true
  },
  steps: {
    type: Number,
    required: [true, 'Steps count is required'],
    min: [0, 'Steps cannot be negative'],
    max: [100000, 'Steps seems unrealistic']
  },
  goal: {
    type: Number,
    default: 10000,
    min: [0, 'Goal cannot be negative']
  },
  distance: {
    type: Number,
    min: [0, 'Distance cannot be negative']
  },
  caloriesBurned: {
    type: Number,
    min: [0, 'Calories cannot be negative']
  },
  notes: {
    type: String,
    maxlength: [500, 'Notes cannot exceed 500 characters'],
    trim: true
  }
}, {
  timestamps: true,
  toJSON: {
    transform: function(doc, ret) {
      ret.id = ret._id;
      delete ret._id;
      delete ret.__v;
      return ret;
    }
  }
});

stepLogSchema.index({ userId: 1, date: -1 });

// Workout Log
export interface IWorkoutLog extends Document {
  userId: mongoose.Types.ObjectId;
  date: Date;
  type: string;
  duration: number; // in minutes
  intensity: number; // 1-10 scale
  caloriesBurned: number;
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

const workoutLogSchema = new Schema<IWorkoutLog>({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required'],
    index: true
  },
  date: {
    type: Date,
    required: [true, 'Date is required'],
    default: Date.now,
    index: true
  },
  type: {
    type: String,
    required: [true, 'Workout type is required'],
    enum: [
      'Cardio',
      'Strength Training',
      'Yoga',
      'Swimming',
      'Cycling',
      'Running',
      'Walking',
      'HIIT',
      'Pilates',
      'Sports',
      'Other'
    ]
  },
  duration: {
    type: Number,
    required: [true, 'Duration is required'],
    min: [1, 'Duration must be at least 1 minute'],
    max: [600, 'Duration seems unrealistic']
  },
  intensity: {
    type: Number,
    required: [true, 'Intensity is required'],
    min: [1, 'Intensity must be between 1 and 10'],
    max: [10, 'Intensity must be between 1 and 10']
  },
  caloriesBurned: {
    type: Number,
    required: [true, 'Calories burned is required'],
    min: [0, 'Calories cannot be negative']
  },
  notes: {
    type: String,
    maxlength: [500, 'Notes cannot exceed 500 characters'],
    trim: true
  }
}, {
  timestamps: true,
  toJSON: {
    transform: function(doc, ret) {
      ret.id = ret._id;
      delete ret._id;
      delete ret.__v;
      return ret;
    }
  }
});

workoutLogSchema.index({ userId: 1, date: -1 });

export const StepLog = mongoose.model<IStepLog>('StepLog', stepLogSchema);
export const WorkoutLog = mongoose.model<IWorkoutLog>('WorkoutLog', workoutLogSchema);

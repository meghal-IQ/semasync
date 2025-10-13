import mongoose, { Document, Schema } from 'mongoose';

export interface ITreatmentSchedule extends Document {
  userId: mongoose.Types.ObjectId;
  
  // Schedule Configuration
  medication: string;
  dosage: string;
  frequency: string; // 'Every day', 'Every 7 days', 'Every 14 days', 'Custom'
  customInterval?: number; // For custom frequency (in days)
  
  // Schedule Timing
  preferredTime?: string; // 'Morning', 'Afternoon', 'Evening', 'Night', 'Any time'
  specificTime?: string; // Specific time like "08:00" for daily doses
  timeZone: string;
  
  // Schedule Status
  isActive: boolean;
  startDate: Date;
  endDate?: Date;
  
  // Reminder Settings
  reminders: {
    enabled: boolean;
    preDoseHours: number[]; // [24, 2] means 24 hours and 2 hours before
    postDoseHours: number[]; // Hours after dose to remind about side effects
    missedDoseHours: number[]; // Hours after missed dose to escalate
    escalationEnabled: boolean;
  };
  
  // Adherence Tracking
  adherence: {
    totalScheduledDoses: number;
    totalTakenDoses: number;
    totalMissedDoses: number;
    currentStreak: number;
    longestStreak: number;
    adherencePercentage: number;
    lastCalculated: Date;
  };
  
  // Schedule Adjustments
  adjustments: {
    date: Date;
    reason: 'dose_change' | 'frequency_change' | 'medication_change' | 'manual_adjustment';
    oldValue: any;
    newValue: any;
    notes?: string;
  }[];
  
  // Metadata
  createdAt: Date;
  updatedAt: Date;
}

const TreatmentScheduleSchema = new Schema<ITreatmentSchedule>({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required'],
    index: true
  },
  
  // Schedule Configuration
  medication: {
    type: String,
    required: [true, 'Medication is required'],
    enum: [
      'Ozempic®',
      'Wegovy®', 
      'Mounjaro®',
      'Zepbound®',
      'Trulicity®',
      'Compounded Semaglutide',
      'Compounded Tirzepatide'
    ]
  },
  dosage: {
    type: String,
    required: [true, 'Dosage is required'],
    enum: ['0.25mg', '0.5mg', '0.7mg', '1.0mg', '1.5mg', '1.7mg', '2.0mg', '2.4mg']
  },
  frequency: {
    type: String,
    required: [true, 'Frequency is required'],
    enum: ['Every day', 'Every 7 days (most common)', 'Every 14 days', 'Custom', 'Not sure, still figuring it out']
  },
  customInterval: {
    type: Number,
    min: [1, 'Custom interval must be at least 1 day']
  },
  
  // Schedule Timing
  preferredTime: {
    type: String,
    enum: ['Morning', 'Afternoon', 'Evening', 'Night', 'Any time'],
    default: 'Any time'
  },
  specificTime: {
    type: String,
    match: [/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/, 'Invalid time format. Use HH:MM']
  },
  timeZone: {
    type: String,
    required: [true, 'Time zone is required'],
    default: 'UTC'
  },
  
  // Schedule Status
  isActive: {
    type: Boolean,
    default: true
  },
  startDate: {
    type: Date,
    required: [true, 'Start date is required'],
    default: Date.now
  },
  endDate: {
    type: Date
  },
  
  // Reminder Settings
  reminders: {
    enabled: {
      type: Boolean,
      default: true
    },
    preDoseHours: [{
      type: Number,
      min: [0, 'Pre-dose hours must be non-negative']
    }],
    postDoseHours: [{
      type: Number,
      min: [0, 'Post-dose hours must be non-negative']
    }],
    missedDoseHours: [{
      type: Number,
      min: [0, 'Missed dose hours must be non-negative']
    }],
    escalationEnabled: {
      type: Boolean,
      default: false
    }
  },
  
  // Adherence Tracking
  adherence: {
    totalScheduledDoses: {
      type: Number,
      default: 0,
      min: [0, 'Total scheduled doses cannot be negative']
    },
    totalTakenDoses: {
      type: Number,
      default: 0,
      min: [0, 'Total taken doses cannot be negative']
    },
    totalMissedDoses: {
      type: Number,
      default: 0,
      min: [0, 'Total missed doses cannot be negative']
    },
    currentStreak: {
      type: Number,
      default: 0,
      min: [0, 'Current streak cannot be negative']
    },
    longestStreak: {
      type: Number,
      default: 0,
      min: [0, 'Longest streak cannot be negative']
    },
    adherencePercentage: {
      type: Number,
      default: 100,
      min: [0, 'Adherence percentage cannot be negative'],
      max: [100, 'Adherence percentage cannot exceed 100']
    },
    lastCalculated: {
      type: Date,
      default: Date.now
    }
  },
  
  // Schedule Adjustments
  adjustments: [{
    date: {
      type: Date,
      required: true
    },
    reason: {
      type: String,
      required: true,
      enum: ['dose_change', 'frequency_change', 'medication_change', 'manual_adjustment']
    },
    oldValue: Schema.Types.Mixed,
    newValue: Schema.Types.Mixed,
    notes: String
  }],
  
  // Metadata
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
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

// Indexes for better performance
TreatmentScheduleSchema.index({ userId: 1, isActive: 1 });
TreatmentScheduleSchema.index({ userId: 1, startDate: 1, endDate: 1 });

// Update adherence when schedule changes
TreatmentScheduleSchema.pre('save', function(next) {
  if (this.isModified('adherence.totalTakenDoses') || this.isModified('adherence.totalScheduledDoses')) {
    if (this.adherence.totalScheduledDoses > 0) {
      this.adherence.adherencePercentage = Math.round(
        (this.adherence.totalTakenDoses / this.adherence.totalScheduledDoses) * 100
      );
    }
    this.adherence.lastCalculated = new Date();
  }
  next();
});

export default mongoose.model<ITreatmentSchedule>('TreatmentSchedule', TreatmentScheduleSchema);

import mongoose, { Document, Schema } from 'mongoose';

export interface ISideEffectLog extends Document {
  userId: mongoose.Types.ObjectId;
  date: Date;
  effects: Array<{
    name: string;
    severity: number; // 0-10 scale
    description?: string;
    duration?: number; // Hours the effect lasted
    triggers?: string[]; // What might have triggered it
    remedies?: string[]; // What helped alleviate it
  }>;
  overallSeverity: number;
  notes?: string;
  relatedToShot?: boolean;
  shotId?: mongoose.Types.ObjectId; // Reference to specific shot
  daysSinceShot?: number;
  // New fields for enhanced tracking
  isActive: boolean; // Whether side effects are still ongoing
  resolvedAt?: Date; // When side effects were resolved
  createdAt: Date;
  updatedAt: Date;
}

const sideEffectLogSchema = new Schema<ISideEffectLog>({
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
  effects: [{
    name: {
      type: String,
      required: [true, 'Effect name is required'],
      enum: [
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
      ]
    },
    severity: {
      type: Number,
      required: [true, 'Severity is required'],
      min: [0, 'Severity must be between 0 and 10'],
      max: [10, 'Severity must be between 0 and 10']
    },
    description: {
      type: String,
      maxlength: [200, 'Description cannot exceed 200 characters']
    },
    duration: {
      type: Number,
      min: [0, 'Duration cannot be negative']
    },
    triggers: [{
      type: String,
      enum: [
        'Medication dose',
        'Food intake',
        'Stress',
        'Exercise',
        'Weather changes',
        'Sleep disruption',
        'Other medications',
        'Unknown'
      ]
    }],
    remedies: [{
      type: String,
      enum: [
        'Rest',
        'Hydration',
        'Light meal',
        'Ginger',
        'Peppermint',
        'Over-the-counter medication',
        'Prescription medication',
        'Deep breathing',
        'Other'
      ]
    }]
  }],
  overallSeverity: {
    type: Number,
    required: [true, 'Overall severity is required'],
    min: [0, 'Severity must be between 0 and 10'],
    max: [10, 'Severity must be between 0 and 10'],
    default: 0
  },
  notes: {
    type: String,
    maxlength: [500, 'Notes cannot exceed 500 characters'],
    trim: true
  },
  relatedToShot: {
    type: Boolean,
    default: false
  },
  shotId: {
    type: Schema.Types.ObjectId,
    ref: 'ShotLog'
  },
  daysSinceShot: {
    type: Number,
    min: [0, 'Days cannot be negative']
  },
  isActive: {
    type: Boolean,
    default: true
  },
  resolvedAt: {
    type: Date
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

// Indexes for efficient queries
sideEffectLogSchema.index({ userId: 1, date: -1 });
sideEffectLogSchema.index({ userId: 1, 'effects.name': 1 });

const SideEffectLog = mongoose.model<ISideEffectLog>('SideEffectLog', sideEffectLogSchema);

export default SideEffectLog;

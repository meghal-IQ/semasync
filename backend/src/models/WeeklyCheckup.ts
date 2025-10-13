import mongoose, { Document, Schema } from 'mongoose';

export interface IWeeklyCheckup extends Document {
  userId: mongoose.Types.ObjectId;
  date: Date;
  currentWeight: number;
  weightUnit: 'kg' | 'lbs';
  weightChange?: number;
  weightChangePercent?: number;
  sideEffects: string[];
  overallSideEffectSeverity: number;
  dosageRecommendation: string;
  recommendationReason: string;
  bayesianFactors: {
    priorProbability: number;
    likelihood: number;
    posteriorProbability: number;
    individualFactors: Record<string, number>;
    confidenceLevel: 'low' | 'medium' | 'high';
  };
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

const weeklyCheckupSchema = new Schema<IWeeklyCheckup>({
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
  currentWeight: {
    type: Number,
    required: [true, 'Current weight is required'],
    min: [20, 'Weight must be at least 20kg'],
    max: [500, 'Weight cannot exceed 500kg']
  },
  weightUnit: {
    type: String,
    enum: ['kg', 'lbs'],
    required: [true, 'Weight unit is required'],
    default: 'lbs'
  },
  weightChange: {
    type: Number
  },
  weightChangePercent: {
    type: Number
  },
  sideEffects: [{
    type: String,
    enum: [
      'Nausea',
      'Vomiting',
      'Diarrhea',
      'Constipation',
      'Fatigue',
      'Headache',
      'Dizziness',
      'Abdominal Pain',
      'Decreased Appetite',
      'Injection Site Reaction',
      'Heartburn',
      'Bloating',
      'Hair Loss',
      'Muscle Loss',
      'Low Blood Sugar',
      'Mood Changes',
      'Sleep Disturbances',
      'Dry Mouth',
      'Sulfur Burps',
      'Food Noise',
      'Loose Skin',
      'Injection Anxiety',
    ]
  }],
  overallSideEffectSeverity: {
    type: Number,
    required: [true, 'Overall side effect severity is required'],
    min: [0, 'Severity must be between 0 and 10'],
    max: [10, 'Severity must be between 0 and 10']
  },
  dosageRecommendation: {
    type: String,
    required: [true, 'Dosage recommendation is required'],
    enum: [
      'continueCurrent',
      'increaseDose',
      'decreaseDose',
      'pauseTreatment',
      'consultDoctor'
    ],
    default: 'continueCurrent'
  },
  recommendationReason: {
    type: String,
    required: [true, 'Recommendation reason is required'],
    maxlength: [500, 'Reason cannot exceed 500 characters']
  },
  bayesianFactors: {
    priorProbability: {
      type: Number,
      required: true,
      min: 0,
      max: 1
    },
    likelihood: {
      type: Number,
      required: true,
      min: 0,
      max: 1
    },
    posteriorProbability: {
      type: Number,
      required: true,
      min: 0,
      max: 1
    },
    individualFactors: {
      type: Map,
      of: Number,
      required: true
    },
    confidenceLevel: {
      type: String,
      enum: ['low', 'medium', 'high'],
      required: true
    }
  },
  notes: {
    type: String,
    maxlength: [500, 'Notes cannot exceed 500 characters']
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

// Indexes for performance
weeklyCheckupSchema.index({ userId: 1, date: -1 });
weeklyCheckupSchema.index({ userId: 1, dosageRecommendation: 1 });
weeklyCheckupSchema.index({ date: -1 });

export default mongoose.model<IWeeklyCheckup>('WeeklyCheckup', weeklyCheckupSchema);

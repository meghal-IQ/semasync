import mongoose, { Document, Schema } from 'mongoose';

export interface IWeightLog extends Document {
  userId: mongoose.Types.ObjectId;
  date: Date;
  weight: number;
  unit: 'kg' | 'lbs';
  notes?: string;
  photoUrl?: string;
  bodyFat?: number;
  muscleMass?: number;
  createdAt: Date;
  updatedAt: Date;
}

const weightLogSchema = new Schema<IWeightLog>({
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
  weight: {
    type: Number,
    required: [true, 'Weight is required'],
    min: [20, 'Weight must be at least 20'],
    max: [500, 'Weight cannot exceed 500']
  },
  unit: {
    type: String,
    required: [true, 'Unit is required'],
    enum: ['kg', 'lbs'],
    default: 'lbs'
  },
  notes: {
    type: String,
    maxlength: [500, 'Notes cannot exceed 500 characters'],
    trim: true
  },
  photoUrl: {
    type: String,
    trim: true
  },
  bodyFat: {
    type: Number,
    min: [0, 'Body fat percentage cannot be negative'],
    max: [100, 'Body fat percentage cannot exceed 100']
  },
  muscleMass: {
    type: Number,
    min: [0, 'Muscle mass cannot be negative']
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
weightLogSchema.index({ userId: 1, date: -1 });
weightLogSchema.index({ createdAt: -1 });

const WeightLog = mongoose.model<IWeightLog>('WeightLog', weightLogSchema);

export default WeightLog;

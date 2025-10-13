import mongoose, { Document, Schema } from 'mongoose';

export interface IMedicationLevelHistory extends Document {
  userId: mongoose.Types.ObjectId;
  date: Date;
  medication: string;
  dosage: string;
  calculatedLevel: number;
  percentageOfPeak: number;
  shotId?: mongoose.Types.ObjectId;
  daysSinceLastShot?: number;
  hoursSinceLastShot?: number;
  nextDueDate?: Date;
  status: 'optimal' | 'declining' | 'low' | 'overdue';
  createdAt: Date;
  updatedAt: Date;
}

const medicationLevelHistorySchema = new Schema<IMedicationLevelHistory>({
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
  medication: {
    type: String,
    required: [true, 'Medication is required'],
    enum: [
      'Zepbound®',
      'Mounjaro®',
      'Ozempic®',
      'Wegovy®',
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
  calculatedLevel: {
    type: Number,
    required: [true, 'Calculated level is required'],
    min: [0, 'Level cannot be negative'],
    max: [100, 'Level cannot exceed 100']
  },
  percentageOfPeak: {
    type: Number,
    required: [true, 'Percentage of peak is required'],
    min: [0, 'Percentage cannot be negative'],
    max: [100, 'Percentage cannot exceed 100']
  },
  shotId: {
    type: Schema.Types.ObjectId,
    ref: 'ShotLog'
  },
  daysSinceLastShot: {
    type: Number,
    min: [0, 'Days cannot be negative']
  },
  hoursSinceLastShot: {
    type: Number,
    min: [0, 'Hours cannot be negative']
  },
  nextDueDate: {
    type: Date,
    index: true
  },
  status: {
    type: String,
    required: [true, 'Status is required'],
    enum: ['optimal', 'declining', 'low', 'overdue'],
    default: 'optimal'
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
medicationLevelHistorySchema.index({ userId: 1, date: -1 });
medicationLevelHistorySchema.index({ userId: 1, status: 1 });
medicationLevelHistorySchema.index({ userId: 1, medication: 1 });

const MedicationLevelHistory = mongoose.model<IMedicationLevelHistory>('MedicationLevelHistory', medicationLevelHistorySchema);

export default MedicationLevelHistory;

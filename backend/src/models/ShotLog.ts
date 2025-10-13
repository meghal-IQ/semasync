import mongoose, { Document, Schema } from 'mongoose';

export interface IShotLog extends Document {
  userId: mongoose.Types.ObjectId;
  date: Date;
  medication: string;
  dosage: string;
  injectionSite: string;
  painLevel: number;
  sideEffects: string[];
  notes?: string;
  nextDueDate?: Date;
  photoUrl?: string;
  createdAt: Date;
  updatedAt: Date;
}

const shotLogSchema = new Schema<IShotLog>({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required'],
    index: true
  },
  date: {
    type: Date,
    required: [true, 'Shot date is required'],
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
  injectionSite: {
    type: String,
    required: [true, 'Injection site is required'],
    enum: [
      'Left Thigh',
      'Right Thigh',
      'Left Arm',
      'Right Arm',
      'Left Abdomen',
      'Right Abdomen',
      'Left Buttock',
      'Right Buttock'
    ]
  },
  painLevel: {
    type: Number,
    required: [true, 'Pain level is required'],
    min: [0, 'Pain level must be between 0 and 10'],
    max: [10, 'Pain level must be between 0 and 10'],
    default: 0
  },
  sideEffects: [{
    type: String,
    enum: [
      'None',
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
      'Other'
    ]
  }],
  notes: {
    type: String,
    maxlength: [500, 'Notes cannot exceed 500 characters'],
    trim: true
  },
  nextDueDate: {
    type: Date,
    index: true
  },
  photoUrl: {
    type: String,
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

// Indexes for efficient queries
shotLogSchema.index({ userId: 1, date: -1 });
shotLogSchema.index({ userId: 1, nextDueDate: 1 });
shotLogSchema.index({ createdAt: -1 });

// Calculate next due date before saving
shotLogSchema.pre('save', function(next) {
  if (this.isNew || this.isModified('date')) {
    // Get user's frequency from their profile (we'll populate this)
    // For now, default to 7 days (most common for GLP-1 medications)
    const daysToAdd = 7;
    const nextDate = new Date(this.date);
    nextDate.setDate(nextDate.getDate() + daysToAdd);
    this.nextDueDate = nextDate;
  }
  next();
});

const ShotLog = mongoose.model<IShotLog>('ShotLog', shotLogSchema);

export default ShotLog;

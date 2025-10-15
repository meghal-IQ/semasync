import mongoose, { Schema, Document } from 'mongoose';

export interface IShotDayTask extends Document {
  userId: mongoose.Types.ObjectId;
  date: Date;
  tasks: {
    title: string;
    time: string;
    completed: boolean;
    isMainTask?: boolean;
  }[];
  selectedDays: number[]; // 1=Monday, 2=Tuesday, etc.
  createdAt: Date;
  updatedAt: Date;
}

const shotDayTaskSchema = new Schema({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  date: {
    type: Date,
    required: true,
    index: true
  },
  tasks: [{
    title: {
      type: String,
      required: true
    },
    time: {
      type: String,
      required: true
    },
    completed: {
      type: Boolean,
      default: false
    },
    isMainTask: {
      type: Boolean,
      default: false
    }
  }],
  selectedDays: [{
    type: Number,
    min: 1,
    max: 7
  }]
}, {
  timestamps: true
});

// Compound index for efficient queries
shotDayTaskSchema.index({ userId: 1, date: 1 }, { unique: true });

export default mongoose.model<IShotDayTask>('ShotDayTask', shotDayTaskSchema);


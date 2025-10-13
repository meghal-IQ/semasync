import mongoose, { Document, Schema } from 'mongoose';

export interface IPhotoLog extends Document {
  userId: mongoose.Types.ObjectId;
  date: Date;
  photoUrls: string[];
  weight?: number;
  notes?: string;
  tags: string[]; // 'front', 'side', 'back', etc.
  visibility: 'private' | 'shared';
  createdAt: Date;
  updatedAt: Date;
}

const photoLogSchema = new Schema<IPhotoLog>({
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
  photoUrls: [{
    type: String,
    required: [true, 'At least one photo URL is required']
  }],
  weight: {
    type: Number,
    min: [20, 'Weight must be at least 20'],
    max: [500, 'Weight cannot exceed 500']
  },
  notes: {
    type: String,
    maxlength: [500, 'Notes cannot exceed 500 characters'],
    trim: true
  },
  tags: [{
    type: String,
    enum: ['front', 'side', 'back', 'face', 'full-body', 'before', 'progress', 'after', 'other']
  }],
  visibility: {
    type: String,
    enum: ['private', 'shared'],
    default: 'private'
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
photoLogSchema.index({ userId: 1, date: -1 });
photoLogSchema.index({ userId: 1, tags: 1 });

const PhotoLog = mongoose.model<IPhotoLog>('PhotoLog', photoLogSchema);

export default PhotoLog;

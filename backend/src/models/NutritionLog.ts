import mongoose, { Document, Schema } from 'mongoose';

// Meal Log
export interface IMealLog extends Document {
  userId: mongoose.Types.ObjectId;
  date: Date;
  mealType: 'breakfast' | 'lunch' | 'dinner' | 'snack';
  foods: Array<{
    name: string;
    portion: string;
    calories: number;
    protein: number;
    carbs: number;
    fat: number;
    fiber?: number;
  }>;
  totalCalories: number;
  totalProtein: number;
  totalCarbs: number;
  totalFat: number;
  totalFiber: number;
  notes?: string;
  photoUrl?: string;
  createdAt: Date;
  updatedAt: Date;
}

const mealLogSchema = new Schema<IMealLog>({
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
  mealType: {
    type: String,
    required: [true, 'Meal type is required'],
    enum: ['breakfast', 'lunch', 'dinner', 'snack']
  },
  foods: [{
    name: {
      type: String,
      required: [true, 'Food name is required']
    },
    portion: {
      type: String,
      required: [true, 'Portion is required']
    },
    calories: {
      type: Number,
      required: [true, 'Calories is required']
    },
    protein: {
      type: Number,
      required: [true, 'Protein is required']
    },
    carbs: {
      type: Number,
      required: [true, 'Carbs is required']
    },
    fat: {
      type: Number,
      required: [true, 'Fat is required']
    },
    fiber: {
      type: Number
    }
  }],
  totalCalories: {
    type: Number,
    required: [true, 'Total calories is required'],
    default: 0
  },
  totalProtein: {
    type: Number,
    required: [true, 'Total protein is required'],
    default: 0
  },
  totalCarbs: {
    type: Number,
    required: [true, 'Total carbs is required'],
    default: 0
  },
  totalFat: {
    type: Number,
    required: [true, 'Total fat is required'],
    default: 0
  },
  totalFiber: {
    type: Number,
    default: 0
  },
  notes: {
    type: String,
    maxlength: [500, 'Notes cannot exceed 500 characters'],
    trim: true
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

// Calculate totals before saving
mealLogSchema.pre('save', function(next) {
  if (this.foods && this.foods.length > 0) {
    this.totalCalories = this.foods.reduce((sum, food) => sum + food.calories, 0);
    this.totalProtein = this.foods.reduce((sum, food) => sum + food.protein, 0);
    this.totalCarbs = this.foods.reduce((sum, food) => sum + food.carbs, 0);
    this.totalFat = this.foods.reduce((sum, food) => sum + food.fat, 0);
    this.totalFiber = this.foods.reduce((sum, food) => sum + (food.fiber || 0), 0);
  }
  next();
});

mealLogSchema.index({ userId: 1, date: -1 });

// Water Log
export interface IWaterLog extends Document {
  userId: mongoose.Types.ObjectId;
  date: Date;
  amount: number; // in ml
  goal: number; // in ml
  entries: Array<{
    time: string;
    amount: number;
    type: string; // 'Glass', 'Bottle', 'Liter', etc.
  }>;
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

const waterLogSchema = new Schema<IWaterLog>({
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
  amount: {
    type: Number,
    required: [true, 'Amount is required'],
    default: 0
  },
  goal: {
    type: Number,
    default: 2500, // 2.5 liters default
    min: [0, 'Goal cannot be negative']
  },
  entries: [{
    time: {
      type: String,
      required: [true, 'Time is required']
    },
    amount: {
      type: Number,
      required: [true, 'Amount is required']
    },
    type: {
      type: String,
      enum: ['Glass', 'Bottle', 'Liter', 'Large Bottle', 'Cup', 'Other', 'Removal'],
      default: 'Glass'
    }
  }],
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

// Calculate total amount before saving
waterLogSchema.pre('save', function(next) {
  if (this.entries && this.entries.length > 0) {
    this.amount = this.entries.reduce((sum, entry) => sum + entry.amount, 0);
  }
  next();
});

waterLogSchema.index({ userId: 1, date: -1 });

export const MealLog = mongoose.model<IMealLog>('MealLog', mealLogSchema);
export const WaterLog = mongoose.model<IWaterLog>('WaterLog', waterLogSchema);

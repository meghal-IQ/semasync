import mongoose, { Document, Schema } from 'mongoose';
import bcrypt from 'bcryptjs';

export interface IUser extends Document {
  email: string;
  password: string;
  username?: string;
  phoneNumber?: string;
  
  // Account Status
  isEmailVerified: boolean;
  isPhoneVerified: boolean;
  accountStatus: 'active' | 'suspended' | 'deleted';
  lastLogin?: Date;
  failedLoginAttempts: number;
  
  // Profile Information
  firstName: string;
  lastName: string;
  dateOfBirth: Date;
  gender: 'male' | 'female' | 'other';
  
  // Physical Measurements
  height: number;
  weight: number;
  preferredUnits: {
    weight: 'kg' | 'lbs';
    height: 'cm' | 'ft';
    distance: 'km' | 'miles';
  };
  
  // GLP-1 Journey Information
  glp1Journey: {
    medication: string;
    startingDose: string;
    frequency: string;
    injectionDays?: string[];
    startDate?: Date;
    currentDose?: string;
    isActive: boolean;
  };
  
  // Motivation and Goals
  motivation: string;
  
  // Concerns and Side Effects
  concerns: string[];
  
  // Health Goals
  goals: {
    targetWeight?: number;
    targetDate?: Date;
    primaryGoal: string;
    secondaryGoals?: string[];
  };
  
  // Security
  refreshToken?: string;
  passwordResetToken?: string;
  passwordResetExpires?: Date;
  twoFactorEnabled: boolean;
  twoFactorSecret?: string;
  
  // Methods
  comparePassword(candidatePassword: string): Promise<boolean>;
  generatePasswordResetToken(): string;
}

const userSchema = new Schema<IUser>({
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please enter a valid email']
  },
  password: {
    type: String,
    required: [true, 'Password is required'],
    minlength: [6, 'Password must be at least 6 characters'],
    select: false
  },
  username: {
    type: String,
    unique: true,
    sparse: true,
    trim: true,
    minlength: [3, 'Username must be at least 3 characters']
  },
  phoneNumber: {
    type: String,
    trim: true,
    match: [/^\+?[\d\s\-\(\)]+$/, 'Please enter a valid phone number']
  },
  
  // Account Status
  isEmailVerified: {
    type: Boolean,
    default: false
  },
  isPhoneVerified: {
    type: Boolean,
    default: false
  },
  accountStatus: {
    type: String,
    enum: ['active', 'suspended', 'deleted'],
    default: 'active'
  },
  lastLogin: {
    type: Date
  },
  failedLoginAttempts: {
    type: Number,
    default: 0
  },
  
  // Profile Information
  firstName: {
    type: String,
    required: [true, 'First name is required'],
    trim: true,
    maxlength: [50, 'First name cannot exceed 50 characters']
  },
  lastName: {
    type: String,
    required: [true, 'Last name is required'],
    trim: true,
    maxlength: [50, 'Last name cannot exceed 50 characters']
  },
  dateOfBirth: {
    type: Date,
    required: [true, 'Date of birth is required']
  },
  gender: {
    type: String,
    enum: ['male', 'female', 'other'],
    required: [true, 'Gender is required']
  },
  
  // Physical Measurements
  height: {
    type: Number,
    required: [true, 'Height is required'],
    min: [50, 'Height must be at least 50cm'],
    max: [300, 'Height cannot exceed 300cm']
  },
  weight: {
    type: Number,
    required: [true, 'Weight is required'],
    min: [20, 'Weight must be at least 20kg'],
    max: [500, 'Weight cannot exceed 500kg']
  },
  preferredUnits: {
    weight: {
      type: String,
      enum: ['kg', 'lbs'],
      default: 'lbs'
    },
    height: {
      type: String,
      enum: ['cm', 'ft'],
      default: 'ft'
    },
    distance: {
      type: String,
      enum: ['km', 'miles'],
      default: 'miles'
    }
  },
  
  // GLP-1 Journey Information
  glp1Journey: {
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
    startingDose: {
      type: String,
      required: [true, 'Starting dose is required'],
      enum: ['0.25mg', '0.5mg', '1.0mg', '1.7mg', '2.4mg']
    },
    frequency: {
      type: String,
      required: [true, 'Frequency is required'],
      enum: [
        'Every day',
        'Every 7 days (most common)',
        'Every 14 days',
        'Custom',
        'Not sure, still figuring it out'
      ]
    },
    injectionDays: [{
      type: String,
      enum: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    }],
    startDate: {
      type: Date
    },
    currentDose: {
      type: String
    },
    isActive: {
      type: Boolean,
      default: true
    }
  },
  
  // Motivation and Goals
  motivation: {
    type: String,
    required: [true, 'Motivation is required'],
    enum: [
      'I want to feel more confident in my own skin.',
      'I\'m just ready for a fresh start.',
      'I want to boost my energy and strength.',
      'To improve my health and manage PCOS.',
      'I want to show up for the people I love.',
      'I have a special event or milestone coming up.',
      'To feel good wearing the clothes I love again.'
    ]
  },
  
  // Concerns and Side Effects
  concerns: [{
    type: String,
    enum: [
      'Nausea',
      'Fatigue', 
      'Hair Loss',
      'Muscle Loss',
      'Injection Anxiety',
      'Loose Skin'
    ]
  }],
  
  // Health Goals
  goals: {
    targetWeight: {
      type: Number,
      min: [20, 'Target weight must be at least 20kg'],
      max: [500, 'Target weight cannot exceed 500kg']
    },
    targetDate: {
      type: Date
    },
    primaryGoal: {
      type: String,
      default: 'Weight loss'
    },
    secondaryGoals: [{
      type: String,
      enum: [
        'Improved energy',
        'Better sleep',
        'Increased strength',
        'Reduced inflammation',
        'Better mood',
        'Improved confidence'
      ]
    }]
  },
  
  // Security
  refreshToken: {
    type: String,
    select: false
  },
  passwordResetToken: {
    type: String,
    select: false
  },
  passwordResetExpires: {
    type: Date,
    select: false
  },
  twoFactorEnabled: {
    type: Boolean,
    default: false
  },
  twoFactorSecret: {
    type: String,
    select: false
  }
}, {
  timestamps: true,
  toJSON: {
    transform: function(doc, ret) {
      delete ret.password;
      delete ret.refreshToken;
      delete ret.passwordResetToken;
      delete ret.passwordResetExpires;
      delete ret.twoFactorSecret;
      return ret;
    }
  }
});

// Index for performance
userSchema.index({ email: 1 });
userSchema.index({ username: 1 });
userSchema.index({ createdAt: -1 });

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(12);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error: any) {
    next(error);
  }
});

// Compare password method
userSchema.methods.comparePassword = async function(candidatePassword: string): Promise<boolean> {
  return bcrypt.compare(candidatePassword, this.password);
};

// Generate password reset token
userSchema.methods.generatePasswordResetToken = function(): string {
  const crypto = require('crypto');
  const resetToken = crypto.randomBytes(32).toString('hex');
  
  this.passwordResetToken = crypto
    .createHash('sha256')
    .update(resetToken)
    .digest('hex');
  
  this.passwordResetExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes
  
  return resetToken;
};

export default mongoose.model<IUser>('User', userSchema);

import User from '../../src/models/User';
import { generateTokens } from '../../src/utils/auth';

export const createTestUser = async (overrides: any = {}) => {
  const defaultUserData = {
    email: 'test@example.com',
    password: 'password123',
    firstName: 'John',
    lastName: 'Doe',
    dateOfBirth: new Date('1990-01-01'),
    gender: 'male' as const,
    height: 175,
    weight: 70,
    preferredUnits: {
      weight: 'kg' as const,
      height: 'cm' as const,
      distance: 'km' as const
    },
    glp1Journey: {
      medication: 'Ozempic®',
      startingDose: '0.25mg',
      frequency: 'Every 7 days (most common)',
      injectionDays: ['Monday'],
      startDate: new Date('2024-01-15'),
      isActive: true
    },
    motivation: 'I want to feel more confident in my own skin.',
    concerns: ['Nausea', 'Fatigue'],
    goals: {
      targetWeight: 60,
      targetDate: new Date('2024-12-31'),
      primaryGoal: 'Weight loss',
      secondaryGoals: ['Improved energy']
    }
  };

  const userData = { ...defaultUserData, ...overrides };
  const user = new User(userData);
  await user.save();
  return user;
};

export const createTestTokens = (user: any) => {
  return generateTokens(user);
};

export const validUserData = {
  email: 'test@example.com',
  password: 'password123',
  firstName: 'John',
  lastName: 'Doe',
  dateOfBirth: '1990-01-01',
  gender: 'male',
  height: 175,
  weight: 70,
  preferredUnits: {
    weight: 'kg',
    height: 'cm',
    distance: 'km'
  },
  glp1Journey: {
    medication: 'Ozempic®',
    startingDose: '0.25mg',
    frequency: 'Every 7 days (most common)',
    injectionDays: ['Monday'],
    startDate: '2024-01-15'
  },
  motivation: 'I want to feel more confident in my own skin.',
  concerns: ['Nausea', 'Fatigue'],
  goals: {
    targetWeight: 60,
    targetDate: '2024-12-31',
    primaryGoal: 'Weight loss',
    secondaryGoals: ['Improved energy']
  }
};

export const invalidUserData = {
  email: 'invalid-email',
  password: '123',
  firstName: '',
  lastName: '',
  dateOfBirth: 'invalid-date',
  gender: 'invalid',
  height: 10,
  weight: 5,
  glp1Journey: {
    medication: 'Invalid Medication',
    startingDose: 'Invalid Dose',
    frequency: 'Invalid Frequency'
  },
  motivation: 'Invalid motivation',
  concerns: ['Invalid Concern']
};

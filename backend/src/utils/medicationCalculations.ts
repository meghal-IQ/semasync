/**
 * Medication Level Calculations
 * 
 * This module calculates medication levels in the bloodstream based on
 * pharmacokinetic principles (half-life, absorption, elimination)
 */

export interface MedicationLevel {
  currentLevel: number;
  percentageOfPeak: number;
  daysUntilNextDose: number;
  hoursUntilNextDose: number;
  isOverdue: boolean;
  status: 'optimal' | 'declining' | 'low' | 'overdue';
}

/**
 * Half-life data for common GLP-1 medications (in hours)
 */
const MEDICATION_HALF_LIVES: { [key: string]: number } = {
  'Ozempic®': 168, // ~7 days (Semaglutide)
  'Wegovy®': 168, // ~7 days (Semaglutide)
  'Compounded Semaglutide': 168, // ~7 days
  'Mounjaro®': 120, // ~5 days (Tirzepatide)
  'Zepbound®': 120, // ~5 days (Tirzepatide)
  'Compounded Tirzepatide': 120, // ~5 days
  'Trulicity®': 120, // ~5 days (Dulaglutide)
};

/**
 * Calculate current medication level based on time since last dose
 */
export function calculateMedicationLevel(
  medication: string,
  dosage: string,
  lastShotDate: Date,
  nextDueDate: Date
): MedicationLevel {
  const now = new Date();
  const halfLife = MEDICATION_HALF_LIVES[medication] || 168; // Default to 7 days
  
  // Calculate hours since last shot
  const hoursSinceShot = (now.getTime() - lastShotDate.getTime()) / (1000 * 60 * 60);
  
  // Calculate hours until next dose
  const hoursUntilNext = (nextDueDate.getTime() - now.getTime()) / (1000 * 60 * 60);
  const daysUntilNext = hoursUntilNext / 24;
  
  // Calculate current level using exponential decay formula
  // Level = 100 * (0.5)^(time/halfLife)
  const currentLevel = 100 * Math.pow(0.5, hoursSinceShot / halfLife);
  
  // Determine status
  let status: 'optimal' | 'declining' | 'low' | 'overdue';
  const isOverdue = hoursUntilNext < 0;
  
  if (isOverdue) {
    status = 'overdue';
  } else if (currentLevel >= 60) {
    status = 'optimal';
  } else if (currentLevel >= 30) {
    status = 'declining';
  } else {
    status = 'low';
  }
  
  return {
    currentLevel: Math.max(0, Math.min(100, currentLevel)),
    percentageOfPeak: Math.max(0, Math.min(100, currentLevel)),
    daysUntilNextDose: Math.max(0, daysUntilNext),
    hoursUntilNextDose: Math.max(0, hoursUntilNext),
    isOverdue,
    status
  };
}

/**
 * Calculate next shot due date based on frequency
 */
export function calculateNextDueDate(lastShotDate: Date, frequency: string): Date {
  const nextDate = new Date(lastShotDate);
  
  switch (frequency) {
    case 'Every day':
      nextDate.setDate(nextDate.getDate() + 1);
      break;
    case 'Every 7 days (most common)':
      nextDate.setDate(nextDate.getDate() + 7);
      break;
    case 'Every 14 days':
      nextDate.setDate(nextDate.getDate() + 14);
      break;
    case 'Custom':
    case 'Not sure, still figuring it out':
    default:
      // Default to 7 days
      nextDate.setDate(nextDate.getDate() + 7);
      break;
  }
  
  return nextDate;
}

/**
 * Format countdown timer for next dose
 */
export function formatCountdown(hoursUntilNext: number): string {
  if (hoursUntilNext < 0) {
    const hoursOverdue = Math.abs(hoursUntilNext);
    const daysOverdue = Math.floor(hoursOverdue / 24);
    const remainingHours = Math.floor(hoursOverdue % 24);
    return `Overdue by ${daysOverdue}d ${remainingHours}h`;
  }
  
  const days = Math.floor(hoursUntilNext / 24);
  const hours = Math.floor(hoursUntilNext % 24);
  
  return `${days}d ${hours}h`;
}

/**
 * Determine if it's time for a reminder (24 hours before due)
 */
export function shouldSendReminder(nextDueDate: Date): boolean {
  const now = new Date();
  const hoursUntilDue = (nextDueDate.getTime() - now.getTime()) / (1000 * 60 * 60);
  
  // Send reminder when 24 hours away
  return hoursUntilDue <= 24 && hoursUntilDue > 0;
}

/**
 * Calculate adherence percentage
 */
export function calculateAdherence(
  totalExpectedShots: number,
  totalActualShots: number
): number {
  if (totalExpectedShots === 0) return 100;
  return Math.min(100, (totalActualShots / totalExpectedShots) * 100);
}

/**
 * Get injection site recommendation (rotate sites)
 */
export function getRecommendedInjectionSite(lastSites: string[]): string[] {
  const allSites = [
    'Left Thigh',
    'Right Thigh',
    'Left Abdomen',
    'Right Abdomen',
    'Left Arm',
    'Right Arm'
  ];
  
  // Filter out recently used sites (last 2-3 injections)
  const recentSites = lastSites.slice(0, 3);
  const availableSites = allSites.filter(site => !recentSites.includes(site));
  
  return availableSites.length > 0 ? availableSites : allSites;
}

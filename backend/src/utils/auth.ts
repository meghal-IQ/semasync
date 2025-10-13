import jwt from 'jsonwebtoken';
import { IUser } from '../models/User';

export interface TokenPayload {
  userId: string;
  email: string;
  iat?: number;
  exp?: number;
}

export const generateTokens = (user: IUser) => {
  const payload: TokenPayload = {
    userId: user._id.toString(),
    email: user.email
  };

  const jwtSecret = process.env.JWT_SECRET || 'fallback-secret-key';
  const jwtRefreshSecret = process.env.JWT_REFRESH_SECRET || 'fallback-refresh-secret-key';

  const accessToken = jwt.sign(payload, jwtSecret, { expiresIn: '24h' });
  const refreshToken = jwt.sign(payload, jwtRefreshSecret, { expiresIn: '7d' });

  return { accessToken, refreshToken };
};

export const verifyAccessToken = (token: string): TokenPayload => {
  const jwtSecret = process.env.JWT_SECRET || 'fallback-secret-key';
  return jwt.verify(token, jwtSecret) as TokenPayload;
};

export const verifyRefreshToken = (token: string): TokenPayload => {
  const jwtRefreshSecret = process.env.JWT_REFRESH_SECRET || 'fallback-refresh-secret-key';
  return jwt.verify(token, jwtRefreshSecret) as TokenPayload;
};

export const generateEmailVerificationToken = (userId: string): string => {
  const jwtSecret = process.env.JWT_SECRET || 'fallback-secret-key';
  return jwt.sign(
    { userId, type: 'email_verification' },
    jwtSecret,
    { expiresIn: '24h' }
  );
};

export const verifyEmailToken = (token: string): { userId: string; type: string } => {
  const jwtSecret = process.env.JWT_SECRET || 'fallback-secret-key';
  return jwt.verify(token, jwtSecret) as { userId: string; type: string };
};

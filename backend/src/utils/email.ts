import nodemailer from 'nodemailer';

interface EmailOptions {
  to: string;
  subject: string;
  html: string;
  text?: string;
}

// Create transporter
const createTransporter = () => {
  return nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: parseInt(process.env.EMAIL_PORT || '587'),
    secure: process.env.EMAIL_PORT === '465', // true for 465, false for other ports
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS
    }
  });
};

export const sendEmail = async (options: EmailOptions): Promise<void> => {
  try {
    const transporter = createTransporter();
    
    const mailOptions = {
      from: `"SemaSync App" <${process.env.EMAIL_USER}>`,
      to: options.to,
      subject: options.subject,
      html: options.html,
      text: options.text
    };

    await transporter.sendMail(mailOptions);
    console.log('Email sent successfully to:', options.to);
  } catch (error) {
    console.error('Email sending failed:', error);
    throw new Error('Failed to send email');
  }
};

export const sendWelcomeEmail = async (email: string, firstName: string): Promise<void> => {
  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
      <h1 style="color: #333;">Welcome to SemaSync, ${firstName}!</h1>
      <p>Thank you for joining SemaSync. We're excited to help you track your health journey.</p>
      <p>Here's what you can do with SemaSync:</p>
      <ul>
        <li>Track your daily activities and workouts</li>
        <li>Log your meals and nutrition</li>
        <li>Monitor your weight and body metrics</li>
        <li>Manage your medical treatments</li>
        <li>Get insights into your health patterns</li>
      </ul>
      <p>If you have any questions, feel free to reach out to our support team.</p>
      <p>Best regards,<br>The SemaSync Team</p>
    </div>
  `;

  await sendEmail({
    to: email,
    subject: 'Welcome to SemaSync!',
    html
  });
};

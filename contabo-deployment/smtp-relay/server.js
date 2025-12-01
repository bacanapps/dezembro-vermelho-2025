/**
 * SMTP Relay Server for Dezembro Vermelho 2025
 *
 * Receives HTTP POST requests from n8n and forwards emails
 * via government internal SMTP server (10.101.40.1:25)
 *
 * Connection flow:
 * n8n.bebot.co → This relay → VPN tunnel → 10.101.40.1:25 → Email sent
 */

const express = require('express');
const bodyParser = require('body-parser');
const nodemailer = require('nodemailer');
const winston = require('winston');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const app = express();

// Configuration (can be moved to .env file later)
const CONFIG = {
  PORT: process.env.PORT || 3000,
  SMTP_HOST: process.env.SMTP_HOST || '10.101.40.1',
  SMTP_PORT: process.env.SMTP_PORT || 25,
  SMTP_SECURE: process.env.SMTP_SECURE === 'true' || false,
  SMTP_USER: process.env.SMTP_USER || 'producao@aids.gov.br',
  SMTP_PASS: process.env.SMTP_PASS || '', // Set via environment variable
  SMTP_REQUIRE_AUTH: process.env.SMTP_REQUIRE_AUTH === 'true' || false,
  API_KEY: process.env.API_KEY || 'CHANGE_THIS_API_KEY', // Security
  DEFAULT_FROM: 'Dezembro Vermelho 2025 <producao@aids.gov.br>'
};

// Logger setup
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: '/var/log/smtp-relay/error.log', level: 'error' }),
    new winston.transports.File({ filename: '/var/log/smtp-relay/combined.log' }),
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    })
  ]
});

// Security middleware
app.use(helmet());
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ extended: true, limit: '10mb' }));

// Rate limiting (max 100 requests per 15 minutes per IP)
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: { success: false, error: 'Too many requests, please try again later' }
});
app.use('/send-email', limiter);

// API Key authentication middleware
const authenticate = (req, res, next) => {
  const apiKey = req.headers['x-api-key'] || req.query.api_key;

  if (!apiKey || apiKey !== CONFIG.API_KEY) {
    logger.warn('Unauthorized access attempt', { ip: req.ip });
    return res.status(401).json({
      success: false,
      error: 'Unauthorized - Invalid API key'
    });
  }

  next();
};

// SMTP transporter configuration
const createTransporter = () => {
  const transportConfig = {
    host: CONFIG.SMTP_HOST,
    port: CONFIG.SMTP_PORT,
    secure: CONFIG.SMTP_SECURE,
    tls: {
      rejectUnauthorized: false
    }
  };

  // Add authentication if required
  if (CONFIG.SMTP_REQUIRE_AUTH && CONFIG.SMTP_PASS) {
    transportConfig.auth = {
      user: CONFIG.SMTP_USER,
      pass: CONFIG.SMTP_PASS
    };
  }

  logger.info('SMTP Transporter configured', {
    host: CONFIG.SMTP_HOST,
    port: CONFIG.SMTP_PORT,
    secure: CONFIG.SMTP_SECURE,
    auth: CONFIG.SMTP_REQUIRE_AUTH
  });

  return nodemailer.createTransporter(transportConfig);
};

const transporter = createTransporter();

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'SMTP Relay - Dezembro Vermelho 2025',
    smtp: {
      host: CONFIG.SMTP_HOST,
      port: CONFIG.SMTP_PORT
    },
    timestamp: new Date().toISOString()
  });
});

// Verify SMTP connection endpoint
app.get('/verify-smtp', authenticate, async (req, res) => {
  try {
    await transporter.verify();
    logger.info('SMTP connection verified successfully');
    res.json({
      success: true,
      message: 'SMTP server is ready to send emails',
      smtp: `${CONFIG.SMTP_HOST}:${CONFIG.SMTP_PORT}`
    });
  } catch (error) {
    logger.error('SMTP verification failed', { error: error.message });
    res.status(500).json({
      success: false,
      error: 'SMTP server connection failed',
      details: error.message
    });
  }
});

// Send email endpoint
app.post('/send-email', authenticate, async (req, res) => {
  try {
    const { to, subject, html, text, from } = req.body;

    // Validation
    if (!to || !subject || (!html && !text)) {
      logger.warn('Invalid email request - missing required fields', { to, subject });
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: to, subject, and html or text'
      });
    }

    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(to)) {
      logger.warn('Invalid email address', { to });
      return res.status(400).json({
        success: false,
        error: 'Invalid email address'
      });
    }

    // Prepare email options
    const mailOptions = {
      from: from || CONFIG.DEFAULT_FROM,
      to: to,
      subject: subject,
      html: html,
      text: text
    };

    logger.info('Sending email', {
      to,
      subject,
      from: mailOptions.from
    });

    // Send email
    const info = await transporter.sendMail(mailOptions);

    logger.info('Email sent successfully', {
      messageId: info.messageId,
      to,
      response: info.response
    });

    res.json({
      success: true,
      messageId: info.messageId,
      to,
      subject,
      response: info.response
    });

  } catch (error) {
    logger.error('Email send error', {
      error: error.message,
      stack: error.stack,
      to: req.body.to
    });

    res.status(500).json({
      success: false,
      error: 'Failed to send email',
      details: error.message
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  logger.error('Unhandled error', { error: err.message, stack: err.stack });
  res.status(500).json({
    success: false,
    error: 'Internal server error'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found'
  });
});

// Start server
const PORT = CONFIG.PORT;
app.listen(PORT, '0.0.0.0', () => {
  logger.info(`SMTP Relay Server started on port ${PORT}`);
  logger.info(`SMTP Backend: ${CONFIG.SMTP_HOST}:${CONFIG.SMTP_PORT}`);
  logger.info(`API Key Authentication: ${CONFIG.API_KEY !== 'CHANGE_THIS_API_KEY' ? 'Enabled' : 'WARNING - Using default API key!'}`);

  if (CONFIG.API_KEY === 'CHANGE_THIS_API_KEY') {
    logger.warn('⚠️  SECURITY WARNING: Change the API_KEY in environment variables!');
  }
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  process.exit(0);
});

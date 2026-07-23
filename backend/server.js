/**
 * K2 DENT BACKEND - Production Server
 * Proxy sécurisé pour API Anthropic + Services Supabase
 *
 * @author Ismail Sialyen
 * @date July 2026
 * @version 1.0.0
 */

import Fastify from 'fastify';
import cors from '@fastify/cors';
import { config } from 'dotenv';
import Anthropic from '@anthropic-ai/sdk';
import { createClient } from '@supabase/supabase-js';
import authRoutes from './routes/auth-routes.js';

// Load environment variables
config();

// Initialize Fastify
const fastify = Fastify({
  logger: {
    level: process.env.LOG_LEVEL || 'info'
  }
});

// Initialize Anthropic client
const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY
});

// Initialize Supabase client
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

// ============================================================================
// MIDDLEWARE
// ============================================================================

// CORS Configuration
await fastify.register(cors, {
  origin: process.env.CORS_ORIGINS?.split(',') || [
    'https://ismaikami.github.io',
    'http://localhost:3000'
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS']
});

// Rate Limiting (simple implementation)
const requestCounts = new Map();
const RATE_LIMIT_WINDOW = parseInt(process.env.RATE_LIMIT_WINDOW) || 900000; // 15min
const RATE_LIMIT_MAX = parseInt(process.env.RATE_LIMIT_MAX) || 100;

fastify.addHook('onRequest', async (request, reply) => {
  const ip = request.ip;
  const now = Date.now();

  if (!requestCounts.has(ip)) {
    requestCounts.set(ip, { count: 1, resetTime: now + RATE_LIMIT_WINDOW });
  } else {
    const record = requestCounts.get(ip);

    if (now > record.resetTime) {
      record.count = 1;
      record.resetTime = now + RATE_LIMIT_WINDOW;
    } else {
      record.count++;

      if (record.count > RATE_LIMIT_MAX) {
        reply.code(429).send({
          error: 'Too Many Requests',
          message: 'Rate limit exceeded. Please try again later.',
          retryAfter: Math.ceil((record.resetTime - now) / 1000)
        });
      }
    }
  }
});

// Request logging
fastify.addHook('onRequest', async (request, reply) => {
  fastify.log.info({
    method: request.method,
    url: request.url,
    ip: request.ip,
    userAgent: request.headers['user-agent']
  });
});

// ============================================================================
// ROUTES
// ============================================================================

// Register auth routes
await fastify.register(authRoutes, { prefix: '/api/auth' });

// Health Check
fastify.get('/health', async (request, reply) => {
  return {
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV
  };
});

// Root endpoint
fastify.get('/', async (request, reply) => {
  return {
    name: 'K2 Dent Backend API',
    version: '1.0.0',
    author: 'Dr. Ismail Sialyen',
    endpoints: {
      health: '/health',
      ai: {
        anamnesis: 'POST /api/ai/anamnesis',
        prescription: 'POST /api/ai/prescription'
      }
    }
  };
});

// ============================================================================
// AI ENDPOINTS
// ============================================================================

/**
 * Generate AI-powered anamnesis
 * POST /api/ai/anamnesis
 */
fastify.post('/api/ai/anamnesis', async (request, reply) => {
  try {
    const { patientData, transcription, systemPrompt, maxTokens = 1500 } = request.body;

    if (!patientData) {
      return reply.code(400).send({
        error: 'Bad Request',
        message: 'Patient data is required'
      });
    }

    // Build prompt
    const userPrompt = `**DONNÉES PATIENT:**
Nom: ${patientData.name || 'Non renseigné'}
Âge: ${patientData.age || 'Non renseigné'} ans
NISS: ${patientData.niss || 'Non renseigné'}
Mutuelle: ${patientData.mutuelle || 'Non renseignée'}
Allergies: ${patientData.allergies || 'Aucune allergie connue'}
Médications: ${patientData.medications || 'Aucune médication'}

**TRANSCRIPTION CONSULTATION:**
${transcription || 'Pas de transcription disponible'}

**INSTRUCTION:**
Génère l'anamnèse complète en suivant le format imposé.`;

    // Call Anthropic API
    const response = await anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: maxTokens,
      temperature: 0.3,
      system: systemPrompt || 'Tu es un assistant médical spécialisé en anamnèse dentaire.',
      messages: [{
        role: 'user',
        content: userPrompt
      }]
    });

    // Log usage
    fastify.log.info({
      endpoint: 'anamnesis',
      tokens: response.usage,
      patient: patientData.name
    });

    return {
      success: true,
      content: response.content[0].text,
      usage: response.usage,
      model: response.model
    };

  } catch (error) {
    fastify.log.error('Error generating anamnesis:', error);

    return reply.code(500).send({
      error: 'Internal Server Error',
      message: error.message || 'Failed to generate anamnesis'
    });
  }
});

/**
 * Generate AI-powered prescription suggestions
 * POST /api/ai/prescription
 */
fastify.post('/api/ai/prescription', async (request, reply) => {
  try {
    const { diagnosis, symptoms, patientData, maxTokens = 1200 } = request.body;

    if (!diagnosis && !symptoms) {
      return reply.code(400).send({
        error: 'Bad Request',
        message: 'Diagnosis or symptoms required'
      });
    }

    const userPrompt = `**DIAGNOSTIC:** ${diagnosis || 'Non spécifié'}
**SYMPTÔMES:** ${symptoms || 'Non spécifiés'}
**PATIENT:** ${patientData?.name || 'Anonyme'} (${patientData?.age || 'N/A'} ans)
**ALLERGIES:** ${patientData?.allergies || 'Aucune'}

Suggère une prescription dentaire appropriée.`;

    const response = await anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: maxTokens,
      temperature: 0.3,
      system: 'Tu es un dentiste expert qui suggère des prescriptions médicamenteuses.',
      messages: [{
        role: 'user',
        content: userPrompt
      }]
    });

    fastify.log.info({
      endpoint: 'prescription',
      tokens: response.usage
    });

    return {
      success: true,
      content: response.content[0].text,
      usage: response.usage,
      model: response.model
    };

  } catch (error) {
    fastify.log.error('Error generating prescription:', error);

    return reply.code(500).send({
      error: 'Internal Server Error',
      message: error.message || 'Failed to generate prescription'
    });
  }
});

// ============================================================================
// ERROR HANDLING
// ============================================================================

fastify.setErrorHandler((error, request, reply) => {
  fastify.log.error(error);

  reply.code(error.statusCode || 500).send({
    error: error.name || 'Internal Server Error',
    message: error.message || 'An unexpected error occurred',
    timestamp: new Date().toISOString()
  });
});

// ============================================================================
// START SERVER
// ============================================================================

const start = async () => {
  try {
    const port = parseInt(process.env.PORT) || 3000;
    const host = process.env.SERVER_HOST || '0.0.0.0';

    await fastify.listen({ port, host });

    console.log('');
    console.log('🚀 K2 Dent Backend Server Started');
    console.log('=====================================');
    console.log(`📍 URL: http://${host}:${port}`);
    console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`✅ Health Check: http://${host}:${port}/health`);
    console.log('=====================================');
    console.log('');

  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down gracefully...');
  await fastify.close();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('SIGINT received, shutting down gracefully...');
  await fastify.close();
  process.exit(0);
});

start();

/**
 * K2 DENT - FRONTEND CONFIGURATION
 *
 * Ce fichier centralise toutes les URLs et configurations
 * pour faciliter le basculement dev/prod
 */

// Environnement (à changer manuellement)
const ENV = 'production'; // 'development' ou 'production'

// Configuration par environnement
const CONFIG = {
  development: {
    BACKEND_URL: 'http://localhost:3000',
    SUPABASE_URL: 'https://sqgxscrwcffjfomlsoyf.supabase.co',
    SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNxZ3hzY3J3Y2ZmamZvbWxzb3lmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ2NTE2NjMsImV4cCI6MjEwMDIyNzY2M30.TtLYJKBM7XxrdsHiHS9EGOxnyniSdAhBLPUkhpReidU',
    FRONTEND_URL: 'http://localhost:8000'
  },
  production: {
    BACKEND_URL: 'https://k2-dent-production-production.up.railway.app',
    SUPABASE_URL: 'https://sqgxscrwcffjfomlsoyf.supabase.co',
    SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNxZ3hzY3J3Y2ZmamZvbWxzb3lmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ2NTE2NjMsImV4cCI6MjEwMDIyNzY2M30.TtLYJKBM7XxrdsHiHS9EGOxnyniSdAhBLPUkhpReidU',
    FRONTEND_URL: 'https://ismaikami.github.io/K2-Dent-Production'
  }
};

// Export configuration active
const ACTIVE_CONFIG = CONFIG[ENV];

// API Endpoints
const API = {
  ANAMNESIS: `${ACTIVE_CONFIG.BACKEND_URL}/api/ai/anamnesis`,
  PRESCRIPTION: `${ACTIVE_CONFIG.BACKEND_URL}/api/ai/prescription`,
  HEALTH: `${ACTIVE_CONFIG.BACKEND_URL}/health`
};

// Log configuration (dev only)
if (ENV === 'development') {
  console.log('🔧 K2 Dent Configuration:', {
    env: ENV,
    backend: ACTIVE_CONFIG.BACKEND_URL,
    frontend: ACTIVE_CONFIG.FRONTEND_URL
  });
}

// Export pour utilisation dans autres fichiers
window.K2_CONFIG = ACTIVE_CONFIG;
window.K2_API = API;
window.K2_ENV = ENV;

console.log('✅ K2 Dent Config loaded - Environment:', ENV);

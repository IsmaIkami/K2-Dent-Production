/**
 * K2 DENT - FRONTEND CONFIGURATION
 *
 * Ce fichier centralise toutes les URLs et configurations
 * pour faciliter le basculement dev/prod
 */

// Environnement (à changer manuellement)
const ENV = 'development'; // 'development' ou 'production'

// Configuration par environnement
const CONFIG = {
  development: {
    BACKEND_URL: 'http://localhost:3000',
    SUPABASE_URL: 'https://xxxxx.supabase.co', // À remplir
    SUPABASE_ANON_KEY: 'eyJhbGci...', // À remplir
    FRONTEND_URL: 'http://localhost:8000'
  },
  production: {
    BACKEND_URL: 'https://k2dent-backend-production.up.railway.app', // À remplir avec votre URL Railway
    SUPABASE_URL: 'https://xxxxx.supabase.co', // À remplir
    SUPABASE_ANON_KEY: 'eyJhbGci...', // À remplir
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

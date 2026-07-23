/**
 * K2 DENT - FRONTEND CONFIGURATION
 *
 * Ce fichier centralise toutes les URLs et configurations
 * pour faciliter le basculement dev/prod
 */

// Vérifier si déjà chargé pour éviter les duplications
if (typeof window.K2_CONFIG_LOADED === 'undefined') {
    window.K2_CONFIG_LOADED = true;

    // Environnement (à changer manuellement)
    window.ENV = 'production'; // 'development' ou 'production'

    // Configuration par environnement
    window.CONFIG = {
      development: {
        BACKEND_URL: 'http://localhost:3000',
        SUPABASE_URL: 'https://zkjhemeysleurnvqsclq.supabase.co',
        SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpramhlbWV5c2xldXJudnFzY2xxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ3OTIxMjQsImV4cCI6MjEwMDM2ODEyNH0.kMb6uDXowRrsuyQC252d1DKYkEuKNOI7aGeEz90-ick',
        FRONTEND_URL: 'http://localhost:8000'
      },
      production: {
        BACKEND_URL: 'https://k2-dent-production-production.up.railway.app',
        SUPABASE_URL: 'https://zkjhemeysleurnvqsclq.supabase.co',
        SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpramhlbWV5c2xldXJudnFzY2xxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ3OTIxMjQsImV4cCI6MjEwMDM2ODEyNH0.kMb6uDXowRrsuyQC252d1DKYkEuKNOI7aGeEz90-ick',
        FRONTEND_URL: 'https://ismaikami.github.io/K2-Dent-Production'
      }
    };

    // Export configuration active
    window.ACTIVE_CONFIG = window.CONFIG[window.ENV];

    // API Endpoints
    window.API = {
      ANAMNESIS: `${window.ACTIVE_CONFIG.BACKEND_URL}/api/ai/anamnesis`,
      PRESCRIPTION: `${window.ACTIVE_CONFIG.BACKEND_URL}/api/ai/prescription`,
      HEALTH: `${window.ACTIVE_CONFIG.BACKEND_URL}/health`
    };
}

// Log configuration (dev only)
if (window.ENV === 'development') {
  console.log('🔧 K2 Dent Configuration:', {
    env: window.ENV,
    backend: window.ACTIVE_CONFIG.BACKEND_URL,
    frontend: window.ACTIVE_CONFIG.FRONTEND_URL
  });
}

// Alias pour compatibilité avec code existant
window.K2_CONFIG = window.ACTIVE_CONFIG;
window.K2_API = window.API;
window.K2_ENV = window.ENV;

console.log('✅ K2 Dent Config loaded - Environment:', window.ENV);

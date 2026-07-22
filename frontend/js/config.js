/**
 * K2 DENT — CONFIGURATION
 * Centralized configuration for the application
 *
 * @author Ismail Sialyen
 * @powered-by RCE AI Engine
 */

window.K2_CONFIG = {
    // Supabase Configuration
    // ⚠️ IMPORTANT: Replace with your own Supabase credentials
    // Get them from: https://supabase.com/dashboard/project/_/settings/api
    SUPABASE_URL: '',  // Ex: 'https://xxxxx.supabase.co'
    SUPABASE_ANON_KEY: '',  // Your anon/public key

    // Demo Mode (when no Supabase credentials)
    DEMO_MODE: true,  // Set to false when you have real Supabase

    // Application Settings
    APP_NAME: 'K2 DENT',
    APP_VERSION: '1.0.0',

    // Features
    ENABLE_AI_SUGGESTIONS: true,
    ENABLE_REMINDERS: true,

    // Debug
    DEBUG: true
};

console.log('✅ K2 Config loaded');

/**
 * K2 DENT — CONFIGURATION
 * Centralized configuration for the application
 *
 * @author Ismail Sialyen
 * @powered-by RCE AI Engine
 */

window.K2_CONFIG = {
    // Supabase Configuration - K2 Dent Production
    SUPABASE_URL: 'https://sqgxscrwcffjfomlsoyf.supabase.co',
    SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNxZ3hzY3J3Y2ZmamZvbWxzb3lmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ2NTE2NjMsImV4cCI6MjEwMDIyNzY2M30.TtLYJKBM7XxrdsHiHS9EGOxnyniSdAhBLPUkhpReidU',

    // Demo Mode - Set to FALSE for production with real database
    DEMO_MODE: false,

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

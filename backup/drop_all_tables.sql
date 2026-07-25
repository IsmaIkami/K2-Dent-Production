-- ============================================
-- K2 DENT - DROP ALL TABLES
-- WARNING: This will DELETE all data!
-- ============================================

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS treatment_plans CASCADE;
DROP TABLE IF EXISTS invoices CASCADE;
DROP TABLE IF EXISTS timeline_events CASCADE;
DROP TABLE IF EXISTS anamneses CASCADE;
DROP TABLE IF EXISTS appointments CASCADE;
DROP TABLE IF EXISTS patients CASCADE;

-- Drop extension
DROP EXTENSION IF EXISTS "uuid-ossp";

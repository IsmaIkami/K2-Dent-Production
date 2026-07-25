-- ============================================
-- K2 DENT - DATABASE DATA BACKUP
-- Date: 2026-07-25
-- ============================================

-- ⚠️ MANUAL EXPORT REQUIRED
--
-- To export data from Supabase:
--
-- 1. Go to Supabase Dashboard
--    https://supabase.com/dashboard/project/zkjhemeysleurnvqsclq
--
-- 2. Go to "Table Editor"
--
-- 3. For each table, click "Export" → "SQL INSERT statements"
--    - patients
--    - appointments
--    - anamneses
--    - timeline_events
--    - invoices (if exists)
--    - treatment_plans (if exists)
--
-- 4. Save the INSERT statements to this file
--
-- OR use pg_dump (requires direct DB access):
--
-- pg_dump -h db.zkjhemeysleurnvqsclq.supabase.co \
--         -U postgres \
--         -d postgres \
--         --data-only \
--         --table=patients \
--         --table=appointments \
--         --table=anamneses \
--         --table=timeline_events \
--         --table=invoices \
--         --table=treatment_plans \
--         > supabase_data_2026-07-25.sql

-- ============================================
-- SAMPLE DATA (Replace with actual exports)
-- ============================================

-- Example patients (10 test patients)
-- INSERT INTO patients (id, niss, first_name, last_name, ...) VALUES (...);

-- Example appointments
-- INSERT INTO appointments (id, patient_id, start_time, ...) VALUES (...);

-- Example anamneses
-- INSERT INTO anamneses (id, patient_id, medical_conditions, ...) VALUES (...);

-- Example timeline events
-- INSERT INTO timeline_events (id, patient_id, event_type, ...) VALUES (...);


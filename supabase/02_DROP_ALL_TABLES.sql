-- ============================================
-- NETTOYAGE COMPLET - REPARTIR DE ZÉRO
-- ============================================
-- ⚠️  ATTENTION: Ce script SUPPRIME TOUTES LES TABLES
-- ⚠️  Utilisez uniquement si vous voulez repartir de zéro
-- ⚠️  Toutes les données seront perdues!
-- ============================================

-- Désactiver RLS temporairement
ALTER TABLE IF EXISTS xrays DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS staff_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS appointments DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS certificates DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS prescriptions DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS inami_acts DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS tooth_treatments DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS dental_charts DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS timeline_events DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS anamnesis DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS patients DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS medical_history DISABLE ROW LEVEL SECURITY;

-- Supprimer toutes les policies existantes
DROP POLICY IF EXISTS "Allow all for authenticated users" ON xrays;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON staff_profiles;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON appointments;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON certificates;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON prescriptions;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON inami_acts;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON tooth_treatments;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON dental_charts;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON timeline_events;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON anamnesis;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON patients;

-- Supprimer les tables (dans l'ordre inverse des dépendances)
DROP TABLE IF EXISTS xrays CASCADE;
DROP TABLE IF EXISTS staff_profiles CASCADE;
DROP TABLE IF EXISTS appointments CASCADE;
DROP TABLE IF EXISTS certificates CASCADE;
DROP TABLE IF EXISTS prescriptions CASCADE;
DROP TABLE IF EXISTS inami_acts CASCADE;
DROP TABLE IF EXISTS tooth_treatments CASCADE;
DROP TABLE IF EXISTS dental_charts CASCADE;
DROP TABLE IF EXISTS timeline_events CASCADE;
DROP TABLE IF EXISTS anamnesis CASCADE;
DROP TABLE IF EXISTS medical_history CASCADE;
DROP TABLE IF EXISTS patients CASCADE;

-- Supprimer les vues
DROP VIEW IF EXISTS patient_complete_view CASCADE;

-- Supprimer les fonctions
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS create_medical_history_version() CASCADE;

-- Vérification
SELECT 'Toutes les tables ont été supprimées!' as status;

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Si cette requête ne retourne rien, c'est bon!

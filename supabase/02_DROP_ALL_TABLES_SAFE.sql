-- ============================================
-- NETTOYAGE COMPLET - VERSION SÉCURISÉE
-- ============================================
-- Ce script supprime tout ce qui existe
-- Sans erreur si une table n'existe pas déjà
-- ============================================

-- Supprimer les tables (dans l'ordre inverse des dépendances)
-- CASCADE supprime aussi les dépendances automatiquement
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

-- Supprimer les vues si elles existent
DROP VIEW IF EXISTS patient_complete_view CASCADE;

-- Supprimer les fonctions si elles existent
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS create_medical_history_version() CASCADE;

-- Vérification finale
SELECT 'Nettoyage terminé!' as status;

-- Vérifier qu'il ne reste rien
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Si la liste est vide, c'est parfait!

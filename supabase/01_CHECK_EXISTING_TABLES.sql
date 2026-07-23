-- ============================================
-- DIAGNOSTIC: Vérifier tables existantes
-- ============================================
-- Exécutez ce script AVANT la migration
-- pour voir ce qui existe déjà dans votre DB
-- ============================================

-- Liste toutes les tables
SELECT
  table_name,
  table_type
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Pour chaque table, voir sa structure
-- (décommentez la table qui vous intéresse)

-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns
-- WHERE table_schema = 'public' AND table_name = 'patients'
-- ORDER BY ordinal_position;

-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns
-- WHERE table_schema = 'public' AND table_name = 'timeline_events'
-- ORDER BY ordinal_position;

-- ============================================
-- CORRECTION RLS - Permettre accès aux données
-- ============================================
-- Problème: Row Level Security bloque l'insertion
-- Solution: Désactiver RLS temporairement OU créer policies permissives
-- ============================================

-- OPTION 1: Désactiver RLS complètement (pour développement)
-- Décommentez ces lignes pour désactiver RLS:

ALTER TABLE patients DISABLE ROW LEVEL SECURITY;
ALTER TABLE anamnesis DISABLE ROW LEVEL SECURITY;
ALTER TABLE timeline_events DISABLE ROW LEVEL SECURITY;
ALTER TABLE dental_charts DISABLE ROW LEVEL SECURITY;
ALTER TABLE tooth_treatments DISABLE ROW LEVEL SECURITY;
ALTER TABLE inami_acts DISABLE ROW LEVEL SECURITY;
ALTER TABLE prescriptions DISABLE ROW LEVEL SECURITY;
ALTER TABLE certificates DISABLE ROW LEVEL SECURITY;
ALTER TABLE appointments DISABLE ROW LEVEL SECURITY;
ALTER TABLE staff_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE xrays DISABLE ROW LEVEL SECURITY;

SELECT 'RLS désactivé sur toutes les tables - Accès complet autorisé!' as status;

-- OPTION 2: Créer des policies permissives (si vous voulez garder RLS activé)
-- Décommentez ces lignes pour activer RLS avec policies permissives:

/*
-- Réactiver RLS
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE anamnesis ENABLE ROW LEVEL SECURITY;
ALTER TABLE timeline_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE dental_charts ENABLE ROW LEVEL SECURITY;
ALTER TABLE tooth_treatments ENABLE ROW LEVEL SECURITY;
ALTER TABLE inami_acts ENABLE ROW LEVEL SECURITY;
ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE xrays ENABLE ROW LEVEL SECURITY;

-- Créer policies qui autorisent tout (temporaire - dev only)
CREATE POLICY "allow_all_patients" ON patients FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_anamnesis" ON anamnesis FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_timeline" ON timeline_events FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_charts" ON dental_charts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_treatments" ON tooth_treatments FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_inami" ON inami_acts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_prescriptions" ON prescriptions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_certificates" ON certificates FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_appointments" ON appointments FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_staff" ON staff_profiles FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_xrays" ON xrays FOR ALL USING (true) WITH CHECK (true);

SELECT 'RLS activé avec policies permissives - Accès complet autorisé!' as status;
*/

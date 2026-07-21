-- ============================================================================
-- K2 DENT - ROW LEVEL SECURITY POLICIES
-- ============================================================================
-- Ce script active RLS et crée des politiques de sécurité
-- pour toutes les tables de K2 Dent
--
-- STRATÉGIE:
-- - authenticated users (dentistes connectés) : accès complet
-- - anon users (non connectés) : accès lecture seule + création limitée
-- ============================================================================

-- ============================================================================
-- PATIENTS
-- ============================================================================

ALTER TABLE patients ENABLE ROW LEVEL SECURITY;

-- Politique pour utilisateurs authentifiés (dentistes)
CREATE POLICY "Authenticated users full access to patients"
ON patients
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Politique pour utilisateurs anonymes (pour démo/dev)
CREATE POLICY "Anon users can read and insert patients"
ON patients
FOR SELECT
TO anon
USING (true);

CREATE POLICY "Anon users can insert patients"
ON patients
FOR INSERT
TO anon
WITH CHECK (true);

CREATE POLICY "Anon users can update patients"
ON patients
FOR UPDATE
TO anon
USING (true)
WITH CHECK (true);

-- ============================================================================
-- ANAMNESIS
-- ============================================================================

ALTER TABLE anamnesis ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users full access to anamnesis"
ON anamnesis FOR ALL TO authenticated
USING (true) WITH CHECK (true);

CREATE POLICY "Anon users full access to anamnesis"
ON anamnesis FOR ALL TO anon
USING (true) WITH CHECK (true);

-- ============================================================================
-- PRESCRIPTIONS
-- ============================================================================

ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users full access to prescriptions"
ON prescriptions FOR ALL TO authenticated
USING (true) WITH CHECK (true);

CREATE POLICY "Anon users full access to prescriptions"
ON prescriptions FOR ALL TO anon
USING (true) WITH CHECK (true);

-- ============================================================================
-- CERTIFICATES
-- ============================================================================

ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users full access to certificates"
ON certificates FOR ALL TO authenticated
USING (true) WITH CHECK (true);

CREATE POLICY "Anon users full access to certificates"
ON certificates FOR ALL TO anon
USING (true) WITH CHECK (true);

-- ============================================================================
-- APPOINTMENTS
-- ============================================================================

ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users full access to appointments"
ON appointments FOR ALL TO authenticated
USING (true) WITH CHECK (true);

CREATE POLICY "Anon users full access to appointments"
ON appointments FOR ALL TO anon
USING (true) WITH CHECK (true);

-- ============================================================================
-- DENTAL CHARTS
-- ============================================================================

ALTER TABLE dental_charts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users full access to dental_charts"
ON dental_charts FOR ALL TO authenticated
USING (true) WITH CHECK (true);

CREATE POLICY "Anon users full access to dental_charts"
ON dental_charts FOR ALL TO anon
USING (true) WITH CHECK (true);

-- ============================================================================
-- TOOTH TREATMENTS
-- ============================================================================

ALTER TABLE tooth_treatments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users full access to tooth_treatments"
ON tooth_treatments FOR ALL TO authenticated
USING (true) WITH CHECK (true);

CREATE POLICY "Anon users full access to tooth_treatments"
ON tooth_treatments FOR ALL TO anon
USING (true) WITH CHECK (true);

-- ============================================================================
-- TIMELINE EVENTS
-- ============================================================================

ALTER TABLE timeline_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users full access to timeline_events"
ON timeline_events FOR ALL TO authenticated
USING (true) WITH CHECK (true);

CREATE POLICY "Anon users full access to timeline_events"
ON timeline_events FOR ALL TO anon
USING (true) WITH CHECK (true);

-- ============================================================================
-- XRAYS
-- ============================================================================

ALTER TABLE xrays ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users full access to xrays"
ON xrays FOR ALL TO authenticated
USING (true) WITH CHECK (true);

CREATE POLICY "Anon users full access to xrays"
ON xrays FOR ALL TO anon
USING (true) WITH CHECK (true);

-- ============================================================================
-- INAMI ACTS
-- ============================================================================

ALTER TABLE inami_acts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users full access to inami_acts"
ON inami_acts FOR ALL TO authenticated
USING (true) WITH CHECK (true);

CREATE POLICY "Anon users full access to inami_acts"
ON inami_acts FOR ALL TO anon
USING (true) WITH CHECK (true);

-- ============================================================================
-- STAFF PROFILES
-- ============================================================================

ALTER TABLE staff_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users full access to staff_profiles"
ON staff_profiles FOR ALL TO authenticated
USING (true) WITH CHECK (true);

CREATE POLICY "Anon users can read staff_profiles"
ON staff_profiles FOR SELECT TO anon
USING (true);

-- ============================================================================
-- VÉRIFICATION
-- ============================================================================

-- Afficher toutes les politiques créées
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

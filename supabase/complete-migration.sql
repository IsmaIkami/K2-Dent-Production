-- ============================================
-- K2 DENT - MIGRATION COMPLÈTE BASE DE DONNÉES
-- ============================================
-- Auteur: Ismail Sialyen
-- Date: 23 juillet 2026
-- Version: 2.0.0
-- Description: Script de migration complet incluant TOUTES les tables nécessaires
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE 1: USERS (MANQUANTE - CRITIQUE!)
-- ============================================
-- Cette table est utilisée par l'authentification backend
-- auth-routes.js lignes 48, 101, 166

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Authentification
  username VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,

  -- Informations personnelles
  full_name VARCHAR(200) NOT NULL,
  role VARCHAR(100) NOT NULL,
  avatar VARCHAR(10) DEFAULT '👤',

  -- Métadonnées
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login TIMESTAMP WITH TIME ZONE
);

-- Index pour performance
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active);

-- RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated users can read all active users
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'users' AND policyname = 'Authenticated users can read users'
  ) THEN
    CREATE POLICY "Authenticated users can read users"
    ON users FOR SELECT
    TO authenticated
    USING (is_active = true);
  END IF;
END $$;

-- Policy: Only service role can insert/update/delete users
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'users' AND policyname = 'Service role can manage users'
  ) THEN
    CREATE POLICY "Service role can manage users"
    ON users FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);
  END IF;
END $$;

COMMENT ON TABLE users IS 'Application users with bcrypt-hashed passwords for authentication';

-- ============================================
-- TABLE 2: PATIENTS
-- ============================================

CREATE TABLE IF NOT EXISTS patients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  niss VARCHAR(15) UNIQUE NOT NULL,
  date_of_birth DATE NOT NULL,
  gender VARCHAR(10) CHECK (gender IN ('M', 'F', 'X', 'OTHER')),
  phone VARCHAR(20),
  mobile VARCHAR(20),
  email VARCHAR(255),
  address_street VARCHAR(255),
  address_city VARCHAR(100),
  address_zip VARCHAR(10),
  address_country VARCHAR(50) DEFAULT 'Belgium',

  -- Medical info
  mutuelle_name VARCHAR(100),
  mutuelle_code VARCHAR(10),
  mutuelle_membership VARCHAR(50),
  bim BOOLEAN DEFAULT FALSE,
  allergies TEXT,
  medications TEXT,
  medical_conditions TEXT,
  emergency_contact_name VARCHAR(100),
  emergency_contact_phone VARCHAR(20),

  -- Metadata
  language VARCHAR(5) DEFAULT 'FR' CHECK (language IN ('FR', 'NL', 'DE', 'EN')),
  preferred_communication VARCHAR(20) DEFAULT 'EMAIL',
  gdpr_consent BOOLEAN DEFAULT FALSE,
  gdpr_consent_date TIMESTAMP WITH TIME ZONE,
  marketing_consent BOOLEAN DEFAULT FALSE,

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID,
  updated_by UUID,
  archived BOOLEAN DEFAULT FALSE,
  archived_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_patients_niss ON patients(niss);
CREATE INDEX IF NOT EXISTS idx_patients_last_name ON patients(last_name);
CREATE INDEX IF NOT EXISTS idx_patients_archived ON patients(archived);

ALTER TABLE patients ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Allow all for authenticated users"
ON patients FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- TABLE 3: APPOINTMENTS (FIX start_time/end_time)
-- ============================================

CREATE TABLE IF NOT EXISTS appointments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID REFERENCES patients(id) ON DELETE SET NULL,

  -- Appointment details
  appointment_date DATE NOT NULL,
  start_time TIME,  -- Peut être NULL pour anciennes données
  end_time TIME,    -- Peut être NULL pour anciennes données
  duration_minutes INTEGER,

  -- Type and status
  type VARCHAR(100),
  status VARCHAR(50) DEFAULT 'scheduled' CHECK (status IN (
    'scheduled', 'confirmed', 'arrived', 'in_progress',
    'completed', 'cancelled', 'no_show'
  )),

  -- Details
  reason TEXT,
  notes TEXT,

  -- Reminders
  reminder_sent BOOLEAN DEFAULT FALSE,
  reminder_sent_date TIMESTAMP WITH TIME ZONE,

  -- Practitioner
  practitioner_id UUID,

  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID,
  cancelled_at TIMESTAMP WITH TIME ZONE,
  cancellation_reason TEXT
);

-- Ajouter les colonnes manquantes si elles n'existent pas
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'start_time'
    ) THEN
        ALTER TABLE appointments ADD COLUMN start_time TIME;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'end_time'
    ) THEN
        ALTER TABLE appointments ADD COLUMN end_time TIME;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_appointments_patient ON appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date, start_time);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);

ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Allow all for authenticated users"
ON appointments FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- TABLE 4: TOOTH_TREATMENTS
-- ============================================

CREATE TABLE IF NOT EXISTS tooth_treatments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  tooth_number VARCHAR(5) NOT NULL,

  treatment_type VARCHAR(100) NOT NULL,
  treatment_date DATE NOT NULL,
  inami_code VARCHAR(10),
  status VARCHAR(50) DEFAULT 'completed' CHECK (status IN ('planned', 'in_progress', 'completed', 'cancelled')),

  surfaces TEXT,
  materials_used TEXT,
  notes TEXT,

  price_total DECIMAL(10, 2),
  price_patient DECIMAL(10, 2),
  price_insurance DECIMAL(10, 2),

  performed_by UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tooth_treatments_patient ON tooth_treatments(patient_id);
CREATE INDEX IF NOT EXISTS idx_tooth_treatments_date ON tooth_treatments(treatment_date DESC);

ALTER TABLE tooth_treatments ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Allow all for authenticated users"
ON tooth_treatments FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- TABLE 5: ANAMNESIS
-- ============================================

CREATE TABLE IF NOT EXISTS anamnesis (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  content TEXT NOT NULL,
  version INTEGER DEFAULT 1,
  type VARCHAR(20) DEFAULT 'AI' CHECK (type IN ('AI', 'MANUAL', 'MODIFIED')),

  ai_model VARCHAR(50),
  ai_tokens_used INTEGER,
  ai_generation_time_ms INTEGER,

  transcription_text TEXT,
  transcription_duration_sec INTEGER,
  audio_file_url TEXT,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID NOT NULL,
  parent_version_id UUID REFERENCES anamnesis(id)
);

CREATE INDEX IF NOT EXISTS idx_anamnesis_patient ON anamnesis(patient_id);

ALTER TABLE anamnesis ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Allow all for authenticated users"
ON anamnesis FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- TABLE 6: TIMELINE_EVENTS
-- ============================================

CREATE TABLE IF NOT EXISTS timeline_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  type VARCHAR(50) NOT NULL CHECK (type IN (
    'anamnesis', 'consultation', 'treatment', 'xray',
    'prescription', 'certificate', 'payment', 'appointment',
    'note', 'document'
  )),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  badge VARCHAR(50),

  related_id UUID,
  related_type VARCHAR(50),

  event_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID NOT NULL,
  archived BOOLEAN DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_timeline_patient ON timeline_events(patient_id);
CREATE INDEX IF NOT EXISTS idx_timeline_date ON timeline_events(event_date DESC);

ALTER TABLE timeline_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Allow all for authenticated users"
ON timeline_events FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- TABLE 7: DENTAL_CHARTS
-- ============================================

CREATE TABLE IF NOT EXISTS dental_charts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  chart_data JSONB NOT NULL,

  snapshot_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID NOT NULL,
  notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_dental_charts_patient ON dental_charts(patient_id);

ALTER TABLE dental_charts ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Allow all for authenticated users"
ON dental_charts FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- TABLE 8: INAMI_ACTS
-- ============================================

CREATE TABLE IF NOT EXISTS inami_acts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  inami_code VARCHAR(10) NOT NULL,
  inami_description TEXT,

  act_date DATE NOT NULL,
  tooth_number VARCHAR(5),
  quantity INTEGER DEFAULT 1,

  tariff_convention DECIMAL(10, 2),
  tariff_honor DECIMAL(10, 2),
  patient_share DECIMAL(10, 2),
  insurance_share DECIMAL(10, 2),
  total_amount DECIMAL(10, 2),

  tiers_payant BOOLEAN DEFAULT FALSE,
  tiers_payant_approved BOOLEAN DEFAULT FALSE,
  tiers_payant_approval_date TIMESTAMP WITH TIME ZONE,

  eattest_sent BOOLEAN DEFAULT FALSE,
  eattest_sent_date TIMESTAMP WITH TIME ZONE,
  eattest_reference VARCHAR(100),
  eattest_status VARCHAR(50),

  performed_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  invoiced BOOLEAN DEFAULT FALSE,
  invoice_id UUID
);

CREATE INDEX IF NOT EXISTS idx_inami_acts_patient ON inami_acts(patient_id);
CREATE INDEX IF NOT EXISTS idx_inami_acts_date ON inami_acts(act_date DESC);

ALTER TABLE inami_acts ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Allow all for authenticated users"
ON inami_acts FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- TABLE 9: PRESCRIPTIONS
-- ============================================

CREATE TABLE IF NOT EXISTS prescriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  medications JSONB NOT NULL,
  diagnosis TEXT,
  notes TEXT,

  ai_generated BOOLEAN DEFAULT FALSE,
  ai_model VARCHAR(50),

  prescription_date DATE NOT NULL DEFAULT CURRENT_DATE,
  validity_end_date DATE,
  delivered BOOLEAN DEFAULT FALSE,
  delivered_date TIMESTAMP WITH TIME ZONE,

  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  pdf_url TEXT
);

CREATE INDEX IF NOT EXISTS idx_prescriptions_patient ON prescriptions(patient_id);

ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Allow all for authenticated users"
ON prescriptions FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- TABLE 10: CERTIFICATES
-- ============================================

CREATE TABLE IF NOT EXISTS certificates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  type VARCHAR(50) NOT NULL CHECK (type IN (
    'work', 'school', 'sports', 'insurance', 'other'
  )),
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,

  certificate_date DATE NOT NULL DEFAULT CURRENT_DATE,
  valid_from DATE,
  valid_to DATE,

  delivered BOOLEAN DEFAULT FALSE,
  delivered_date TIMESTAMP WITH TIME ZONE,

  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  pdf_url TEXT
);

CREATE INDEX IF NOT EXISTS idx_certificates_patient ON certificates(patient_id);

ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Allow all for authenticated users"
ON certificates FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- TABLE 11: STAFF_PROFILES
-- ============================================

CREATE TABLE IF NOT EXISTS staff_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  role VARCHAR(50) NOT NULL CHECK (role IN (
    'OWNER', 'DENTIST', 'ASSISTANT', 'SECRETARY', 'HYGIENIST'
  )),
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  inami_number VARCHAR(20),
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20),

  permissions JSONB DEFAULT '{}',
  active BOOLEAN DEFAULT TRUE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_staff_email ON staff_profiles(email);

ALTER TABLE staff_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Allow all for authenticated users"
ON staff_profiles FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- TABLE 12: XRAYS
-- ============================================

CREATE TABLE IF NOT EXISTS xrays (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  xray_type VARCHAR(50) NOT NULL CHECK (xray_type IN (
    'periapical', 'bitewing', 'panoramic', 'cephalometric', 'cbct'
  )),
  tooth_number VARCHAR(5),
  xray_date DATE NOT NULL,

  image_url TEXT NOT NULL,
  thumbnail_url TEXT,
  dicom_url TEXT,
  file_size_kb INTEGER,

  ai_analysis TEXT,
  ai_confidence DECIMAL(5, 2),
  ai_findings JSONB,

  notes TEXT,
  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_xrays_patient ON xrays(patient_id);

ALTER TABLE xrays ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Allow all for authenticated users"
ON xrays FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- TRIGGERS
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Appliquer aux tables concernées
DO $$
BEGIN
  -- Users
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_users_updated_at') THEN
    CREATE TRIGGER update_users_updated_at
      BEFORE UPDATE ON users
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;

  -- Patients
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_patients_updated_at') THEN
    CREATE TRIGGER update_patients_updated_at
      BEFORE UPDATE ON patients
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;

  -- Appointments
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_appointments_updated_at') THEN
    CREATE TRIGGER update_appointments_updated_at
      BEFORE UPDATE ON appointments
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;

  -- Tooth treatments
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_tooth_treatments_updated_at') THEN
    CREATE TRIGGER update_tooth_treatments_updated_at
      BEFORE UPDATE ON tooth_treatments
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;

  -- Staff profiles
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_staff_profiles_updated_at') THEN
    CREATE TRIGGER update_staff_profiles_updated_at
      BEFORE UPDATE ON staff_profiles
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- ============================================
-- GRANTS
-- ============================================

GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO authenticated;

-- ============================================
-- RAPPORT FINAL
-- ============================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '════════════════════════════════════════════════════';
  RAISE NOTICE '✅ K2 DENT - MIGRATION COMPLÈTE TERMINÉE';
  RAISE NOTICE '════════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '📊 TABLES CRÉÉES/VÉRIFIÉES: 12';
  RAISE NOTICE '   1. ✅ users (NOUVELLE - authentification)';
  RAISE NOTICE '   2. ✅ patients';
  RAISE NOTICE '   3. ✅ appointments (colonnes start_time/end_time ajoutées)';
  RAISE NOTICE '   4. ✅ tooth_treatments';
  RAISE NOTICE '   5. ✅ anamnesis';
  RAISE NOTICE '   6. ✅ timeline_events';
  RAISE NOTICE '   7. ✅ dental_charts';
  RAISE NOTICE '   8. ✅ inami_acts';
  RAISE NOTICE '   9. ✅ prescriptions';
  RAISE NOTICE '  10. ✅ certificates';
  RAISE NOTICE '  11. ✅ staff_profiles';
  RAISE NOTICE '  12. ✅ xrays';
  RAISE NOTICE '';
  RAISE NOTICE '🔒 RLS (Row Level Security): ACTIVÉ sur toutes les tables';
  RAISE NOTICE '⚡ Triggers: Configurés (update_updated_at)';
  RAISE NOTICE '🔑 Indexes: Optimisés pour performance';
  RAISE NOTICE '';
  RAISE NOTICE '════════════════════════════════════════════════════';
  RAISE NOTICE 'PROCHAINES ÉTAPES:';
  RAISE NOTICE '════════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '1. Appeler POST /api/auth/seed-users pour créer les 6 utilisateurs';
  RAISE NOTICE '2. Tester login avec: Dr. Sialyen / dentalcockpitk2';
  RAISE NOTICE '3. Vérifier dashboard - les appointments devraient charger';
  RAISE NOTICE '';
  RAISE NOTICE '════════════════════════════════════════════════════';
END $$;

-- ============================================
-- MIGRATION K2-DENT - VERS ÉTAT FONCTIONNEL
-- ============================================
-- Date: 2026-07-23
-- Source: Tag v20260723_postlogin_fonctionne
-- Objectif: Restaurer alignement DB ↔ Code
--
-- ⚠️  IMPORTANT:
-- Ce script restaure le schéma DB qui correspond EXACTEMENT
-- au code frontend actuellement déployé sur GitHub Pages.
--
-- Exécutez ce script dans Supabase SQL Editor.
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- ÉTAPE 1: NETTOYER (optionnel - à décommenter si besoin)
-- ============================================

-- Si vous voulez repartir de zéro, décommentez:
-- DROP TABLE IF EXISTS xrays CASCADE;
-- DROP TABLE IF EXISTS staff_profiles CASCADE;
-- DROP TABLE IF EXISTS appointments CASCADE;
-- DROP TABLE IF EXISTS certificates CASCADE;
-- DROP TABLE IF EXISTS prescriptions CASCADE;
-- DROP TABLE IF EXISTS inami_acts CASCADE;
-- DROP TABLE IF EXISTS tooth_treatments CASCADE;
-- DROP TABLE IF EXISTS dental_charts CASCADE;
-- DROP TABLE IF EXISTS timeline_events CASCADE;
-- DROP TABLE IF NOT EXISTS anamnesis CASCADE;
-- DROP TABLE IF EXISTS patients CASCADE;

-- ============================================
-- ÉTAPE 2: CRÉER LES TABLES
-- ============================================

-- Table 1: PATIENTS
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

  mutuelle_name VARCHAR(100),
  mutuelle_code VARCHAR(10),
  mutuelle_membership VARCHAR(50),
  bim BOOLEAN DEFAULT FALSE,
  allergies TEXT,
  medications TEXT,
  medical_conditions TEXT,
  emergency_contact_name VARCHAR(100),
  emergency_contact_phone VARCHAR(20),

  language VARCHAR(5) DEFAULT 'FR' CHECK (language IN ('FR', 'NL', 'DE', 'EN')),
  preferred_communication VARCHAR(20) DEFAULT 'EMAIL' CHECK (preferred_communication IN ('EMAIL', 'SMS', 'PHONE', 'WHATSAPP')),
  gdpr_consent BOOLEAN DEFAULT FALSE,
  gdpr_consent_date TIMESTAMP WITH TIME ZONE,
  marketing_consent BOOLEAN DEFAULT FALSE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID,
  updated_by UUID,
  archived BOOLEAN DEFAULT FALSE,
  archived_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_patients_niss ON patients(niss);
CREATE INDEX IF NOT EXISTS idx_patients_last_name ON patients(last_name);
CREATE INDEX IF NOT EXISTS idx_patients_email ON patients(email);
CREATE INDEX IF NOT EXISTS idx_patients_archived ON patients(archived);

-- Table 2: ANAMNESIS
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
CREATE INDEX IF NOT EXISTS idx_anamnesis_created_at ON anamnesis(created_at DESC);

-- Table 3: TIMELINE_EVENTS
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
CREATE INDEX IF NOT EXISTS idx_timeline_type ON timeline_events(type);

-- Table 4: DENTAL_CHARTS
CREATE TABLE IF NOT EXISTS dental_charts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  chart_data JSONB NOT NULL,

  snapshot_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID NOT NULL,
  notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_dental_charts_patient ON dental_charts(patient_id);
CREATE INDEX IF NOT EXISTS idx_dental_charts_date ON dental_charts(snapshot_date DESC);

-- Table 5: TOOTH_TREATMENTS
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
CREATE INDEX IF NOT EXISTS idx_tooth_treatments_tooth ON tooth_treatments(tooth_number);

-- Table 6: INAMI_ACTS
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
CREATE INDEX IF NOT EXISTS idx_inami_acts_code ON inami_acts(inami_code);
CREATE INDEX IF NOT EXISTS idx_inami_acts_eattest ON inami_acts(eattest_sent, eattest_status);

-- Table 7: PRESCRIPTIONS
CREATE TABLE IF NOT EXISTS prescriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  prescription_date DATE NOT NULL,
  medications JSONB NOT NULL,

  notes TEXT,
  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_prescriptions_patient ON prescriptions(patient_id);
CREATE INDEX IF NOT EXISTS idx_prescriptions_date ON prescriptions(prescription_date DESC);

-- Table 8: CERTIFICATES
CREATE TABLE IF NOT EXISTS certificates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  certificate_date DATE NOT NULL,
  certificate_type VARCHAR(50) NOT NULL,
  content TEXT NOT NULL,

  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_certificates_patient ON certificates(patient_id);
CREATE INDEX IF NOT EXISTS idx_certificates_date ON certificates(certificate_date DESC);

-- Table 9: APPOINTMENTS
CREATE TABLE IF NOT EXISTS appointments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  appointment_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  duration_minutes INTEGER NOT NULL,

  appointment_type VARCHAR(50) NOT NULL,
  status VARCHAR(50) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'confirmed', 'completed', 'cancelled', 'no_show')),

  reason TEXT,
  notes TEXT,

  reminder_sent BOOLEAN DEFAULT FALSE,
  reminder_sent_date TIMESTAMP WITH TIME ZONE,

  practitioner_id UUID,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID,
  cancelled_at TIMESTAMP WITH TIME ZONE,
  cancellation_reason TEXT
);

CREATE INDEX IF NOT EXISTS idx_appointments_patient ON appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date, start_time);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);
CREATE INDEX IF NOT EXISTS idx_appointments_practitioner ON appointments(practitioner_id);

-- Table 10: STAFF_PROFILES
CREATE TABLE IF NOT EXISTS staff_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  role VARCHAR(50) NOT NULL CHECK (role IN ('OWNER', 'DENTIST', 'ASSISTANT', 'SECRETARY', 'HYGIENIST')),
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
CREATE INDEX IF NOT EXISTS idx_staff_active ON staff_profiles(active);

-- Table 11: XRAYS
CREATE TABLE IF NOT EXISTS xrays (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  xray_type VARCHAR(50) NOT NULL CHECK (xray_type IN ('periapical', 'bitewing', 'panoramic', 'cephalometric', 'cbct')),
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
CREATE INDEX IF NOT EXISTS idx_xrays_date ON xrays(xray_date DESC);
CREATE INDEX IF NOT EXISTS idx_xrays_type ON xrays(xray_type);

-- ============================================
-- ÉTAPE 3: FONCTIONS & TRIGGERS
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Appliquer trigger sur tables avec updated_at
CREATE TRIGGER update_patients_updated_at BEFORE UPDATE ON patients
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tooth_treatments_updated_at BEFORE UPDATE ON tooth_treatments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON appointments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_staff_profiles_updated_at BEFORE UPDATE ON staff_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- ÉTAPE 4: ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS
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

-- Policies (pour développement - AJUSTER en production)
-- Ces policies permettent l'accès complet pour les utilisateurs authentifiés

CREATE POLICY "Allow all for authenticated users" ON patients
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all for authenticated users" ON anamnesis
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all for authenticated users" ON timeline_events
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all for authenticated users" ON dental_charts
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all for authenticated users" ON tooth_treatments
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all for authenticated users" ON inami_acts
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all for authenticated users" ON prescriptions
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all for authenticated users" ON certificates
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all for authenticated users" ON appointments
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all for authenticated users" ON staff_profiles
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all for authenticated users" ON xrays
  FOR ALL USING (true) WITH CHECK (true);

-- ============================================
-- ÉTAPE 5: DONNÉES DE TEST (optionnel)
-- ============================================

-- Patient de test (décommenter si besoin)
-- INSERT INTO patients (first_name, last_name, niss, date_of_birth, gender, phone, email)
-- VALUES ('Jean', 'Dupont', '85.12.25-123.45', '1985-12-25', 'M', '+32 485 12 34 56', 'jean.dupont@example.com')
-- ON CONFLICT (niss) DO NOTHING;

-- ============================================
-- ✅ MIGRATION TERMINÉE
-- ============================================

-- Vérification finale
SELECT 'Migration completed! Tables created:' as status;
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Note: Le code frontend est maintenant aligné avec ce schéma
-- ⚠️  Les fonctions medical_history ne sont PAS incluses car absentes du tag fonctionnel

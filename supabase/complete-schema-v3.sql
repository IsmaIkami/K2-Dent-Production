-- ============================================
-- K2 DENT - SCHÉMA COMPLET BASE DE DONNÉES
-- ============================================
-- Auteur: Ismail Sialyen (Claude Code Analysis)
-- Date: 23 juillet 2026
-- Version: 3.0.0 COMPLET
-- Description: Recréation COMPLÈTE du schéma DB à partir de l'analyse du code
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE 1: USERS (CRITIQUE - Authentification backend)
-- ============================================

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(200) NOT NULL,
  role VARCHAR(100) NOT NULL,
  avatar VARCHAR(10) DEFAULT '👤',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active);

-- ============================================
-- TABLE 2: PATIENTS (avec colonnes médicales avancées)
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

  -- Mutuelle
  mutuelle_name VARCHAR(100),
  mutuelle_code VARCHAR(10),
  mutuelle_membership VARCHAR(50),
  bim BOOLEAN DEFAULT FALSE,

  -- Informations médicales de base
  allergies TEXT,
  medications TEXT,
  medical_conditions TEXT,
  emergency_contact_name VARCHAR(100),
  emergency_contact_phone VARCHAR(20),

  -- Colonnes médicales avancées
  blood_type VARCHAR(5),
  smoker BOOLEAN DEFAULT FALSE,
  alcohol_consumption VARCHAR(20) CHECK (alcohol_consumption IN ('NONE', 'OCCASIONAL', 'MODERATE', 'HEAVY')),
  pregnant BOOLEAN DEFAULT FALSE,
  breastfeeding BOOLEAN DEFAULT FALSE,
  anticoagulant_therapy BOOLEAN DEFAULT FALSE,
  diabetes BOOLEAN DEFAULT FALSE,
  hypertension BOOLEAN DEFAULT FALSE,
  heart_disease BOOLEAN DEFAULT FALSE,
  last_dental_visit DATE,
  dental_hygiene_frequency VARCHAR(50),

  -- Préférences
  language VARCHAR(5) DEFAULT 'FR' CHECK (language IN ('FR', 'NL', 'DE', 'EN')),
  preferred_communication VARCHAR(20) DEFAULT 'EMAIL',
  gdpr_consent BOOLEAN DEFAULT FALSE,
  gdpr_consent_date TIMESTAMP WITH TIME ZONE,
  marketing_consent BOOLEAN DEFAULT FALSE,

  -- Métadonnées
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

-- ============================================
-- TABLE 3: APPOINTMENTS
-- ============================================

CREATE TABLE IF NOT EXISTS appointments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID REFERENCES patients(id) ON DELETE SET NULL,

  appointment_date DATE NOT NULL,
  start_time TIME,
  end_time TIME,
  duration_minutes INTEGER,

  type VARCHAR(100),
  status VARCHAR(50) DEFAULT 'scheduled' CHECK (status IN (
    'scheduled', 'confirmed', 'arrived', 'in_progress',
    'completed', 'cancelled', 'no_show'
  )),

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
CREATE INDEX IF NOT EXISTS idx_tooth_treatments_tooth ON tooth_treatments(tooth_number);

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
CREATE INDEX IF NOT EXISTS idx_anamnesis_created_at ON anamnesis(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_anamnesis_version ON anamnesis(patient_id, version DESC);

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
CREATE INDEX IF NOT EXISTS idx_timeline_type ON timeline_events(type);

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
CREATE INDEX IF NOT EXISTS idx_dental_charts_date ON dental_charts(snapshot_date DESC);

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
CREATE INDEX IF NOT EXISTS idx_inami_acts_code ON inami_acts(inami_code);
CREATE INDEX IF NOT EXISTS idx_inami_acts_eattest ON inami_acts(eattest_sent, eattest_status);

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
CREATE INDEX IF NOT EXISTS idx_prescriptions_date ON prescriptions(prescription_date DESC);

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
CREATE INDEX IF NOT EXISTS idx_certificates_date ON certificates(certificate_date DESC);
CREATE INDEX IF NOT EXISTS idx_certificates_type ON certificates(type);

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
CREATE INDEX IF NOT EXISTS idx_staff_active ON staff_profiles(active);

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
CREATE INDEX IF NOT EXISTS idx_xrays_date ON xrays(xray_date DESC);
CREATE INDEX IF NOT EXISTS idx_xrays_type ON xrays(xray_type);

-- ============================================
-- TABLE 13: MEDICAL_HISTORY (Historique médical versionné)
-- ============================================

CREATE TABLE IF NOT EXISTS medical_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  -- Données médicales structurées
  allergies TEXT[],
  medications TEXT[],
  medical_conditions TEXT[],
  surgical_history TEXT[],

  -- Données dentaires
  dental_concerns TEXT,
  previous_dental_treatments TEXT[],
  dental_anxiety_level INTEGER CHECK (dental_anxiety_level BETWEEN 0 AND 10),

  -- Habitudes
  brushing_frequency VARCHAR(50),
  flossing_frequency VARCHAR(50),
  mouthwash_use BOOLEAN DEFAULT FALSE,

  -- Notes du praticien
  practitioner_notes TEXT,

  -- Versioning
  version INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID NOT NULL,
  parent_version_id UUID REFERENCES medical_history(id)
);

CREATE INDEX IF NOT EXISTS idx_medical_history_patient ON medical_history(patient_id);
CREATE INDEX IF NOT EXISTS idx_medical_history_created_at ON medical_history(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_medical_history_version ON medical_history(patient_id, version DESC);

-- ============================================
-- TABLE 14: APPOINTMENT_REMINDERS (Rappels IA)
-- ============================================

CREATE TABLE IF NOT EXISTS appointment_reminders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  appointment_id UUID NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  reminder_type VARCHAR(20) CHECK (reminder_type IN ('SMS', 'EMAIL', 'WHATSAPP', 'PHONE')),
  reminder_timing VARCHAR(50) CHECK (reminder_timing IN ('24H_BEFORE', '48H_BEFORE', '1WEEK_BEFORE', 'SAME_DAY', 'FOLLOWUP')),

  message_content TEXT NOT NULL,
  recipient VARCHAR(255) NOT NULL,

  status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'delivered', 'failed', 'bounced')),
  sent_at TIMESTAMP WITH TIME ZONE,
  delivered_at TIMESTAMP WITH TIME ZONE,
  error_message TEXT,

  ai_score FLOAT,
  ai_reason TEXT,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID
);

CREATE INDEX IF NOT EXISTS idx_reminders_appointment ON appointment_reminders(appointment_id);
CREATE INDEX IF NOT EXISTS idx_reminders_patient ON appointment_reminders(patient_id);
CREATE INDEX IF NOT EXISTS idx_reminders_status ON appointment_reminders(status, sent_at);

-- ============================================
-- TABLE 15: REMINDER_AI_CONFIG (Configuration rappels)
-- ============================================

CREATE TABLE IF NOT EXISTS reminder_ai_config (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  enabled BOOLEAN DEFAULT TRUE,
  default_reminder_timing VARCHAR(50) DEFAULT '24H_BEFORE',
  send_sms BOOLEAN DEFAULT TRUE,
  send_email BOOLEAN DEFAULT TRUE,

  send_time_start TIME DEFAULT '09:00:00',
  send_time_end TIME DEFAULT '18:00:00',
  no_send_weekends BOOLEAN DEFAULT TRUE,

  ai_personalization_enabled BOOLEAN DEFAULT TRUE,
  ai_language_detection BOOLEAN DEFAULT TRUE,
  ai_optimal_timing BOOLEAN DEFAULT TRUE,

  sms_template_24h TEXT DEFAULT 'Bonjour {first_name}, rappel RDV demain à {time} chez K2 Dent. À bientôt !',
  email_template_24h TEXT DEFAULT 'Bonjour {first_name}, rappel RDV demain à {time}. Type: {type}.',

  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_by UUID
);

-- Insert default config
INSERT INTO reminder_ai_config (id)
VALUES ('00000000-0000-0000-0000-000000000001')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- VUES
-- ============================================

-- Vue complète patient avec dernières données médicales
CREATE OR REPLACE VIEW patient_complete_view AS
SELECT
  p.*,
  mh.allergies AS current_allergies,
  mh.medications AS current_medications,
  mh.medical_conditions AS current_conditions,
  mh.surgical_history,
  mh.dental_concerns,
  mh.dental_anxiety_level,
  mh.practitioner_notes,
  mh.created_at AS medical_data_last_updated
FROM patients p
LEFT JOIN LATERAL (
  SELECT * FROM medical_history
  WHERE patient_id = p.id
  ORDER BY created_at DESC
  LIMIT 1
) mh ON true
WHERE p.archived = FALSE;

-- ============================================
-- FONCTIONS
-- ============================================

-- Fonction pour créer version medical history
CREATE OR REPLACE FUNCTION create_medical_history_version(
  p_patient_id UUID,
  p_allergies TEXT[],
  p_medications TEXT[],
  p_medical_conditions TEXT[],
  p_surgical_history TEXT[],
  p_dental_concerns TEXT,
  p_previous_dental_treatments TEXT[],
  p_dental_anxiety_level INTEGER,
  p_brushing_frequency VARCHAR,
  p_flossing_frequency VARCHAR,
  p_mouthwash_use BOOLEAN,
  p_practitioner_notes TEXT,
  p_created_by UUID
) RETURNS UUID AS $$
DECLARE
  v_parent_id UUID;
  v_new_version INTEGER;
  v_new_id UUID;
BEGIN
  SELECT id, version INTO v_parent_id, v_new_version
  FROM medical_history
  WHERE patient_id = p_patient_id
  ORDER BY created_at DESC
  LIMIT 1;

  IF v_new_version IS NULL THEN
    v_new_version := 1;
  ELSE
    v_new_version := v_new_version + 1;
  END IF;

  INSERT INTO medical_history (
    patient_id, allergies, medications, medical_conditions,
    surgical_history, dental_concerns, previous_dental_treatments,
    dental_anxiety_level, brushing_frequency, flossing_frequency,
    mouthwash_use, practitioner_notes, version,
    created_by, parent_version_id
  ) VALUES (
    p_patient_id, p_allergies, p_medications, p_medical_conditions,
    p_surgical_history, p_dental_concerns, p_previous_dental_treatments,
    p_dental_anxiety_level, p_brushing_frequency, p_flossing_frequency,
    p_mouthwash_use, p_practitioner_notes, v_new_version,
    p_created_by, v_parent_id
  ) RETURNING id INTO v_new_id;

  INSERT INTO timeline_events (
    patient_id, type, title, description, badge,
    related_id, related_type, created_by
  ) VALUES (
    p_patient_id, 'note', 'Mise à jour données médicales',
    'Historique médical mis à jour (version ' || v_new_version || ')',
    'badge-info', v_new_id, 'medical_history', p_created_by
  );

  RETURN v_new_id;
END;
$$ LANGUAGE plpgsql;

-- Fonction update_updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGERS
-- ============================================

-- Triggers pour updated_at
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_patients_updated_at ON patients;
CREATE TRIGGER update_patients_updated_at
  BEFORE UPDATE ON patients
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_appointments_updated_at ON appointments;
CREATE TRIGGER update_appointments_updated_at
  BEFORE UPDATE ON appointments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_tooth_treatments_updated_at ON tooth_treatments;
CREATE TRIGGER update_tooth_treatments_updated_at
  BEFORE UPDATE ON tooth_treatments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_staff_profiles_updated_at ON staff_profiles;
CREATE TRIGGER update_staff_profiles_updated_at
  BEFORE UPDATE ON staff_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Activer RLS sur toutes les tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE tooth_treatments ENABLE ROW LEVEL SECURITY;
ALTER TABLE anamnesis ENABLE ROW LEVEL SECURITY;
ALTER TABLE timeline_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE dental_charts ENABLE ROW LEVEL SECURITY;
ALTER TABLE inami_acts ENABLE ROW LEVEL SECURITY;
ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE xrays ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointment_reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminder_ai_config ENABLE ROW LEVEL SECURITY;

-- Policies: Accès complet pour authenticated
DO $$
DECLARE
  table_name TEXT;
BEGIN
  FOR table_name IN
    SELECT tablename FROM pg_tables
    WHERE schemaname = 'public'
    AND tablename IN (
      'users', 'patients', 'appointments', 'tooth_treatments',
      'anamnesis', 'timeline_events', 'dental_charts', 'inami_acts',
      'prescriptions', 'certificates', 'staff_profiles', 'xrays',
      'medical_history', 'appointment_reminders', 'reminder_ai_config'
    )
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS "Allow all for authenticated" ON %I', table_name);
    EXECUTE format('CREATE POLICY "Allow all for authenticated" ON %I FOR ALL TO authenticated USING (true) WITH CHECK (true)', table_name);
    EXECUTE format('DROP POLICY IF EXISTS "Allow all for anon" ON %I', table_name);
    EXECUTE format('CREATE POLICY "Allow all for anon" ON %I FOR ALL TO anon USING (true) WITH CHECK (true)', table_name);
  END LOOP;
END $$;

-- ============================================
-- GRANTS
-- ============================================

GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated, anon;
GRANT SELECT ON patient_complete_view TO anon, authenticated;
GRANT EXECUTE ON FUNCTION create_medical_history_version TO authenticated, anon;
GRANT EXECUTE ON FUNCTION update_updated_at_column TO authenticated, anon;

-- ============================================
-- RAPPORT FINAL
-- ============================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════════════';
  RAISE NOTICE '✅ K2 DENT - SCHÉMA COMPLET CRÉÉ AVEC SUCCÈS';
  RAISE NOTICE '═══════════════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '📊 TABLES CRÉÉES: 15';
  RAISE NOTICE '   1. ✅ users (authentification)';
  RAISE NOTICE '   2. ✅ patients (avec colonnes médicales avancées)';
  RAISE NOTICE '   3. ✅ appointments';
  RAISE NOTICE '   4. ✅ tooth_treatments';
  RAISE NOTICE '   5. ✅ anamnesis';
  RAISE NOTICE '   6. ✅ timeline_events';
  RAISE NOTICE '   7. ✅ dental_charts';
  RAISE NOTICE '   8. ✅ inami_acts';
  RAISE NOTICE '   9. ✅ prescriptions';
  RAISE NOTICE '  10. ✅ certificates';
  RAISE NOTICE '  11. ✅ staff_profiles';
  RAISE NOTICE '  12. ✅ xrays';
  RAISE NOTICE '  13. ✅ medical_history (versioning)';
  RAISE NOTICE '  14. ✅ appointment_reminders (IA)';
  RAISE NOTICE '  15. ✅ reminder_ai_config';
  RAISE NOTICE '';
  RAISE NOTICE '🔍 VUES: 1';
  RAISE NOTICE '   • patient_complete_view';
  RAISE NOTICE '';
  RAISE NOTICE '⚙️  FONCTIONS: 2';
  RAISE NOTICE '   • create_medical_history_version()';
  RAISE NOTICE '   • update_updated_at_column()';
  RAISE NOTICE '';
  RAISE NOTICE '🔒 RLS: ACTIVÉ sur toutes les tables';
  RAISE NOTICE '⚡ TRIGGERS: Configurés (updated_at)';
  RAISE NOTICE '🔑 INDEXES: Optimisés pour performance';
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════════════';
  RAISE NOTICE 'PROCHAINES ÉTAPES:';
  RAISE NOTICE '═══════════════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '1. Créer les utilisateurs:';
  RAISE NOTICE '   curl -X POST https://k2-dent-production-production.up.railway.app/api/auth/seed-users';
  RAISE NOTICE '';
  RAISE NOTICE '2. Tester le login:';
  RAISE NOTICE '   Username: Dr. Sialyen';
  RAISE NOTICE '   Password: dentalcockpitk2';
  RAISE NOTICE '';
  RAISE NOTICE '3. Vérifier que le dashboard charge correctement';
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════════════';
END $$;

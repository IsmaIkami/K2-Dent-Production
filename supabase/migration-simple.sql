-- ============================================
-- K2 DENT - MIGRATION SIMPLIFIÉE
-- ============================================
-- Version sans IF NOT EXISTS pour les policies
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE USERS (CRITIQUE - MANQUANTE)
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

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated users can read users" ON users;
CREATE POLICY "Authenticated users can read users"
ON users FOR SELECT
TO authenticated
USING (is_active = true);

DROP POLICY IF EXISTS "Service role can manage users" ON users;
CREATE POLICY "Service role can manage users"
ON users FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- TABLE PATIENTS
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
  mutuelle_name VARCHAR(100),
  mutuelle_code VARCHAR(10),
  mutuelle_membership VARCHAR(50),
  bim BOOLEAN DEFAULT FALSE,
  allergies TEXT,
  medications TEXT,
  medical_conditions TEXT,
  emergency_contact_name VARCHAR(100),
  emergency_contact_phone VARCHAR(20),
  language VARCHAR(5) DEFAULT 'FR',
  preferred_communication VARCHAR(20) DEFAULT 'EMAIL',
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
CREATE INDEX IF NOT EXISTS idx_patients_archived ON patients(archived);

ALTER TABLE patients ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all for authenticated users" ON patients;
CREATE POLICY "Allow all for authenticated users"
ON patients FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- TABLE APPOINTMENTS (FIX start_time/end_time)
-- ============================================

CREATE TABLE IF NOT EXISTS appointments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID REFERENCES patients(id) ON DELETE SET NULL,
  appointment_date DATE NOT NULL,
  start_time TIME,
  end_time TIME,
  duration_minutes INTEGER,
  type VARCHAR(100),
  status VARCHAR(50) DEFAULT 'scheduled',
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

-- Ajouter colonnes si manquantes
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

DROP POLICY IF EXISTS "Allow all for authenticated users" ON appointments;
CREATE POLICY "Allow all for authenticated users"
ON appointments FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- TABLE TOOTH_TREATMENTS
-- ============================================

CREATE TABLE IF NOT EXISTS tooth_treatments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  tooth_number VARCHAR(5) NOT NULL,
  treatment_type VARCHAR(100) NOT NULL,
  treatment_date DATE NOT NULL,
  inami_code VARCHAR(10),
  status VARCHAR(50) DEFAULT 'completed',
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

DROP POLICY IF EXISTS "Allow all for authenticated users" ON tooth_treatments;
CREATE POLICY "Allow all for authenticated users"
ON tooth_treatments FOR ALL
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
  RAISE NOTICE '✅ K2 DENT - MIGRATION SIMPLIFIÉE TERMINÉE';
  RAISE NOTICE '════════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '📊 TABLES CRÉÉES/VÉRIFIÉES:';
  RAISE NOTICE '   1. ✅ users (NOUVELLE - authentification)';
  RAISE NOTICE '   2. ✅ patients';
  RAISE NOTICE '   3. ✅ appointments (start_time/end_time ajoutés)';
  RAISE NOTICE '   4. ✅ tooth_treatments';
  RAISE NOTICE '';
  RAISE NOTICE '🔒 RLS: ACTIVÉ';
  RAISE NOTICE '⚡ Triggers: Configurés';
  RAISE NOTICE '';
  RAISE NOTICE '════════════════════════════════════════════════════';
  RAISE NOTICE 'PROCHAINES ÉTAPES:';
  RAISE NOTICE '════════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '1. Appeler POST /api/auth/seed-users';
  RAISE NOTICE '2. Tester login: Dr. Sialyen / dentalcockpitk2';
  RAISE NOTICE '3. Vérifier dashboard';
  RAISE NOTICE '';
  RAISE NOTICE '════════════════════════════════════════════════════';
END $$;

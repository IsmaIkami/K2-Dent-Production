-- ================================================
-- K2 DENT - SETUP COMPLET DE LA BASE DE DONNÉES
-- ================================================
-- Auteur: Ismail Sialyen
-- Date: 23 juillet 2026
-- Description: Recrée toutes les tables avec données de test
-- ================================================

-- ================================================
-- EXTENSIONS
-- ================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ================================================
-- TABLE: users (Authentification)
-- ================================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('Dentiste Principal', 'Dentiste', 'Orthodontiste', 'Parodontiste', 'Assistante Dentaire', 'Administrateur', 'Utilisateur')),
  avatar TEXT NOT NULL DEFAULT '👤',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour users
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);

-- ================================================
-- TABLE: patients
-- ================================================
CREATE TABLE IF NOT EXISTS patients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  date_of_birth DATE,
  gender TEXT CHECK (gender IN ('M', 'F', 'Autre')),
  niss TEXT UNIQUE,
  phone TEXT,
  email TEXT,
  address TEXT,
  city TEXT,
  postal_code TEXT,
  country TEXT DEFAULT 'Belgique',
  mutuelle TEXT,
  emergency_contact_name TEXT,
  emergency_contact_phone TEXT,
  preferred_language TEXT DEFAULT 'fr',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour patients
CREATE INDEX IF NOT EXISTS idx_patients_last_name ON patients(last_name);
CREATE INDEX IF NOT EXISTS idx_patients_niss ON patients(niss);

-- ================================================
-- TABLE: medical_history (Historique médical versionné)
-- ================================================
CREATE TABLE IF NOT EXISTS medical_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  version INTEGER NOT NULL DEFAULT 1,

  -- Antécédents médicaux
  allergies JSONB DEFAULT '[]',
  medications JSONB DEFAULT '[]',
  medical_conditions JSONB DEFAULT '[]',
  surgical_history JSONB DEFAULT '[]',

  -- Historique dentaire
  dental_concerns TEXT,
  previous_dental_treatments JSONB DEFAULT '[]',
  dental_anxiety_level INTEGER CHECK (dental_anxiety_level BETWEEN 1 AND 10),

  -- Hygiène
  brushing_frequency TEXT,
  flossing_frequency TEXT,
  mouthwash_use BOOLEAN DEFAULT false,

  -- Notes praticien
  practitioner_notes TEXT,

  -- Métadonnées
  created_by UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour medical_history
CREATE INDEX IF NOT EXISTS idx_medical_history_patient ON medical_history(patient_id);
CREATE INDEX IF NOT EXISTS idx_medical_history_version ON medical_history(patient_id, version DESC);

-- ================================================
-- TABLE: anamnesis (Anamnèses versionnées)
-- ================================================
CREATE TABLE IF NOT EXISTS anamnesis (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  version INTEGER NOT NULL DEFAULT 1,
  content TEXT NOT NULL,
  type TEXT CHECK (type IN ('AI', 'MODIFIED', 'MANUAL')) DEFAULT 'AI',
  transcription TEXT,
  recording_duration INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour anamnesis
CREATE INDEX IF NOT EXISTS idx_anamnesis_patient ON anamnesis(patient_id);
CREATE INDEX IF NOT EXISTS idx_anamnesis_version ON anamnesis(patient_id, version DESC);

-- ================================================
-- TABLE: appointments (Rendez-vous)
-- ================================================
CREATE TABLE IF NOT EXISTS appointments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  appointment_date DATE NOT NULL,
  appointment_time TIME NOT NULL,
  duration INTEGER DEFAULT 30,
  type TEXT,
  status TEXT CHECK (status IN ('scheduled', 'confirmed', 'completed', 'cancelled', 'no-show')) DEFAULT 'scheduled',
  notes TEXT,
  created_by UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour appointments
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_appointments_patient ON appointments(patient_id);

-- ================================================
-- TABLE: dental_charts (Schémas dentaires)
-- ================================================
CREATE TABLE IF NOT EXISTS dental_charts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID UNIQUE NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  chart_data JSONB DEFAULT '{}',
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================================
-- TABLE: tooth_treatments (Traitements par dent)
-- ================================================
CREATE TABLE IF NOT EXISTS tooth_treatments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  tooth_number INTEGER NOT NULL,
  treatment_type TEXT NOT NULL,
  treatment_date DATE NOT NULL,
  notes TEXT,
  cost DECIMAL(10, 2),
  created_by UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour tooth_treatments
CREATE INDEX IF NOT EXISTS idx_tooth_treatments_patient ON tooth_treatments(patient_id);
CREATE INDEX IF NOT EXISTS idx_tooth_treatments_date ON tooth_treatments(treatment_date);

-- ================================================
-- TABLE: timeline_events (Timeline patient)
-- ================================================
CREATE TABLE IF NOT EXISTS timeline_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  event_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  badge TEXT,
  related_id UUID,
  related_type TEXT,
  created_by UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour timeline_events
CREATE INDEX IF NOT EXISTS idx_timeline_patient ON timeline_events(patient_id);
CREATE INDEX IF NOT EXISTS idx_timeline_date ON timeline_events(event_date DESC);

-- ================================================
-- TABLE: inami_acts (Actes INAMI)
-- ================================================
CREATE TABLE IF NOT EXISTS inami_acts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  act_code TEXT NOT NULL,
  act_description TEXT NOT NULL,
  act_date DATE NOT NULL,
  tooth_number TEXT,
  quantity INTEGER DEFAULT 1,
  cost DECIMAL(10, 2),
  reimbursement DECIMAL(10, 2),
  status TEXT CHECK (status IN ('draft', 'submitted', 'approved', 'rejected')) DEFAULT 'draft',
  created_by UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour inami_acts
CREATE INDEX IF NOT EXISTS idx_inami_acts_patient ON inami_acts(patient_id);
CREATE INDEX IF NOT EXISTS idx_inami_acts_date ON inami_acts(act_date);

-- ================================================
-- TABLE: prescriptions (Ordonnances)
-- ================================================
CREATE TABLE IF NOT EXISTS prescriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  prescription_date DATE NOT NULL,
  medications JSONB NOT NULL,
  diagnosis TEXT,
  notes TEXT,
  prescriber_name TEXT,
  prescriber_inami TEXT,
  created_by UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour prescriptions
CREATE INDEX IF NOT EXISTS idx_prescriptions_patient ON prescriptions(patient_id);
CREATE INDEX IF NOT EXISTS idx_prescriptions_date ON prescriptions(prescription_date);

-- ================================================
-- TABLE: certificates (Attestations)
-- ================================================
CREATE TABLE IF NOT EXISTS certificates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  certificate_date DATE NOT NULL,
  certificate_type TEXT NOT NULL,
  content TEXT NOT NULL,
  valid_from DATE,
  valid_until DATE,
  created_by UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour certificates
CREATE INDEX IF NOT EXISTS idx_certificates_patient ON certificates(patient_id);
CREATE INDEX IF NOT EXISTS idx_certificates_date ON certificates(certificate_date);

-- ================================================
-- TABLE: xrays (Radiographies)
-- ================================================
CREATE TABLE IF NOT EXISTS xrays (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  xray_date DATE NOT NULL,
  xray_type TEXT NOT NULL,
  tooth_number TEXT,
  file_url TEXT,
  notes TEXT,
  created_by UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour xrays
CREATE INDEX IF NOT EXISTS idx_xrays_patient ON xrays(patient_id);
CREATE INDEX IF NOT EXISTS idx_xrays_date ON xrays(xray_date);

-- ================================================
-- TRIGGERS
-- ================================================

-- Trigger pour updated_at sur users
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_patients_updated_at
    BEFORE UPDATE ON patients
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointments_updated_at
    BEFORE UPDATE ON appointments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger pour auto-incrémenter version dans medical_history
CREATE OR REPLACE FUNCTION increment_medical_history_version()
RETURNS TRIGGER AS $$
BEGIN
    NEW.version := COALESCE(
        (SELECT MAX(version) + 1 FROM medical_history WHERE patient_id = NEW.patient_id),
        1
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_increment_medical_history_version
    BEFORE INSERT ON medical_history
    FOR EACH ROW
    EXECUTE FUNCTION increment_medical_history_version();

-- Trigger pour auto-incrémenter version dans anamnesis
CREATE OR REPLACE FUNCTION increment_anamnesis_version()
RETURNS TRIGGER AS $$
BEGIN
    NEW.version := COALESCE(
        (SELECT MAX(version) + 1 FROM anamnesis WHERE patient_id = NEW.patient_id),
        1
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_increment_anamnesis_version
    BEFORE INSERT ON anamnesis
    FOR EACH ROW
    EXECUTE FUNCTION increment_anamnesis_version();

-- ================================================
-- FONCTION: Créer version medical_history
-- ================================================
CREATE OR REPLACE FUNCTION create_medical_history_version(
    p_patient_id UUID,
    p_allergies JSONB DEFAULT '[]',
    p_medications JSONB DEFAULT '[]',
    p_medical_conditions JSONB DEFAULT '[]',
    p_surgical_history JSONB DEFAULT '[]',
    p_dental_concerns TEXT DEFAULT NULL,
    p_previous_dental_treatments JSONB DEFAULT '[]',
    p_dental_anxiety_level INTEGER DEFAULT NULL,
    p_brushing_frequency TEXT DEFAULT NULL,
    p_flossing_frequency TEXT DEFAULT NULL,
    p_mouthwash_use BOOLEAN DEFAULT false,
    p_practitioner_notes TEXT DEFAULT NULL,
    p_created_by UUID DEFAULT '00000000-0000-0000-0000-000000000000'
)
RETURNS UUID AS $$
DECLARE
    new_id UUID;
BEGIN
    INSERT INTO medical_history (
        patient_id,
        allergies,
        medications,
        medical_conditions,
        surgical_history,
        dental_concerns,
        previous_dental_treatments,
        dental_anxiety_level,
        brushing_frequency,
        flossing_frequency,
        mouthwash_use,
        practitioner_notes,
        created_by
    ) VALUES (
        p_patient_id,
        p_allergies,
        p_medications,
        p_medical_conditions,
        p_surgical_history,
        p_dental_concerns,
        p_previous_dental_treatments,
        p_dental_anxiety_level,
        p_brushing_frequency,
        p_flossing_frequency,
        p_mouthwash_use,
        p_practitioner_notes,
        p_created_by
    ) RETURNING id INTO new_id;

    RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- ================================================
-- VIEW: patient_complete_view
-- ================================================
CREATE OR REPLACE VIEW patient_complete_view AS
SELECT
    p.*,
    mh.allergies AS latest_allergies,
    mh.medications AS latest_medications,
    mh.medical_conditions AS latest_medical_conditions,
    mh.dental_concerns AS latest_dental_concerns
FROM patients p
LEFT JOIN LATERAL (
    SELECT * FROM medical_history
    WHERE patient_id = p.id
    ORDER BY version DESC
    LIMIT 1
) mh ON true;

-- ================================================
-- ROW LEVEL SECURITY (RLS)
-- ================================================

-- Activer RLS sur toutes les tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE anamnesis ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE dental_charts ENABLE ROW LEVEL SECURITY;
ALTER TABLE tooth_treatments ENABLE ROW LEVEL SECURITY;
ALTER TABLE timeline_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE inami_acts ENABLE ROW LEVEL SECURITY;
ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE xrays ENABLE ROW LEVEL SECURITY;

-- Politiques RLS pour users
CREATE POLICY "Users can read all profiles"
    ON users FOR SELECT
    USING (true);

CREATE POLICY "Only admins can modify users"
    ON users FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE username = current_user
            AND role = 'Administrateur'
        )
    );

-- Politiques RLS pour les autres tables (lecture publique, modification authentifiée)
CREATE POLICY "Public read access" ON patients FOR SELECT USING (true);
CREATE POLICY "Authenticated users can modify" ON patients FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Public read access" ON medical_history FOR SELECT USING (true);
CREATE POLICY "Authenticated users can modify" ON medical_history FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Public read access" ON anamnesis FOR SELECT USING (true);
CREATE POLICY "Authenticated users can modify" ON anamnesis FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Public read access" ON appointments FOR SELECT USING (true);
CREATE POLICY "Authenticated users can modify" ON appointments FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Public read access" ON dental_charts FOR SELECT USING (true);
CREATE POLICY "Authenticated users can modify" ON dental_charts FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Public read access" ON tooth_treatments FOR SELECT USING (true);
CREATE POLICY "Authenticated users can modify" ON tooth_treatments FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Public read access" ON timeline_events FOR SELECT USING (true);
CREATE POLICY "Authenticated users can modify" ON timeline_events FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Public read access" ON inami_acts FOR SELECT USING (true);
CREATE POLICY "Authenticated users can modify" ON inami_acts FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Public read access" ON prescriptions FOR SELECT USING (true);
CREATE POLICY "Authenticated users can modify" ON prescriptions FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Public read access" ON certificates FOR SELECT USING (true);
CREATE POLICY "Authenticated users can modify" ON certificates FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Public read access" ON xrays FOR SELECT USING (true);
CREATE POLICY "Authenticated users can modify" ON xrays FOR ALL USING (auth.role() = 'authenticated');

-- ================================================
-- DONNÉES DE TEST - PATIENTS
-- ================================================

-- Patient 1: Jean Dupont
INSERT INTO patients (id, first_name, last_name, date_of_birth, gender, niss, phone, email, address, city, postal_code, mutuelle)
VALUES (
    '11111111-1111-1111-1111-111111111111',
    'Jean',
    'Dupont',
    '1985-03-15',
    'M',
    '85.03.15-123.45',
    '+32 475 12 34 56',
    'jean.dupont@email.be',
    'Rue de la Santé 123',
    'Bruxelles',
    '1000',
    'Mutualité Chrétienne'
) ON CONFLICT (id) DO NOTHING;

-- Patient 2: Marie Martin
INSERT INTO patients (id, first_name, last_name, date_of_birth, gender, niss, phone, email, address, city, postal_code, mutuelle)
VALUES (
    '22222222-2222-2222-2222-222222222222',
    'Marie',
    'Martin',
    '1990-07-22',
    'F',
    '90.07.22-234.56',
    '+32 476 23 45 67',
    'marie.martin@email.be',
    'Avenue des Dents 45',
    'Liège',
    '4000',
    'Mutualité Socialiste'
) ON CONFLICT (id) DO NOTHING;

-- Patient 3: Pierre Dubois
INSERT INTO patients (id, first_name, last_name, date_of_birth, gender, niss, phone, email, address, city, postal_code, mutuelle)
VALUES (
    '33333333-3333-3333-3333-333333333333',
    'Pierre',
    'Dubois',
    '1978-11-05',
    'M',
    '78.11.05-345.67',
    '+32 477 34 56 78',
    'pierre.dubois@email.be',
    'Boulevard du Sourire 78',
    'Gand',
    '9000',
    'Mutualité Libérale'
) ON CONFLICT (id) DO NOTHING;

-- ================================================
-- DONNÉES DE TEST - MEDICAL HISTORY
-- ================================================

INSERT INTO medical_history (patient_id, allergies, medications, medical_conditions, dental_anxiety_level, brushing_frequency, flossing_frequency)
VALUES (
    '11111111-1111-1111-1111-111111111111',
    '["Pénicilline", "Latex"]'::jsonb,
    '["Aspirine 100mg"]'::jsonb,
    '["Hypertension"]'::jsonb,
    3,
    '2 fois par jour',
    'Rarement'
) ON CONFLICT DO NOTHING;

INSERT INTO medical_history (patient_id, allergies, medications, medical_conditions, dental_anxiety_level, brushing_frequency, flossing_frequency)
VALUES (
    '22222222-2222-2222-2222-222222222222',
    '[]'::jsonb,
    '[]'::jsonb,
    '[]'::jsonb,
    5,
    '2 fois par jour',
    'Quotidiennement'
) ON CONFLICT DO NOTHING;

-- ================================================
-- DONNÉES DE TEST - APPOINTMENTS
-- ================================================

-- Rendez-vous aujourd'hui
INSERT INTO appointments (patient_id, appointment_date, appointment_time, duration, type, status)
VALUES (
    '11111111-1111-1111-1111-111111111111',
    CURRENT_DATE,
    '10:00',
    30,
    'Contrôle',
    'confirmed'
) ON CONFLICT DO NOTHING;

INSERT INTO appointments (patient_id, appointment_date, appointment_time, duration, type, status)
VALUES (
    '22222222-2222-2222-2222-222222222222',
    CURRENT_DATE,
    '14:30',
    60,
    'Détartrage',
    'scheduled'
) ON CONFLICT DO NOTHING;

-- ================================================
-- COMMENTAIRES
-- ================================================

COMMENT ON TABLE users IS 'Utilisateurs avec authentification hashée';
COMMENT ON TABLE patients IS 'Patients du cabinet dentaire';
COMMENT ON TABLE medical_history IS 'Historique médical versionné des patients';
COMMENT ON TABLE anamnesis IS 'Anamnèses versionnées générées par IA ou manuelles';
COMMENT ON TABLE appointments IS 'Rendez-vous patients';
COMMENT ON TABLE dental_charts IS 'Schémas dentaires (JSONB)';
COMMENT ON TABLE tooth_treatments IS 'Traitements par dent';
COMMENT ON TABLE timeline_events IS 'Timeline des événements patient';
COMMENT ON TABLE inami_acts IS 'Actes INAMI pour facturation';
COMMENT ON TABLE prescriptions IS 'Ordonnances médicamenteuses';
COMMENT ON TABLE certificates IS 'Attestations médicales';
COMMENT ON TABLE xrays IS 'Radiographies et imagerie';

-- ================================================
-- FIN DU SCRIPT
-- ================================================

SELECT 'Database setup completed successfully!' AS status;

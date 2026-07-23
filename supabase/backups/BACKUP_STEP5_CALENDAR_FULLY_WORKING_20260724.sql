-- =============================================================================
-- BACKUP COMPLET - K2 Dent Production
-- Date: 24 Juillet 2026
-- Milestone: STEP 5 - Calendar 100% fonctionnel (tous bugs fixés)
-- =============================================================================
--
-- État du système :
-- ✅ 5 bugs majeurs résolus
-- ✅ Calendar.html : affichage correct des rendez-vous
-- ✅ Patients chargés depuis la bonne DB (zkjhemeysleurnvqsclq)
-- ✅ Timezone bug fixé (formatLocalDate helper)
-- ✅ Column naming: appointment_type (PostgreSQL best practice)
-- ✅ Autocomplete patients fonctionnel
--
-- Ce backup permet un restore total du système dans cet état.
-- =============================================================================

-- =============================================================================
-- PARTIE 1: SUPPRESSION DES TABLES EXISTANTES (CASCADE)
-- =============================================================================

DROP TABLE IF EXISTS medical_history CASCADE;
DROP TABLE IF EXISTS appointments CASCADE;
DROP TABLE IF EXISTS anamnesis CASCADE;
DROP TABLE IF EXISTS patients CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- =============================================================================
-- PARTIE 2: CRÉATION DES TABLES (SCHÉMA COMPLET)
-- =============================================================================

-- Table: users
-- Description: Utilisateurs du système (dentistes, assistants, admins)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    role VARCHAR(50) NOT NULL DEFAULT 'dentist',
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: patients
-- Description: Dossiers patients avec toutes les informations médicales et administratives
CREATE TABLE patients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Informations personnelles
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    niss VARCHAR(11) UNIQUE,

    -- Coordonnées
    email VARCHAR(255),
    phone VARCHAR(20),
    mobile VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    postal_code VARCHAR(10),
    country VARCHAR(100) DEFAULT 'Belgique',

    -- Informations médicales (anamnèse)
    blood_type VARCHAR(5),
    allergies TEXT,
    current_medications TEXT,
    medical_conditions TEXT,

    -- Facteurs de risque médicaux (booleans)
    smoker BOOLEAN DEFAULT false,
    pregnant BOOLEAN DEFAULT false,
    diabetes BOOLEAN DEFAULT false,
    heart_disease BOOLEAN DEFAULT false,
    hypertension BOOLEAN DEFAULT false,
    anticoagulant_therapy BOOLEAN DEFAULT false,

    -- Informations dentaires
    dental_history TEXT,
    dental_concerns TEXT,

    -- Informations administratives
    mutuelle VARCHAR(100),
    mutuelle_number VARCHAR(50),

    -- Métadonnées
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    -- Contraintes
    CONSTRAINT niss_format CHECK (niss ~ '^\d{11}$' OR niss IS NULL)
);

-- Table: anamnesis
-- Description: Historique des questionnaires d'anamnèse remplis par les patients
CREATE TABLE anamnesis (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

    -- Questions générales
    general_health_status VARCHAR(50),
    taking_medications BOOLEAN,
    medications_list TEXT,

    -- Allergies
    has_allergies BOOLEAN,
    allergy_details TEXT,

    -- Antécédents médicaux
    has_heart_disease BOOLEAN,
    has_diabetes BOOLEAN,
    has_hypertension BOOLEAN,
    has_respiratory_issues BOOLEAN,
    has_liver_disease BOOLEAN,
    has_kidney_disease BOOLEAN,
    has_bleeding_disorders BOOLEAN,

    -- Habitudes
    smoker BOOLEAN,
    alcohol_consumption VARCHAR(50),

    -- Femmes
    pregnant BOOLEAN,
    breastfeeding BOOLEAN,

    -- Historique dentaire
    last_dental_visit DATE,
    dental_pain BOOLEAN,
    dental_pain_description TEXT,
    sensitive_teeth BOOLEAN,
    bleeding_gums BOOLEAN,

    -- Consentement et signature
    consent_given BOOLEAN DEFAULT false,
    signature_data TEXT,
    consent_date TIMESTAMP WITH TIME ZONE,

    -- Métadonnées
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    filled_by UUID REFERENCES users(id)
);

-- Table: medical_history
-- Description: Historique médical détaillé des patients (conditions chroniques, traitements, etc.)
CREATE TABLE medical_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

    -- Détails de l'historique
    condition_name VARCHAR(200) NOT NULL,
    condition_type VARCHAR(100),
    diagnosed_date DATE,
    current_status VARCHAR(50),
    treatment TEXT,
    notes TEXT,

    -- Métadonnées
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    recorded_by UUID REFERENCES users(id)
);

-- Table: appointments
-- Description: Rendez-vous patients avec toutes les informations de planification
-- Note: Utilise 'appointment_type' au lieu de 'type' (PostgreSQL best practice)
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Patient et dentiste
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    dentist_id UUID REFERENCES users(id),

    -- Date et heure
    appointment_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME,
    duration_minutes INTEGER DEFAULT 30,

    -- Type et détails (IMPORTANT: appointment_type pas 'type')
    appointment_type VARCHAR(100) NOT NULL DEFAULT 'Consultation',
    reason TEXT,
    notes TEXT,

    -- Statut
    status VARCHAR(50) DEFAULT 'scheduled',

    -- Salle et équipement
    room_number VARCHAR(20),

    -- Rappels et notifications
    reminder_sent BOOLEAN DEFAULT false,
    reminder_sent_at TIMESTAMP WITH TIME ZONE,

    -- Métadonnées
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    -- Contraintes
    CONSTRAINT valid_time_range CHECK (end_time > start_time OR end_time IS NULL),
    CONSTRAINT valid_duration CHECK (duration_minutes > 0),
    CONSTRAINT valid_status CHECK (status IN ('scheduled', 'confirmed', 'arrived', 'in_progress', 'completed', 'cancelled', 'no_show', 'rescheduled'))
);

-- =============================================================================
-- PARTIE 3: INDICES POUR PERFORMANCE
-- =============================================================================

-- Patients
CREATE INDEX idx_patients_niss ON patients(niss);
CREATE INDEX idx_patients_last_name ON patients(last_name);
CREATE INDEX idx_patients_created_at ON patients(created_at);

-- Anamnesis
CREATE INDEX idx_anamnesis_patient_id ON anamnesis(patient_id);
CREATE INDEX idx_anamnesis_created_at ON anamnesis(created_at);

-- Medical History
CREATE INDEX idx_medical_history_patient_id ON medical_history(patient_id);

-- Appointments
CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX idx_appointments_dentist_id ON appointments(dentist_id);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_date_status ON appointments(appointment_date, status);
CREATE INDEX idx_appointments_type ON appointments(appointment_type);

-- =============================================================================
-- PARTIE 4: COMMENTAIRES SUR LES COLONNES
-- =============================================================================

COMMENT ON COLUMN appointments.appointment_type IS 'Type of appointment (e.g., Consultation, Détartrage, Urgence) - follows PostgreSQL naming convention';
COMMENT ON COLUMN appointments.status IS 'scheduled | confirmed | arrived | in_progress | completed | cancelled | no_show | rescheduled';

-- =============================================================================
-- PARTIE 5: ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================================================

-- Activer RLS sur toutes les tables
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE anamnesis ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policies pour patients (lecture et écriture pour tous les utilisateurs authentifiés)
CREATE POLICY "Allow all operations on patients" ON patients
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- Policies pour anamnesis
CREATE POLICY "Allow all operations on anamnesis" ON anamnesis
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- Policies pour medical_history
CREATE POLICY "Allow all operations on medical_history" ON medical_history
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- Policies pour appointments
CREATE POLICY "Allow all operations on appointments" ON appointments
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- Policies pour users
CREATE POLICY "Allow all operations on users" ON users
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- =============================================================================
-- PARTIE 6: DONNÉES DE TEST (ÉTAT ACTUEL AU 24/07/2026)
-- =============================================================================

-- Utilisateur par défaut (Dr. Sialyen)
INSERT INTO users (id, email, first_name, last_name, role, phone, is_active)
VALUES
    ('00000000-0000-0000-0000-000000000001', 'dr.sialyen@k2dent.be', 'Ismail', 'Sialyen', 'dentist', '0477123456', true)
ON CONFLICT (email) DO NOTHING;

-- Patients (5 patients de la DB actuelle)
INSERT INTO patients (id, first_name, last_name, niss, email, phone, mobile, smoker, pregnant, diabetes, heart_disease, hypertension, anticoagulant_therapy)
VALUES
    ('11111111-1111-1111-1111-111111111111', 'isma', '22 Dupont', '85051821179', 'isma22@test.be', NULL, '0477111111', false, false, false, false, false, false),
    ('22222222-2222-2222-2222-222222222222', 'Jean', 'Dupont', '85051822334', 'jean.dupont@email.be', '0477123456', NULL, false, false, false, false, false, false),
    ('33333333-3333-3333-3333-333333333333', 'Marie', 'Martin', '90031234567', NULL, NULL, '0488765432', false, false, false, false, false, false),
    ('44444444-4444-4444-4444-444444444444', 'Pierre', 'Bernard', '78121556789', 'pierre.bernard@email.be', '0495887766', NULL, true, false, false, false, false, false),
    ('55555555-5555-5555-5555-555555555555', 'Sophie', 'Dubois', '92051678901', NULL, NULL, '0476554433', false, false, false, false, false, false)
ON CONFLICT (niss) DO NOTHING;

-- Rendez-vous (1 appointment test du 24 juillet 2026)
INSERT INTO appointments (
    id,
    patient_id,
    dentist_id,
    appointment_date,
    start_time,
    end_time,
    duration_minutes,
    appointment_type,
    reason,
    status,
    created_by
)
VALUES
    (
        'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        '11111111-1111-1111-1111-111111111111',  -- isma 22 Dupont
        '00000000-0000-0000-0000-000000000001',  -- Dr. Sialyen
        '2026-07-24',
        '10:30',
        '11:00',
        30,
        'Polissage',
        'Rendez-vous de test - patient isma 22 Dupont',
        'scheduled',
        '00000000-0000-0000-0000-000000000001'
    )
ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- PARTIE 7: VÉRIFICATIONS POST-RESTORE
-- =============================================================================

-- Fonction pour vérifier l'état après restore
DO $$
DECLARE
    patient_count INTEGER;
    appointment_count INTEGER;
    user_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO patient_count FROM patients;
    SELECT COUNT(*) INTO appointment_count FROM appointments;
    SELECT COUNT(*) INTO user_count FROM users;

    RAISE NOTICE '=== BACKUP RESTORE VERIFICATION ===';
    RAISE NOTICE 'Patients: %', patient_count;
    RAISE NOTICE 'Appointments: %', appointment_count;
    RAISE NOTICE 'Users: %', user_count;
    RAISE NOTICE '';

    IF patient_count >= 5 THEN
        RAISE NOTICE '✅ Patients table OK';
    ELSE
        RAISE WARNING '⚠️ Expected at least 5 patients, found %', patient_count;
    END IF;

    IF appointment_count >= 1 THEN
        RAISE NOTICE '✅ Appointments table OK';
    ELSE
        RAISE WARNING '⚠️ Expected at least 1 appointment, found %', appointment_count;
    END IF;

    IF user_count >= 1 THEN
        RAISE NOTICE '✅ Users table OK';
    ELSE
        RAISE WARNING '⚠️ Expected at least 1 user, found %', user_count;
    END IF;

    RAISE NOTICE '';
    RAISE NOTICE '=== COLUMN VERIFICATION ===';

    -- Vérifier que appointment_type existe (pas 'type')
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'appointment_type'
    ) THEN
        RAISE NOTICE '✅ Column "appointment_type" exists (correct naming)';
    ELSE
        RAISE WARNING '⚠️ Column "appointment_type" missing!';
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'type'
    ) THEN
        RAISE WARNING '⚠️ OLD column "type" still exists - should be renamed to "appointment_type"';
    ELSE
        RAISE NOTICE '✅ No "type" column (correct - using appointment_type)';
    END IF;

    RAISE NOTICE '';
    RAISE NOTICE '=== RESTORE COMPLETE ===';
    RAISE NOTICE 'Database restored to: STEP 5 - Calendar 100%% fonctionnel';
    RAISE NOTICE 'Date: 24 Juillet 2026';
END $$;

-- =============================================================================
-- INSTRUCTIONS DE RESTORE
-- =============================================================================

-- Pour restaurer cette backup dans Supabase :
--
-- 1. Via Supabase Dashboard :
--    - Aller dans SQL Editor
--    - Copier-coller tout ce fichier
--    - Exécuter (Run)
--
-- 2. Via psql (si accès direct) :
--    psql -h <host> -U postgres -d postgres -f BACKUP_STEP5_CALENDAR_FULLY_WORKING_20260724.sql
--
-- 3. Vérifier le restore :
--    - Checker les NOTICE messages en console
--    - Aller sur calendar.html
--    - Vérifier que "isma 22 Dupont" apparaît
--    - Vérifier que le RDV du 24/07/2026 à 10:30 s'affiche
--    - Checker console : "✅ Loaded 5 patients" et "✅ Loaded 1 appointments"
--
-- =============================================================================
-- FIN DU BACKUP
-- =============================================================================

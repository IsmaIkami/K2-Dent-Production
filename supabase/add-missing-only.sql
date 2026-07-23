-- ============================================
-- K2 DENT - AJOUT UNIQUEMENT CE QUI MANQUE
-- ============================================
-- Script minimal qui ajoute SEULEMENT les éléments manquants
-- Sans toucher aux tables existantes
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. CRÉER TABLE USERS (si n'existe pas)
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
-- 2. AJOUTER COLONNES MANQUANTES À APPOINTMENTS
-- ============================================

DO $$
BEGIN
    -- Ajouter start_time si manquant
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'start_time'
    ) THEN
        ALTER TABLE appointments ADD COLUMN start_time TIME;
        RAISE NOTICE '✅ Colonne start_time ajoutée à appointments';
    ELSE
        RAISE NOTICE 'ℹ️  Colonne start_time existe déjà';
    END IF;

    -- Ajouter end_time si manquant
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'end_time'
    ) THEN
        ALTER TABLE appointments ADD COLUMN end_time TIME;
        RAISE NOTICE '✅ Colonne end_time ajoutée à appointments';
    ELSE
        RAISE NOTICE 'ℹ️  Colonne end_time existe déjà';
    END IF;
END $$;

-- ============================================
-- 3. ACTIVER RLS SUR TOUTES LES TABLES
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 4. CRÉER POLICIES (DROP + CREATE pour éviter erreurs)
-- ============================================

-- Users policies
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

-- Patients policies
DROP POLICY IF EXISTS "Allow all for authenticated users" ON patients;
CREATE POLICY "Allow all for authenticated users"
ON patients FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Appointments policies
DROP POLICY IF EXISTS "Allow all for authenticated users" ON appointments;
CREATE POLICY "Allow all for authenticated users"
ON appointments FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- 5. CRÉER INDEXES POUR APPOINTMENTS
-- ============================================

CREATE INDEX IF NOT EXISTS idx_appointments_patient ON appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date, start_time);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);

-- ============================================
-- 6. CRÉER FONCTION ET TRIGGERS updated_at
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour users
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger pour patients (si colonne updated_at existe)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'patients' AND column_name = 'updated_at'
    ) THEN
        DROP TRIGGER IF EXISTS update_patients_updated_at ON patients;
        CREATE TRIGGER update_patients_updated_at
          BEFORE UPDATE ON patients
          FOR EACH ROW
          EXECUTE FUNCTION update_updated_at_column();
        RAISE NOTICE '✅ Trigger updated_at créé pour patients';
    END IF;
END $$;

-- Trigger pour appointments (si colonne updated_at existe)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'updated_at'
    ) THEN
        DROP TRIGGER IF EXISTS update_appointments_updated_at ON appointments;
        CREATE TRIGGER update_appointments_updated_at
          BEFORE UPDATE ON appointments
          FOR EACH ROW
          EXECUTE FUNCTION update_updated_at_column();
        RAISE NOTICE '✅ Trigger updated_at créé pour appointments';
    END IF;
END $$;

-- ============================================
-- 7. GRANTS
-- ============================================

GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;

-- ============================================
-- RAPPORT FINAL
-- ============================================

DO $$
DECLARE
    users_exists BOOLEAN;
    start_time_exists BOOLEAN;
    end_time_exists BOOLEAN;
BEGIN
    -- Vérifier table users
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_name = 'users'
    ) INTO users_exists;

    -- Vérifier colonnes appointments
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'start_time'
    ) INTO start_time_exists;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'end_time'
    ) INTO end_time_exists;

    RAISE NOTICE '';
    RAISE NOTICE '════════════════════════════════════════════════════';
    RAISE NOTICE '✅ K2 DENT - MIGRATION MINIMALE TERMINÉE';
    RAISE NOTICE '════════════════════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE '📊 VÉRIFICATIONS:';

    IF users_exists THEN
        RAISE NOTICE '   ✅ Table users existe';
    ELSE
        RAISE NOTICE '   ❌ Table users MANQUANTE';
    END IF;

    IF start_time_exists THEN
        RAISE NOTICE '   ✅ Colonne appointments.start_time existe';
    ELSE
        RAISE NOTICE '   ❌ Colonne appointments.start_time MANQUANTE';
    END IF;

    IF end_time_exists THEN
        RAISE NOTICE '   ✅ Colonne appointments.end_time existe';
    ELSE
        RAISE NOTICE '   ❌ Colonne appointments.end_time MANQUANTE';
    END IF;

    RAISE NOTICE '';
    RAISE NOTICE '🔒 RLS: ACTIVÉ sur users, patients, appointments';
    RAISE NOTICE '⚡ Triggers: Configurés';
    RAISE NOTICE '';
    RAISE NOTICE '════════════════════════════════════════════════════';
    RAISE NOTICE 'PROCHAINES ÉTAPES:';
    RAISE NOTICE '════════════════════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE '1. curl -X POST https://k2-dent-production-production.up.railway.app/api/auth/seed-users';
    RAISE NOTICE '2. Login: Dr. Sialyen / dentalcockpitk2';
    RAISE NOTICE '3. Vérifier dashboard';
    RAISE NOTICE '';
    RAISE NOTICE '════════════════════════════════════════════════════';
END $$;

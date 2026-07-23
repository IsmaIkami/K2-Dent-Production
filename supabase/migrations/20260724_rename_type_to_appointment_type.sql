-- =============================================================================
-- RENAME type TO appointment_type (SQL best practice)
-- Version: 1.0
-- Description: Renomme la colonne 'type' en 'appointment_type' pour suivre
--              les conventions PostgreSQL et éviter l'ambiguïté
-- =============================================================================

-- Rename type to appointment_type
DO $$
BEGIN
    -- Case 1: If 'type' exists and 'appointment_type' doesn't, rename it
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'type'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'appointment_type'
    ) THEN
        ALTER TABLE appointments RENAME COLUMN type TO appointment_type;
        RAISE NOTICE 'Renamed type to appointment_type';
    END IF;

    -- Case 2: If both exist, drop 'type' and keep 'appointment_type'
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'type'
    ) AND EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'appointment_type'
    ) THEN
        -- Copy data from type to appointment_type if appointment_type is NULL
        UPDATE appointments
        SET appointment_type = type
        WHERE appointment_type IS NULL AND type IS NOT NULL;

        -- Drop the old 'type' column
        ALTER TABLE appointments DROP COLUMN type;
        RAISE NOTICE 'Dropped redundant type column, kept appointment_type';
    END IF;

    -- Ensure appointment_type is NOT NULL
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'appointment_type'
    ) THEN
        -- Set default for any NULL values first
        UPDATE appointments SET appointment_type = 'Consultation' WHERE appointment_type IS NULL;

        -- Make it NOT NULL
        ALTER TABLE appointments ALTER COLUMN appointment_type SET NOT NULL;
        RAISE NOTICE 'Set appointment_type as NOT NULL';
    END IF;
END $$;

-- Update comment
COMMENT ON COLUMN appointments.appointment_type IS 'Type of appointment (e.g., Consultation, Détartrage, Urgence) - follows PostgreSQL naming convention';

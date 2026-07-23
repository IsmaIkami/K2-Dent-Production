-- =============================================================================
-- RENAME appointment_type TO type (matching schema.sql)
-- Version: 1.0
-- Description: Renomme appointment_type en type pour matcher le schéma officiel
-- =============================================================================

-- Check if appointment_type column exists and rename it to type
DO $$
BEGIN
    -- If appointment_type exists but type doesn't, rename it
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'appointment_type'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'type'
    ) THEN
        ALTER TABLE appointments RENAME COLUMN appointment_type TO type;
        RAISE NOTICE 'Renamed appointment_type to type';
    END IF;

    -- If type doesn't exist yet (fresh table), create it
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'type'
    ) THEN
        ALTER TABLE appointments ADD COLUMN type VARCHAR(100);
        UPDATE appointments SET type = 'Consultation' WHERE type IS NULL;
        ALTER TABLE appointments ALTER COLUMN type SET NOT NULL;
        RAISE NOTICE 'Added type column';
    END IF;

    -- Ensure type is NOT NULL with proper default
    -- First set a default for any existing NULL values
    UPDATE appointments SET type = 'Consultation' WHERE type IS NULL;

    -- Then make it NOT NULL
    ALTER TABLE appointments ALTER COLUMN type SET NOT NULL;
END $$;

COMMENT ON COLUMN appointments.type IS 'Type of appointment (e.g., Consultation, Détartrage, Urgence)';

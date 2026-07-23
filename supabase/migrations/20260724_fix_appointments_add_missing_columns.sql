-- =============================================================================
-- ADD MISSING COLUMNS TO APPOINTMENTS TABLE
-- Version: 1.0
-- Description: Ajoute les colonnes manquantes (type, duration_minutes, etc.)
-- =============================================================================

-- Add type column (REQUIRED)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'type'
    ) THEN
        ALTER TABLE appointments ADD COLUMN type VARCHAR(100);
        -- Set default value for existing rows
        UPDATE appointments SET type = 'Consultation' WHERE type IS NULL;
        -- Make it NOT NULL after setting defaults
        ALTER TABLE appointments ALTER COLUMN type SET NOT NULL;
    END IF;
END $$;

-- Add duration_minutes column (REQUIRED)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'duration_minutes'
    ) THEN
        ALTER TABLE appointments ADD COLUMN duration_minutes INTEGER;
        -- Calculate from start_time and end_time if they exist
        UPDATE appointments
        SET duration_minutes = EXTRACT(EPOCH FROM (end_time - start_time)) / 60
        WHERE start_time IS NOT NULL AND end_time IS NOT NULL;
        -- Default 30 min for rows without times
        UPDATE appointments SET duration_minutes = 30 WHERE duration_minutes IS NULL;
        -- Make it NOT NULL
        ALTER TABLE appointments ALTER COLUMN duration_minutes SET NOT NULL;
    END IF;
END $$;

-- Add reason column (optional)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'reason'
    ) THEN
        ALTER TABLE appointments ADD COLUMN reason TEXT;
    END IF;
END $$;

-- Add reminder fields
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'reminder_sent'
    ) THEN
        ALTER TABLE appointments ADD COLUMN reminder_sent BOOLEAN DEFAULT FALSE;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'reminder_sent_date'
    ) THEN
        ALTER TABLE appointments ADD COLUMN reminder_sent_date TIMESTAMP WITH TIME ZONE;
    END IF;
END $$;

-- Add practitioner_id
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'practitioner_id'
    ) THEN
        ALTER TABLE appointments ADD COLUMN practitioner_id UUID;
    END IF;
END $$;

-- Add cancellation fields
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'created_by'
    ) THEN
        ALTER TABLE appointments ADD COLUMN created_by UUID;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'cancelled_at'
    ) THEN
        ALTER TABLE appointments ADD COLUMN cancelled_at TIMESTAMP WITH TIME ZONE;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'appointments' AND column_name = 'cancellation_reason'
    ) THEN
        ALTER TABLE appointments ADD COLUMN cancellation_reason TEXT;
    END IF;
END $$;

-- Add status constraint if it doesn't exist
DO $$
BEGIN
    -- Drop existing constraint if any
    ALTER TABLE appointments DROP CONSTRAINT IF EXISTS appointments_status_check;

    -- Add proper constraint
    ALTER TABLE appointments ADD CONSTRAINT appointments_status_check
    CHECK (status IN ('scheduled', 'confirmed', 'arrived', 'in_progress', 'completed', 'cancelled', 'no_show'));
EXCEPTION
    WHEN OTHERS THEN NULL;
END $$;

-- Comments
COMMENT ON COLUMN appointments.type IS 'Type of appointment (e.g., Consultation, Détartrage, Urgence)';
COMMENT ON COLUMN appointments.duration_minutes IS 'Duration of appointment in minutes';
COMMENT ON COLUMN appointments.reason IS 'Reason for the appointment';

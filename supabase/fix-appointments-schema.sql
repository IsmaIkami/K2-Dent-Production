-- Fix appointments table schema
-- Add missing start_time column

-- Check if appointments table exists, if not create it
CREATE TABLE IF NOT EXISTS appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
    appointment_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    status TEXT DEFAULT 'scheduled',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- If table exists but column doesn't, add it
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

-- Add index for faster queries
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_appointments_patient ON appointments(patient_id);

-- Enable RLS
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Allow all operations for authenticated users
CREATE POLICY IF NOT EXISTS "Allow all for authenticated users"
ON appointments
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

COMMENT ON TABLE appointments IS 'Patient appointments with date and time slots';

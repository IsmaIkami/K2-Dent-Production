-- Create anamneses table for patient medical history
-- Each anamnesis is a snapshot of patient medical state at a specific date

CREATE TABLE IF NOT EXISTS anamneses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

    -- Date and practitioner
    anamnesis_date DATE NOT NULL DEFAULT CURRENT_DATE,
    practitioner_name VARCHAR(255),
    practitioner_id VARCHAR(100),

    -- Chief complaint
    chief_complaint TEXT,

    -- Medical history
    medical_conditions TEXT[], -- Array of conditions: diabetes, hypertension, etc.
    allergies TEXT[], -- Array of allergies
    current_medications TEXT[], -- Array of medications
    smoking_status VARCHAR(50), -- non-smoker, former, current
    alcohol_consumption VARCHAR(50), -- none, occasional, regular, heavy

    -- Dental history
    last_dental_visit DATE,
    dental_pain BOOLEAN DEFAULT false,
    dental_pain_description TEXT,
    bleeding_gums BOOLEAN DEFAULT false,
    sensitivity BOOLEAN DEFAULT false,
    previous_treatments TEXT[], -- Array of previous treatments

    -- Examination findings
    oral_hygiene_score INTEGER CHECK (oral_hygiene_score >= 0 AND oral_hygiene_score <= 10),
    periodontal_status VARCHAR(50), -- healthy, gingivitis, periodontitis
    caries_risk VARCHAR(50), -- low, medium, high

    -- Treatment plan
    proposed_treatment TEXT,
    treatment_priority VARCHAR(50), -- urgent, high, medium, low
    estimated_cost DECIMAL(10,2),

    -- Notes
    clinical_notes TEXT,
    patient_concerns TEXT,

    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(100),

    -- Constraints
    CONSTRAINT valid_date CHECK (anamnesis_date <= CURRENT_DATE)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_anamneses_patient_id ON anamneses(patient_id);
CREATE INDEX IF NOT EXISTS idx_anamneses_date ON anamneses(anamnesis_date DESC);
CREATE INDEX IF NOT EXISTS idx_anamneses_patient_date ON anamneses(patient_id, anamnesis_date DESC);

-- Enable Row Level Security
ALTER TABLE anamneses ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Allow all operations for authenticated users (for now)
CREATE POLICY "Enable all operations for authenticated users" ON anamneses
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_anamneses_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_anamneses_updated_at
    BEFORE UPDATE ON anamneses
    FOR EACH ROW
    EXECUTE FUNCTION update_anamneses_updated_at();

-- Add comment
COMMENT ON TABLE anamneses IS 'Patient medical history and anamnesis records. Each record is a snapshot at a specific date.';

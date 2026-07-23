-- =============================================================================
-- MEDICAL HISTORY TABLE WITH VERSIONING
-- Version: 1.0
-- Description: Table pour stocker l'historique médical versionné des patients
-- =============================================================================

-- Drop existing objects if they exist
DROP TABLE IF EXISTS public.medical_history CASCADE;
DROP FUNCTION IF EXISTS public.create_medical_history_version CASCADE;

-- Create medical_history table with versioning support
CREATE TABLE public.medical_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,

    -- Medical information (arrays for versioning)
    allergies TEXT[] DEFAULT '{}',
    medications TEXT[] DEFAULT '{}',
    medical_conditions TEXT[] DEFAULT '{}',
    surgical_history TEXT[] DEFAULT '{}',

    -- Dental information
    dental_concerns TEXT,
    previous_dental_treatments TEXT[] DEFAULT '{}',
    dental_anxiety_level TEXT,

    -- Oral hygiene habits
    brushing_frequency TEXT,
    flossing_frequency TEXT,
    mouthwash_use BOOLEAN DEFAULT false,

    -- Professional notes
    practitioner_notes TEXT,

    -- Audit fields
    created_by UUID NOT NULL REFERENCES auth.users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- Indexes for performance
    CONSTRAINT valid_dental_anxiety CHECK (dental_anxiety_level IN ('low', 'medium', 'high', NULL))
);

-- Indexes
CREATE INDEX idx_medical_history_patient ON public.medical_history(patient_id);
CREATE INDEX idx_medical_history_created_at ON public.medical_history(created_at DESC);

-- Enable RLS
ALTER TABLE public.medical_history ENABLE ROW LEVEL SECURITY;

-- RLS Policies - Simplified (no organization concept yet)
CREATE POLICY "Authenticated users can view all medical history"
    ON public.medical_history
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can insert medical history"
    ON public.medical_history
    FOR INSERT
    WITH CHECK (
        auth.uid() IS NOT NULL
        AND created_by = auth.uid()
    );

-- =============================================================================
-- RPC FUNCTION: create_medical_history_version
-- Description: Creates a new version of medical history for a patient
-- =============================================================================

CREATE OR REPLACE FUNCTION public.create_medical_history_version(
    p_patient_id UUID,
    p_allergies TEXT[] DEFAULT '{}',
    p_medications TEXT[] DEFAULT '{}',
    p_medical_conditions TEXT[] DEFAULT '{}',
    p_surgical_history TEXT[] DEFAULT '{}',
    p_dental_concerns TEXT DEFAULT NULL,
    p_previous_dental_treatments TEXT[] DEFAULT '{}',
    p_dental_anxiety_level TEXT DEFAULT NULL,
    p_brushing_frequency TEXT DEFAULT NULL,
    p_flossing_frequency TEXT DEFAULT NULL,
    p_mouthwash_use BOOLEAN DEFAULT false,
    p_practitioner_notes TEXT DEFAULT NULL,
    p_created_by UUID DEFAULT auth.uid()
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_new_id UUID;
BEGIN
    -- Validate that patient exists
    IF NOT EXISTS (
        SELECT 1 FROM public.patients p
        WHERE p.id = p_patient_id
    ) THEN
        RAISE EXCEPTION 'Patient not found';
    END IF;

    -- Insert new medical history version
    INSERT INTO public.medical_history (
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
    )
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.create_medical_history_version TO authenticated;

-- Comments
COMMENT ON TABLE public.medical_history IS 'Versioned medical history for patients with dental-specific fields';
COMMENT ON FUNCTION public.create_medical_history_version IS 'Creates a new version of medical history for a patient';

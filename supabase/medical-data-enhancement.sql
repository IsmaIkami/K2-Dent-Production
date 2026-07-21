-- ============================================================================
-- K2 DENT - AMÉLIORATION DONNÉES MÉDICALES
-- ============================================================================
-- Ajoute des champs structurés pour les données médicales courantes
-- utilisées dans les cabinets dentaires
-- Version: 1.0 - Safe to re-run (uses IF NOT EXISTS)
-- ============================================================================

-- Ajouter champs médicaux manquants à la table patients (safe - IF NOT EXISTS)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='patients' AND column_name='blood_type') THEN
        ALTER TABLE patients ADD COLUMN blood_type VARCHAR(5);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='patients' AND column_name='smoker') THEN
        ALTER TABLE patients ADD COLUMN smoker BOOLEAN DEFAULT FALSE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='patients' AND column_name='alcohol_consumption') THEN
        ALTER TABLE patients ADD COLUMN alcohol_consumption VARCHAR(20) CHECK (alcohol_consumption IN ('NONE', 'OCCASIONAL', 'MODERATE', 'HEAVY'));
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='patients' AND column_name='pregnant') THEN
        ALTER TABLE patients ADD COLUMN pregnant BOOLEAN DEFAULT FALSE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='patients' AND column_name='breastfeeding') THEN
        ALTER TABLE patients ADD COLUMN breastfeeding BOOLEAN DEFAULT FALSE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='patients' AND column_name='anticoagulant_therapy') THEN
        ALTER TABLE patients ADD COLUMN anticoagulant_therapy BOOLEAN DEFAULT FALSE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='patients' AND column_name='diabetes') THEN
        ALTER TABLE patients ADD COLUMN diabetes BOOLEAN DEFAULT FALSE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='patients' AND column_name='hypertension') THEN
        ALTER TABLE patients ADD COLUMN hypertension BOOLEAN DEFAULT FALSE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='patients' AND column_name='heart_disease') THEN
        ALTER TABLE patients ADD COLUMN heart_disease BOOLEAN DEFAULT FALSE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='patients' AND column_name='last_dental_visit') THEN
        ALTER TABLE patients ADD COLUMN last_dental_visit DATE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='patients' AND column_name='dental_hygiene_frequency') THEN
        ALTER TABLE patients ADD COLUMN dental_hygiene_frequency VARCHAR(50);
    END IF;
END $$;

-- Créer table pour historique des antécédents médicaux (versioning)
CREATE TABLE IF NOT EXISTS medical_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  -- Données médicales structurées
  allergies TEXT[], -- Array pour faciliter la recherche
  medications TEXT[],
  medical_conditions TEXT[],
  surgical_history TEXT[],

  -- Données dentaires
  dental_concerns TEXT,
  previous_dental_treatments TEXT[],
  dental_anxiety_level INTEGER CHECK (dental_anxiety_level BETWEEN 0 AND 10),

  -- Habitudes
  brushing_frequency VARCHAR(50),
  flossing_frequency VARCHAR(50),
  mouthwash_use BOOLEAN DEFAULT FALSE,

  -- Notes du praticien
  practitioner_notes TEXT,

  -- Metadata
  version INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID NOT NULL,
  parent_version_id UUID REFERENCES medical_history(id),

  CONSTRAINT fk_patient FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_medical_history_patient ON medical_history(patient_id);
CREATE INDEX IF NOT EXISTS idx_medical_history_created_at ON medical_history(created_at DESC);

-- Vue complète du patient avec dernières données médicales
CREATE OR REPLACE VIEW patient_complete_view AS
SELECT
  p.*,
  mh.allergies AS current_allergies,
  mh.medications AS current_medications,
  mh.medical_conditions AS current_conditions,
  mh.surgical_history,
  mh.dental_concerns,
  mh.dental_anxiety_level,
  mh.practitioner_notes,
  mh.created_at AS medical_data_last_updated
FROM patients p
LEFT JOIN LATERAL (
  SELECT * FROM medical_history
  WHERE patient_id = p.id
  ORDER BY created_at DESC
  LIMIT 1
) mh ON true
WHERE p.archived = FALSE;

-- Fonction pour créer une nouvelle version de l'historique médical
CREATE OR REPLACE FUNCTION create_medical_history_version(
  p_patient_id UUID,
  p_allergies TEXT[],
  p_medications TEXT[],
  p_medical_conditions TEXT[],
  p_surgical_history TEXT[],
  p_dental_concerns TEXT,
  p_previous_dental_treatments TEXT[],
  p_dental_anxiety_level INTEGER,
  p_brushing_frequency VARCHAR,
  p_flossing_frequency VARCHAR,
  p_mouthwash_use BOOLEAN,
  p_practitioner_notes TEXT,
  p_created_by UUID
) RETURNS UUID AS $$
DECLARE
  v_parent_id UUID;
  v_new_version INTEGER;
  v_new_id UUID;
BEGIN
  -- Get latest version
  SELECT id, version INTO v_parent_id, v_new_version
  FROM medical_history
  WHERE patient_id = p_patient_id
  ORDER BY created_at DESC
  LIMIT 1;

  -- Increment version or start at 1
  IF v_new_version IS NULL THEN
    v_new_version := 1;
  ELSE
    v_new_version := v_new_version + 1;
  END IF;

  -- Insert new version
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
    version,
    created_by,
    parent_version_id
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
    v_new_version,
    p_created_by,
    v_parent_id
  ) RETURNING id INTO v_new_id;

  -- Create timeline event
  INSERT INTO timeline_events (
    patient_id,
    type,
    title,
    description,
    badge,
    related_id,
    related_type,
    created_by
  ) VALUES (
    p_patient_id,
    'note',
    'Mise à jour données médicales',
    'Historique médical mis à jour (version ' || v_new_version || ')',
    'badge-info',
    v_new_id,
    'medical_history',
    p_created_by
  );

  RETURN v_new_id;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if exists, then create
DROP TRIGGER IF EXISTS update_patients_updated_at ON patients;
CREATE TRIGGER update_patients_updated_at
  BEFORE UPDATE ON patients
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Commentaires pour documentation
COMMENT ON TABLE medical_history IS 'Historique versionné des données médicales du patient';
COMMENT ON VIEW patient_complete_view IS 'Vue complète du patient avec dernières données médicales';
COMMENT ON FUNCTION create_medical_history_version IS 'Crée une nouvelle version de l''historique médical avec événement timeline';

-- Grant permissions (adjust based on your roles)
GRANT SELECT ON patient_complete_view TO anon, authenticated;
GRANT EXECUTE ON FUNCTION create_medical_history_version TO authenticated;

-- ============================================================================
-- ROW LEVEL SECURITY - MEDICAL HISTORY
-- ============================================================================

-- Enable RLS on medical_history
ALTER TABLE medical_history ENABLE ROW LEVEL SECURITY;

-- Politique pour utilisateurs authentifiés (dentistes)
CREATE POLICY "Authenticated users full access to medical_history"
ON medical_history
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Politique pour utilisateurs anonymes (pour démo/dev)
CREATE POLICY "Anon users full access to medical_history"
ON medical_history
FOR ALL
TO anon
USING (true)
WITH CHECK (true);

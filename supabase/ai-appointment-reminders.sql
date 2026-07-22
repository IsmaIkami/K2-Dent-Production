-- ============================================================================
-- K2 DENT - MODULE IA RAPPELS AUTOMATIQUES RDV
-- ============================================================================
-- Système intelligent de relances SMS/Email avec optimisation IA
-- Version: 1.0
-- ============================================================================

-- Table pour logs des rappels envoyés
CREATE TABLE IF NOT EXISTS appointment_reminders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  appointment_id UUID NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  -- Type et statut
  reminder_type VARCHAR(20) CHECK (reminder_type IN ('SMS', 'EMAIL', 'WHATSAPP', 'PHONE')),
  reminder_timing VARCHAR(50) CHECK (reminder_timing IN ('24H_BEFORE', '48H_BEFORE', '1WEEK_BEFORE', 'SAME_DAY', 'FOLLOWUP')),

  -- Contenu
  message_content TEXT NOT NULL,
  recipient VARCHAR(255) NOT NULL, -- phone or email

  -- Statut envoi
  status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'delivered', 'failed', 'bounced')),
  sent_at TIMESTAMP WITH TIME ZONE,
  delivered_at TIMESTAMP WITH TIME ZONE,
  error_message TEXT,

  -- IA tracking
  ai_score FLOAT, -- Score priorité IA (0-1)
  ai_reason TEXT, -- Raison du timing choisi par IA

  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID
);

CREATE INDEX IF NOT EXISTS idx_reminders_appointment ON appointment_reminders(appointment_id);
CREATE INDEX IF NOT EXISTS idx_reminders_patient ON appointment_reminders(patient_id);
CREATE INDEX IF NOT EXISTS idx_reminders_status ON appointment_reminders(status, sent_at);

-- Table pour configuration IA rappels
CREATE TABLE IF NOT EXISTS reminder_ai_config (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Règles de base
  enabled BOOLEAN DEFAULT TRUE,
  default_reminder_timing VARCHAR(50) DEFAULT '24H_BEFORE',
  send_sms BOOLEAN DEFAULT TRUE,
  send_email BOOLEAN DEFAULT TRUE,

  -- Horaires d'envoi
  send_time_start TIME DEFAULT '09:00:00',
  send_time_end TIME DEFAULT '18:00:00',
  no_send_weekends BOOLEAN DEFAULT TRUE,

  -- IA personnalisation
  ai_personalization_enabled BOOLEAN DEFAULT TRUE,
  ai_language_detection BOOLEAN DEFAULT TRUE,
  ai_optimal_timing BOOLEAN DEFAULT TRUE,

  -- Templates
  sms_template_24h TEXT DEFAULT 'Bonjour {first_name}, rappel de votre RDV dentaire demain à {time} chez K2 Dent. Confirmez par SMS ou appelez-nous. À bientôt !',
  email_template_24h TEXT DEFAULT 'Bonjour {first_name},\n\nNous vous rappelons votre rendez-vous dentaire demain à {time}.\n\nType: {type}\nDurée: {duration} min\n\nEn cas d''empêchement, merci de nous prévenir au plus vite.\n\nÀ bientôt,\nL''équipe K2 Dent',

  -- Metadata
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_by UUID
);

-- Insert default config
INSERT INTO reminder_ai_config (id)
VALUES ('00000000-0000-0000-0000-000000000001')
ON CONFLICT (id) DO NOTHING;

-- Vue pour rappels à envoyer (IA decision)
CREATE OR REPLACE VIEW pending_reminders_ai AS
SELECT
  a.id as appointment_id,
  a.patient_id,
  a.appointment_date,
  a.start_time,
  a.type,
  a.duration_minutes,
  a.status as appointment_status,
  p.first_name,
  p.last_name,
  p.phone,
  p.mobile,
  p.email,
  p.language,
  p.preferred_communication,

  -- IA Score calculation
  CASE
    -- Urgences = haute priorité
    WHEN a.type ILIKE '%urgence%' THEN 0.95
    -- Patients à risque = priorité élevée
    WHEN p.anticoagulant_therapy OR p.heart_disease THEN 0.85
    -- Nouveaux patients = priorité moyenne-haute
    WHEN a.created_at > NOW() - INTERVAL '30 days' THEN 0.75
    -- RDV longs = priorité moyenne
    WHEN a.duration_minutes > 60 THEN 0.70
    -- Défaut
    ELSE 0.60
  END as ai_priority_score,

  -- Temps optimal d'envoi (IA)
  CASE
    -- Urgences: même jour
    WHEN a.type ILIKE '%urgence%' THEN '24H_BEFORE'
    -- Patients anxieux: 48h pour préparation
    WHEN EXISTS (
      SELECT 1 FROM medical_history mh
      WHERE mh.patient_id = p.id
      AND mh.dental_anxiety_level > 7
    ) THEN '48H_BEFORE'
    -- RDV longs: 48h
    WHEN a.duration_minutes > 90 THEN '48H_BEFORE'
    -- Défaut: 24h
    ELSE '24H_BEFORE'
  END as ai_recommended_timing,

  -- Raison IA
  CASE
    WHEN a.type ILIKE '%urgence%' THEN 'Urgence - rappel même jour'
    WHEN p.anticoagulant_therapy THEN 'Patient anticoagulant - haute priorité'
    WHEN EXISTS (
      SELECT 1 FROM medical_history mh
      WHERE mh.patient_id = p.id
      AND mh.dental_anxiety_level > 7
    ) THEN 'Anxiété dentaire - rappel anticipé 48h'
    WHEN a.duration_minutes > 90 THEN 'RDV long - rappel anticipé'
    ELSE 'Rappel standard optimisé'
  END as ai_reason

FROM appointments a
JOIN patients p ON p.id = a.patient_id
WHERE
  -- RDV futurs non annulés
  a.appointment_date >= CURRENT_DATE
  AND a.status NOT IN ('cancelled', 'completed', 'no_show')
  -- Pas encore de rappel envoyé
  AND NOT EXISTS (
    SELECT 1 FROM appointment_reminders ar
    WHERE ar.appointment_id = a.id
    AND ar.status = 'sent'
  )
ORDER BY ai_priority_score DESC, a.appointment_date ASC;

-- Fonction pour créer rappels IA automatiques
CREATE OR REPLACE FUNCTION generate_ai_reminders()
RETURNS TABLE (
  appointment_id UUID,
  patient_name TEXT,
  reminder_type VARCHAR(20),
  scheduled_for TIMESTAMP WITH TIME ZONE,
  ai_score FLOAT
) AS $$
DECLARE
  config RECORD;
  pending RECORD;
  send_time TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Charger config
  SELECT * INTO config FROM reminder_ai_config LIMIT 1;

  IF NOT config.enabled THEN
    RETURN;
  END IF;

  -- Pour chaque RDV nécessitant rappel
  FOR pending IN SELECT * FROM pending_reminders_ai LOOP

    -- Calculer timing optimal
    send_time := pending.appointment_date - INTERVAL '24 hours';

    IF pending.ai_recommended_timing = '48H_BEFORE' THEN
      send_time := pending.appointment_date - INTERVAL '48 hours';
    ELSIF pending.ai_recommended_timing = '1WEEK_BEFORE' THEN
      send_time := pending.appointment_date - INTERVAL '7 days';
    END IF;

    -- Ajuster horaire (pas avant 9h, pas après 18h)
    send_time := DATE_TRUNC('day', send_time) + config.send_time_start;

    -- Skip weekends si configuré
    IF config.no_send_weekends AND EXTRACT(DOW FROM send_time) IN (0, 6) THEN
      -- Déplacer au vendredi précédent
      send_time := send_time - INTERVAL '1 day' * (EXTRACT(DOW FROM send_time));
    END IF;

    -- Créer rappel SMS si téléphone et config activé
    IF config.send_sms AND (pending.phone IS NOT NULL OR pending.mobile IS NOT NULL) THEN
      INSERT INTO appointment_reminders (
        appointment_id, patient_id, reminder_type, reminder_timing,
        message_content, recipient, status, ai_score, ai_reason
      ) VALUES (
        pending.appointment_id,
        pending.patient_id,
        'SMS',
        pending.ai_recommended_timing,
        REPLACE(REPLACE(REPLACE(
          config.sms_template_24h,
          '{first_name}', pending.first_name),
          '{time}', pending.start_time::TEXT),
          '{type}', pending.type
        ),
        COALESCE(pending.mobile, pending.phone),
        'pending',
        pending.ai_priority_score,
        pending.ai_reason
      );

      RETURN QUERY SELECT
        pending.appointment_id,
        pending.first_name || ' ' || pending.last_name,
        'SMS'::VARCHAR(20),
        send_time,
        pending.ai_priority_score;
    END IF;

    -- Créer rappel Email si config activé
    IF config.send_email AND pending.email IS NOT NULL THEN
      INSERT INTO appointment_reminders (
        appointment_id, patient_id, reminder_type, reminder_timing,
        message_content, recipient, status, ai_score, ai_reason
      ) VALUES (
        pending.appointment_id,
        pending.patient_id,
        'EMAIL',
        pending.ai_recommended_timing,
        REPLACE(REPLACE(REPLACE(REPLACE(
          config.email_template_24h,
          '{first_name}', pending.first_name),
          '{time}', pending.start_time::TEXT),
          '{type}', pending.type),
          '{duration}', pending.duration_minutes::TEXT
        ),
        pending.email,
        'pending',
        pending.ai_priority_score,
        pending.ai_reason
      );

      RETURN QUERY SELECT
        pending.appointment_id,
        pending.first_name || ' ' || pending.last_name,
        'EMAIL'::VARCHAR(20),
        send_time,
        pending.ai_priority_score;
    END IF;

  END LOOP;

  RETURN;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour marquer rappel comme envoyé
CREATE OR REPLACE FUNCTION mark_reminder_sent(
  p_reminder_id UUID,
  p_status VARCHAR(50) DEFAULT 'sent',
  p_error_message TEXT DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
  UPDATE appointment_reminders
  SET
    status = p_status,
    sent_at = NOW(),
    error_message = p_error_message
  WHERE id = p_reminder_id;

  -- Marquer aussi le RDV
  IF p_status = 'sent' THEN
    UPDATE appointments
    SET
      reminder_sent = TRUE,
      reminder_sent_date = NOW()
    WHERE id = (SELECT appointment_id FROM appointment_reminders WHERE id = p_reminder_id);
  END IF;
END;
$$ LANGUAGE plpgsql;

-- RLS
ALTER TABLE appointment_reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminder_ai_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Full access to appointment_reminders" ON appointment_reminders FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Full access to reminder_ai_config" ON reminder_ai_config FOR ALL USING (true) WITH CHECK (true);

-- Commentaires
COMMENT ON TABLE appointment_reminders IS 'Logs des rappels SMS/Email envoyés avec tracking IA';
COMMENT ON TABLE reminder_ai_config IS 'Configuration du système IA de rappels automatiques';
COMMENT ON VIEW pending_reminders_ai IS 'Vue IA: rappels à envoyer avec scoring prioritaire';
COMMENT ON FUNCTION generate_ai_reminders IS 'Génère automatiquement les rappels optimisés par IA';
COMMENT ON FUNCTION mark_reminder_sent IS 'Marque un rappel comme envoyé avec statut';

-- Permissions
GRANT SELECT, INSERT, UPDATE ON appointment_reminders TO authenticated, anon;
GRANT SELECT, UPDATE ON reminder_ai_config TO authenticated, anon;
GRANT EXECUTE ON FUNCTION generate_ai_reminders TO authenticated, anon;
GRANT EXECUTE ON FUNCTION mark_reminder_sent TO authenticated, anon;

-- Logs
SELECT 'Module IA Rappels RDV installé avec succès' as status;

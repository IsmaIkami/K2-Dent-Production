-- ============================================
-- K2 DENT - TEST DATA SEED SCRIPT
-- ============================================
-- Purpose: Populate realistic test data for patient case management
-- Author: Claude Code
-- Date: July 2026
-- ============================================

-- NOTE: Update the patient_id UUID below with an actual patient from your database
-- To get a patient ID, run: SELECT id, first_name, last_name FROM patients LIMIT 1;

DO $$
DECLARE
    test_patient_id UUID;
    practitioner_id UUID;
    anamnesis_id UUID;
BEGIN
    -- Get the first patient from the database
    SELECT id INTO test_patient_id FROM patients ORDER BY created_at LIMIT 1;

    IF test_patient_id IS NULL THEN
        RAISE EXCEPTION 'No patients found in database. Please create a patient first.';
    END IF;

    -- Get or create a practitioner (you can replace with actual practitioner ID)
    SELECT id INTO practitioner_id FROM users WHERE role = 'admin' OR role = 'dentist' LIMIT 1;

    RAISE NOTICE 'Populating test data for patient: %', test_patient_id;

    -- ============================================
    -- 1. APPOINTMENTS (realistic history)
    -- ============================================

    -- Past appointment 1 (completed, 3 months ago)
    INSERT INTO appointments (
        patient_id,
        appointment_date,
        start_time,
        end_time,
        duration_minutes,
        type,
        status,
        reason,
        notes,
        practitioner_id,
        created_at
    ) VALUES (
        test_patient_id,
        CURRENT_DATE - INTERVAL '90 days',
        '09:00',
        '09:45',
        45,
        'Consultation',
        'completed',
        'Contrôle semestriel',
        'Examen complet. Patient en bonne santé bucco-dentaire. Détartrage effectué.',
        practitioner_id,
        NOW() - INTERVAL '90 days'
    );

    -- Past appointment 2 (completed, 2 months ago, on time)
    INSERT INTO appointments (
        patient_id,
        appointment_date,
        start_time,
        end_time,
        duration_minutes,
        type,
        status,
        reason,
        notes,
        practitioner_id,
        created_at
    ) VALUES (
        test_patient_id,
        CURRENT_DATE - INTERVAL '60 days',
        '14:30',
        '15:15',
        45,
        'Détartrage',
        'completed',
        'Détartrage prophylactique',
        'Détartrage complet. Pas de caries détectées. Conseils d''hygiène donnés.',
        practitioner_id,
        NOW() - INTERVAL '60 days'
    );

    -- Past appointment 3 (completed, 1 month ago)
    INSERT INTO appointments (
        patient_id,
        appointment_date,
        start_time,
        end_time,
        duration_minutes,
        type,
        status,
        reason,
        notes,
        practitioner_id,
        created_at
    ) VALUES (
        test_patient_id,
        CURRENT_DATE - INTERVAL '30 days',
        '10:15',
        '11:00',
        45,
        'Soins',
        'completed',
        'Pose composite dent 16',
        'Composite esthétique dent 16 face occlusale. Anesthésie locale. Pas de complications.',
        practitioner_id,
        NOW() - INTERVAL '30 days'
    );

    -- Past appointment 4 (completed, 2 weeks ago)
    INSERT INTO appointments (
        patient_id,
        appointment_date,
        start_time,
        end_time,
        duration_minutes,
        type,
        status,
        reason,
        notes,
        practitioner_id,
        created_at
    ) VALUES (
        test_patient_id,
        CURRENT_DATE - INTERVAL '14 days',
        '16:00',
        '16:30',
        30,
        'Consultation',
        'completed',
        'Suivi post-soins',
        'Contrôle composite dent 16. Cicatrisation parfaite. Patient satisfait.',
        practitioner_id,
        NOW() - INTERVAL '14 days'
    );

    -- Upcoming appointment 1 (scheduled, tomorrow)
    INSERT INTO appointments (
        patient_id,
        appointment_date,
        start_time,
        end_time,
        duration_minutes,
        type,
        status,
        reason,
        notes,
        practitioner_id,
        reminder_sent,
        reminder_sent_date
    ) VALUES (
        test_patient_id,
        CURRENT_DATE + INTERVAL '1 day',
        '14:00',
        '14:45',
        45,
        'Consultation',
        'confirmed',
        'Contrôle trimestriel',
        'Examen de routine programmé.',
        practitioner_id,
        TRUE,
        NOW() - INTERVAL '2 days'
    );

    -- Upcoming appointment 2 (scheduled, next week)
    INSERT INTO appointments (
        patient_id,
        appointment_date,
        start_time,
        end_time,
        duration_minutes,
        type,
        status,
        reason,
        notes,
        practitioner_id,
        reminder_sent,
        reminder_sent_date
    ) VALUES (
        test_patient_id,
        CURRENT_DATE + INTERVAL '7 days',
        '09:30',
        '10:30',
        60,
        'Radiographie',
        'scheduled',
        'Panoramique dentaire',
        'Radiographie panoramique de contrôle.',
        practitioner_id,
        FALSE,
        NULL
    );

    -- Past appointment 5 (no-show, 5 months ago)
    INSERT INTO appointments (
        patient_id,
        appointment_date,
        start_time,
        end_time,
        duration_minutes,
        type,
        status,
        reason,
        notes,
        practitioner_id,
        created_at,
        cancellation_reason
    ) VALUES (
        test_patient_id,
        CURRENT_DATE - INTERVAL '150 days',
        '11:00',
        '11:45',
        45,
        'Consultation',
        'no_show',
        'Contrôle',
        'Patient ne s''est pas présenté.',
        practitioner_id,
        NOW() - INTERVAL '150 days',
        'Patient n''a pas prévenu'
    );

    -- ============================================
    -- 2. TIMELINE EVENTS
    -- ============================================

    -- Create a comprehensive anamnesis record
    INSERT INTO anamneses (
        patient_id,
        anamnesis_date,
        practitioner_name,
        practitioner_id,
        chief_complaint,
        medical_conditions,
        allergies,
        current_medications,
        smoking_status,
        alcohol_consumption,
        last_dental_visit,
        dental_pain,
        dental_pain_description,
        bleeding_gums,
        sensitivity,
        previous_treatments,
        oral_hygiene_score,
        periodontal_status,
        caries_risk,
        proposed_treatment,
        treatment_priority,
        estimated_cost,
        clinical_notes,
        patient_concerns,
        created_at,
        created_by
    ) VALUES (
        test_patient_id,
        CURRENT_DATE - INTERVAL '90 days',
        'Dr. Sialyen',
        practitioner_id::text,
        'Contrôle semestriel de routine',
        ARRAY['Aucune'],
        ARRAY['Aucune allergie connue'],
        ARRAY['Aucun traitement en cours'],
        'non-fumeur',
        'occasional',
        CURRENT_DATE - INTERVAL '6 months',
        FALSE,
        NULL,
        FALSE,
        FALSE,
        ARRAY['Détartrage', 'Composite dent 24 (2020)'],
        8,
        'healthy',
        'low',
        'Détartrage prophylactique recommandé. Surveillance dent 16.',
        'medium',
        85.00,
        'Patient en bonne santé bucco-dentaire générale. Hygiène correcte. Poursuivre les contrôles semestriels.',
        'Préoccupé par la couleur des dents, intéressé par blanchiment.',
        NOW() - INTERVAL '90 days',
        practitioner_id::text
    ) RETURNING id INTO anamnesis_id;

    -- Timeline: Anamnesis creation
    INSERT INTO timeline_events (
        patient_id,
        type,
        title,
        description,
        badge,
        related_id,
        related_type,
        event_date,
        created_by
    ) VALUES (
        test_patient_id,
        'anamnesis',
        'Anamnèse complétée',
        'Anamnèse médicale initiale enregistrée par le praticien.',
        'AI',
        anamnesis_id,
        'anamnesis',
        NOW() - INTERVAL '90 days',
        practitioner_id
    );

    -- Timeline: First consultation
    INSERT INTO timeline_events (
        patient_id,
        type,
        title,
        description,
        badge,
        event_date,
        created_by
    ) VALUES (
        test_patient_id,
        'consultation',
        'Première consultation',
        'Contrôle semestriel - examen complet et détartrage.',
        'Manual',
        NOW() - INTERVAL '90 days',
        practitioner_id
    );

    -- Timeline: Treatment (composite)
    INSERT INTO timeline_events (
        patient_id,
        type,
        title,
        description,
        badge,
        event_date,
        created_by
    ) VALUES (
        test_patient_id,
        'treatment',
        'Composite dent 16',
        'Pose composite esthétique face occlusale dent 16.',
        'Manual',
        NOW() - INTERVAL '30 days',
        practitioner_id
    );

    -- Timeline: X-Ray (if planned)
    INSERT INTO timeline_events (
        patient_id,
        type,
        title,
        description,
        badge,
        event_date,
        created_by
    ) VALUES (
        test_patient_id,
        'xray',
        'Radiographie panoramique prévue',
        'Radiographie de contrôle programmée pour ' || TO_CHAR(CURRENT_DATE + INTERVAL '7 days', 'DD/MM/YYYY'),
        'X-Ray',
        NOW(),
        practitioner_id
    );

    -- Timeline: Note
    INSERT INTO timeline_events (
        patient_id,
        type,
        title,
        description,
        badge,
        event_date,
        created_by
    ) VALUES (
        test_patient_id,
        'note',
        'Note praticien',
        'Patient très coopératif. Bonne hygiène bucco-dentaire. Suivi régulier recommandé.',
        'Manual',
        NOW() - INTERVAL '14 days',
        practitioner_id
    );

    -- ============================================
    -- 3. DENTAL CHART (if table exists)
    -- ============================================

    -- Check if dental_charts table exists and insert
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'dental_charts') THEN
        INSERT INTO dental_charts (
            patient_id,
            chart_data,
            snapshot_date,
            created_by,
            notes
        ) VALUES (
            test_patient_id,
            '{
                "11": {"status": "healthy", "treatments": [], "notes": ""},
                "12": {"status": "healthy", "treatments": [], "notes": ""},
                "13": {"status": "healthy", "treatments": [], "notes": ""},
                "14": {"status": "healthy", "treatments": [], "notes": ""},
                "15": {"status": "healthy", "treatments": [], "notes": ""},
                "16": {"status": "watch", "treatments": ["composite"], "notes": "Composite occlusale posé le ' || TO_CHAR(CURRENT_DATE - INTERVAL '30 days', 'DD/MM/YYYY') || '"},
                "17": {"status": "healthy", "treatments": [], "notes": ""},
                "18": {"status": "healthy", "treatments": [], "notes": ""},
                "21": {"status": "healthy", "treatments": [], "notes": ""},
                "22": {"status": "healthy", "treatments": [], "notes": ""},
                "23": {"status": "healthy", "treatments": [], "notes": ""},
                "24": {"status": "healthy", "treatments": [], "notes": ""},
                "25": {"status": "healthy", "treatments": [], "notes": ""},
                "26": {"status": "watch", "treatments": [], "notes": "Légère déminéralisation à surveiller"},
                "27": {"status": "healthy", "treatments": [], "notes": ""},
                "28": {"status": "healthy", "treatments": [], "notes": ""},
                "31": {"status": "healthy", "treatments": [], "notes": ""},
                "32": {"status": "healthy", "treatments": [], "notes": ""},
                "33": {"status": "healthy", "treatments": [], "notes": ""},
                "34": {"status": "healthy", "treatments": [], "notes": ""},
                "35": {"status": "healthy", "treatments": [], "notes": ""},
                "36": {"status": "urgent", "treatments": [], "notes": "Carie profonde - traitement urgent requis"},
                "37": {"status": "healthy", "treatments": [], "notes": ""},
                "38": {"status": "healthy", "treatments": [], "notes": ""},
                "41": {"status": "healthy", "treatments": [], "notes": ""},
                "42": {"status": "healthy", "treatments": [], "notes": ""},
                "43": {"status": "healthy", "treatments": [], "notes": ""},
                "44": {"status": "healthy", "treatments": [], "notes": ""},
                "45": {"status": "healthy", "treatments": [], "notes": ""},
                "46": {"status": "healthy", "treatments": [], "notes": ""},
                "47": {"status": "healthy", "treatments": [], "notes": ""},
                "48": {"status": "healthy", "treatments": [], "notes": ""}
            }'::jsonb,
            NOW(),
            practitioner_id,
            'État dentaire général bon. Surveillance dent 26 et traitement urgent dent 36 requis.'
        );
    END IF;

    RAISE NOTICE 'Test data successfully populated for patient %', test_patient_id;
    RAISE NOTICE 'Created:';
    RAISE NOTICE '  - 7 appointments (5 completed, 1 no-show, 2 upcoming)';
    RAISE NOTICE '  - 5 timeline events';
    RAISE NOTICE '  - 1 anamnesis record';
    RAISE NOTICE '  - 1 dental chart (if table exists)';

END $$;

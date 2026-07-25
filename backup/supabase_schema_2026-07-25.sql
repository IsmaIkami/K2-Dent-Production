-- ============================================
-- K2 DENT - DATABASE SCHEMA BACKUP
-- Date: 2026-07-25
-- Supabase Project: zkjhemeysleurnvqsclq
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: patients
-- ============================================
CREATE TABLE IF NOT EXISTS patients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    niss TEXT UNIQUE NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    date_of_birth DATE NOT NULL,
    gender TEXT NOT NULL CHECK (gender IN ('M', 'F', 'X')),
    email TEXT,
    phone TEXT,
    mobile TEXT,
    address TEXT,
    mutuelle_code TEXT CHECK (mutuelle_code IN ('306', '307', '309', '311', '313', '')),
    is_bim BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- ============================================
-- TABLE: appointments
-- ============================================
CREATE TABLE IF NOT EXISTS appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    appointment_type TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'completed', 'cancelled', 'no-show')),
    notes TEXT,
    email_sent_at TIMESTAMPTZ,
    sms_sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- ============================================
-- TABLE: anamneses
-- ============================================
CREATE TABLE IF NOT EXISTS anamneses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    anamnesis_date DATE NOT NULL DEFAULT CURRENT_DATE,
    medical_conditions TEXT,
    allergies TEXT,
    medications TEXT,
    smoking_status TEXT CHECK (smoking_status IN ('non-smoker', 'smoker', 'former-smoker', '')),
    alcohol_consumption TEXT CHECK (alcohol_consumption IN ('none', 'occasional', 'moderate', 'heavy', '')),
    periodontal_status TEXT CHECK (periodontal_status IN ('healthy', 'gingivitis', 'periodontitis', '')),
    caries_risk TEXT CHECK (caries_risk IN ('low', 'medium', 'high', '')),
    brushing_frequency TEXT CHECK (brushing_frequency IN ('1x', '2x', '3x+', '')),
    interdental_cleaning TEXT CHECK (interdental_cleaning IN ('never', 'sometimes', 'daily', '')),
    dental_floss BOOLEAN DEFAULT FALSE,
    mouthwash BOOLEAN DEFAULT FALSE,
    last_dental_visit DATE,
    notes TEXT,
    version INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ
);

-- ============================================
-- TABLE: timeline_events
-- ============================================
CREATE TABLE IF NOT EXISTS timeline_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    event_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    event_type TEXT NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID
);

-- ============================================
-- TABLE: invoices (Optional)
-- ============================================
CREATE TABLE IF NOT EXISTS invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    invoice_number TEXT,
    invoice_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    payment_status TEXT NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'overdue', 'cancelled')),
    payment_date DATE,
    payment_method TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ
);

-- ============================================
-- TABLE: treatment_plans (Optional)
-- ============================================
CREATE TABLE IF NOT EXISTS treatment_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    plan_name TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'in_progress', 'completed', 'cancelled')),
    start_date DATE,
    end_date DATE,
    total_sessions INTEGER DEFAULT 0,
    completed_sessions INTEGER DEFAULT 0,
    estimated_cost DECIMAL(10, 2),
    actual_cost DECIMAL(10, 2),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ
);

-- ============================================
-- INDEXES for Performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_patients_niss ON patients(niss);
CREATE INDEX IF NOT EXISTS idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_start_time ON appointments(start_time);
CREATE INDEX IF NOT EXISTS idx_anamneses_patient_id ON anamneses(patient_id);
CREATE INDEX IF NOT EXISTS idx_anamneses_date ON anamneses(anamnesis_date);
CREATE INDEX IF NOT EXISTS idx_timeline_patient_id ON timeline_events(patient_id);
CREATE INDEX IF NOT EXISTS idx_timeline_date ON timeline_events(event_date);
CREATE INDEX IF NOT EXISTS idx_invoices_patient_id ON invoices(patient_id);
CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(payment_status);
CREATE INDEX IF NOT EXISTS idx_invoices_date ON invoices(invoice_date);
CREATE INDEX IF NOT EXISTS idx_treatment_plans_patient_id ON treatment_plans(patient_id);
CREATE INDEX IF NOT EXISTS idx_treatment_plans_status ON treatment_plans(status);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE anamneses ENABLE ROW LEVEL SECURITY;
ALTER TABLE timeline_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE treatment_plans ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Allow authenticated users full access
CREATE POLICY "Allow authenticated read access on patients" ON patients FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert on patients" ON patients FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update on patients" ON patients FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow authenticated delete on patients" ON patients FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read access on appointments" ON appointments FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert on appointments" ON appointments FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update on appointments" ON appointments FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow authenticated delete on appointments" ON appointments FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read access on anamneses" ON anamneses FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert on anamneses" ON anamneses FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update on anamneses" ON anamneses FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow authenticated delete on anamneses" ON anamneses FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read access on timeline_events" ON timeline_events FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert on timeline_events" ON timeline_events FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update on timeline_events" ON timeline_events FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow authenticated delete on timeline_events" ON timeline_events FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read access on invoices" ON invoices FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert on invoices" ON invoices FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update on invoices" ON invoices FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow authenticated delete on invoices" ON invoices FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read access on treatment_plans" ON treatment_plans FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert on treatment_plans" ON treatment_plans FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update on treatment_plans" ON treatment_plans FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow authenticated delete on treatment_plans" ON treatment_plans FOR DELETE TO authenticated USING (true);

-- ============================================
-- COMMENTS
-- ============================================
COMMENT ON TABLE patients IS 'Patient master data with Belgian NISS';
COMMENT ON TABLE appointments IS 'Patient appointments with notification tracking';
COMMENT ON TABLE anamneses IS 'Medical anamnesis with versioning';
COMMENT ON TABLE timeline_events IS 'Patient timeline for case management';
COMMENT ON TABLE invoices IS 'Patient invoices for billing';
COMMENT ON TABLE treatment_plans IS 'Treatment plans with progress tracking';

-- ============================================
-- K2 DENT - OPTIONAL TABLES CREATION
-- ============================================
-- Purpose: Create optional tables to eliminate 404 errors in console
-- Author: Ismail Sialyen
-- Date: 2026-07-24
-- ============================================

-- Table: invoices
-- Purpose: Store patient invoices for billing tracking
CREATE TABLE IF NOT EXISTS invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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

-- Table: treatment_plans
-- Purpose: Store patient treatment plans and track progress
CREATE TABLE IF NOT EXISTS treatment_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_invoices_patient_id ON invoices(patient_id);
CREATE INDEX IF NOT EXISTS idx_invoices_payment_status ON invoices(payment_status);
CREATE INDEX IF NOT EXISTS idx_invoices_invoice_date ON invoices(invoice_date);

CREATE INDEX IF NOT EXISTS idx_treatment_plans_patient_id ON treatment_plans(patient_id);
CREATE INDEX IF NOT EXISTS idx_treatment_plans_status ON treatment_plans(status);

-- Row Level Security (RLS)
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE treatment_plans ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Allow authenticated users to read all
CREATE POLICY "Allow authenticated read access on invoices"
    ON invoices FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Allow authenticated read access on treatment_plans"
    ON treatment_plans FOR SELECT
    TO authenticated
    USING (true);

-- RLS Policies: Allow authenticated users to insert/update/delete
CREATE POLICY "Allow authenticated insert on invoices"
    ON invoices FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "Allow authenticated update on invoices"
    ON invoices FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow authenticated delete on invoices"
    ON invoices FOR DELETE
    TO authenticated
    USING (true);

CREATE POLICY "Allow authenticated insert on treatment_plans"
    ON treatment_plans FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "Allow authenticated update on treatment_plans"
    ON treatment_plans FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow authenticated delete on treatment_plans"
    ON treatment_plans FOR DELETE
    TO authenticated
    USING (true);

-- Comments
COMMENT ON TABLE invoices IS 'Patient invoices for billing and payment tracking';
COMMENT ON TABLE treatment_plans IS 'Patient treatment plans with progress tracking';

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Optional tables created successfully: invoices, treatment_plans';
    RAISE NOTICE '📊 Indexes created for performance';
    RAISE NOTICE '🔒 Row Level Security enabled with policies';
END $$;

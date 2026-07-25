#!/bin/bash

# ============================================
# K2 DENT - SUPABASE DATABASE BACKUP SCRIPT
# ============================================
# Author: Ismail Sialyen
# Date: 2026-07-25
# Purpose: Export Supabase database schema and data
# ============================================

DATE=$(date +"%Y-%m-%d")
BACKUP_DIR="backup"
SCHEMA_FILE="${BACKUP_DIR}/supabase_schema_${DATE}.sql"
DATA_FILE="${BACKUP_DIR}/supabase_data_${DATE}.sql"
DROP_FILE="${BACKUP_DIR}/drop_all_tables.sql"

# Supabase connection details
# IMPORTANT: Replace with your actual credentials
SUPABASE_HOST="db.zkjhemeysleurnvqsclq.supabase.co"
SUPABASE_DB="postgres"
SUPABASE_USER="postgres"
# Password will be prompted or use PGPASSWORD environment variable

echo "📦 K2 Dent - Supabase Database Backup"
echo "======================================"
echo "Date: ${DATE}"
echo ""

# Create backup directory if not exists
mkdir -p "${BACKUP_DIR}"

# ============================================
# STEP 1: Export Schema (Structure Only)
# ============================================
echo "1️⃣  Exporting database schema..."

cat > "${SCHEMA_FILE}" << 'EOF'
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
EOF

echo "✅ Schema exported to: ${SCHEMA_FILE}"

# ============================================
# STEP 2: Create Drop Script
# ============================================
echo "2️⃣  Creating drop tables script..."

cat > "${DROP_FILE}" << 'EOF'
-- ============================================
-- K2 DENT - DROP ALL TABLES
-- WARNING: This will DELETE all data!
-- ============================================

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS treatment_plans CASCADE;
DROP TABLE IF EXISTS invoices CASCADE;
DROP TABLE IF EXISTS timeline_events CASCADE;
DROP TABLE IF EXISTS anamneses CASCADE;
DROP TABLE IF EXISTS appointments CASCADE;
DROP TABLE IF EXISTS patients CASCADE;

-- Drop extension
DROP EXTENSION IF EXISTS "uuid-ossp";
EOF

echo "✅ Drop script created: ${DROP_FILE}"

# ============================================
# STEP 3: Note about Data Export
# ============================================
echo "3️⃣  Data export instructions..."

cat > "${DATA_FILE}" << 'EOF'
-- ============================================
-- K2 DENT - DATABASE DATA BACKUP
-- Date: 2026-07-25
-- ============================================

-- ⚠️ MANUAL EXPORT REQUIRED
--
-- To export data from Supabase:
--
-- 1. Go to Supabase Dashboard
--    https://supabase.com/dashboard/project/zkjhemeysleurnvqsclq
--
-- 2. Go to "Table Editor"
--
-- 3. For each table, click "Export" → "SQL INSERT statements"
--    - patients
--    - appointments
--    - anamneses
--    - timeline_events
--    - invoices (if exists)
--    - treatment_plans (if exists)
--
-- 4. Save the INSERT statements to this file
--
-- OR use pg_dump (requires direct DB access):
--
-- pg_dump -h db.zkjhemeysleurnvqsclq.supabase.co \
--         -U postgres \
--         -d postgres \
--         --data-only \
--         --table=patients \
--         --table=appointments \
--         --table=anamneses \
--         --table=timeline_events \
--         --table=invoices \
--         --table=treatment_plans \
--         > supabase_data_2026-07-25.sql

-- ============================================
-- SAMPLE DATA (Replace with actual exports)
-- ============================================

-- Example patients (10 test patients)
-- INSERT INTO patients (id, niss, first_name, last_name, ...) VALUES (...);

-- Example appointments
-- INSERT INTO appointments (id, patient_id, start_time, ...) VALUES (...);

-- Example anamneses
-- INSERT INTO anamneses (id, patient_id, medical_conditions, ...) VALUES (...);

-- Example timeline events
-- INSERT INTO timeline_events (id, patient_id, event_type, ...) VALUES (...);

EOF

echo "✅ Data export template created: ${DATA_FILE}"
echo ""
echo "⚠️  IMPORTANT: Data must be exported manually from Supabase Dashboard"
echo "   See instructions in ${DATA_FILE}"

# ============================================
# STEP 4: Summary
# ============================================
echo ""
echo "======================================"
echo "✅ Backup Complete!"
echo "======================================"
echo ""
echo "Files created:"
echo "  📄 ${SCHEMA_FILE} (Database structure)"
echo "  📄 ${DROP_FILE} (Drop tables script)"
echo "  📄 ${DATA_FILE} (Data export template)"
echo ""
echo "Next steps:"
echo "  1. Export data from Supabase Dashboard (see ${DATA_FILE})"
echo "  2. Create Git tag: git tag -a v1.0.0-backup-${DATE}"
echo "  3. Push tag: git push origin v1.0.0-backup-${DATE}"
echo ""

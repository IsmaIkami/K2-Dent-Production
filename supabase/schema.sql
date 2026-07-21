-- ============================================
-- K2 DENT - SUPABASE DATABASE SCHEMA
-- ============================================
-- Author: Ismail Sialyen
-- Date: July 2026
-- Version: 1.0.0
-- Description: Complete database schema for K2 Dent dental practice management
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable Row Level Security
ALTER DATABASE postgres SET "app.jwt_secret" TO 'your-jwt-secret-here';

-- ============================================
-- PATIENTS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS patients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  niss VARCHAR(15) UNIQUE NOT NULL, -- Belgian National Insurance Number
  date_of_birth DATE NOT NULL,
  gender VARCHAR(10) CHECK (gender IN ('M', 'F', 'X', 'OTHER')),
  phone VARCHAR(20),
  mobile VARCHAR(20),
  email VARCHAR(255),
  address_street VARCHAR(255),
  address_city VARCHAR(100),
  address_zip VARCHAR(10),
  address_country VARCHAR(50) DEFAULT 'Belgium',

  -- Medical info
  mutuelle_name VARCHAR(100), -- Insurance company
  mutuelle_code VARCHAR(10),
  mutuelle_membership VARCHAR(50),
  bim BOOLEAN DEFAULT FALSE, -- Beneficiary of increased intervention
  allergies TEXT,
  medications TEXT,
  medical_conditions TEXT,
  emergency_contact_name VARCHAR(100),
  emergency_contact_phone VARCHAR(20),

  -- Metadata
  language VARCHAR(5) DEFAULT 'FR' CHECK (language IN ('FR', 'NL', 'DE', 'EN')),
  preferred_communication VARCHAR(20) DEFAULT 'EMAIL' CHECK (preferred_communication IN ('EMAIL', 'SMS', 'PHONE', 'WHATSAPP')),
  gdpr_consent BOOLEAN DEFAULT FALSE,
  gdpr_consent_date TIMESTAMP WITH TIME ZONE,
  marketing_consent BOOLEAN DEFAULT FALSE,

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID,
  updated_by UUID,
  archived BOOLEAN DEFAULT FALSE,
  archived_at TIMESTAMP WITH TIME ZONE
);

-- Indexes
CREATE INDEX idx_patients_niss ON patients(niss);
CREATE INDEX idx_patients_last_name ON patients(last_name);
CREATE INDEX idx_patients_email ON patients(email);
CREATE INDEX idx_patients_archived ON patients(archived);

-- ============================================
-- ANAMNESIS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS anamnesis (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  -- Content
  content TEXT NOT NULL, -- Markdown format
  version INTEGER DEFAULT 1,
  type VARCHAR(20) DEFAULT 'AI' CHECK (type IN ('AI', 'MANUAL', 'MODIFIED')),

  -- AI metadata
  ai_model VARCHAR(50),
  ai_tokens_used INTEGER,
  ai_generation_time_ms INTEGER,

  -- Voice transcription
  transcription_text TEXT,
  transcription_duration_sec INTEGER,
  audio_file_url TEXT,

  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID NOT NULL,
  parent_version_id UUID REFERENCES anamnesis(id)
);

-- Indexes
CREATE INDEX idx_anamnesis_patient ON anamnesis(patient_id);
CREATE INDEX idx_anamnesis_created_at ON anamnesis(created_at DESC);

-- ============================================
-- TIMELINE EVENTS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS timeline_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  -- Event details
  type VARCHAR(50) NOT NULL CHECK (type IN (
    'anamnesis', 'consultation', 'treatment', 'xray',
    'prescription', 'certificate', 'payment', 'appointment',
    'note', 'document'
  )),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  badge VARCHAR(50), -- CSS class for badge

  -- Related data
  related_id UUID, -- ID of related record (anamnesis, treatment, etc.)
  related_type VARCHAR(50),

  -- Metadata
  event_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID NOT NULL,
  archived BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_timeline_patient ON timeline_events(patient_id);
CREATE INDEX idx_timeline_date ON timeline_events(event_date DESC);
CREATE INDEX idx_timeline_type ON timeline_events(type);

-- ============================================
-- DENTAL CHARTS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS dental_charts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  -- Chart data (JSON format for flexibility)
  chart_data JSONB NOT NULL,
  -- Example structure:
  -- {
  --   "11": { "status": "healthy", "treatments": [], "notes": "" },
  --   "12": { "status": "cavity", "treatments": ["filling"], "notes": "Carie distale" }
  -- }

  -- Snapshot info
  snapshot_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID NOT NULL,
  notes TEXT
);

-- Indexes
CREATE INDEX idx_dental_charts_patient ON dental_charts(patient_id);
CREATE INDEX idx_dental_charts_date ON dental_charts(snapshot_date DESC);

-- ============================================
-- TOOTH TREATMENTS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS tooth_treatments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  tooth_number VARCHAR(5) NOT NULL, -- FDI notation: 11-48

  -- Treatment details
  treatment_type VARCHAR(100) NOT NULL,
  treatment_date DATE NOT NULL,
  inami_code VARCHAR(10),
  status VARCHAR(50) DEFAULT 'completed' CHECK (status IN ('planned', 'in_progress', 'completed', 'cancelled')),

  -- Clinical info
  surfaces TEXT, -- e.g., "MO", "DOL"
  materials_used TEXT,
  notes TEXT,

  -- Pricing
  price_total DECIMAL(10, 2),
  price_patient DECIMAL(10, 2),
  price_insurance DECIMAL(10, 2),

  -- Metadata
  performed_by UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_tooth_treatments_patient ON tooth_treatments(patient_id);
CREATE INDEX idx_tooth_treatments_date ON tooth_treatments(treatment_date DESC);
CREATE INDEX idx_tooth_treatments_tooth ON tooth_treatments(tooth_number);

-- ============================================
-- INAMI ACTS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS inami_acts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  -- INAMI nomenclature
  inami_code VARCHAR(10) NOT NULL,
  inami_description TEXT,

  -- Act details
  act_date DATE NOT NULL,
  tooth_number VARCHAR(5), -- FDI notation, optional
  quantity INTEGER DEFAULT 1,

  -- Pricing (Belgian nomenclature)
  tariff_convention DECIMAL(10, 2), -- Convention tariff
  tariff_honor DECIMAL(10, 2), -- Honor supplement
  patient_share DECIMAL(10, 2), -- Ticket modérateur
  insurance_share DECIMAL(10, 2), -- OA part
  total_amount DECIMAL(10, 2),

  -- Tiers payant
  tiers_payant BOOLEAN DEFAULT FALSE,
  tiers_payant_approved BOOLEAN DEFAULT FALSE,
  tiers_payant_approval_date TIMESTAMP WITH TIME ZONE,

  -- eAttest
  eattest_sent BOOLEAN DEFAULT FALSE,
  eattest_sent_date TIMESTAMP WITH TIME ZONE,
  eattest_reference VARCHAR(100),
  eattest_status VARCHAR(50),

  -- Metadata
  performed_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  invoiced BOOLEAN DEFAULT FALSE,
  invoice_id UUID
);

-- Indexes
CREATE INDEX idx_inami_acts_patient ON inami_acts(patient_id);
CREATE INDEX idx_inami_acts_date ON inami_acts(act_date DESC);
CREATE INDEX idx_inami_acts_code ON inami_acts(inami_code);
CREATE INDEX idx_inami_acts_eattest ON inami_acts(eattest_sent, eattest_status);

-- ============================================
-- PRESCRIPTIONS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS prescriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  -- Prescription content
  medications JSONB NOT NULL,
  -- Example:
  -- [
  --   {
  --     "name": "Amoxicilline 500mg",
  --     "dosage": "1 comprimé",
  --     "frequency": "3x/jour",
  --     "duration": "7 jours",
  --     "instructions": "À prendre pendant les repas"
  --   }
  -- ]

  -- Additional info
  diagnosis TEXT,
  notes TEXT,

  -- AI generation
  ai_generated BOOLEAN DEFAULT FALSE,
  ai_model VARCHAR(50),

  -- Delivery
  prescription_date DATE NOT NULL DEFAULT CURRENT_DATE,
  validity_end_date DATE,
  delivered BOOLEAN DEFAULT FALSE,
  delivered_date TIMESTAMP WITH TIME ZONE,

  -- Metadata
  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  pdf_url TEXT
);

-- Indexes
CREATE INDEX idx_prescriptions_patient ON prescriptions(patient_id);
CREATE INDEX idx_prescriptions_date ON prescriptions(prescription_date DESC);

-- ============================================
-- CERTIFICATES TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS certificates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  -- Certificate details
  type VARCHAR(50) NOT NULL CHECK (type IN (
    'work', 'school', 'sports', 'insurance', 'other'
  )),
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,

  -- Dates
  certificate_date DATE NOT NULL DEFAULT CURRENT_DATE,
  valid_from DATE,
  valid_to DATE,

  -- Delivery
  delivered BOOLEAN DEFAULT FALSE,
  delivered_date TIMESTAMP WITH TIME ZONE,

  -- Metadata
  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  pdf_url TEXT
);

-- Indexes
CREATE INDEX idx_certificates_patient ON certificates(patient_id);
CREATE INDEX idx_certificates_date ON certificates(certificate_date DESC);
CREATE INDEX idx_certificates_type ON certificates(type);

-- ============================================
-- APPOINTMENTS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS appointments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID REFERENCES patients(id) ON DELETE SET NULL,

  -- Appointment details
  appointment_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  duration_minutes INTEGER NOT NULL,

  -- Type and status
  type VARCHAR(100) NOT NULL, -- e.g., "Consultation", "Détartrage", "Urgence"
  status VARCHAR(50) DEFAULT 'scheduled' CHECK (status IN (
    'scheduled', 'confirmed', 'arrived', 'in_progress',
    'completed', 'cancelled', 'no_show'
  )),

  -- Details
  reason TEXT,
  notes TEXT,

  -- Reminders
  reminder_sent BOOLEAN DEFAULT FALSE,
  reminder_sent_date TIMESTAMP WITH TIME ZONE,

  -- Practitioner
  practitioner_id UUID,

  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID,
  cancelled_at TIMESTAMP WITH TIME ZONE,
  cancellation_reason TEXT
);

-- Indexes
CREATE INDEX idx_appointments_patient ON appointments(patient_id);
CREATE INDEX idx_appointments_date ON appointments(appointment_date, start_time);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_practitioner ON appointments(practitioner_id);

-- ============================================
-- STAFF PROFILES TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS staff_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Personal info
  role VARCHAR(50) NOT NULL CHECK (role IN (
    'OWNER', 'DENTIST', 'ASSISTANT', 'SECRETARY', 'HYGIENIST'
  )),
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  inami_number VARCHAR(20), -- For dentists
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20),

  -- Access control
  permissions JSONB DEFAULT '{}',
  active BOOLEAN DEFAULT TRUE,

  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_staff_email ON staff_profiles(email);
CREATE INDEX idx_staff_active ON staff_profiles(active);

-- ============================================
-- X-RAYS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS xrays (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  -- X-ray details
  xray_type VARCHAR(50) NOT NULL CHECK (xray_type IN (
    'periapical', 'bitewing', 'panoramic', 'cephalometric', 'cbct'
  )),
  tooth_number VARCHAR(5), -- FDI notation, if applicable
  xray_date DATE NOT NULL,

  -- Files
  image_url TEXT NOT NULL,
  thumbnail_url TEXT,
  dicom_url TEXT,
  file_size_kb INTEGER,

  -- AI Analysis
  ai_analysis TEXT,
  ai_confidence DECIMAL(5, 2),
  ai_findings JSONB,

  -- Metadata
  notes TEXT,
  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_xrays_patient ON xrays(patient_id);
CREATE INDEX idx_xrays_date ON xrays(xray_date DESC);
CREATE INDEX idx_xrays_type ON xrays(xray_type);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE anamnesis ENABLE ROW LEVEL SECURITY;
ALTER TABLE timeline_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE dental_charts ENABLE ROW LEVEL SECURITY;
ALTER TABLE tooth_treatments ENABLE ROW LEVEL SECURITY;
ALTER TABLE inami_acts ENABLE ROW LEVEL SECURITY;
ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE xrays ENABLE ROW LEVEL SECURITY;

-- Example RLS policies (adjust based on your auth setup)

-- Staff can read all patients
CREATE POLICY "Staff can view all patients"
  ON patients FOR SELECT
  USING (auth.role() = 'authenticated');

-- Staff can insert/update patients
CREATE POLICY "Staff can insert patients"
  ON patients FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Staff can update patients"
  ON patients FOR UPDATE
  USING (auth.role() = 'authenticated');

-- Only owners can delete patients
CREATE POLICY "Only owners can delete patients"
  ON patients FOR DELETE
  USING (auth.jwt() ->> 'role' = 'OWNER');

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Update updated_at timestamp automatically
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to relevant tables
CREATE TRIGGER update_patients_updated_at
  BEFORE UPDATE ON patients
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tooth_treatments_updated_at
  BEFORE UPDATE ON tooth_treatments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointments_updated_at
  BEFORE UPDATE ON appointments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_staff_profiles_updated_at
  BEFORE UPDATE ON staff_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- SEED DATA (Optional - for testing)
-- ============================================

-- Insert default staff member
INSERT INTO staff_profiles (role, first_name, last_name, inami_number, email, active)
VALUES
  ('OWNER', 'Ismail', 'Sialyen', '3-02462-81-001', 'is.sialyen@gmail.com', true)
ON CONFLICT (email) DO NOTHING;

-- ============================================
-- GRANTS (Adjust based on your setup)
-- ============================================

-- Grant usage on sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- Grant select/insert/update on tables to authenticated users
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO authenticated;

-- ============================================
-- END OF SCHEMA
-- ============================================

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ K2 Dent database schema created successfully!';
  RAISE NOTICE '📊 Tables created: 11';
  RAISE NOTICE '🔒 Row Level Security enabled';
  RAISE NOTICE '⚡ Triggers configured';
  RAISE NOTICE '';
  RAISE NOTICE 'Next steps:';
  RAISE NOTICE '1. Configure authentication (Supabase Auth)';
  RAISE NOTICE '2. Update RLS policies for your specific needs';
  RAISE NOTICE '3. Test with sample data';
END $$;

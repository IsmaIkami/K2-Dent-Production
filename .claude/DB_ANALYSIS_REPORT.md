# 📊 ANALYSE DB - K2-DENT-PRODUCTION vs TAG FONCTIONNEL

**Date:** 2026-07-23
**Tag Référence:** `v20260723_postlogin_fonctionne`
**Objectif:** Identifier écarts entre schéma DB actuel et schéma fonctionnel

---

## ✅ SCHÉMA FONCTIONNEL (Tag v20260723_postlogin_fonctionne)

### Tables Créées (11 tables)

1. **patients** - Informations patients
2. **anamnesis** - Historique anamnèses avec versioning
3. **timeline_events** - Événements chronologiques patient
4. **dental_charts** - Cartes dentaires (JSONB)
5. **tooth_treatments** - Traitements par dent
6. **inami_acts** - Actes INAMI avec nomenclature
7. **prescriptions** - Prescriptions médicales
8. **certificates** - Certificats médicaux
9. **appointments** - Rendez-vous
10. **staff_profiles** - Profils équipe médicale
11. **xrays** - Radiographies avec analyse AI

### Fonctions & Triggers

- `update_updated_at_column()` - Auto-update timestamp

### Row Level Security (RLS)

- ✅ Activé sur toutes les tables
- Policies pour authenticated users

---

## 📋 STRUCTURE DÉTAILLÉE DES TABLES

### 1. PATIENTS (Table Principale)

```sql
CREATE TABLE IF NOT EXISTS patients (
  id UUID PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  niss VARCHAR(15) UNIQUE NOT NULL,
  date_of_birth DATE NOT NULL,
  gender VARCHAR(10) CHECK (gender IN ('M', 'F', 'X', 'OTHER')),
  phone VARCHAR(20),
  mobile VARCHAR(20),
  email VARCHAR(255),

  -- Adresse
  address_street VARCHAR(255),
  address_city VARCHAR(100),
  address_zip VARCHAR(10),
  address_country VARCHAR(50) DEFAULT 'Belgium',

  -- Mutuelle
  mutuelle_name VARCHAR(100),
  mutuelle_code VARCHAR(10),
  mutuelle_membership VARCHAR(50),
  bim BOOLEAN DEFAULT FALSE,

  -- Médical
  allergies TEXT,
  medications TEXT,
  medical_conditions TEXT,
  emergency_contact_name VARCHAR(100),
  emergency_contact_phone VARCHAR(20),

  -- Préférences
  language VARCHAR(5) DEFAULT 'FR',
  preferred_communication VARCHAR(20) DEFAULT 'EMAIL',
  gdpr_consent BOOLEAN DEFAULT FALSE,
  gdpr_consent_date TIMESTAMP WITH TIME ZONE,
  marketing_consent BOOLEAN DEFAULT FALSE,

  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID,
  updated_by UUID,
  archived BOOLEAN DEFAULT FALSE,
  archived_at TIMESTAMP WITH TIME ZONE
);
```

**Indexes:**
- `idx_patients_niss`
- `idx_patients_last_name`
- `idx_patients_email`
- `idx_patients_archived`

---

### 2. ANAMNESIS (Historique Médical Versionné)

```sql
CREATE TABLE IF NOT EXISTS anamnesis (
  id UUID PRIMARY KEY,
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  -- Contenu
  content TEXT NOT NULL,
  version INTEGER DEFAULT 1,
  type VARCHAR(20) DEFAULT 'AI' CHECK (type IN ('AI', 'MANUAL', 'MODIFIED')),

  -- AI Metadata
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
```

**Indexes:**
- `idx_anamnesis_patient`
- `idx_anamnesis_created_at`

---

### 3. TIMELINE_EVENTS (Chronologie Patient)

```sql
CREATE TABLE IF NOT EXISTS timeline_events (
  id UUID PRIMARY KEY,
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  type VARCHAR(50) NOT NULL CHECK (type IN (
    'anamnesis', 'consultation', 'treatment', 'xray',
    'prescription', 'certificate', 'payment', 'appointment',
    'note', 'document'
  )),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  badge VARCHAR(50),

  related_id UUID,
  related_type VARCHAR(50),

  event_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID NOT NULL,
  archived BOOLEAN DEFAULT FALSE
);
```

**Indexes:**
- `idx_timeline_patient`
- `idx_timeline_date`
- `idx_timeline_type`

---

### 4. DENTAL_CHARTS (Carte Dentaire)

```sql
CREATE TABLE IF NOT EXISTS dental_charts (
  id UUID PRIMARY KEY,
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  chart_data JSONB NOT NULL,
  -- Structure: { "11": { "status": "healthy", "treatments": [], "notes": "" } }

  snapshot_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID NOT NULL,
  notes TEXT
);
```

**Indexes:**
- `idx_dental_charts_patient`
- `idx_dental_charts_date`

---

### 5. TOOTH_TREATMENTS (Traitements Dentaires)

```sql
CREATE TABLE IF NOT EXISTS tooth_treatments (
  id UUID PRIMARY KEY,
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  tooth_number VARCHAR(5) NOT NULL, -- FDI: 11-48

  treatment_type VARCHAR(100) NOT NULL,
  treatment_date DATE NOT NULL,
  inami_code VARCHAR(10),
  status VARCHAR(50) DEFAULT 'completed' CHECK (status IN
    ('planned', 'in_progress', 'completed', 'cancelled')),

  surfaces TEXT, -- "MO", "DOL"
  materials_used TEXT,
  notes TEXT,

  price_total DECIMAL(10, 2),
  price_patient DECIMAL(10, 2),
  price_insurance DECIMAL(10, 2),

  performed_by UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Indexes:**
- `idx_tooth_treatments_patient`
- `idx_tooth_treatments_date`
- `idx_tooth_treatments_tooth`

---

### 6. INAMI_ACTS (Nomenclature INAMI)

```sql
CREATE TABLE IF NOT EXISTS inami_acts (
  id UUID PRIMARY KEY,
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  inami_code VARCHAR(10) NOT NULL,
  inami_description TEXT,

  act_date DATE NOT NULL,
  tooth_number VARCHAR(5),
  quantity INTEGER DEFAULT 1,

  -- Pricing
  tariff_convention DECIMAL(10, 2),
  tariff_honor DECIMAL(10, 2),
  patient_share DECIMAL(10, 2),
  insurance_share DECIMAL(10, 2),
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

  performed_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  invoiced BOOLEAN DEFAULT FALSE,
  invoice_id UUID
);
```

**Indexes:**
- `idx_inami_acts_patient`
- `idx_inami_acts_date`
- `idx_inami_acts_code`
- `idx_inami_acts_eattest`

---

### 7. PRESCRIPTIONS (Ordonnances)

```sql
CREATE TABLE IF NOT EXISTS prescriptions (
  id UUID PRIMARY KEY,
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  prescription_date DATE NOT NULL,
  medications JSONB NOT NULL,
  -- Structure: [{ "name": "...", "dosage": "...", "duration": "..." }]

  notes TEXT,
  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

### 8. CERTIFICATES (Certificats Médicaux)

```sql
CREATE TABLE IF NOT EXISTS certificates (
  id UUID PRIMARY KEY,
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  certificate_date DATE NOT NULL,
  certificate_type VARCHAR(50) NOT NULL,
  content TEXT NOT NULL,

  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

### 9. APPOINTMENTS (Rendez-vous)

```sql
CREATE TABLE IF NOT EXISTS appointments (
  id UUID PRIMARY KEY,
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  appointment_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  duration_minutes INTEGER NOT NULL,

  appointment_type VARCHAR(50) NOT NULL,
  status VARCHAR(50) DEFAULT 'scheduled' CHECK (status IN
    ('scheduled', 'confirmed', 'completed', 'cancelled', 'no_show')),

  reason TEXT,
  notes TEXT,

  reminder_sent BOOLEAN DEFAULT FALSE,
  reminder_sent_date TIMESTAMP WITH TIME ZONE,

  practitioner_id UUID,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID,
  cancelled_at TIMESTAMP WITH TIME ZONE,
  cancellation_reason TEXT
);
```

**Indexes:**
- `idx_appointments_patient`
- `idx_appointments_date`
- `idx_appointments_status`
- `idx_appointments_practitioner`

---

### 10. STAFF_PROFILES (Équipe Médicale)

```sql
CREATE TABLE IF NOT EXISTS staff_profiles (
  id UUID PRIMARY KEY,

  role VARCHAR(50) NOT NULL CHECK (role IN
    ('OWNER', 'DENTIST', 'ASSISTANT', 'SECRETARY', 'HYGIENIST')),
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  inami_number VARCHAR(20),
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20),

  permissions JSONB DEFAULT '{}',
  active BOOLEAN DEFAULT TRUE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Indexes:**
- `idx_staff_email`
- `idx_staff_active`

---

### 11. XRAYS (Radiographies)

```sql
CREATE TABLE IF NOT EXISTS xrays (
  id UUID PRIMARY KEY,
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  xray_type VARCHAR(50) NOT NULL CHECK (xray_type IN
    ('periapical', 'bitewing', 'panoramic', 'cephalometric', 'cbct')),
  tooth_number VARCHAR(5),
  xray_date DATE NOT NULL,

  image_url TEXT NOT NULL,
  thumbnail_url TEXT,
  dicom_url TEXT,
  file_size_kb INTEGER,

  ai_analysis TEXT,
  ai_confidence DECIMAL(5, 2),
  ai_findings JSONB,

  notes TEXT,
  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Indexes:**
- `idx_xrays_patient`
- `idx_xrays_date`
- `idx_xrays_type`

---

## ⚠️ TABLES MANQUANTES DANS LE CODE

Le code `supabase-client.js` fait référence à ces tables **NON présentes** dans le schéma fonctionnel:

### 1. `medical_history` ❌

**Utilisée dans:** `supabase-client.js`
- `getLatestMedicalHistory()`
- `getAllMedicalHistory()`
- `saveMedicalHistory()`

**Fonction RPC appelée:**
- `create_medical_history_version()`

**STATUS:** ⚠️ Table absente du schéma - code ne fonctionnera pas

---

### 2. `patient_complete_view` ❌

**Utilisée dans:** `supabase-client.js`
- `getPatientCompleteView()`

**STATUS:** ⚠️ Vue absente du schéma - code ne fonctionnera pas

---

## 📝 RÉSUMÉ DES ÉCARTS

### ✅ Ce qui FONCTIONNE (11 tables présentes)
- `patients`
- `anamnesis`
- `timeline_events`
- `dental_charts`
- `tooth_treatments`
- `inami_acts`
- `prescriptions`
- `certificates`
- `appointments`
- `staff_profiles`
- `xrays`

### ❌ Ce qui MANQUE (code mais pas DB)
- `medical_history` table
- `create_medical_history_version()` fonction
- `patient_complete_view` vue

---

## 🎯 RECOMMANDATION

**Option 1: Utiliser le schéma fonctionnel tel quel**
- ✅ Exécuter `/tmp/schema_working_v20260723.sql` dans Supabase
- ✅ Commenter temporairement le code `medical_history` dans `supabase-client.js`
- ✅ Tout fonctionne immédiatement

**Option 2: Créer les objets manquants**
- Créer table `medical_history`
- Créer fonction `create_medical_history_version()`
- Créer vue `patient_complete_view`
- Adapter le code

**Je recommande:** **Option 1** pour restaurer immédiatement le fonctionnement ✅

---

**Rapport généré le:** 2026-07-23
**Prochaine étape:** Générer script SQL de migration

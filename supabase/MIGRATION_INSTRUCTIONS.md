# Migration Instructions - Anamneses Table

## How to Execute Migration 006

### Option 1: Supabase Dashboard (Recommended)

1. Go to https://supabase.com/dashboard
2. Select your project: `zkjhemeysleurnvqsclq`
3. Click on "SQL Editor" in the left sidebar
4. Click "New Query"
5. Copy the entire content of `migrations/006_create_anamneses_table.sql`
6. Paste into the SQL editor
7. Click "Run" (or press Cmd/Ctrl + Enter)
8. Verify success: "Success. No rows returned"

### Option 2: Supabase CLI

```bash
cd ~/K2-Dent-Production
supabase db push
```

### Option 3: Manual SQL Execution

Copy and execute this SQL in Supabase SQL Editor:

```sql
-- (Content of 006_create_anamneses_table.sql)
```

## Verification

After running the migration, verify the table was created:

```sql
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'anamneses'
ORDER BY ordinal_position;
```

You should see all columns:
- id, patient_id, anamnesis_date, practitioner_name, etc.

## Test Data (Optional)

Insert a test anamnesis:

```sql
INSERT INTO anamneses (
    patient_id,
    anamnesis_date,
    chief_complaint,
    medical_conditions,
    oral_hygiene_score,
    periodontal_status,
    clinical_notes
) VALUES (
    (SELECT id FROM patients LIMIT 1), -- Takes first patient
    CURRENT_DATE,
    'Routine checkup',
    ARRAY['none']::TEXT[],
    7,
    'healthy',
    'Patient in good oral health. Continue regular checkups.'
);
```

## Rollback (if needed)

To remove the table:

```sql
DROP TABLE IF EXISTS anamneses CASCADE;
```

---

**Status:** Ready to execute
**Dependencies:** Requires `patients` table to exist
**Next Step:** Run migration, then test frontend integration

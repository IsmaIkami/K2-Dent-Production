# 🔍 PEER REVIEW - MVP Production Launch
**Date:** 2026-07-24
**Reviewer:** Analyse technique senior
**Documents analysés:** MVP_SPEC.md, complete-schema-final.sql, ai-appointment-reminders.sql, GitHub Issue #1

---

## 📊 Score Global: 6.5/10

**Verdict:** Spec solide mais **INCOHÉRENCES CRITIQUES** entre spec et code existant. Nécessite réconciliation avant implémentation.

---

## ✅ Points Forts

### 1. Documentation Exhaustive (9/10)
- ✅ 830 lignes MVP_SPEC.md très complète
- ✅ Architecture technique détaillée avec rationale
- ✅ Code samples SQL, TypeScript, bash
- ✅ Questions techniques identifiées (5 pending)
- ✅ Critères acceptation MVP clairs
- ⚠️ **Mais:** Incohérences avec code existant non détectées

### 2. Approche 100% Free Tier (8/10)
- ✅ Supabase Free (500MB + 1GB + 500K functions)
- ✅ SendGrid Free (100 emails/day)
- ✅ GitHub Actions (2000 min/month)
- ✅ Puppeteer gratuit sur Edge Functions
- ✅ Budget €0/mois respecté
- ⚠️ **Risque:** Limite SendGrid 100/jour peut bloquer clinic >100 RDV/jour

### 3. Choix Puppeteer PDF (9/10)
- ✅ Justification solide (industrie médicale standard)
- ✅ Exemples code concrets
- ✅ HIPAA-adjacent compliance
- ✅ Multi-page, fonts médicales, QR codes
- ✅ Meilleur que jsPDF client-side

### 4. GitHub Issue Kanban (7/10)
- ✅ Structure 6 epics claire
- ✅ Checkboxes interactives
- ✅ Questions techniques inline
- ⚠️ **Manque:** Labels GitHub (epic, mvp échoué), milestones, assignees

---

## 🚨 PROBLÈMES CRITIQUES

### 🔴 CRITIQUE #1: Duplication Table INAMI (BLOQUANT)

**Problème:**
- MVP_SPEC.md propose `tooth_treatments` avec colonne `inami_code` (ligne 83-97 spec)
- `complete-schema-final.sql` crée **DEUX tables distinctes:**
  - `tooth_treatments` (ligne 80-97) avec `inami_code VARCHAR(10)`
  - `inami_acts` (ligne 191-213) table COMPLÈTE nomenclature INAMI
- **= DUPLICATION DE DONNÉES** → Risque désynchronisation

**Impact:** ÉLEVÉ - Facturation incohérente, CSV eAttest faux

**Solution recommandée:**
```sql
-- Option A: Merger dans tooth_treatments (simple)
ALTER TABLE tooth_treatments
ADD COLUMN tariff_convention DECIMAL(10,2),
ADD COLUMN tariff_honor DECIMAL(10,2),
ADD COLUMN patient_share DECIMAL(10,2),
ADD COLUMN insurance_share DECIMAL(10,2),
ADD COLUMN eattest_sent BOOLEAN DEFAULT FALSE;

DROP TABLE inami_acts; -- Supprimer doublon

-- Option B: Garder inami_acts, supprimer tooth_treatments.inami_code
-- tooth_treatments devient générique (pas que INAMI)
-- inami_acts = table officielle facturation
```

**Décision requise:** A ou B ?

---

### 🔴 CRITIQUE #2: Table `users` Custom vs Supabase Auth (BLOQUANT)

**Problème:**
- `complete-schema-final.sql` ligne 107-118 crée table `users` custom:
  ```sql
  CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,  -- ❌ DUPLIQUE Supabase Auth!
    ...
  );
  ```
- **Supabase Auth a déjà une table `auth.users`** (service managé)
- = **DUPLICATION AUTHENTIFICATION** → Security nightmare

**Impact:** CRITIQUE - 2FA impossible, auth cassée, faille sécurité

**Solution recommandée:**
```sql
-- SUPPRIMER table users custom
DROP TABLE users CASCADE;

-- Utiliser auth.users (Supabase Auth natif)
-- Lier staff_profiles:
ALTER TABLE staff_profiles
ADD COLUMN user_id UUID UNIQUE REFERENCES auth.users(id);

-- Toutes les FK created_by → auth.users(id)
```

**MVP_SPEC.md ligne 75-80 a RAISON:**
```sql
ALTER TABLE staff_profiles
ADD COLUMN IF NOT EXISTS user_id UUID UNIQUE REFERENCES users(id);
```
**Mais devrait être `auth.users(id)` pas `users(id)`**

---

### 🟠 CRITIQUE #3: DROP CASCADE = Migration Destructive (BLOQUANT)

**Problème:**
- MVP_SPEC.md recommande "incremental migration" (ligne 21):
  ```
  Incremental approach: CREATE TABLE IF NOT EXISTS,
  ALTER TABLE ADD COLUMN IF NOT EXISTS
  ```
- **MAIS** `complete-schema-final.sql` utilise:
  ```sql
  DROP TABLE IF EXISTS tooth_treatments CASCADE; -- ligne 78
  DROP TABLE IF EXISTS dental_charts CASCADE;    -- ligne 173
  ```
- = **PERTE DE DONNÉES** si tables existent

**Impact:** ÉLEVÉ - Effacement données production

**Solution:**
```sql
-- Remplacer tous DROP TABLE par:
CREATE TABLE IF NOT EXISTS tooth_treatments (...);

-- Si schema change, utiliser:
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'tooth_treatments'
                 AND column_name = 'inami_code') THEN
    ALTER TABLE tooth_treatments ADD COLUMN inami_code VARCHAR(10);
  END IF;
END $$;
```

**Contradiction spec/code:** MVP_SPEC.md dit "incremental", code SQL dit "destructive"

---

### 🟠 CRITIQUE #4: Schéma `appointment_reminders` Incohérent

**Problème:**

**MVP_SPEC.md** (ligne 12-36):
```sql
CREATE TABLE appointment_reminders (
  id UUID PRIMARY KEY,
  appointment_id UUID REFERENCES appointments(id),
  reminder_type VARCHAR(20),  -- email uniquement
  scheduled_send_time TIMESTAMP,
  ai_priority_score DECIMAL(3,2),
  template_data JSONB  -- ← Juste variables template
);
```

**ai-appointment-reminders.sql** (ligne 9-35):
```sql
CREATE TABLE appointment_reminders (
  id UUID,
  appointment_id UUID REFERENCES appointments(id),
  patient_id UUID REFERENCES patients(id),  -- ❌ REDONDANT (appointment lie déjà patient)
  reminder_type VARCHAR(20) CHECK (reminder_type IN ('SMS', 'EMAIL', 'WHATSAPP', 'PHONE')),  -- ❌ SMS/WHATSAPP payant!
  reminder_timing VARCHAR(50) CHECK (...),  -- ❌ Complexe, pas dans spec
  message_content TEXT NOT NULL,  -- ❌ Stockage message complet (pas template)
  recipient VARCHAR(255),  -- ❌ Duplique patient.email
  ai_score FLOAT,  -- ⚠️ Naming: ai_score vs ai_priority_score
  ...
);
```

**Incohérences:**
1. `patient_id` redondant (JOIN via appointment)
2. `SMS`, `WHATSAPP`, `PHONE` non supportés free tier (MVP_SPEC dit EMAIL only)
3. `message_content` stocké complet → devrait être généré à la volée depuis template
4. `reminder_timing` ENUM complexe pas dans spec
5. `recipient` duplique `patients.email`

**Impact:** MOYEN - Fonctionne mais gaspillage DB, options payantes confusantes

**Solution:**
```sql
-- Aligner sur MVP_SPEC (simple, free tier)
CREATE TABLE appointment_reminders (
  id UUID PRIMARY KEY,
  appointment_id UUID NOT NULL REFERENCES appointments(id),
  reminder_type VARCHAR(20) DEFAULT 'email',  -- Seulement EMAIL
  scheduled_send_time TIMESTAMP WITH TIME ZONE NOT NULL,
  sent_at TIMESTAMP WITH TIME ZONE,
  status VARCHAR(20) DEFAULT 'pending',
  ai_priority_score DECIMAL(3,2),  -- 0.60 à 0.95
  template_data JSONB  -- { "patient_name": "...", "date": "..." }
);

-- patient_id, email, message_content = JOIN runtime, pas stocké
```

---

### 🟡 CRITIQUE #5: Table `certificates` Schema Différent

**MVP_SPEC.md:**
```sql
CREATE TABLE certificates (
  certificate_type VARCHAR(100),  -- sick_leave, fitness, dental_treatment
  start_date DATE,
  end_date DATE,
  reason TEXT,
  pdf_url TEXT
);
```

**complete-schema-final.sql ligne 241-257:**
```sql
CREATE TABLE certificates (
  type VARCHAR(50) NOT NULL,  -- ⚠️ Naming: type vs certificate_type
  title VARCHAR(255) NOT NULL,  -- ❌ PAS dans spec
  content TEXT NOT NULL,  -- ❌ PAS dans spec (remplace reason?)
  certificate_date DATE,  -- ⚠️ Une date vs start/end
  valid_from DATE,  -- ⚠️ Renommé
  valid_to DATE,  -- ⚠️ Renommé
  delivered BOOLEAN,  -- ❌ PAS dans spec
  pdf_url TEXT
);
```

**Impact:** FAIBLE - Structure différente mais fonctionne

**Recommandation:** Choisir UNE spec et s'y tenir:
- Spec MVP (simple): `certificate_type`, `start_date`, `end_date`, `reason`
- OU Spec SQL (riche): `type`, `title`, `content`, `valid_from`, `valid_to`, `delivered`

---

### 🟡 CRITIQUE #6: Table `xrays` - Champ `ai_analysis` Type Différent

**MVP_SPEC.md:**
```sql
CREATE TABLE xrays (
  ai_analysis JSONB  -- { "notes": "..." } (manuel MVP)
);
```

**complete-schema-final.sql ligne 292:**
```sql
CREATE TABLE xrays (
  ai_analysis TEXT,  -- ❌ TEXT au lieu de JSONB
  ai_confidence DECIMAL(5,2),  -- ❌ PAS dans spec
  ai_findings JSONB  -- ❌ PAS dans spec
);
```

**Impact:** FAIBLE - TEXT fonctionne mais JSONB meilleur (queryable)

**Recommandation:**
```sql
ALTER TABLE xrays
ALTER COLUMN ai_analysis TYPE JSONB USING ai_analysis::jsonb;
-- Uniformiser sur JSONB
```

---

### 🟡 CRITIQUE #7: Chaos Migrations (20+ Fichiers SQL)

**Problème:**
```
supabase/migrations/007_add_notification_tracking.sql
supabase/migrations/006_create_anamneses_table.sql
supabase/migrations/20260723_medical_history.sql
supabase/migrations/20260724_rename_type_to_appointment_type.sql
supabase/complete-schema-final.sql
supabase/migration-simple.sql
supabase/MIGRATION_TO_WORKING_STATE.sql
supabase/MIGRATION_TO_WORKING_STATE_FIXED.sql
supabase/complete-migration.sql
supabase/complete-schema-v3-fixed.sql
...
```

**= 20+ fichiers SQL migration non versionnés**

**Impact:** MOYEN - Impossible de savoir quelle est la "source of truth"

**Solution:**
1. **Supprimer tous les fichiers** sauf ONE source of truth
2. Créer `supabase/migrations/001_initial_schema.sql` (Supabase convention)
3. Versioning incrémental: `002_add_xrays.sql`, `003_add_reminders.sql`
4. MVP_SPEC.md pointe vers `migrations/` comme référence

---

## ⚠️ PROBLÈMES MAJEURS (Non-Bloquants)

### 1. RLS Policies "dev-open" = Security Risk (IMPORTANT)

**MVP_SPEC.md ligne 85:**
```
RLS policies: dev-open for MVP (tighten post-launch)
```

**Problème:** Aucune RLS = **TOUTES données accessibles** via API publique

**Risque:** Patient A peut lire dossier Patient B (RGPD violation)

**Solution temporaire MVP:**
```sql
-- RLS minimum (médecins seulement)
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Staff can view all patients"
ON patients FOR SELECT
TO authenticated
USING (auth.uid() IN (SELECT user_id FROM staff_profiles WHERE active = true));

-- Idem pour prescriptions, xrays, dental_charts, etc.
```

**Recommandation:** Ajouter Epic 0.5 (30min) pour RLS basique avant Phase 1

---

### 2. Puppeteer Timeout Edge Functions (RISQUE TECHNIQUE)

**MVP_SPEC.md assume:**
- PDF generation < 5s (ligne 820)

**Réalité Supabase Edge Functions:**
- Timeout max: **150 secondes** (2.5 min) [OK]
- Cold start: 5-10s first invocation
- Puppeteer launch: 2-3s
- PDF complex: 3-10s

**Risque:** Prescription 20 médicaments = timeout ?

**Solution:**
```typescript
// Edge Function avec timeout handling
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 30000); // 30s max

try {
  const pdf = await page.pdf({ format: 'A4', signal: controller.signal });
} catch (err) {
  if (err.name === 'AbortError') {
    // Fallback: simple HTML template sans Puppeteer
    return generateSimplePDF(data);
  }
}
```

**Recommandation:** Tester Puppeteer performance AVANT Phase 2 (epic 1.5)

---

### 3. SendGrid 100/day Overflow - Pas de Solution Implémentée

**MVP_SPEC.md Question #1:**
> SendGrid 100/day overflow ? → Priorité IA + queue FIFO

**Problème:** Aucun code implémenté pour queue/cap

**Impact:** Clinic 150 RDV/jour = 50 patients sans rappel

**Solution:**
```sql
-- View avec LIMIT 100 priorité IA
CREATE VIEW sendgrid_queue_daily AS
SELECT * FROM appointment_reminders
WHERE status = 'pending'
  AND scheduled_send_time <= NOW()
ORDER BY ai_priority_score DESC
LIMIT 100;  -- Hard cap free tier
```

```typescript
// Edge Function cron
const reminders = await supabase
  .from('sendgrid_queue_daily')
  .select('*');

// Send max 100, reste pending pour demain
```

**Recommandation:** Implémenter queue dans Epic 5 (pas juste mention)

---

### 4. Pas de Supabase CLI Config (`supabase/config.toml`)

**MVP_SPEC.md Epic 2.1:**
> Setup Supabase CLI local (`supabase init`)

**Problème:** Aucun fichier `supabase/config.toml` existant

**Impact:** `supabase functions serve` échouera

**Solution:**
```bash
cd /Users/isma/K2-Dent-Production
supabase init  # Génère config.toml
supabase link --project-ref sqgxscrwcffjfomlsoyf
```

**Recommandation:** Ajouter task Epic 2.0 "Init Supabase CLI config"

---

### 5. EPC QR Code Format Incomplet

**MVP_SPEC.md ligne 39:**
```
BCD|002|1|SCT||[Nom]|[IBAN]|EUR[Montant]|||[Référence]
```

**Standard EPC réel:** 12 lignes, pas 1 ligne pipe-separated

```
BCD
002
1
SCT
[BIC]
[Nom bénéficiaire]
[IBAN bénéficiaire]
EUR[Montant]
[Purpose code]
[Référence structurée]
[Remittance info unstructured]
[Beneficiary to originator info]
```

**Impact:** QR code non-scannable banking apps

**Solution:**
```typescript
// Correct EPC format
const epcData = [
  'BCD',
  '002',
  '1',
  'SCT',
  '',  // BIC optionnel
  doctor.name,
  doctor.iban,
  `EUR${total.toFixed(2)}`,
  '',  // Purpose
  invoice.reference,
  `Facture ${invoice.id}`,
  ''
].join('\n');  // ← NEWLINES, pas pipes!
```

**Recommandation:** Fix Epic 2.4 code sample

---

### 6. Three.js STL Viewer - Pas de Gestion Fichiers Lourds

**MVP_SPEC.md assume:**
- STL viewer load < 3s (ligne 820)

**Réalité STL dentaire:**
- Scan intraorale full jaw: 50-200 MB
- Three.js parse: O(n) vertices
- Render 2M triangles = freeze browser

**Solution:**
```javascript
// Lazy loading + decimation
const loader = new STLLoader();
loader.load(url, (geometry) => {
  if (geometry.attributes.position.count > 500000) {
    // Decimate pour performance
    geometry = decimateGeometry(geometry, 0.5);
  }
  const mesh = new THREE.Mesh(geometry, material);
  scene.add(mesh);
});
```

**Recommandation:** Ajouter task Epic 3.4 "STL compression/decimation"

---

## 🔧 AMÉLIORATIONS RECOMMANDÉES

### Architecture

1. **Créer ADR (Architecture Decision Records)**
   ```
   docs/adr/001-puppeteer-pdf.md
   docs/adr/002-free-tier-only.md
   docs/adr/003-no-sms-reminders.md
   ```
   Rationale + trade-offs + alternatives considered

2. **Diagramme Architecture**
   ```
   docs/architecture-mvp.excalidraw
   ```
   Frontend → Supabase → Edge Functions → SendGrid
   (Visual manque dans spec)

3. **Data Flow Diagrams**
   Cycle de vie patient = 9 étapes → créer flowchart
   Puppeteer PDF generation → sequence diagram

### Code Quality

4. **TypeScript Types Supabase**
   ```bash
   supabase gen types typescript --project-id sqgxscrwcffjfomlsoyf > types/database.ts
   ```
   Type safety Edge Functions

5. **ESLint + Prettier Config**
   ```json
   // .eslintrc.json
   {
     "extends": ["eslint:recommended", "plugin:@typescript-eslint/recommended"],
     "rules": { "no-console": "warn" }
   }
   ```

6. **Git Hooks Pre-commit**
   ```bash
   # .husky/pre-commit
   npm run lint
   npm run test
   ```

### Testing (MANQUE CRITIQUE)

7. **Aucun Test Mentionné!**
   - MVP_SPEC.md = 0 mention tests
   - GitHub Issue = 0 task testing

   **Recommandation:**
   ```
   Epic 7: Testing (2h)
   - [ ] Unit tests Edge Functions (Deno.test)
   - [ ] Integration tests Supabase (pgTAP)
   - [ ] E2E tests frontend (Playwright)
   - [ ] Load test SendGrid (100 emails burst)
   ```

8. **CI/CD Pipeline**
   ```yaml
   # .github/workflows/ci.yml
   name: CI
   on: [push, pull_request]
   jobs:
     test:
       runs-on: ubuntu-latest
       steps:
         - run: deno test functions/**/*_test.ts
         - run: supabase db test
   ```

### Documentation

9. **README.md Principal Manquant**
   - Aucun README.md root
   - Nouveau dev = perdu

   **Créer:**
   ```markdown
   # K2 Dental Cockpit

   ## Quick Start
   1. `git clone ...`
   2. `supabase link ...`
   3. `supabase db push`

   ## Stack
   - Supabase Free (PostgreSQL + Auth + Storage + Functions)
   - Vanilla JS frontend
   - Puppeteer PDF generation
   - SendGrid email (100/day)

   ## Docs
   - [MVP Spec](MVP_SPEC.md)
   - [Migration Guide](supabase/README_MIGRATION.md)
   - [GitHub Issue #1](https://github.com/IsmaIkami/K2-Dent-Production/issues/1)
   ```

10. **CHANGELOG.md**
    ```markdown
    # Changelog

    ## [Unreleased]
    - Epic 1: Database Migration
    - Epic 2: PDF Generation

    ## [0.1.0] - 2026-07-24
    - Initial spec MVP
    ```

### Sécurité

11. **`.env.example` Template**
    ```bash
    # .env.example
    SUPABASE_URL=https://xxx.supabase.co
    SUPABASE_ANON_KEY=eyJ...
    SENDGRID_API_KEY=SG.xxx
    ```
    (Actuellement keys hardcodées config.js ligne 11-12)

12. **Content Security Policy**
    ```html
    <meta http-equiv="Content-Security-Policy"
          content="default-src 'self'; script-src 'self' https://cdn.jsdelivr.net">
    ```

---

## 📋 CHECKLIST AVANT IMPLÉMENTATION

### Must Fix (Bloquants)

- [ ] **CRITIQUE #1:** Résoudre duplication `inami_acts` vs `tooth_treatments`
- [ ] **CRITIQUE #2:** Supprimer table `users` custom, utiliser `auth.users`
- [ ] **CRITIQUE #3:** Remplacer DROP CASCADE par incremental migration
- [ ] **CRITIQUE #4:** Aligner schéma `appointment_reminders` (supprimer SMS/WhatsApp)
- [ ] Nettoyer chaos migrations (1 seul `001_initial_schema.sql`)
- [ ] Ajouter RLS policies basiques (Epic 0.5 - 30min)
- [ ] Fix EPC QR code format (newlines pas pipes)
- [ ] Créer `supabase/config.toml` (supabase init)

### Should Fix (Recommandé)

- [ ] Uniformiser naming: `certificate_type` vs `type`
- [ ] Changer `xrays.ai_analysis` TEXT → JSONB
- [ ] Implémenter queue SendGrid 100/day (code, pas juste mention)
- [ ] Ajouter timeout handling Puppeteer
- [ ] STL viewer decimation gros fichiers
- [ ] Créer README.md root
- [ ] Ajouter Epic 7: Testing (2h)

### Nice to Have (Optionnel)

- [ ] ADR documents (rationale decisions)
- [ ] Diagrammes architecture (Excalidraw)
- [ ] TypeScript types Supabase gen
- [ ] ESLint + Prettier config
- [ ] Git hooks pre-commit
- [ ] CI/CD GitHub Actions
- [ ] CHANGELOG.md
- [ ] .env.example template
- [ ] Content Security Policy headers

---

## 🎯 RECOMMANDATIONS POUR FUTURES SESSIONS

### Session 1: Réconciliation Schéma (URGENT - 2h)

**Objectif:** Aligner MVP_SPEC.md avec code SQL existant

**Tasks:**
1. Décider: Garder `inami_acts` OU merger dans `tooth_treatments` ?
2. Supprimer table `users` custom → utiliser `auth.users`
3. Remplacer tous DROP CASCADE par CREATE IF NOT EXISTS
4. Consolider 20+ migrations → 1 seul `001_initial_schema.sql`
5. Mettre à jour MVP_SPEC.md avec schéma FINAL réconcilié

**Output:** `SCHEMA_RECONCILIATION.md` avec décisions

---

### Session 2: Epic 0 - Préparation Infrastructure (1h)

**Avant Phase 1:**
1. `supabase init` + link project
2. Créer `migrations/001_initial_schema.sql`
3. RLS policies basiques (staff only)
4. README.md root
5. .env.example

---

### Session 3: Testing Strategy (1h)

**Définir:**
1. Quels tests sont MUST (bloquent merge) vs NICE (CI warning)
2. Couverture target (80% Edge Functions, 60% SQL, 0% frontend acceptable MVP)
3. Tools: Deno.test, pgTAP, Playwright ?
4. Où tests vont (supabase/tests/, functions/**/*_test.ts) ?

---

### Session 4: Exécution Epics 1-6

**Avec spec réconciliée:**
- Suivre GitHub Issue #1 checklist
- 1 commit par task complétée
- Author: "Ismail Sialyen" (jamais Claude)
- Tests inline (si décidé Session 3)

---

## 📈 Métriques Qualité Spec

| Critère | Score | Commentaire |
|---------|-------|-------------|
| **Complétude** | 8/10 | Très détaillée, manque tests |
| **Clarté** | 9/10 | Excellente structure, code samples |
| **Cohérence** | 4/10 | ⚠️ Incohérences majeures spec/code |
| **Faisabilité** | 7/10 | Réaliste free tier, risques identifiés |
| **Maintenabilité** | 5/10 | Chaos migrations, pas de versioning |
| **Sécurité** | 3/10 | RLS dev-open, users custom, keys hardcodées |
| **Performance** | 6/10 | Timeouts potentiels, STL lourds |
| **Documentation** | 7/10 | Spec détaillée, manque README/ADR |

**Score Global: 6.5/10** — Bonne base mais NÉCESSITE réconciliation critique

---

## 🚀 CONCLUSION

**MVP_SPEC.md est une excellente spec technique** (830 lignes, détaillée, rationale solide) **MAIS elle ne reflète PAS le code SQL existant**.

**3 blockers critiques avant implémentation:**

1. **Duplication INAMI** (inami_acts vs tooth_treatments)
2. **Table users custom** (conflits Supabase Auth)
3. **Migrations destructives** (DROP CASCADE vs incremental)

**Recommandation:** **NE PAS commencer Phase 1** avant Session 1 (Réconciliation Schéma).

**Risque:** Implémenter la spec actuelle = écraser données existantes + conflits auth + facturation cassée.

**Action immédiate:** Créer `SCHEMA_RECONCILIATION.md` avec décisions finales, puis mettre à jour MVP_SPEC.md.

---

**Review complétée:** 2026-07-24
**Reviewer:** Peer Review Senior
**Next:** Session 1 - Réconciliation Schéma

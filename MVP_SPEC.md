# K2 Dental Cockpit - MVP Production Launch
**Spécification Technique Complète**

---

## 📋 Vue d'ensemble

**Projet:** K2 Dental Cockpit - Système de gestion pour clinique dentaire belge
**Objectif MVP:** Déploiement production avec cycle de vie patient complet
**Contrainte budgétaire:** €0/mois (100% free tier)
**Effort estimé:** 13 heures d'implémentation
**Auteur:** Ismail Sialyen

### Périmètre MVP

Cycle de vie patient complet de bout en bout:
1. **Booking** → Prise de rendez-vous avec calendrier
2. **Anamnèse** → Questionnaire médical patient
3. **Carte dentaire** → Visualisation et édition des dents (JSONB)
4. **Prescriptions** → Génération PDF médicaments avec Puppeteer
5. **Radiographies** → Upload et viewer 3D STL avec Three.js
6. **Certificats** → Génération PDF certificats médicaux
7. **Timeline** → Journal d'audit des événements patient
8. **Facturation INAMI** → Export CSV pour eAttest (nomenclature belge)
9. **Factures** → PDF avec QR code EPC (virements bancaires)
10. **Rappels rendez-vous** → Email automatisés via SendGrid avec scoring IA

### Utilisateurs MVP

- ✅ **Médecins/Staff:** Accès complet avec 2FA (Supabase Auth)
- ❌ **Patients:** Aucun accès pour MVP (future phase)

---

## 🏗 Architecture Technique

### Stack Technologique (100% Free Tier)

#### Backend
- **Supabase Free Tier:**
  - PostgreSQL: 500MB base de données
  - Storage: 1GB fichiers (PDF, STL, images)
  - Edge Functions: 500K invocations/mois
  - Auth: 2FA inclus
  - Row Level Security (RLS): dev-open pour MVP

#### Frontend
- **Vanilla JavaScript** (pas de framework, zéro overhead)
- **Three.js** pour viewer 3D STL (radiographies)
- **Éditeur JSONB** pour carte dentaire (dental-chart-v2.html existant)

#### Services Externes
- **SendGrid Free:** 100 emails/jour (rappels rendez-vous)
- **GitHub Actions:** 2000 minutes/mois (backups automatiques)
- **Puppeteer (Deno):** Génération PDF server-side sur Edge Functions

#### Standards & Compliance
- **EPC QR Code:** Standard européen virements SEPA
- **INAMI:** Nomenclature dentaire belge (codes prestations)
- **HIPAA-adjacent:** PHI jamais exposé côté client, PDF server-side

---

## 🗄 Schéma Base de Données

### Tables Existantes (5)
Baseline: `BACKUP_STEP5_CALENDAR_FULLY_WORKING_20260724.sql`

1. **users** - Authentification Supabase Auth
2. **patients** - Données démographiques patients
3. **anamnesis** - Questionnaires médicaux
4. **medical_history** - Historique médical
5. **appointments** - Calendrier rendez-vous

### Tables à Créer (6 core)
Source: `complete-schema-final.sql`

6. **dental_charts**
   ```sql
   CREATE TABLE dental_charts (
     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
     patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
     chart_data JSONB NOT NULL,  -- Structure: { "teeth": { "11": {...}, "12": {...} } }
     snapshot_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
     created_by UUID NOT NULL REFERENCES users(id),
     notes TEXT
   );
   ```

7. **tooth_treatments**
   ```sql
   CREATE TABLE tooth_treatments (
     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
     dental_chart_id UUID REFERENCES dental_charts(id) ON DELETE CASCADE,
     tooth_number VARCHAR(2) NOT NULL,  -- FDI notation: "11" à "48"
     treatment_type VARCHAR(100),
     inami_code VARCHAR(20),  -- Code nomenclature INAMI
     status VARCHAR(50),  -- planned, completed, canceled
     treatment_date DATE,
     cost DECIMAL(10,2),
     notes TEXT
   );
   ```

8. **prescriptions**
   ```sql
   CREATE TABLE prescriptions (
     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
     patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
     medications JSONB NOT NULL,  -- [{ "name": "...", "dosage": "...", "frequency": "..." }]
     diagnosis TEXT,
     ai_generated BOOLEAN DEFAULT FALSE,  -- Manuel pour MVP
     prescription_date DATE NOT NULL DEFAULT CURRENT_DATE,
     pdf_url TEXT,  -- Supabase Storage URL
     created_by UUID NOT NULL REFERENCES users(id)
   );
   ```

9. **certificates**
   ```sql
   CREATE TABLE certificates (
     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
     patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
     certificate_type VARCHAR(100),  -- sick_leave, fitness, dental_treatment
     start_date DATE,
     end_date DATE,
     reason TEXT,
     pdf_url TEXT,
     created_by UUID NOT NULL REFERENCES users(id),
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );
   ```

10. **xrays**
    ```sql
    CREATE TABLE xrays (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
      file_url TEXT NOT NULL,  -- Supabase Storage (STL, PNG, DICOM)
      file_type VARCHAR(20),  -- stl, png, dicom
      tooth_number VARCHAR(2),  -- FDI notation si applicable
      ai_analysis JSONB,  -- Manuel pour MVP: { "notes": "..." }
      capture_date DATE DEFAULT CURRENT_DATE,
      created_by UUID NOT NULL REFERENCES users(id)
    );
    ```

11. **timeline_events**
    ```sql
    CREATE TABLE timeline_events (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
      event_type VARCHAR(100),  -- appointment, prescription, xray, payment, etc.
      event_data JSONB,
      created_by UUID REFERENCES users(id),
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
    ```

### Tables IA Rappels (2)
Source: `ai-appointment-reminders.sql`

12. **appointment_reminders**
    ```sql
    CREATE TABLE appointment_reminders (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      appointment_id UUID NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
      reminder_type VARCHAR(20),  -- email (pas SMS pour free tier)
      scheduled_send_time TIMESTAMP WITH TIME ZONE NOT NULL,
      sent_at TIMESTAMP WITH TIME ZONE,
      status VARCHAR(20),  -- pending, sent, failed
      ai_priority_score DECIMAL(3,2),  -- 0.60 à 0.95
      template_data JSONB
    );
    ```

13. **reminder_ai_config** (singleton)
    ```sql
    CREATE TABLE reminder_ai_config (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      email_template TEXT,
      sms_template TEXT,  -- Null pour MVP (pas de SMS)
      ai_scoring_rules JSONB,
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
    ```

### Relation Manquante (Inférée)

14. **staff_profiles.user_id** (FK à ajouter)
    ```sql
    ALTER TABLE staff_profiles
    ADD COLUMN IF NOT EXISTS user_id UUID UNIQUE REFERENCES users(id);
    ```
    Lie authentification (users) 1:1 avec données métier (staff_profiles)

### Vue IA

**pending_reminders_ai** - Calcul automatique priorité
```sql
CREATE VIEW pending_reminders_ai AS
SELECT
  a.id AS appointment_id,
  p.name AS patient_name,
  a.appointment_date,
  a.type AS appointment_type,
  CASE
    WHEN a.type ILIKE '%urgence%' THEN 0.95
    WHEN p.anticoagulant_therapy OR p.heart_disease THEN 0.85
    WHEN a.created_at > NOW() - INTERVAL '30 days' THEN 0.75
    ELSE 0.60
  END AS ai_priority_score
FROM appointments a
JOIN patients p ON a.patient_id = p.id
WHERE a.appointment_date > NOW()
  AND NOT EXISTS (
    SELECT 1 FROM appointment_reminders ar
    WHERE ar.appointment_id = a.id AND ar.status = 'sent'
  );
```

### Fonctions PostgreSQL

**generate_ai_reminders()** - Cron quotidien
```sql
CREATE OR REPLACE FUNCTION generate_ai_reminders()
RETURNS void AS $$
BEGIN
  INSERT INTO appointment_reminders (appointment_id, reminder_type, scheduled_send_time, ai_priority_score)
  SELECT
    appointment_id,
    'email',
    appointment_date - INTERVAL '24 hours',
    ai_priority_score
  FROM pending_reminders_ai
  WHERE appointment_date BETWEEN NOW() AND NOW() + INTERVAL '2 days';
END;
$$ LANGUAGE plpgsql;
```

**mark_reminder_sent()** - Callback SendGrid
```sql
CREATE OR REPLACE FUNCTION mark_reminder_sent(reminder_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE appointment_reminders
  SET status = 'sent', sent_at = NOW()
  WHERE id = reminder_id;
END;
$$ LANGUAGE plpgsql;
```

---

## 🔄 Flux de Données - Cycle de Vie Patient

### 1. Booking (Rendez-vous)
```
Frontend → Supabase appointments table → Timeline event
```
- Formulaire calendrier existant (dashboard.html)
- Insertion appointment avec `appointment_type`
- Trigger timeline_event automatique

### 2. Anamnèse
```
Frontend form → Supabase anamnesis table → Timeline event
```
- Questionnaire médical (medical_history aussi)
- Validation côté client + RLS

### 3. Carte Dentaire
```
dental-chart-v2.html (JSONB editor) → dental_charts table → Timeline event
```
- Structure JSONB: `{ "teeth": { "11": { "status": "healthy", "treatments": [...] } } }`
- Snapshot par date pour historique

### 4. Prescription
```
Frontend form → Edge Function (Puppeteer) → PDF Storage → prescriptions table
```
**Workflow:**
1. User saisit médicaments + diagnostic
2. POST `/functions/v1/generate-prescription-pdf`
3. Puppeteer génère PDF A4 avec en-tête médecin
4. Upload Supabase Storage → URL
5. Insert prescriptions avec pdf_url
6. Timeline event

### 5. Radiographie (X-Ray)
```
Upload STL → Supabase Storage → xrays table → Three.js viewer
```
**Workflow:**
1. Upload fichier STL (3D scan)
2. Storage URL → xrays.file_url
3. Frontend charge Three.js, render STL
4. Médecin ajoute notes manuelles (ai_analysis.notes)

### 6. Certificat Médical
```
Frontend form → Edge Function (Puppeteer) → PDF Storage → certificates table
```
Similaire prescription, template différent

### 7. Facturation INAMI
```
tooth_treatments (codes INAMI) → CSV export → Import eAttest manuel
```
**Workflow:**
1. Médecin saisit traitements avec codes INAMI
2. Frontend bouton "Export eAttest CSV"
3. Génération CSV format eAttest
4. Téléchargement → import manuel site INAMI

### 8. Facture Patient
```
Treatments → Edge Function (Puppeteer + EPC QR) → PDF Storage
```
**Workflow:**
1. Sélection traitements à facturer
2. POST `/functions/v1/generate-invoice-pdf` avec IBAN
3. Puppeteer génère PDF avec:
   - Détail prestations INAMI
   - Total EUR
   - QR code EPC (virement SEPA)
4. Patient scanne QR → virement automatique

### 9. Rappels Rendez-vous
```
Cron quotidien → generate_ai_reminders() → SendGrid API → Email patient
```
**Workflow:**
1. Edge Function cron (8h daily)
2. Appel generate_ai_reminders()
3. Boucle appointment_reminders WHERE status='pending'
4. SendGrid API (template dynamic)
5. Callback mark_reminder_sent()

---

## 🎯 Décisions Techniques & Rationale

### Pourquoi Puppeteer (pas jsPDF) ?

**Industrie médicale = server-side PDF**
- Epic, Cerner, Athenahealth utilisent server-side
- Meilleur rendu fonts médicales, symboles Unicode
- Multi-page complexe (prescriptions longues)
- HIPAA: PHI jamais dans logs navigateur

**Code:**
```typescript
// supabase/functions/generate-prescription-pdf/index.ts
import puppeteer from 'https://deno.land/x/puppeteer@16.2.0/mod.ts';

Deno.serve(async (req) => {
  const { patient, medications, diagnosis, doctor } = await req.json();

  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();

  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial; padding: 40px; }
        .header { text-align: center; border-bottom: 2px solid #000; }
        .patient { margin-top: 20px; }
        .medications { margin-top: 30px; }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>Prescription Médicale</h1>
        <p>Dr. ${doctor.name} - ${doctor.riziv}</p>
      </div>
      <div class="patient">
        <p><strong>Patient:</strong> ${patient.name}</p>
        <p><strong>Date de naissance:</strong> ${patient.dob}</p>
      </div>
      <div class="medications">
        <p><strong>Diagnostic:</strong> ${diagnosis}</p>
        <ul>
          ${medications.map(m => `
            <li><strong>${m.name}</strong> - ${m.dosage} - ${m.frequency}</li>
          `).join('')}
        </ul>
      </div>
      <div class="footer">
        <p>Date: ${new Date().toLocaleDateString('fr-BE')}</p>
        <p>Signature: _______________________</p>
      </div>
    </body>
    </html>
  `;

  await page.setContent(html);
  const pdf = await page.pdf({
    format: 'A4',
    printBackground: true,
    margin: { top: '20mm', bottom: '20mm', left: '15mm', right: '15mm' }
  });

  await browser.close();

  // Upload to Supabase Storage
  const filename = `prescription-${patient.id}-${Date.now()}.pdf`;
  // ... storage upload logic ...

  return new Response(pdf, {
    headers: { 'Content-Type': 'application/pdf' }
  });
});
```

### Pourquoi SendGrid Email uniquement (pas SMS) ?

**Contrainte budget €0:**
- SendGrid Free: 100 emails/jour gratuit
- Twilio SMS: €0.07/SMS = PAYANT

**Solution 100 emails/jour:**
- Filtrer rendez-vous par priorité IA (0.95 urgences first)
- Queue overflow → cap à 100/jour ou différer J-2

### Pourquoi Migration Incrémentale ?

**Préserver données existantes:**
```sql
CREATE TABLE IF NOT EXISTS dental_charts (...);
ALTER TABLE staff_profiles ADD COLUMN IF NOT EXISTS user_id UUID;
```
- Pas de DROP TABLE
- Baseline BACKUP_STEP5 = 5 tables stables
- Ajout 8 tables sans casser existant

### Pourquoi Workflows Manuels (eAttest, AI) ?

**APIs payantes:**
- MyCareNet API eAttest: Setup complexe + coûts
- OpenAI GPT-4 Vision: $0.10/image pour analyse radios

**Solution MVP gratuite:**
- Export CSV nomenclature INAMI → import manuel eAttest
- Textarea notes radios → médecin saisit manuellement

---

## 📐 Standards de Code

### Git Commits

**CRITIQUE:** Auteur TOUJOURS "Ismail Sialyen"

```bash
# ✅ CORRECT
git commit -m "feat: add prescription PDF generation" --author="Ismail Sialyen <email@example.com>"

# ❌ INTERDIT
git commit -m "feat: ... 🤖 Generated with Claude Code"
```

### Conventions SQL

- Tables: snake_case pluriel (`dental_charts`)
- Colonnes: snake_case (`patient_id`)
- FDI notation dents: VARCHAR(2) `"11"` à `"48"`
- JSONB pour structures complexes (carte dentaire, médicaments)
- `created_at` / `updated_at` partout
- RLS policies: `dev-open` MVP, tighten post-launch

### Conventions Frontend

- Vanilla JS (pas de build step)
- Naming: camelCase fonctions, PascalCase classes
- Config global: `window.K2_CONFIG` (config.js)
- Supabase client: `window.supabaseClient`
- Commentaires français (métier dentaire)

### Edge Functions

- Deno runtime
- TypeScript strict
- Error handling: try/catch + logs
- CORS: allow frontend origin
- Auth: vérifier JWT Supabase

---

## 🚀 Plan d'Implémentation - 6 Epics

### Epic 1: Database Migration (2h)
**Objectif:** Schema complet 13 tables + fonctions

**Tasks:**
- [ ] 1.1 - Backup actuel (BACKUP_STEP5 vérifié ✅)
- [ ] 1.2 - Run `complete-schema-final.sql` (6 tables core)
- [ ] 1.3 - Run `ai-appointment-reminders.sql` (2 tables + view + fonctions)
- [ ] 1.4 - `ALTER TABLE staff_profiles ADD COLUMN user_id UUID`
- [ ] 1.5 - Vérifier RLS policies (psql queries)
- [ ] 1.6 - Test inserts manuels toutes tables
- [ ] 1.7 - Backup post-migration

**Validation:**
```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' ORDER BY table_name;
-- Doit lister 13 tables
```

---

### Epic 2: PDF Generation avec Puppeteer (3h)
**Objectif:** 3 Edge Functions PDF (prescription, certificat, facture)

**Tasks:**
- [ ] 2.1 - Setup Supabase CLI local (`supabase init`)
- [ ] 2.2 - Create `functions/generate-prescription-pdf/index.ts`
  - Import Puppeteer Deno
  - Template HTML prescription
  - Upload Storage + return URL
- [ ] 2.3 - Create `functions/generate-certificate-pdf/index.ts`
  - Template certificat médical
  - start_date / end_date rendering
- [ ] 2.4 - Create `functions/generate-invoice-pdf/index.ts`
  - Boucle treatments INAMI codes
  - Calcul total EUR
  - **EPC QR Code generation** (lib: `qrcode` Deno)
- [ ] 2.5 - Test local toutes fonctions (`supabase functions serve`)
- [ ] 2.6 - Deploy production (`supabase functions deploy`)
- [ ] 2.7 - Test end-to-end frontend → PDF download

**EPC QR Code Format:**
```
BCD
002
1
SCT
[BIC optionnel]
[Nom bénéficiaire]
[IBAN bénéficiaire]
EUR[Montant]
[Code]
[Référence]
[Communication]
```

**Validation:** PDF téléchargé, QR scannable avec banking app

---

### Epic 3: Frontend Integration (3h)
**Objectif:** UI pour toutes features cycle de vie patient

**Tasks:**
- [ ] 3.1 - **Dental Chart Editor**
  - Vérifier dental-chart-v2.html existant
  - Adapter JSONB structure `{ "teeth": { "11": {...} } }`
  - Save → dental_charts table
- [ ] 3.2 - **Prescription Form**
  - Formulaire medications (add/remove rows)
  - Diagnostic textarea
  - Button "Générer PDF" → POST Edge Function
  - Display PDF url, download link
- [ ] 3.3 - **Certificate Form**
  - Type dropdown (sick_leave, fitness, dental_treatment)
  - Date range picker
  - Reason textarea
  - Generate PDF
- [ ] 3.4 - **X-Ray Viewer STL**
  - Upload fichier STL
  - Three.js scene setup
  - Load STL, render 3D
  - Rotate/zoom controls
  - Textarea notes manuelles → xrays.ai_analysis
- [ ] 3.5 - **Timeline Patient**
  - Query timeline_events ORDER BY created_at DESC
  - Display list (type, date, data preview)
  - Auto-refresh ou manual

**Validation:** Toutes features accessibles depuis dashboard patient

---

### Epic 4: INAMI & Billing (2h)
**Objectif:** Facturation nomenclature belge + virements

**Tasks:**
- [ ] 4.1 - **INAMI Codes Database**
  - Scraper nomenclature INAMI.be (ou CSV manuel)
  - Stocker codes + libellés (table `inami_codes` ou JSON static)
- [ ] 4.2 - **Treatment Form avec INAMI**
  - Autocomplete codes INAMI
  - tooth_treatments insert avec inami_code
- [ ] 4.3 - **eAttest CSV Export**
  - Query tooth_treatments WHERE status='completed'
  - Generate CSV format eAttest
  - Download client-side
- [ ] 4.4 - **Invoice Generator**
  - UI: select multiple treatments
  - Input IBAN médecin
  - Call generate-invoice-pdf Edge Function
  - Display PDF + QR code
- [ ] 4.5 - Test virement QR code (banking app scan)

**Questions Pending:**
- **Q2:** INAMI scraping légal ? → Confirmer ou CSV manuel
- **Q3:** IBAN placeholder ? → Utiliser IBAN réel médecin ou template "BEXX XXXX XXXX XXXX"

**Validation:** CSV importable eAttest, QR code scanne vers bon IBAN

---

### Epic 5: Appointment Reminders (2h)
**Objectif:** Emails automatiques 24h avant rendez-vous

**Tasks:**
- [ ] 5.1 - **SendGrid Setup**
  - Créer compte SendGrid Free
  - Vérifier sender email (SPF/DKIM)
  - Obtenir API key
  - Store dans Supabase Vault (`SENDGRID_API_KEY`)
- [ ] 5.2 - **Edge Function send-reminders**
  - Query appointment_reminders WHERE status='pending' AND scheduled_send_time <= NOW()
  - Loop: SendGrid API call (template dynamic)
  - Call mark_reminder_sent(id)
- [ ] 5.3 - **Cron Schedule**
  - `supabase functions schedule send-reminders --cron "0 8 * * *"`
  - Quotidien 8h matin
- [ ] 5.4 - **Template Email**
  - Insert reminder_ai_config singleton
  - Template: "Bonjour {patient_name}, rappel rendez-vous {date} à {time}"
- [ ] 5.5 - Test manuel trigger
- [ ] 5.6 - Monitor logs 24h

**Questions Pending:**
- **Q1:** SendGrid 100/day overflow ? → Cap bookings ou queue FIFO avec priorité IA

**Validation:** Email reçu inbox patient, lien confirm/cancel

---

### Epic 6: Backup & Monitoring (1h)
**Objectif:** Backups quotidiens + dashboard limites

**Tasks:**
- [ ] 6.1 - **GitHub Actions Backup**
  - Create `.github/workflows/daily-backup.yml`
  - Cron `0 2 * * *` (2h matin)
  - Script: `supabase db dump --project-ref sqgxscrwcffjfomlsoyf`
  - Commit backup SQL to repo (ou artifact)
- [ ] 6.2 - **Monitoring Dashboard**
  - Page `frontend/monitoring-dashboard.html`
  - Query DB size: `SELECT pg_database_size('postgres')`
  - Query Storage usage: API Supabase
  - Query Edge Functions invocations (logs parsing ou API)
  - Display: DB 500MB limit, Storage 1GB, Functions 500K
  - Alerts visuels si > 80%
- [ ] 6.3 - Test backup restore (dry-run)

**Questions Pending:**
- **Q5:** Monitoring dashboard threshold 80% → Email alert automatique ou check manuel ?

**Validation:** Backup SQL généré daily, dashboard affiche métriques réelles

---

## ❓ Questions Techniques en Attente

### Q1: SendGrid 100 emails/jour - Overflow handling
**Contexte:** Free tier limité 100 emails/jour
**Options:**
- A) Queue FIFO avec priorité IA (0.95 urgences first) → différer low-priority
- B) Cap bookings à 100 rendez-vous/jour max
- C) Upgrade SendGrid Essential ($15/mois) si dépassement

**Recommandation:** Option A (gratuit, intelligent)

---

### Q2: INAMI Nomenclature - Scraping légal ?
**Contexte:** Codes prestations dentaires sur INAMI.be
**Options:**
- A) Scraper automatique nomenclature (legal gray zone)
- B) CSV manuel téléchargé une fois, stocké static
- C) Saisie manuelle codes (tedious)

**Recommandation:** Option B (safe, one-time effort)

---

### Q3: IBAN Placeholder Factures
**Contexte:** QR code EPC nécessite IBAN bénéficiaire
**Options:**
- A) IBAN réel médecin hardcodé config
- B) Template "BEXX XXXX XXXX XXXX" → médecin édite PDF
- C) Input IBAN par facture (UI form)

**Recommandation:** Option C (flexible, multi-médecins)

---

### Q4: STL Test Files - Radiographies 3D
**Contexte:** Viewer Three.js nécessite fichiers STL test
**Options:**
- A) Vrais scans patients anonymisés (si disponibles)
- B) Générer dummy STL (dent simple Blender export)
- C) Télécharger samples open-source (Thingiverse dental)

**Recommandation:** Option C (rapide, réaliste)

---

### Q5: Monitoring Dashboard - Alerts 80%
**Contexte:** Supabase limits (500MB DB, 1GB Storage, 500K functions)
**Options:**
- A) Email alert automatique via Edge Function cron
- B) Check manuel dashboard weekly
- C) Slack webhook notification (free tier Slack)

**Recommandation:** Option A (proactive, automatisé)

---

## 🚨 Risques & Contraintes

### Risques Techniques

| Risque | Impact | Probabilité | Mitigation |
|--------|--------|-------------|------------|
| Supabase DB 500MB dépassé | CRITIQUE | Moyenne | Monitoring dashboard + archivage old data |
| SendGrid 100 emails/jour insuffisant | ÉLEVÉ | Élevée | Priorité IA + cap bookings temporaire |
| Puppeteer timeout Edge Functions | MOYEN | Faible | Timeout 30s, retry logic, fallback jsPDF |
| Three.js STL viewer lent (gros fichiers) | FAIBLE | Moyenne | Compression STL, lazy loading |
| RLS policies dev-open = sécurité faible | ÉLEVÉ | Certaine | Tighten RLS post-MVP (phase 2) |

### Contraintes

- **Budget €0:** Aucune dépense autorisée MVP
- **Free tier limits:** Respecter strictement (monitoring)
- **Pas de patients access:** MVP médecins uniquement
- **Author attribution:** Jamais "Claude" dans git
- **INAMI compliance:** Codes nomenclature exacts
- **RGPD/HIPAA-adjacent:** PHI protégé (server-side PDF)

---

## ✅ Critères d'Acceptation MVP

### Must-Have (Bloquants Launch)

- [x] 13 tables database déployées production
- [ ] Cycle de vie patient complet fonctionnel (9 étapes)
- [ ] PDF prescriptions/certificats/factures générés
- [ ] Viewer 3D STL radiographies opérationnel
- [ ] Rappels emails quotidiens envoyés
- [ ] Backups quotidiens GitHub Actions actifs
- [ ] Monitoring dashboard limites Supabase
- [ ] RLS policies activées (même dev-open)
- [ ] 2FA médecins configuré
- [ ] Zero bugs bloquants

### Nice-to-Have (Post-MVP)

- [ ] SMS rappels (Twilio payant)
- [ ] IA analyse radiographies (GPT-4 Vision)
- [ ] MyCareNet API eAttest automatique
- [ ] Patient portal (self-booking)
- [ ] Stripe payments automatiques
- [ ] Ortho/Paro modules spécialisés
- [ ] RLS policies granulaires par rôle

### Performance Targets

- PDF generation: < 5 secondes
- STL viewer load: < 3 secondes (fichiers < 10MB)
- Dashboard load time: < 2 secondes
- Email delivery: < 1 minute post-cron

---

## 📊 Métriques Succès MVP

### Techniques

- Uptime Supabase: > 99%
- Email delivery rate: > 95%
- PDF generation success: > 98%
- Zero data loss (backups testés)

### Business

- 1 médecin pilote actif
- 10+ patients cycle complet traités
- Demo investisseurs réussie
- Feedback positif utilisateurs (NPS > 8)

---

## 📚 Références

### Documentation Technique

- Supabase: https://supabase.com/docs
- Puppeteer Deno: https://deno.land/x/puppeteer
- Three.js: https://threejs.org/docs
- SendGrid API: https://docs.sendgrid.com
- EPC QR Code: https://www.europeanpaymentscouncil.eu/

### Standards Belges

- INAMI Nomenclature: https://www.inami.fgov.be
- eAttest: https://www.ehealth.fgov.be
- RIZIV: Numéro identification médecin

### Code Repository

- Main: `github.com/IsmaIkami/K2-Dent-Production`
- Branch: `main`
- Supabase Project: `sqgxscrwcffjfomlsoyf`

---

**Document Version:** 1.0
**Dernière MAJ:** 2026-07-24
**Auteur:** Ismail Sialyen
**Status:** ✅ PRÊT POUR IMPLÉMENTATION

# 🎯 Plan Implémentation K2 Dental Cockpit - 2 Phases

**Auteur:** Ismail Sialyen
**Date:** 2026-07-24
**Stratégie:** MVP Core d'abord (cabinet) → NIC Integration ensuite (B2B)

---

## 📊 VUE D'ENSEMBLE

```
┌─────────────────────────────────────────────────────────────┐
│                    STRATÉGIE 2 PHASES                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  PHASE 1: MVP CORE (Mois 1-2)                               │
│  ├─ Fonctionnalités cabinet essentielles                   │
│  ├─ Utilisable immédiatement                                │
│  ├─ Sans dépendances NIC                                    │
│  └─ €0/mois (free tier)                                     │
│                                                              │
│  ↓ (Cabinet fonctionne en production)                       │
│                                                              │
│  PHASE 2: NIC INTEGRATION (Mois 3-7)                        │
│  ├─ Certification officielle                                │
│  ├─ APIs MyCareNet (SOAP)                                   │
│  ├─ Vente B2B possible                                      │
│  └─ €100 coût certification                                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 PHASE 1: MVP CORE (Mois 1-2)

### Objectif
**Logiciel 100% fonctionnel pour ton cabinet SANS dépendances externes NIC.**

Tu peux gérer patients, prescriptions, factures, rappels dès aujourd'hui.

---

### Fonctionnalités Incluses (10 étapes cycle de vie)

| # | Feature | Nécessite NIC? | Implémentation | Status |
|---|---------|----------------|----------------|--------|
| 1 | 📅 **Booking** - Calendrier rendez-vous | ❌ Non | Existant dashboard.html | ✅ DONE |
| 2 | 📋 **Anamnèse** - Questionnaire médical | ❌ Non | Existant forms | ✅ DONE |
| 3 | 🦷 **Carte dentaire** - Éditeur JSONB | ❌ Non | dental-chart-v2.html + DB | 🔄 TODO |
| 4 | 💊 **Prescriptions** - PDF Puppeteer | ❌ Non | Edge Function + Storage | 🔄 TODO |
| 5 | 📸 **Radiographies** - Viewer 3D STL | ❌ Non | Three.js viewer | 🔄 TODO |
| 6 | 📄 **Certificats** - PDF médical | ❌ Non | Edge Function PDF | 🔄 TODO |
| 7 | 📖 **Timeline** - Audit trail | ❌ Non | Table timeline_events | 🔄 TODO |
| 8 | 💰 **Facturation manuelle** - PDF + QR EPC | ❌ Non | Invoice PDF + QR code | 🔄 TODO |
| 9 | 📊 **INAMI Tracking** - Codes prestations | ❌ Non | Table tooth_treatments | 🔄 TODO |
| 10 | ✉️ **Rappels** - Emails SendGrid | ❌ Non | Edge Function + cron | 🔄 TODO |

**Total:** 10/10 features utilisables SANS NIC ✅

---

### Différence vs NIC

**Phase 1 (MVP Core):**
```
Patient → Traitement → Facture PDF manuelle → Patient paie
                    ↓
          Tu exportes CSV manuellement
                    ↓
          Tu uploads sur portail INAMI web (manuel)
```

**Phase 2 (Avec NIC):**
```
Patient → Traitement → API eAttest automatique → Mutualité
                    ↓
          Confirmation instantanée
                    ↓
          Paiement automatique
```

**Conclusion Phase 1:** Tu fais tout, mais manuellement (export CSV). C'est OK pour démarrer!

---

### Architecture Phase 1 (Simplifiée)

```
┌──────────────────────────────────────────────────────────┐
│                    FRONTEND (HTML/JS)                     │
│  - Dashboard.html (calendrier)                           │
│  - Patients.html (dossiers)                              │
│  - Dental-chart.html (carte dentaire)                    │
│  - Prescriptions.html (formulaire)                       │
│  - Invoices.html (facturation)                           │
└──────────────────┬───────────────────────────────────────┘
                   │
                   ↓ HTTP/REST
┌──────────────────────────────────────────────────────────┐
│              SUPABASE (Backend as a Service)             │
│                                                           │
│  [PostgreSQL 500MB]                                      │
│  ├─ 13 tables (patients, treatments, prescriptions...)  │
│  ├─ RLS policies (sécurité)                             │
│  └─ Functions PostgreSQL (generate_reminders...)         │
│                                                           │
│  [Edge Functions Deno]                                   │
│  ├─ generate-prescription-pdf (Puppeteer)               │
│  ├─ generate-certificate-pdf (Puppeteer)                │
│  ├─ generate-invoice-pdf (Puppeteer + QR EPC)           │
│  └─ send-reminders (SendGrid cron daily)                │
│                                                           │
│  [Storage 1GB]                                           │
│  └─ Bucket: medical-documents/                          │
│      ├─ prescriptions/*.pdf                             │
│      ├─ certificates/*.pdf                              │
│      ├─ invoices/*.pdf                                  │
│      └─ xrays/*.stl                                     │
│                                                           │
│  [Auth]                                                  │
│  └─ 2FA médecins (email + TOTP)                         │
└──────────────────┬───────────────────────────────────────┘
                   │
                   ↓ SMTP
┌──────────────────────────────────────────────────────────┐
│              SENDGRID FREE (100 emails/jour)             │
│  - Rappels rendez-vous automatiques                     │
│  - Confirmations prescriptions                           │
└──────────────────────────────────────────────────────────┘

                   ↓ Git push
┌──────────────────────────────────────────────────────────┐
│           GITHUB ACTIONS (Backups quotidiens)            │
│  - Cron 2h AM: supabase db dump                         │
│  - Commit SQL backup to repo                            │
└──────────────────────────────────────────────────────────┘
```

**Stack:** 100% gratuit, zéro dépendance NIC ✅

---

### Epic 1: Database Core (2h)

**Objectif:** 13 tables complètes pour cycle de vie patient

#### Tasks
```
✅ 1.1 - Vérifier BACKUP_STEP5 (baseline 5 tables)
🔄 1.2 - CREATE TABLE dental_charts (JSONB)
🔄 1.3 - CREATE TABLE tooth_treatments (codes INAMI)
🔄 1.4 - CREATE TABLE prescriptions (PDF URLs)
🔄 1.5 - CREATE TABLE certificates (PDF URLs)
🔄 1.6 - CREATE TABLE xrays (STL files)
🔄 1.7 - CREATE TABLE timeline_events (audit)
🔄 1.8 - CREATE TABLE appointment_reminders (SendGrid)
🔄 1.9 - CREATE TABLE reminder_ai_config (settings)
🔄 1.10 - CREATE VIEW pending_reminders_ai
🔄 1.11 - CREATE FUNCTION generate_ai_reminders()
🔄 1.12 - CREATE FUNCTION mark_reminder_sent(UUID)
🔄 1.13 - ALTER TABLE staff_profiles ADD user_id
🔄 1.14 - Test inserts + RLS policies
🔄 1.15 - Backup post-migration
```

**Validation:** 13 tables + 2 fonctions PostgreSQL

---

### Epic 2: PDF Generation Engine (3h)

**Objectif:** 3 Edge Functions Puppeteer server-side

#### Tasks
```
🔄 2.1 - Setup Supabase CLI local
🔄 2.2 - Create generate-prescription-pdf
       ├─ Input: patient_id, medications[], diagnosis
       ├─ Puppeteer HTML → PDF A4
       ├─ Upload Storage: medical-documents/prescriptions/
       └─ Insert prescriptions table
🔄 2.3 - Create generate-certificate-pdf
       ├─ Input: patient_id, type, dates, reason
       ├─ Templates: sick_leave, fitness, dental_treatment
       └─ Upload Storage + DB insert
🔄 2.4 - Create generate-invoice-pdf
       ├─ Input: patient_id, treatment_ids[], iban_doctor
       ├─ Loop treatments → table INAMI codes + totals
       ├─ Generate EPC QR code (virement SEPA)
       └─ PDF avec QR scannable banking app
🔄 2.5 - Test local functions (supabase functions serve)
🔄 2.6 - Deploy production (supabase functions deploy)
🔄 2.7 - Test end-to-end frontend
```

**Validation:** 3 PDF générés, QR code scannable

---

### Epic 3: Frontend Integration (3h)

**Objectif:** 5 interfaces utilisateur complètes

#### Tasks
```
🔄 3.1 - Dental Chart Editor
       ├─ Adapter dental-chart-v2.html
       ├─ JSONB structure: { teeth: { "11": {...} } }
       ├─ Save button → dental_charts table
       └─ Load existing charts
🔄 3.2 - Prescription Form
       ├─ Dynamic medications rows (add/remove)
       ├─ Autocomplete médicaments (static JSON)
       ├─ Diagnostic textarea
       └─ Generate PDF button → Edge Function
🔄 3.3 - Certificate Form
       ├─ Type dropdown (3 types)
       ├─ Date range picker
       ├─ Reason textarea
       └─ Generate PDF button
🔄 3.4 - X-Ray Viewer (Three.js)
       ├─ Upload STL file → Storage
       ├─ Three.js scene setup
       ├─ STL loader + rendering
       ├─ OrbitControls (rotate/zoom)
       └─ Notes textarea → xrays.ai_analysis
🔄 3.5 - Patient Timeline
       ├─ Query timeline_events DESC
       ├─ Display chronological list
       └─ Auto-refresh 10s
```

**Validation:** 5 UIs fonctionnelles

---

### Epic 4: INAMI Tracking (Manuel) (2h)

**Objectif:** Codes INAMI + facturation manuelle PDF

#### Tasks
```
🔄 4.1 - INAMI Codes Database
       ├─ Download CSV nomenclature INAMI.be
       ├─ Store frontend/data/inami-codes.json (static)
       └─ ~200 codes dentaires Belgique
🔄 4.2 - Treatment Form
       ├─ Autocomplete codes INAMI (datalist)
       ├─ Input: tooth_number, inami_code, cost
       ├─ Insert tooth_treatments
       └─ Timeline event
🔄 4.3 - CSV Export (Manuel)
       ├─ Query treatments WHERE status='completed'
       ├─ Generate CSV format eAttest
       ├─ Colonnes: NISS, Date, Code_INAMI, Montant, RIZIV
       └─ Download client-side
🔄 4.4 - Invoice Generator
       ├─ Select multiple treatments (checkboxes)
       ├─ Input IBAN médecin (form)
       ├─ Call generate-invoice-pdf
       └─ Display PDF + QR code EPC
🔄 4.5 - Test QR virement
       ├─ Generate facture test
       ├─ Scan QR avec banking app (KBC, BNP)
       └─ Verify IBAN + montant pré-rempli
```

**Validation:** CSV téléchargeable, facture PDF avec QR

**Workflow manuel Phase 1:**
```
1. Patient traité → Saisir treatments avec codes INAMI
2. Fin semaine → Export CSV tous traitements completed
3. Upload CSV sur portail INAMI web (https://mycarenet.be)
4. Mutualités traitent CSV manuellement
5. Paiement reçu dans 2-3 semaines
```

---

### Epic 5: Appointment Reminders (2h)

**Objectif:** Emails automatiques quotidiens

#### Tasks
```
🔄 5.1 - SendGrid Setup
       ├─ Sign up SendGrid Free (100/jour)
       ├─ Verify sender email (SPF/DKIM)
       ├─ Create API key
       └─ Store Supabase Vault: SENDGRID_API_KEY
🔄 5.2 - Edge Function send-reminders
       ├─ Query appointment_reminders WHERE pending
       ├─ Filter: scheduled_send_time <= NOW()
       ├─ Order by: ai_priority_score DESC (urgences first)
       ├─ Limit 100 (SendGrid quota)
       ├─ Loop: SendGrid API dynamic template
       └─ Call mark_reminder_sent(id)
🔄 5.3 - Cron Schedule
       └─ supabase functions schedule send-reminders --cron "0 8 * * *"
🔄 5.4 - SendGrid Template
       ├─ Create dynamic template dashboard
       ├─ Variables: patient_name, appointment_date, time, type
       └─ Insert reminder_ai_config (template settings)
🔄 5.5 - Test manuel
       ├─ Insert test appointment_reminder
       ├─ Trigger function manually
       └─ Verify email received inbox
🔄 5.6 - Monitor logs 24h
```

**Validation:** Emails quotidiens envoyés, delivery rate >95%

---

### Epic 6: Backup & Monitoring (1h)

**Objectif:** Sécurité données + dashboard limites

#### Tasks
```
🔄 6.1 - GitHub Actions Backup
       ├─ Create .github/workflows/daily-backup.yml
       ├─ Cron 0 2 * * * (2h AM daily)
       ├─ supabase db dump → backup-YYYYMMDD.sql
       ├─ Commit to repo (ou artifact)
       └─ Keep last 30 backups
🔄 6.2 - Monitoring Dashboard
       ├─ Page frontend/monitoring-dashboard.html
       ├─ Query DB size: pg_database_size()
       ├─ Query Storage usage: Supabase API
       ├─ Display: DB 500MB, Storage 1GB, Functions 500K
       ├─ Colors: green (<60%), yellow (60-80%), red (>80%)
       └─ Auto-refresh 5 min
🔄 6.3 - Test backup restore
       └─ Dry-run: restore backup locally, verify 13 tables
```

**Validation:** Backups daily, dashboard opérationnel

---

### Timeline Phase 1

```
┌─────────┬─────────────────────────────────────┬──────┐
│ Semaine │ Epic                                │ Hours│
├─────────┼─────────────────────────────────────┼──────┤
│ Week 1  │ Epic 1: Database (13 tables)       │  2h  │
│         │ Epic 6.1: GitHub Actions backup    │ 0.5h │
├─────────┼─────────────────────────────────────┼──────┤
│ Week 2  │ Epic 2: PDF Generation (3 funcs)   │  3h  │
├─────────┼─────────────────────────────────────┼──────┤
│ Week 3  │ Epic 3: Frontend (5 UIs)           │  3h  │
│         │ Epic 4: INAMI (manuel CSV)         │  2h  │
├─────────┼─────────────────────────────────────┼──────┤
│ Week 4  │ Epic 5: Reminders (SendGrid)       │  2h  │
│         │ Epic 6.2-6.3: Monitoring + test    │ 0.5h │
├─────────┼─────────────────────────────────────┼──────┤
│ Week 5  │ Testing end-to-end                 │  1h  │
│         │ Fixes bugs                         │  1h  │
│         │ GO-LIVE PHASE 1 ✅                 │      │
└─────────┴─────────────────────────────────────┴──────┘

Total: 13h développement + 2h tests = 15h
```

**Livrable:** Cabinet fonctionnel 100% avec facturation manuelle CSV

---

### Critères Acceptation Phase 1

**Must-Have:**
- [ ] 13 tables déployées production
- [ ] Cycle de vie patient complet (10 étapes)
- [ ] PDF prescriptions/certificats/factures générés
- [ ] Viewer 3D STL fonctionnel
- [ ] Rappels emails quotidiens actifs
- [ ] CSV INAMI exportable (upload manuel portail)
- [ ] Backups GitHub Actions daily
- [ ] Monitoring dashboard opérationnel
- [ ] 2FA médecins configuré
- [ ] Zero bugs bloquants

**Performance:**
- PDF generation < 5s
- STL viewer load < 3s
- Dashboard load < 2s
- Email delivery < 1min

**Business:**
- ✅ Cabinet opérationnel IMMÉDIATEMENT
- ✅ Gestion 10+ patients/jour possible
- ✅ Facturation fonctionnelle (manuelle CSV)
- ✅ €0/mois coûts

---

## 🏆 PHASE 2: NIC INTEGRATION (Mois 3-7)

### Objectif
**Certification officielle NIC → Vente B2B logiciel dentaire**

Automatisation eAttest/Tarification/Insurability via APIs MyCareNet.

---

### Fonctionnalités Ajoutées (3 nouvelles)

| # | Feature | Description | Bénéfice |
|---|---------|-------------|----------|
| 11 | 🔐 **SAML Auth** | I.AM Connect (OIDC) + token conversion | Auth moderne |
| 12 | 📤 **eAttest Auto** | API SOAP v3 envoi attestations | Automatique vs CSV |
| 13 | 💶 **Tarif Real-time** | API Tarification consultation tarifs | Tarifs à jour |
| 14 | 🏥 **Insurability Check** | API Insurability vérification mutualité | Temps réel |

**Total:** 14 features (10 core + 4 NIC) ✅

---

### Architecture Phase 2 (Avec NIC)

```
┌──────────────────────────────────────────────────────────┐
│                    FRONTEND (inchangé)                    │
└──────────────────┬───────────────────────────────────────┘
                   │
                   ↓
┌──────────────────────────────────────────────────────────┐
│              SUPABASE (Backend as a Service)             │
│                                                           │
│  [Edge Functions - NOUVEAUX]                             │
│  ├─ get-saml-token (STS eHealth)                        │
│  ├─ mycarenet-eattest (SOAP)                            │
│  ├─ mycarenet-tarification (SOAP)                       │
│  └─ mycarenet-insurability (SOAP)                       │
│                                                           │
│  [Vault - Secrets]                                       │
│  ├─ EHEALTH_PROD_CERT_P12                               │
│  ├─ EHEALTH_PRIVATE_KEY                                 │
│  └─ SAML_TOKENS (cache 8h)                              │
└──────────────────┬───────────────────────────────────────┘
                   │
                   ↓ HTTPS/SOAP (SSL/TLS)
┌──────────────────────────────────────────────────────────┐
│           eHEALTH PLATFORM (Production)                  │
│  https://services.ehealth.fgov.be/                       │
│                                                           │
│  ├─ STS (Security Token Service)                        │
│  │   └─ SAML tokens (8h validity)                       │
│  │                                                        │
│  └─ MyCareNet APIs                                       │
│      ├─ eAttest v3 (attestations)                       │
│      ├─ Tarification v1 (tarifs INAMI)                  │
│      └─ Insurability v1 (assurabilité)                  │
└──────────────────┬───────────────────────────────────────┘
                   │
                   ↓
┌──────────────────────────────────────────────────────────┐
│              MUTUALITÉS (CM, Solidaris, etc.)            │
│  - Traitement attestations automatique                  │
│  - Paiement 7-14 jours (vs 2-3 semaines manuel)        │
└──────────────────────────────────────────────────────────┘
```

---

### Epic 7: Accès Test Environment (Semaine 1-2)

**Objectif:** Obtenir certificat test + accès SharePoint

#### Tasks
```
🔄 7.1 - Email mycarenet@intermut.be
       ├─ Template: demande accès test
       ├─ Services: eAttest, Tarification, Insurability
       └─ Attendre User ID SharePoint (3-5 jours)
🔄 7.2 - Email info@ehealth.fgov.be
       ├─ Template: demande certificat test
       ├─ Documents: power of attorney, contrat integrator
       └─ Attendre certificat test .p12 (7-10 jours)
🔄 7.3 - Download documentation SharePoint
       ├─ Cookbooks: eAttest v1.2, Tarif v1.5, Insurability v2.0
       ├─ Scénarios test obligatoires
       ├─ Schémas XSD KMEHR
       └─ NISS test patients fictifs
🔄 7.4 - Install certificat test
       ├─ Store Supabase Vault: EHEALTH_TEST_CERT_P12
       └─ Test connexion STS acceptance
```

**Validation:** Certificat test OK, accès SharePoint OK

---

### Epic 8: SAML Token Service (Semaine 3)

**Objectif:** Authentification eHealth Platform

#### Tasks
```
🔄 8.1 - Create Edge Function get-saml-token
       ├─ Load certificat from Vault
       ├─ WS-Security headers (timestamp, signature)
       ├─ POST STS RequestSecurityToken (SOAP)
       └─ Parse SAML token response
🔄 8.2 - Cache SAML tokens
       ├─ Table: saml_tokens (token, expires_at)
       ├─ TTL: 8h validity
       └─ Auto-cleanup expired tokens
🔄 8.3 - Test SAML token
       ├─ Call get-saml-token()
       ├─ Verify token contains INAMI
       └─ Verify expiration future (8h)
```

**Validation:** SAML token obtenu, cache fonctionne

---

### Epic 9: API Insurability (Semaine 4)

**Objectif:** Vérification assurabilité temps réel

#### Tasks
```
🔄 9.1 - Create Edge Function mycarenet-insurability
       ├─ Input: patient NISS, date référence
       ├─ Get SAML token (cached)
       ├─ Build SOAP request GenericInsurability
       ├─ POST https://services-acpt.ehealth.fgov.be/GenericInsurability/v1
       ├─ Parse XML response (mutuality, coverage, tiers payant)
       └─ Return JSON { insured, mutuality_code, third_party_eligible }
🔄 9.2 - Cache insurability results
       ├─ Table: insurability_cache (patient_id, date, result)
       ├─ TTL: 24h (éviter appels répétés)
       └─ Invalidate si patient update
🔄 9.3 - UI Integration
       ├─ Button "Vérifier Assurabilité" patient detail
       ├─ Display mutuality logo + status
       └─ Error handling (NISS invalide, non-assuré)
🔄 9.4 - Test scénarios NIC
       ├─ NISS test assuré CM (00000000097)
       ├─ NISS test non-assuré (fourni NIC)
       └─ Log all requests/responses
```

**Validation:** API call success, mutualité affichée, cache hit

---

### Epic 10: API Tarification (Semaine 5)

**Objectif:** Consultation tarifs INAMI temps réel

#### Tasks
```
🔄 10.1 - Create Edge Function mycarenet-tarification
        ├─ Input: code INAMI, date prestation, âge patient
        ├─ Get SAML token
        ├─ Build SOAP request ConsultTariff
        ├─ POST https://services-acpt.ehealth.fgov.be/MyCareNet/Tarification/v1
        ├─ Parse response (convention, libre, patient_share, insurance_share)
        └─ Return JSON tarif details
🔄 10.2 - Cache tarifs local
        ├─ Table: inami_tariffs_cache (code, date, tarif)
        ├─ TTL: 24h (tarifs changent rarement)
        ├─ Cron refresh quotidien (2h AM)
        └─ Fallback API si cache miss
🔄 10.3 - UI Integration
        ├─ Autocomplete codes INAMI → affiche tarif preview
        ├─ Display: convention €X, libre €Y, patient part €Z
        └─ Warning si code obsolète (validity dates)
🔄 10.4 - Test scénarios NIC
        ├─ Code 305593 (détartrage) → verify tarif
        ├─ Code avec âge patient (tarif réduit enfant)
        └─ Log requests/responses
```

**Validation:** Tarifs corrects, cache fonctionne, UI update

---

### Epic 11: API eAttest (Semaine 6-8)

**Objectif:** Envoi attestations automatique (coeur NIC)

#### Tasks
```
🔄 11.1 - Create Edge Function mycarenet-eattest
        ├─ Input: patient_id, treatment_ids[]
        ├─ Fetch patient (NISS), treatments (codes INAMI)
        ├─ Get SAML token
        ├─ Build SOAP SendAttestationsRequest (KMEHR schema)
        │   ├─ Insuree: NISS patient
        │   ├─ CareProvider: NIHII médecin
        │   ├─ Transactions: loop treatments
        │   │   ├─ Date, Time
        │   │   └─ Items: code INAMI, amount, reimbursed
        │   └─ CommonInput: K2 Dental Cockpit v1.0.0
        ├─ Validate XML against XSD KMEHR
        ├─ POST https://services-acpt.ehealth.fgov.be/MyCareNet/eAttest/v3
        ├─ Parse response (NIP reference, status)
        └─ Log DB: eattest_logs (request, response, NIP, status)
🔄 11.2 - XSD Validation
        ├─ Download KMEHR schema v1.0
        ├─ Integrate XMLValidator
        └─ Reject request si invalid XML
🔄 11.3 - Error Handling
        ├─ Code 200: Success → mark treatments sent
        ├─ Code 400: Invalid XML → log + notify user
        ├─ Code 422: Business error (code INAMI invalide) → log + retry
        ├─ Code 500: Server error → retry 3x exponential backoff
        └─ Timeout 30s → retry
🔄 11.4 - UI Integration
        ├─ Treatments list: checkbox "Envoyer eAttest"
        ├─ Button "Envoyer Attestations" → call Edge Function
        ├─ Display: NIP reference, status (sent, accepted, rejected)
        └─ Timeline event: "eAttest envoyé NIP-XXX"
🔄 11.5 - Operations supplémentaires
        ├─ cancelAttestations() si erreur <48h
        ├─ getAttestationStatus() vérifier traitement mutualité
        └─ UI: annulation possible si status pending
🔄 11.6 - Test scénarios NIC obligatoires
        ├─ Scenario 1: Attestation simple (1 patient, 1 code)
        ├─ Scenario 2: Attestation batch (10 patients)
        ├─ Scenario 3: Annulation attestation
        ├─ Scenario 4: Rejet code INAMI invalide
        ├─ Scenario 5: Rejet NISS incorrect
        └─ Log ALL requests/responses XML
```

**Validation:** eAttest envoyé, NIP reçu, scenarios test OK

---

### Epic 12: Tests Internes NIC (Semaine 9-10)

**Objectif:** Exécuter tous scénarios test obligatoires

#### Tasks
```
🔄 12.1 - Setup test environment
        ├─ NISS test patients (fournis SharePoint)
        ├─ Codes INAMI test (list fournie)
        └─ Table nic_test_logs (tracking)
🔄 12.2 - Execute test scenarios
        ├─ eAttest: 5 scenarios (simple, batch, cancel, rejets)
        ├─ Tarification: 2 scenarios (standard, âge)
        ├─ Insurability: 2 scenarios (assuré, non-assuré)
        └─ Log results: Excel spreadsheet
🔄 12.3 - Generate test report
        ├─ Template: Excel avec colonnes (scenario, date, result, XML)
        ├─ Export logs SQL: nic_test_logs → CSV
        └─ Prepare documentation technique (architecture K2)
🔄 12.4 - Review & fixes
        ├─ Identify failing scenarios
        ├─ Fix bugs
        └─ Re-run tests until 100% pass
```

**Validation:** 100% scenarios pass, rapport Excel complet

---

### Epic 13: Approval Assessment NIC (Semaine 11)

**Objectif:** Certification officielle

#### Tasks
```
🔄 13.1 - Request assessment date
        ├─ Email mycarenet@intermut.be
        ├─ Attach: test report PDF
        └─ Propose 3 dates disponibilités
🔄 13.2 - Prepare demo
        ├─ Environment test accessible (stable)
        ├─ Scenarios reproductibles live
        └─ Backup slides si connexion fail
🔄 13.3 - Assessment meeting (2-3h Teams)
        ├─ 09h00: Présentation K2 (15 min)
        ├─ 09h15: Revue technique services (45 min)
        ├─ 10h00: Démo live scénarios (1h)
        ├─ 11h00: Q&A équipe NIC (30 min)
        └─ 11h30: Feedback & décision
🔄 13.4 - Handle feedback
        ├─ Si approved → Epic 14
        ├─ Si corrections → fix & re-assessment (1-2 weeks)
        └─ Si rejected → refactor major (rare)
```

**Validation:** Approval email NIC reçu ✅

---

### Epic 14: Production Migration (Semaine 12-13)

**Objectif:** Go-live production NIC

#### Tasks
```
🔄 14.1 - Request production certificate
        ├─ Email info@ehealth.fgov.be
        ├─ Attach: NIC approval email
        ├─ Documents: procuration médecin chef
        └─ Receive cert production .p12 (5-7 jours)
🔄 14.2 - Configure production
        ├─ Install cert prod Supabase Vault
        ├─ Update config endpoints (remove -acpt)
        ├─ Deploy Edge Functions production
        └─ Test smoke (1 attestation réelle)
🔄 14.3 - Rollout progressive
        ├─ Week 1: Ton cabinet uniquement
        ├─ Week 2: Monitoring 100% attestations
        ├─ Week 3: Inviter 1-2 médecins beta testers
        └─ Week 4: Open B2B (liste officielle NIC)
🔄 14.4 - Monitor production
        ├─ Dashboard: eAttest success rate
        ├─ Alerts: errors > 5%
        └─ Logs: all SOAP calls
```

**Validation:** Production stable, listed on NIC website

---

### Timeline Phase 2

```
┌──────────┬──────────────────────────────────────┬──────┐
│ Mois     │ Epic                                 │ Hours│
├──────────┼──────────────────────────────────────┼──────┤
│ Mois 3   │ Epic 7: Accès test (2 weeks wait)   │  2h  │
│          │ Epic 8: SAML Token Service           │  8h  │
├──────────┼──────────────────────────────────────┼──────┤
│ Mois 4   │ Epic 9: API Insurability             │ 12h  │
│          │ Epic 10: API Tarification            │ 10h  │
├──────────┼──────────────────────────────────────┼──────┤
│ Mois 5-6 │ Epic 11: API eAttest (complexe)      │ 25h  │
├──────────┼──────────────────────────────────────┼──────┤
│ Mois 6   │ Epic 12: Tests internes              │ 15h  │
├──────────┼──────────────────────────────────────┼──────┤
│ Mois 7   │ Epic 13: Approval Assessment         │  5h  │
│          │ Epic 14: Production migration        │  8h  │
└──────────┴──────────────────────────────────────┴──────┘

Total: 85h développement (3-4 mois effort réel)
Wait time: 2 weeks (accès test), 1 week (cert prod)
```

---

### Coûts Phase 2

| Item | Coût |
|------|------|
| Certificat test eHealth | €0 |
| Certificat production eHealth | €50 |
| Lecteur eID (ACR122U) | €50 |
| Assessment NIC | €0 |
| Temps développeur | 85h |
| **TOTAL** | **€100** |

---

### Critères Acceptation Phase 2

**Must-Have:**
- [ ] Certificat test eHealth obtenu
- [ ] 3 APIs MyCareNet intégrées (eAttest, Tarif, Insurability)
- [ ] 100% scénarios test NIC passent
- [ ] Approval Assessment réussi
- [ ] Certificat production obtenu
- [ ] K2 listé site officiel NIC
- [ ] Production stable >99% uptime

**Business:**
- ✅ Vente B2B possible (certification officielle)
- ✅ Prime télématique éligible médecins
- ✅ Obligation légale Sept 2025 respectée
- ✅ Différentiation vs concurrents (auth moderne OIDC)

---

## 📊 COMPARAISON 2 PHASES

| Aspect | Phase 1: MVP Core | Phase 2: NIC Integration |
|--------|------------------|--------------------------|
| **Timeline** | 5 semaines (1-2 mois) | 16 semaines (3-4 mois) |
| **Effort** | 15h développement | 85h développement |
| **Coût** | €0 | €100 |
| **Features** | 10 core | +4 NIC (14 total) |
| **Facturation** | Manuelle CSV | Automatique API |
| **Mutualités** | Upload manuel portail | Automatique temps réel |
| **Délai paiement** | 2-3 semaines | 7-14 jours |
| **B2B Sales** | ❌ Impossible | ✅ Possible |
| **Certification** | ❌ Non certifié | ✅ NIC approved |
| **Utilisable** | ✅ Immédiat | ✅ Production |

---

## 🎯 DÉCISION: QUELLE PHASE DÉMARRER?

### Option A: Phase 1 UNIQUEMENT (Rapide)
**Pros:**
- ✅ Cabinet fonctionnel en 5 semaines
- ✅ €0 coûts
- ✅ Simplicité (pas SOAP)
- ✅ Validation concept rapide

**Cons:**
- ❌ Facturation manuelle CSV (tedious)
- ❌ Pas vente B2B possible
- ❌ Délai paiement 2-3 semaines

**Recommandé si:**
- Tu veux tester K2 rapidement
- Pas urgent vente B2B
- Budget €0 strict

---

### Option B: Phase 1 + Phase 2 (Complet)
**Pros:**
- ✅ Cabinet immédiat (Phase 1)
- ✅ Certification NIC après (Phase 2)
- ✅ Vente B2B possible (6 mois)
- ✅ Automatisation complète

**Cons:**
- ⏱️ Timeline longue (6 mois total)
- 💰 Coût €100 (certification)
- 🧠 Complexité SOAP/SAML

**Recommandé si:** ✅
- Tu veux vendre B2B
- Tu as 6 mois horizon
- Tu acceptes €100 coût

---

### Option C: Phase 2 DIRECTEMENT (Ambitious)
**Pros:**
- ✅ Tout en 1 fois
- ✅ Certification dès départ
- ✅ Pas double développement

**Cons:**
- ❌ Délai 6 mois avant utilisation
- ❌ Risque bloquage NIC
- ❌ Complexité d'entrée élevée

**Recommandé si:**
- Tu as déjà logiciel basique
- Tu vises B2B immédiat
- Tu acceptes risque

---

## ✅ RECOMMANDATION FINALE

```
┌─────────────────────────────────────────────────────────┐
│         STRATÉGIE RECOMMANDÉE: OPTION B                 │
│              (Phase 1 → Phase 2)                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Mois 1-2:  Phase 1 MVP Core                           │
│             → Cabinet fonctionnel immédiatement        │
│             → Validation concept                        │
│             → Feedback médecins réels                  │
│                                                          │
│  Mois 3-7:  Phase 2 NIC Integration                    │
│             → Certification officielle                  │
│             → Vente B2B possible                       │
│             → Automatisation complète                  │
│                                                          │
│  Résultat:  Logiciel certifié NIC en 7 mois           │
│             Utilisé dès mois 2                         │
│             Coût total: €100                           │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

**Pourquoi Option B?**
1. ✅ **Risque minimisé:** Tu valides le concept avant investir NIC
2. ✅ **Revenue early:** Cabinet opérationnel mois 2
3. ✅ **Feedback loop:** Améliorer MVP avant certification
4. ✅ **Motivation:** Quick wins (Phase 1) avant long grind (Phase 2)

---

## 📋 ACTIONS IMMÉDIATES (Next 48h)

### Si tu choisis Option B (Recommandé):

**Aujourd'hui:**
1. ✅ Décider: Phase 1 d'abord
2. 📅 Bloquer calendrier 5 semaines (Phase 1)
3. 🚀 Démarrer Epic 1 (Database migration)

**Demain:**
4. 📊 Review MVP_SPEC.md (relire fonctionnalités Phase 1)
5. 🗂️ Setup projet local (Supabase CLI, Git, etc.)

**Dans 5 semaines:**
6. 🎉 GO-LIVE Phase 1 (cabinet opérationnel)
7. ✉️ Envoyer emails NIC (démarrer Phase 2)

---

**Auteur:** Ismail Sialyen
**Date:** 2026-07-24
**Version:** 1.0
**Décision:** Option B - Phase 1 puis Phase 2 ✅

**Prêt à démarrer Phase 1 aujourd'hui?** 🚀

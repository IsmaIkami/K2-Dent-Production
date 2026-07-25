# 🦷 K2 Dental Cockpit - MVP Production Roadmap

**Auteur:** Ismail Sialyen
**Version:** 1.0
**Date:** 2026-07-24
**Budget:** €0/mois (100% Free Tier)
**Timeline:** 13 heures (6 epics)

---

## 📌 Vue d'Ensemble

### Objectif MVP
Déployer en production un système de gestion pour clinique dentaire belge avec cycle de vie patient complet, de la prise de rendez-vous jusqu'à la facturation INAMI.

### Périmètre Fonctionnel
**10 étapes cycle de vie patient:**

| # | Fonctionnalité | Statut | Epic |
|---|---------------|--------|------|
| 1 | 📅 **Booking** - Calendrier rendez-vous | ✅ Existant | - |
| 2 | 📋 **Anamnèse** - Questionnaire médical | ✅ Existant | - |
| 3 | 🦷 **Carte dentaire** - Éditeur JSONB | 🔄 À implémenter | Epic 3 |
| 4 | 💊 **Prescriptions** - PDF Puppeteer | 🔄 À implémenter | Epic 2 |
| 5 | 📸 **Radiographies** - Viewer 3D STL | 🔄 À implémenter | Epic 3 |
| 6 | 📄 **Certificats** - PDF médical | 🔄 À implémenter | Epic 2 |
| 7 | 📖 **Timeline** - Audit trail | 🔄 À implémenter | Epic 1 |
| 8 | 💰 **Facturation INAMI** - Export CSV | 🔄 À implémenter | Epic 4 |
| 9 | 🧾 **Factures** - PDF + QR EPC | 🔄 À implémenter | Epic 2, 4 |
| 10 | ✉️ **Rappels** - Emails IA SendGrid | 🔄 À implémenter | Epic 5 |

### Stack Technique (Free Tier)

| Composant | Service | Limite Free | Usage MVP |
|-----------|---------|-------------|-----------|
| **Database** | Supabase PostgreSQL | 500MB | ~200MB (estimé) |
| **Storage** | Supabase Storage | 1GB | ~500MB (PDF + STL) |
| **Functions** | Supabase Edge (Deno) | 500K/mois | ~10K/mois |
| **Auth** | Supabase Auth | ∞ users | ~5 médecins |
| **Email** | SendGrid Free | 100/jour | ~30/jour |
| **Backups** | GitHub Actions | 2000 min/mois | ~60 min/mois |
| **PDF** | Puppeteer (Edge) | Inclus functions | ~500 PDF/mois |

**Total coût:** €0/mois ✅

---

## 📊 KANBAN BOARD - État Actuel

### 🔴 TODO (Non démarré)

| Epic | Tâche | Effort | Priorité | Assigné |
|------|-------|--------|----------|---------|
| Epic 1 | Database Migration (13 tables) | 2h | P0 | - |
| Epic 2 | PDF Generation (3 fonctions) | 3h | P0 | - |
| Epic 3 | Frontend Integration (5 UIs) | 3h | P1 | - |
| Epic 4 | INAMI & Billing (CSV + QR) | 2h | P0 | - |
| Epic 5 | Appointment Reminders (SendGrid) | 2h | P1 | - |
| Epic 6 | Backup & Monitoring | 1h | P2 | - |

**Total TODO:** 13h

---

### 🟡 IN PROGRESS (En cours)

| Epic | Tâche | Progress | Bloqueurs | ETA |
|------|-------|----------|-----------|-----|
| - | - | - | - | - |

**Total IN PROGRESS:** 0h

---

### 🟢 DONE (Terminé)

| Epic | Tâche | Completed | Duration Réelle |
|------|-------|-----------|-----------------|
| Setup | Baseline BACKUP_STEP5 | 2026-07-24 | - |
| Setup | 5 tables existantes (users, patients, appointments, anamnesis, medical_history) | 2026-07-24 | - |
| Setup | Frontend dashboard.html avec calendrier | 2026-07-24 | - |
| Setup | Supabase project configuration | 2026-07-24 | - |

**Total DONE:** Infrastructure baseline ✅

---

### 🔵 BLOCKED (Bloqué)

| Epic | Tâche | Bloqueur | Action Requise |
|------|-------|----------|----------------|
| - | - | - | - |

**Total BLOCKED:** 0

---

## 🎯 EPICS DÉTAILLÉS

---

## Epic 1: Database Migration 📦
**Effort:** 2 heures
**Priorité:** 🔴 P0 (Bloquant)
**Status:** 🔴 TODO

### Objectif
Migrer le schéma complet de 13 tables avec fonctions PostgreSQL pour supporter tout le cycle de vie patient.

### User Stories
- **US1.1:** En tant que médecin, je veux que toutes mes données patients soient stockées dans un schéma normalisé pour éviter la corruption de données.
- **US1.2:** En tant que système, je dois tracker tous les événements patient dans une timeline pour l'audit RGPD.

### Tâches Détaillées

#### ✅ Task 1.1: Backup Vérification
**Effort:** 15 min
**Description:** Vérifier que BACKUP_STEP5 est intact et restorable
```bash
# Commandes
psql -f supabase/backups/BACKUP_STEP5_CALENDAR_FULLY_WORKING_20260724.sql
# Vérifier 5 tables présentes
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';
```
**Critères acceptation:** 5 tables présentes (users, patients, anamnesis, medical_history, appointments)

---

#### 📋 Task 1.2: Run complete-schema-final.sql
**Effort:** 30 min
**Description:** Créer 6 tables core (dental_charts, tooth_treatments, prescriptions, certificates, xrays, timeline_events)
```sql
-- File: supabase/complete-schema-final.sql
-- Tables à créer
CREATE TABLE dental_charts (...);
CREATE TABLE tooth_treatments (...);
CREATE TABLE prescriptions (...);
CREATE TABLE certificates (...);
CREATE TABLE xrays (...);
CREATE TABLE timeline_events (...);
```
**Critères acceptation:** 11 tables totales (5 existantes + 6 nouvelles)

---

#### 📋 Task 1.3: Run ai-appointment-reminders.sql
**Effort:** 20 min
**Description:** Créer 2 tables AI + view + fonctions PostgreSQL
```sql
-- File: supabase/ai-appointment-reminders.sql
CREATE TABLE appointment_reminders (...);
CREATE TABLE reminder_ai_config (...);
CREATE VIEW pending_reminders_ai AS ...;
CREATE FUNCTION generate_ai_reminders() ...;
CREATE FUNCTION mark_reminder_sent(UUID) ...;
```
**Critères acceptation:** 13 tables totales + 1 view + 2 fonctions

---

#### 📋 Task 1.4: ALTER staff_profiles
**Effort:** 10 min
**Description:** Ajouter foreign key user_id vers auth.users (fix blocage peer review)
```sql
ALTER TABLE staff_profiles
ADD COLUMN user_id UUID REFERENCES auth.users(id);
```
**Critères acceptation:** Foreign key contrainte créée sans erreur

---

#### 🔍 Task 1.5: Vérifier RLS Policies
**Effort:** 20 min
**Description:** Check que toutes les 13 tables ont des RLS policies (même dev-open)
```sql
SELECT schemaname, tablename, policyname, permissive, roles, qual
FROM pg_policies
WHERE schemaname = 'public';
```
**Critères acceptation:** Minimum 1 policy par table critique (patients, dental_charts, prescriptions)

---

#### 🧪 Task 1.6: Test Inserts Manuels
**Effort:** 20 min
**Description:** Insérer données test dans chaque nouvelle table
```sql
INSERT INTO dental_charts (patient_id, chart_data, created_by) VALUES (...);
INSERT INTO prescriptions (...);
INSERT INTO xrays (...);
-- Vérifier foreign keys respectés
```
**Critères acceptation:** Inserts réussissent, foreign keys valident

---

#### 💾 Task 1.7: Backup Post-Migration
**Effort:** 10 min
**Description:** Créer nouveau backup avec 13 tables
```bash
supabase db dump --project-ref sqgxscrwcffjfomlsoyf > supabase/backups/BACKUP_13_TABLES_$(date +%Y%m%d).sql
```
**Critères acceptation:** Fichier SQL ~500KB, contient CREATE TABLE × 13

---

### Dépendances
- Aucune (epic de base)

### Risques
| Risque | Impact | Mitigation |
|--------|--------|------------|
| DROP CASCADE perte données | CRITIQUE | Utiliser CREATE IF NOT EXISTS (fix SQL scripts) |
| INAMI table duplication | MOYEN | Utiliser uniquement tooth_treatments.inami_code |
| RLS policies trop ouvertes | ÉLEVÉ | Phase 2: tighten policies post-MVP |

### Validation Epic 1
```sql
-- Requête finale validation
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Doit afficher exactement 13 tables:
-- 1. anamnesis
-- 2. appointment_reminders
-- 3. appointments
-- 4. certificates
-- 5. dental_charts
-- 6. medical_history
-- 7. patients
-- 8. prescriptions
-- 9. reminder_ai_config
-- 10. staff_profiles
-- 11. timeline_events
-- 12. tooth_treatments
-- 13. xrays
```

---

## Epic 2: PDF Generation avec Puppeteer 📄
**Effort:** 3 heures
**Priorité:** 🔴 P0 (Bloquant)
**Status:** 🔴 TODO

### Objectif
Implémenter 3 Edge Functions Deno générant des PDF médicaux server-side avec Puppeteer (prescription, certificat, facture).

### User Stories
- **US2.1:** En tant que médecin, je veux générer une prescription PDF en 1 clic pour l'imprimer et la remettre au patient.
- **US2.2:** En tant que médecin, je veux générer un certificat médical (arrêt maladie, aptitude) avec en-tête légal.
- **US2.3:** En tant que patient, je veux recevoir une facture PDF avec QR code pour payer par virement bancaire.

### Tâches Détaillées

#### ⚙️ Task 2.1: Setup Supabase CLI Local
**Effort:** 15 min
**Description:** Initialiser projet local pour dev Edge Functions
```bash
supabase init
supabase login
supabase link --project-ref sqgxscrwcffjfomlsoyf
```
**Critères acceptation:** `supabase status` affiche services running

---

#### 💊 Task 2.2: generate-prescription-pdf
**Effort:** 60 min
**Description:** Edge Function prescription PDF
```typescript
// supabase/functions/generate-prescription-pdf/index.ts
import puppeteer from 'https://deno.land/x/puppeteer@16.2.0/mod.ts';
import { createClient } from '@supabase/supabase-js';

Deno.serve(async (req) => {
  const { patient_id, medications, diagnosis } = await req.json();

  // Fetch patient + doctor data from DB
  const supabase = createClient(...);
  const { data: patient } = await supabase.from('patients').select('*').eq('id', patient_id).single();
  const { data: doctor } = await supabase.from('staff_profiles').select('*').single();

  // Generate HTML
  const html = `
    <html>
      <head><style>/* Medical prescription styling */</style></head>
      <body>
        <h1>Prescription Médicale</h1>
        <p>Dr. ${doctor.name} - RIZIV ${doctor.riziv}</p>
        <p>Patient: ${patient.name} (${patient.date_of_birth})</p>
        <p>Diagnostic: ${diagnosis}</p>
        <ul>
          ${medications.map(m => `<li>${m.name} - ${m.dosage}</li>`).join('')}
        </ul>
        <p>Date: ${new Date().toLocaleDateString('fr-BE')}</p>
      </body>
    </html>
  `;

  // Puppeteer render
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();
  await page.setContent(html);
  const pdfBuffer = await page.pdf({ format: 'A4' });
  await browser.close();

  // Upload to Storage
  const fileName = `prescriptions/${patient_id}/${Date.now()}.pdf`;
  await supabase.storage.from('medical-documents').upload(fileName, pdfBuffer);

  // Insert DB record
  await supabase.from('prescriptions').insert({
    patient_id,
    medications,
    diagnosis,
    pdf_url: fileName,
    created_by: doctor.id
  });

  return new Response(JSON.stringify({ url: fileName }), {
    headers: { 'Content-Type': 'application/json' }
  });
});
```
**Critères acceptation:** PDF généré < 5s, stocké Storage, URL retournée

---

#### 📋 Task 2.3: generate-certificate-pdf
**Effort:** 45 min
**Description:** Edge Function certificat médical (sick_leave, fitness, dental_treatment)
```typescript
// supabase/functions/generate-certificate-pdf/index.ts
// Similar structure to prescription
// Template différent: certificat header, dates, raison
const html = `
  <h1>Certificat Médical</h1>
  <p>Type: ${certificate_type}</p>
  <p>Du ${start_date} au ${end_date}</p>
  <p>Raison: ${reason}</p>
`;
```
**Critères acceptation:** PDF certificat valide, dates formatées fr-BE

---

#### 💰 Task 2.4: generate-invoice-pdf (avec QR EPC)
**Effort:** 60 min
**Description:** Edge Function facture PDF + QR code virement SEPA
```typescript
// supabase/functions/generate-invoice-pdf/index.ts
import QRCode from 'https://deno.land/x/qrcode/mod.ts';

Deno.serve(async (req) => {
  const { patient_id, treatment_ids, iban_doctor } = await req.json();

  // Fetch treatments with INAMI codes
  const { data: treatments } = await supabase
    .from('tooth_treatments')
    .select('*, dental_chart:dental_charts(patient:patients(*))')
    .in('id', treatment_ids);

  // Calculate total
  const total = treatments.reduce((sum, t) => sum + parseFloat(t.cost), 0);

  // Generate EPC QR code
  const epcData = [
    'BCD',
    '002',
    '1',
    'SCT',
    '',
    'Dr. Cabinet Dentaire',
    iban_doctor,
    `EUR${total.toFixed(2)}`,
    '',
    '',
    `FACTURE-${Date.now()}`
  ].join('\n');

  const qrCodeDataUrl = await QRCode.toDataURL(epcData);

  // HTML template
  const html = `
    <h1>Facture</h1>
    <p>Patient: ${treatments[0].dental_chart.patient.name}</p>
    <table>
      <tr><th>Prestation</th><th>Code INAMI</th><th>Montant</th></tr>
      ${treatments.map(t => `
        <tr>
          <td>${t.treatment_type}</td>
          <td>${t.inami_code}</td>
          <td>€${t.cost}</td>
        </tr>
      `).join('')}
    </table>
    <p><strong>Total: €${total.toFixed(2)}</strong></p>
    <img src="${qrCodeDataUrl}" alt="QR Code Virement" />
    <p>Scannez ce QR code avec votre banking app pour payer</p>
  `;

  // Generate PDF with Puppeteer
  // Upload Storage
  // Return URL
});
```
**Critères acceptation:** QR code scannable banking app, virement pré-rempli

---

#### 🧪 Task 2.5: Test Local Functions
**Effort:** 20 min
**Description:** Tester les 3 fonctions en local
```bash
supabase functions serve
curl -X POST http://localhost:54321/functions/v1/generate-prescription-pdf \
  -H "Content-Type: application/json" \
  -d '{"patient_id": "...", "medications": [...], "diagnosis": "..."}'
```
**Critères acceptation:** 3 fonctions retournent 200 + PDF URL

---

#### 🚀 Task 2.6: Deploy Production
**Effort:** 10 min
**Description:** Déployer les 3 Edge Functions
```bash
supabase functions deploy generate-prescription-pdf
supabase functions deploy generate-certificate-pdf
supabase functions deploy generate-invoice-pdf
```
**Critères acceptation:** 3 fonctions accessibles via `https://sqgxscrwcffjfomlsoyf.functions.supabase.co/`

---

#### 🌐 Task 2.7: Test End-to-End Frontend
**Effort:** 10 min
**Description:** Appeler depuis frontend, télécharger PDF
```javascript
// Frontend test
const response = await fetch('https://sqgxscrwcffjfomlsoyf.functions.supabase.co/generate-prescription-pdf', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ patient_id, medications, diagnosis })
});
const { url } = await response.json();
window.open(url); // Download PDF
```
**Critères acceptation:** PDF téléchargé, affichage correct

---

### Dépendances
- Epic 1 terminé (tables prescriptions, certificates existent)
- Supabase Storage bucket `medical-documents` créé

### Risques
| Risque | Impact | Mitigation |
|--------|--------|------------|
| Puppeteer timeout Edge Functions (>30s) | MOYEN | Optimiser HTML, retry logic, fallback jsPDF |
| Storage 1GB limite dépassée | ÉLEVÉ | Compression PDF, archivage vieux docs |
| QR code illisible si mal formaté | FAIBLE | Test avec vraie banking app (KBC, BNP) |

### Validation Epic 2
- [ ] 3 PDF générés et téléchargeables
- [ ] QR code EPC scannable et virement pré-rempli
- [ ] Storage usage < 500MB
- [ ] PDF generation time < 5s moyenne

---

## Epic 3: Frontend Integration 🎨
**Effort:** 3 heures
**Priorité:** 🟡 P1 (Important)
**Status:** 🔴 TODO

### Objectif
Créer les 5 interfaces utilisateur manquantes pour compléter le cycle de vie patient (carte dentaire, prescription form, certificate form, X-ray viewer, timeline).

### User Stories
- **US3.1:** En tant que médecin, je veux éditer visuellement la carte dentaire du patient et sauvegarder en JSONB.
- **US3.2:** En tant que médecin, je veux remplir un formulaire prescription et générer le PDF en 1 clic.
- **US3.3:** En tant que médecin, je veux visualiser des radiographies 3D STL avec rotation/zoom.
- **US3.4:** En tant que médecin, je veux voir la timeline complète de tous les événements patient (chronologique).

### Tâches Détaillées

#### 🦷 Task 3.1: Dental Chart Editor
**Effort:** 60 min
**Description:** Adapter dental-chart-v2.html existant → JSONB saver
```javascript
// dental-chart-v2.html enhancement
const dentalChartData = {
  "teeth": {
    "11": { "status": "healthy", "treatments": [], "notes": "" },
    "12": { "status": "cavity", "treatments": ["filling"], "notes": "Carie profonde" },
    // ... 32 dents
  }
};

async function saveDentalChart() {
  const { data, error } = await supabase
    .from('dental_charts')
    .insert({
      patient_id: currentPatientId,
      chart_data: dentalChartData,
      created_by: currentUserId,
      notes: document.getElementById('chart-notes').value
    });

  if (!error) {
    alert('Carte dentaire sauvegardée');
    // Trigger timeline event
    await createTimelineEvent('dental_chart_updated', data.id);
  }
}
```
**Critères acceptation:** Carte sauvegardée JSONB, récupérable et éditable

---

#### 💊 Task 3.2: Prescription Form
**Effort:** 40 min
**Description:** Formulaire medications dynamique + génération PDF
```html
<!-- prescription-form.html -->
<form id="prescription-form">
  <input type="text" id="patient-search" placeholder="Rechercher patient...">
  <textarea id="diagnosis" placeholder="Diagnostic"></textarea>

  <div id="medications-container">
    <div class="medication-row">
      <input type="text" placeholder="Nom médicament">
      <input type="text" placeholder="Dosage (ex: 500mg)">
      <input type="text" placeholder="Fréquence (ex: 2x/jour)">
      <button onclick="removeMedication(this)">-</button>
    </div>
  </div>
  <button type="button" onclick="addMedication()">+ Ajouter médicament</button>

  <button type="submit">Générer PDF Prescription</button>
</form>

<script>
document.getElementById('prescription-form').addEventListener('submit', async (e) => {
  e.preventDefault();

  const medications = Array.from(document.querySelectorAll('.medication-row')).map(row => ({
    name: row.children[0].value,
    dosage: row.children[1].value,
    frequency: row.children[2].value
  }));

  const response = await fetch('https://sqgxscrwcffjfomlsoyf.functions.supabase.co/generate-prescription-pdf', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      patient_id: currentPatientId,
      medications,
      diagnosis: document.getElementById('diagnosis').value
    })
  });

  const { url } = await response.json();
  window.open(url); // Download PDF
});
</script>
```
**Critères acceptation:** Formulaire fonctionnel, PDF généré et téléchargé

---

#### 📋 Task 3.3: Certificate Form
**Effort:** 30 min
**Description:** Formulaire certificat médical (type, dates, raison)
```html
<!-- certificate-form.html -->
<form id="certificate-form">
  <select id="certificate-type">
    <option value="sick_leave">Arrêt de travail</option>
    <option value="fitness">Certificat aptitude</option>
    <option value="dental_treatment">Certificat soins dentaires</option>
  </select>

  <input type="date" id="start-date" placeholder="Date début">
  <input type="date" id="end-date" placeholder="Date fin">
  <textarea id="reason" placeholder="Raison"></textarea>

  <button type="submit">Générer Certificat PDF</button>
</form>

<script>
document.getElementById('certificate-form').addEventListener('submit', async (e) => {
  e.preventDefault();

  const response = await fetch('.../generate-certificate-pdf', {
    method: 'POST',
    body: JSON.stringify({
      patient_id: currentPatientId,
      certificate_type: document.getElementById('certificate-type').value,
      start_date: document.getElementById('start-date').value,
      end_date: document.getElementById('end-date').value,
      reason: document.getElementById('reason').value
    })
  });

  const { url } = await response.json();
  window.open(url);
});
</script>
```
**Critères acceptation:** PDF certificat généré avec bon template selon type

---

#### 📸 Task 3.4: X-Ray Viewer STL (Three.js)
**Effort:** 50 min
**Description:** Upload STL + viewer 3D interactif
```html
<!-- xray-viewer.html -->
<input type="file" id="stl-upload" accept=".stl">
<div id="threejs-container" style="width: 800px; height: 600px;"></div>
<textarea id="xray-notes" placeholder="Notes radiographie"></textarea>
<button id="save-xray">Sauvegarder</button>

<script type="module">
import * as THREE from 'https://cdn.skypack.dev/three@0.132.2';
import { STLLoader } from 'https://cdn.skypack.dev/three@0.132.2/examples/jsm/loaders/STLLoader.js';
import { OrbitControls } from 'https://cdn.skypack.dev/three@0.132.2/examples/jsm/controls/OrbitControls.js';

let scene, camera, renderer, controls;

function initThreeJS() {
  scene = new THREE.Scene();
  camera = new THREE.PerspectiveCamera(75, 800/600, 0.1, 1000);
  renderer = new THREE.WebGLRenderer();
  renderer.setSize(800, 600);
  document.getElementById('threejs-container').appendChild(renderer.domElement);

  controls = new OrbitControls(camera, renderer.domElement);
  camera.position.z = 5;

  // Lights
  const light = new THREE.DirectionalLight(0xffffff, 1);
  light.position.set(1, 1, 1);
  scene.add(light);

  animate();
}

function animate() {
  requestAnimationFrame(animate);
  controls.update();
  renderer.render(scene, camera);
}

document.getElementById('stl-upload').addEventListener('change', async (e) => {
  const file = e.target.files[0];

  // Upload to Supabase Storage
  const { data, error } = await supabase.storage
    .from('medical-documents')
    .upload(`xrays/${currentPatientId}/${file.name}`, file);

  // Load STL in Three.js
  const loader = new STLLoader();
  const fileUrl = URL.createObjectURL(file);
  loader.load(fileUrl, (geometry) => {
    const material = new THREE.MeshPhongMaterial({ color: 0xaaaaaa });
    const mesh = new THREE.Mesh(geometry, material);
    scene.add(mesh);
  });

  // Save metadata to DB
  await supabase.from('xrays').insert({
    patient_id: currentPatientId,
    file_url: data.path,
    xray_type: 'stl_3d',
    created_by: currentUserId
  });
});

document.getElementById('save-xray').addEventListener('click', async () => {
  // Update notes in DB
  await supabase.from('xrays')
    .update({ ai_analysis: { notes: document.getElementById('xray-notes').value } })
    .eq('patient_id', currentPatientId)
    .order('created_at', { ascending: false })
    .limit(1);
});

initThreeJS();
</script>
```
**Critères acceptation:** STL chargé, rotatable/zoomable, notes sauvegardées

---

#### 📖 Task 3.5: Timeline Patient
**Effort:** 40 min
**Description:** Afficher tous les événements patient (chronologique)
```html
<!-- patient-timeline.html -->
<div id="timeline-container"></div>

<script>
async function loadTimeline(patientId) {
  const { data: events } = await supabase
    .from('timeline_events')
    .select('*')
    .eq('patient_id', patientId)
    .order('created_at', { ascending: false });

  const container = document.getElementById('timeline-container');
  container.innerHTML = events.map(event => `
    <div class="timeline-event">
      <span class="event-date">${new Date(event.created_at).toLocaleDateString('fr-BE')}</span>
      <span class="event-type">${event.event_type}</span>
      <span class="event-data">${JSON.stringify(event.event_data)}</span>
    </div>
  `).join('');
}

// Auto-refresh every 10s
setInterval(() => loadTimeline(currentPatientId), 10000);
</script>
```
**Critères acceptation:** Timeline affiche tous événements, ordre chronologique inversé

---

### Dépendances
- Epic 1 terminé (tables dental_charts, xrays, timeline_events)
- Epic 2 terminé (Edge Functions PDF déployées)

### Risques
| Risque | Impact | Mitigation |
|--------|--------|------------|
| Three.js lent pour gros fichiers STL (>20MB) | MOYEN | Compression STL, lazy loading, warning UX |
| Timeline trop longue (>1000 events) | FAIBLE | Pagination 50 events, infinite scroll |

### Validation Epic 3
- [ ] Carte dentaire éditable et sauvegardable
- [ ] Prescription form → PDF généré
- [ ] Certificate form → PDF généré
- [ ] STL viewer fonctionnel avec rotation
- [ ] Timeline affiche ≥10 événements test

---

## Epic 4: INAMI & Billing 💶
**Effort:** 2 heures
**Priorité:** 🔴 P0 (Bloquant)
**Status:** 🔴 TODO

### Objectif
Implémenter facturation nomenclature belge INAMI avec export CSV eAttest et génération factures PDF avec QR code EPC.

### User Stories
- **US4.1:** En tant que médecin, je veux saisir les traitements avec codes INAMI pour facturer correctement.
- **US4.2:** En tant que médecin, je veux exporter un CSV eAttest pour envoyer aux mutualités.
- **US4.3:** En tant que patient, je veux recevoir une facture PDF avec QR code pour payer facilement.

### Tâches Détaillées

#### 📊 Task 4.1: INAMI Codes Database
**Effort:** 30 min
**Description:** Importer nomenclature INAMI (CSV manuel ou scraper)
```javascript
// Option A: CSV manuel téléchargé depuis INAMI.be
const inamiCodes = [
  { code: '305593', description: 'Détartrage complet', tarif_convention: 25.50 },
  { code: '377115', description: 'Extraction simple', tarif_convention: 35.00 },
  // ... ~200 codes dentaires
];

// Option B: Static JSON
// frontend/data/inami-codes.json

// Option C: Table database (si fréquents updates)
CREATE TABLE inami_codes (
  code VARCHAR(10) PRIMARY KEY,
  description TEXT,
  tarif_convention DECIMAL(10,2),
  tarif_libre DECIMAL(10,2)
);
```
**Critères acceptation:** Base codes INAMI accessible, autocomplete fonctionnel

---

#### 🦷 Task 4.2: Treatment Form avec INAMI
**Effort:** 30 min
**Description:** Formulaire saisie traitements avec autocomplete INAMI
```html
<!-- treatment-form.html -->
<form id="treatment-form">
  <input type="text" id="tooth-number" placeholder="Numéro dent (ex: 11)">
  <input type="text" id="inami-code-search" placeholder="Code INAMI..." list="inami-codes">
  <datalist id="inami-codes">
    <!-- Populated dynamically from INAMI database -->
  </datalist>
  <input type="text" id="treatment-type" placeholder="Type traitement">
  <input type="number" id="cost" placeholder="Coût EUR">
  <input type="date" id="treatment-date">
  <select id="status">
    <option value="planned">Planifié</option>
    <option value="completed">Terminé</option>
    <option value="canceled">Annulé</option>
  </select>
  <button type="submit">Enregistrer Traitement</button>
</form>

<script>
// Populate autocomplete
fetch('/data/inami-codes.json')
  .then(r => r.json())
  .then(codes => {
    const datalist = document.getElementById('inami-codes');
    codes.forEach(c => {
      const option = document.createElement('option');
      option.value = `${c.code} - ${c.description}`;
      datalist.appendChild(option);
    });
  });

document.getElementById('treatment-form').addEventListener('submit', async (e) => {
  e.preventDefault();

  await supabase.from('tooth_treatments').insert({
    dental_chart_id: currentDentalChartId,
    tooth_number: document.getElementById('tooth-number').value,
    inami_code: document.getElementById('inami-code-search').value.split(' ')[0],
    treatment_type: document.getElementById('treatment-type').value,
    cost: parseFloat(document.getElementById('cost').value),
    treatment_date: document.getElementById('treatment-date').value,
    status: document.getElementById('status').value,
    created_by: currentUserId
  });

  alert('Traitement enregistré');
});
</script>
```
**Critères acceptation:** Traitement sauvegardé avec code INAMI valide

---

#### 📤 Task 4.3: eAttest CSV Export
**Effort:** 30 min
**Description:** Générer CSV format eAttest pour import manuel
```javascript
// eattest-export.js
async function exportEattestCSV(patientId) {
  // Query completed treatments
  const { data: treatments } = await supabase
    .from('tooth_treatments')
    .select('*, dental_chart:dental_charts(patient:patients(*))')
    .eq('status', 'completed')
    .eq('dental_chart.patient_id', patientId);

  // CSV format eAttest (simplified)
  const csvHeader = 'NISS,Date,Code_INAMI,Montant,Dentiste_RIZIV\n';
  const csvRows = treatments.map(t => {
    const patient = t.dental_chart.patient;
    return `${patient.niss},${t.treatment_date},${t.inami_code},${t.cost},${doctorRIZIV}`;
  }).join('\n');

  const csv = csvHeader + csvRows;

  // Download CSV
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `eattest-${patientId}-${Date.now()}.csv`;
  a.click();
}
```
**Critères acceptation:** CSV téléchargé, importable sur portail eAttest

---

#### 💳 Task 4.4: Invoice Generator (UI)
**Effort:** 20 min
**Description:** UI sélection traitements → génération facture PDF
```html
<!-- invoice-generator.html -->
<h2>Générer Facture Patient</h2>
<div id="treatments-list">
  <!-- Checkboxes treatments completed -->
</div>
<input type="text" id="iban-doctor" placeholder="IBAN cabinet (BEXX...)">
<button id="generate-invoice">Générer Facture PDF</button>

<script>
async function loadCompletedTreatments(patientId) {
  const { data: treatments } = await supabase
    .from('tooth_treatments')
    .select('*')
    .eq('status', 'completed')
    .eq('dental_chart.patient_id', patientId);

  const list = document.getElementById('treatments-list');
  list.innerHTML = treatments.map(t => `
    <label>
      <input type="checkbox" value="${t.id}">
      ${t.treatment_type} (${t.inami_code}) - €${t.cost}
    </label>
  `).join('<br>');
}

document.getElementById('generate-invoice').addEventListener('click', async () => {
  const selectedIds = Array.from(document.querySelectorAll('#treatments-list input:checked'))
    .map(cb => cb.value);

  const iban = document.getElementById('iban-doctor').value;

  const response = await fetch('.../generate-invoice-pdf', {
    method: 'POST',
    body: JSON.stringify({
      patient_id: currentPatientId,
      treatment_ids: selectedIds,
      iban_doctor: iban
    })
  });

  const { url } = await response.json();
  window.open(url); // Download facture PDF with QR
});
</script>
```
**Critères acceptation:** Facture PDF générée avec QR code EPC

---

#### 📱 Task 4.5: Test Virement QR Code
**Effort:** 10 min
**Description:** Scanner QR avec vraie banking app
```
1. Générer facture PDF test
2. Scanner QR avec KBC Mobile, BNP Paribas Fortis app, etc.
3. Vérifier:
   - IBAN pré-rempli
   - Montant correct
   - Communication structurée
```
**Critères acceptation:** Virement pré-rempli correctement dans banking app

---

### Dépendances
- Epic 2 Task 2.4 terminé (generate-invoice-pdf déployé)
- Numéro RIZIV médecin disponible

### Risques
| Risque | Impact | Mitigation |
|--------|--------|------------|
| Codes INAMI obsolètes | MOYEN | Update CSV annuel depuis INAMI.be |
| QR code mal formaté (spec EPC) | ÉLEVÉ | Test avec 3+ banking apps différentes |

### Validation Epic 4
- [ ] Autocomplete INAMI fonctionnel (≥50 codes)
- [ ] CSV eAttest exporté et validé format
- [ ] Facture PDF avec QR code EPC scannable
- [ ] Virement pré-rempli dans banking app test

---

## Epic 5: Appointment Reminders ✉️
**Effort:** 2 heures
**Priorité:** 🟡 P1 (Important)
**Status:** 🔴 TODO

### Objectif
Implémenter système emails automatiques de rappel rendez-vous 24h avant via SendGrid avec scoring IA de priorité.

### User Stories
- **US5.1:** En tant que patient, je veux recevoir un email de rappel 24h avant mon rendez-vous pour ne pas oublier.
- **US5.2:** En tant que système, je veux prioriser les emails urgences et patients à risque pour respecter limite 100/jour SendGrid.

### Tâches Détaillées

#### 📧 Task 5.1: SendGrid Setup
**Effort:** 30 min
**Description:** Créer compte SendGrid, vérifier domaine, obtenir API key
```bash
# Steps:
1. Sign up SendGrid Free (100 emails/jour)
2. Verify sender email (ex: noreply@k2dental.be)
   - Configure SPF: v=spf1 include:sendgrid.net ~all
   - Configure DKIM (SendGrid provides keys)
3. Create API key (Settings → API Keys)
4. Store in Supabase Vault:

# Supabase CLI
supabase secrets set SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```
**Critères acceptation:** Sender email vérifié (green checkmark SendGrid dashboard)

---

#### 🤖 Task 5.2: Edge Function send-reminders
**Effort:** 50 min
**Description:** Cron function qui envoie emails via SendGrid
```typescript
// supabase/functions/send-reminders/index.ts
import { createClient } from '@supabase/supabase-js';

Deno.serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );

  // Query pending reminders (scheduled_send_time <= NOW())
  const { data: reminders } = await supabase
    .from('appointment_reminders')
    .select(`
      *,
      appointment:appointments(
        *,
        patient:patients(*)
      )
    `)
    .eq('status', 'pending')
    .lte('scheduled_send_time', new Date().toISOString())
    .order('ai_priority_score', { ascending: false }) // High priority first
    .limit(100); // SendGrid daily limit

  const SENDGRID_API_KEY = Deno.env.get('SENDGRID_API_KEY');

  for (const reminder of reminders) {
    const patient = reminder.appointment.patient;
    const appointment = reminder.appointment;

    // SendGrid API call
    const emailResponse = await fetch('https://api.sendgrid.com/v3/mail/send', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${SENDGRID_API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        personalizations: [{
          to: [{ email: patient.email, name: patient.name }],
          dynamic_template_data: {
            patient_name: patient.name,
            appointment_date: new Date(appointment.appointment_date).toLocaleDateString('fr-BE'),
            appointment_time: appointment.appointment_time,
            appointment_type: appointment.type
          }
        }],
        from: { email: 'noreply@k2dental.be', name: 'K2 Dental Cockpit' },
        template_id: 'd-xxxxxxxxxxxxxxxxxxxxx' // SendGrid dynamic template ID
      })
    });

    if (emailResponse.ok) {
      // Mark as sent
      await supabase.rpc('mark_reminder_sent', { reminder_id: reminder.id });
    } else {
      console.error(`Failed to send email for reminder ${reminder.id}`);
    }
  }

  return new Response(JSON.stringify({ sent: reminders.length }), {
    headers: { 'Content-Type': 'application/json' }
  });
});
```
**Critères acceptation:** Function envoie emails, marque status='sent'

---

#### ⏰ Task 5.3: Cron Schedule
**Effort:** 10 min
**Description:** Configurer cron quotidien 8h matin
```bash
supabase functions schedule send-reminders --cron "0 8 * * *"
# Cron syntax: minute hour day month weekday
# 0 8 * * * = every day at 8:00 AM UTC
```
**Critères acceptation:** Function invoquée automatiquement daily 8h

---

#### 📝 Task 5.4: SendGrid Template Email
**Effort:** 20 min
**Description:** Créer template dynamique SendGrid
```html
<!-- SendGrid Dynamic Template -->
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; padding: 20px; }
    .header { background: #0066cc; color: white; padding: 20px; }
    .content { padding: 20px; }
    .button { background: #0066cc; color: white; padding: 10px 20px; text-decoration: none; }
  </style>
</head>
<body>
  <div class="header">
    <h1>Rappel Rendez-vous</h1>
  </div>
  <div class="content">
    <p>Bonjour {{patient_name}},</p>
    <p>Nous vous rappelons votre rendez-vous demain:</p>
    <ul>
      <li><strong>Date:</strong> {{appointment_date}}</li>
      <li><strong>Heure:</strong> {{appointment_time}}</li>
      <li><strong>Type:</strong> {{appointment_type}}</li>
    </ul>
    <p>Si vous ne pouvez pas vous présenter, veuillez nous contacter au +32 XXX XX XX XX.</p>
    <a href="https://k2dental.be/confirm/{{appointment_id}}" class="button">Confirmer</a>
    <a href="https://k2dental.be/cancel/{{appointment_id}}" class="button">Annuler</a>
  </div>
</body>
</html>
```

**Dans SendGrid dashboard:**
1. Email API → Dynamic Templates → Create Template
2. Copy template ID → Update Edge Function `template_id`
3. Insert singleton config:
```sql
INSERT INTO reminder_ai_config (id, template_subject, enabled) VALUES
  (1, 'Rappel rendez-vous K2 Dental - {{appointment_date}}', true);
```
**Critères acceptation:** Template créé, ID configuré, variables {{}} fonctionnelles

---

#### 🧪 Task 5.5: Test Manuel Trigger
**Effort:** 10 min
**Description:** Appeler function manuellement pour test
```bash
curl -X POST https://sqgxscrwcffjfomlsoyf.functions.supabase.co/send-reminders \
  -H "Authorization: Bearer ANON_KEY"

# Vérifier inbox email patient test
```
**Critères acceptation:** Email reçu dans inbox (pas spam), contenu correct

---

#### 📊 Task 5.6: Monitor Logs 24h
**Effort:** Auto (passive)
**Description:** Vérifier logs Edge Function pour erreurs
```bash
supabase functions logs send-reminders --tail

# Check:
# - SendGrid API responses (202 Accepted)
# - mark_reminder_sent() called
# - No errors
```
**Critères acceptation:** Aucune erreur 24h après activation cron

---

### Dépendances
- Epic 1 terminé (tables appointment_reminders, reminder_ai_config)
- Patients table contient emails valides

### Risques
| Risque | Impact | Mitigation |
|--------|--------|------------|
| SendGrid 100/jour dépassé | ÉLEVÉ | Priorité IA (urgences first), cap bookings |
| Emails dans spam | MOYEN | SPF/DKIM correct, warm-up sending (start slow) |
| Patients sans email | FAIBLE | Validation email required on patient creation |

### Validation Epic 5
- [ ] SendGrid sender verified
- [ ] Template email créé et testé
- [ ] Cron fonctionne (daily 8h)
- [ ] ≥3 emails test reçus inbox (pas spam)
- [ ] mark_reminder_sent() updates status

---

## Epic 6: Backup & Monitoring 💾
**Effort:** 1 heure
**Priorité:** 🔵 P2 (Nice-to-have)
**Status:** 🔴 TODO

### Objectif
Implémenter backups automatiques quotidiens via GitHub Actions et dashboard monitoring des limites Supabase free tier.

### User Stories
- **US6.1:** En tant que développeur, je veux des backups quotidiens automatiques pour éviter perte de données.
- **US6.2:** En tant que développeur, je veux un dashboard visuel des limites Supabase pour anticiper dépassements.

### Tâches Détaillées

#### 🔄 Task 6.1: GitHub Actions Backup
**Effort:** 30 min
**Description:** Workflow daily backup PostgreSQL
```yaml
# .github/workflows/daily-backup.yml
name: Daily Database Backup

on:
  schedule:
    - cron: '0 2 * * *' # 2h AM daily
  workflow_dispatch: # Manual trigger

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Supabase CLI
        run: |
          curl -fsSL https://supabase.com/install.sh | sh
          echo "$HOME/.supabase/bin" >> $GITHUB_PATH

      - name: Login Supabase
        run: |
          supabase login --token ${{ secrets.SUPABASE_ACCESS_TOKEN }}

      - name: Dump database
        run: |
          BACKUP_FILE="supabase/backups/backup-$(date +%Y%m%d-%H%M%S).sql"
          supabase db dump --project-ref sqgxscrwcffjfomlsoyf > $BACKUP_FILE
          echo "Backup created: $BACKUP_FILE"

      - name: Commit backup
        run: |
          git config user.name "K2 Backup Bot"
          git config user.email "backup@k2dental.be"
          git add supabase/backups/*.sql
          git commit -m "🔄 Daily backup $(date +%Y-%m-%d)" || echo "No changes"
          git push
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Cleanup old backups (keep last 30)
        run: |
          cd supabase/backups
          ls -t backup-*.sql | tail -n +31 | xargs -r rm
```

**Secrets à configurer (GitHub Settings → Secrets):**
```
SUPABASE_ACCESS_TOKEN=sbp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Critères acceptation:** Backup SQL généré daily, commit repo, visible dans supabase/backups/

---

#### 📊 Task 6.2: Monitoring Dashboard
**Effort:** 25 min
**Description:** Page HTML dashboard limites Supabase
```html
<!-- frontend/monitoring-dashboard.html -->
<!DOCTYPE html>
<html>
<head>
  <title>K2 Monitoring Dashboard</title>
  <style>
    .metric { padding: 20px; border: 1px solid #ccc; margin: 10px; }
    .warning { background: #fff3cd; }
    .danger { background: #f8d7da; }
    .ok { background: #d4edda; }
  </style>
</head>
<body>
  <h1>K2 Dental Cockpit - Monitoring</h1>

  <div id="db-size" class="metric">
    <h3>Database Size</h3>
    <p id="db-current">Loading...</p>
    <p>Limit: 500MB</p>
    <div id="db-bar"></div>
  </div>

  <div id="storage-size" class="metric">
    <h3>Storage Usage</h3>
    <p id="storage-current">Loading...</p>
    <p>Limit: 1GB</p>
    <div id="storage-bar"></div>
  </div>

  <div id="functions-invocations" class="metric">
    <h3>Edge Functions (ce mois)</h3>
    <p id="functions-current">Loading...</p>
    <p>Limit: 500,000</p>
    <div id="functions-bar"></div>
  </div>

  <script type="module">
    import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm';

    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

    // Database size
    async function checkDBSize() {
      const { data, error } = await supabase.rpc('get_db_size');
      // PostgreSQL function:
      // CREATE OR REPLACE FUNCTION get_db_size() RETURNS bigint AS $$
      //   SELECT pg_database_size(current_database());
      // $$ LANGUAGE sql;

      const sizeMB = data / (1024 * 1024);
      const percentage = (sizeMB / 500) * 100;

      document.getElementById('db-current').textContent = `${sizeMB.toFixed(2)} MB (${percentage.toFixed(1)}%)`;

      const container = document.getElementById('db-size');
      if (percentage > 80) container.classList.add('danger');
      else if (percentage > 60) container.classList.add('warning');
      else container.classList.add('ok');
    }

    // Storage usage (API call)
    async function checkStorageSize() {
      // Supabase Management API
      const response = await fetch(`https://api.supabase.com/v1/projects/sqgxscrwcffjfomlsoyf/usage`, {
        headers: {
          'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
        }
      });
      const usage = await response.json();
      const storageGB = usage.storage_size_bytes / (1024 * 1024 * 1024);
      const percentage = (storageGB / 1) * 100;

      document.getElementById('storage-current').textContent = `${storageGB.toFixed(3)} GB (${percentage.toFixed(1)}%)`;

      const container = document.getElementById('storage-size');
      if (percentage > 80) container.classList.add('danger');
      else if (percentage > 60) container.classList.add('warning');
      else container.classList.add('ok');
    }

    // Functions invocations (mock - API not public)
    async function checkFunctionsUsage() {
      // Estimate from logs or manual tracking
      // For MVP: manual count acceptable
      document.getElementById('functions-current').textContent = 'Manual tracking required';
    }

    // Run checks
    checkDBSize();
    checkStorageSize();
    checkFunctionsUsage();

    // Auto-refresh every 5 minutes
    setInterval(() => {
      checkDBSize();
      checkStorageSize();
      checkFunctionsUsage();
    }, 5 * 60 * 1000);
  </script>
</body>
</html>
```

**PostgreSQL function à créer:**
```sql
CREATE OR REPLACE FUNCTION get_db_size() RETURNS bigint AS $$
  SELECT pg_database_size(current_database());
$$ LANGUAGE sql SECURITY DEFINER;
```

**Critères acceptation:** Dashboard affiche métriques réelles, couleurs warning/danger

---

#### 🧪 Task 6.3: Test Backup Restore (Dry-run)
**Effort:** 5 min
**Description:** Vérifier qu'un backup peut être restauré
```bash
# Local test avec backup récent
supabase db reset
psql -h db.sqgxscrwcffjfomlsoyf.supabase.co -U postgres -f supabase/backups/backup-20260724.sql

# Vérifier tables présentes
psql -h ... -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';"
# Expected: 13
```
**Critères acceptation:** Restore réussit sans erreur, 13 tables récupérées

---

### Dépendances
- GitHub repository configuré
- Supabase access token obtenu

### Risques
| Risque | Impact | Mitigation |
|--------|--------|------------|
| Backups GitHub trop volumineux (>100MB) | MOYEN | Compression .sql.gz, artifact storage au lieu de commit |
| Monitoring API rate limits | FAIBLE | Cache dashboard 5 min, éviter refresh trop fréquent |

### Validation Epic 6
- [ ] GitHub Actions workflow fonctionnel
- [ ] ≥3 backups générés (3 jours consécutifs)
- [ ] Dashboard affiche DB size réel
- [ ] Restore test réussi (dry-run)

---

## 📅 TIMELINE & SPRINT PLANNING

### Sprint 1 (Semaine 1)
**Focus:** Infrastructure & Database
**Durée:** 5 jours
**Effort:** 3h

| Jour | Epic | Tâches | Heures |
|------|------|--------|--------|
| Lundi | Epic 1 | Tasks 1.1-1.4 (Database migration) | 1.5h |
| Mardi | Epic 1 | Tasks 1.5-1.7 (RLS, tests, backup) | 1h |
| Mercredi | Epic 6 | Task 6.1 (GitHub Actions backup) | 0.5h |

**Deliverables:** 13 tables, RLS policies, backups automatiques

---

### Sprint 2 (Semaine 2)
**Focus:** PDF Generation
**Durée:** 5 jours
**Effort:** 3h

| Jour | Epic | Tâches | Heures |
|------|------|--------|--------|
| Lundi | Epic 2 | Tasks 2.1-2.2 (Setup + prescription PDF) | 1.25h |
| Mardi | Epic 2 | Task 2.3 (Certificate PDF) | 0.75h |
| Mercredi | Epic 2 | Task 2.4 (Invoice PDF + QR) | 1h |

**Deliverables:** 3 Edge Functions déployées, PDF générés

---

### Sprint 3 (Semaine 3)
**Focus:** Frontend Integration
**Durée:** 5 jours
**Effort:** 4h

| Jour | Epic | Tâches | Heures |
|------|------|--------|--------|
| Lundi | Epic 3 | Task 3.1 (Dental chart editor) | 1h |
| Mardi | Epic 3 | Tasks 3.2-3.3 (Prescription + certificate forms) | 1.5h |
| Mercredi | Epic 3 | Task 3.4 (X-ray viewer Three.js) | 1h |
| Jeudi | Epic 3 | Task 3.5 (Timeline) | 0.75h |
| Vendredi | Epic 4 | Tasks 4.1-4.2 (INAMI codes + form) | 1h |

**Deliverables:** 5 UIs fonctionnelles, viewer 3D

---

### Sprint 4 (Semaine 4)
**Focus:** Billing & Reminders
**Durée:** 5 jours
**Effort:** 3h

| Jour | Epic | Tâches | Heures |
|------|------|--------|--------|
| Lundi | Epic 4 | Tasks 4.3-4.5 (CSV export + invoice + test QR) | 1h |
| Mardi | Epic 5 | Tasks 5.1-5.2 (SendGrid setup + Edge Function) | 1.25h |
| Mercredi | Epic 5 | Tasks 5.3-5.6 (Cron + template + test) | 0.75h |

**Deliverables:** Facturation complète, emails automatiques

---

### Sprint 5 (Semaine 5)
**Focus:** Monitoring & Final Tests
**Durée:** 3 jours
**Effort:** 1.5h

| Jour | Epic | Tâches | Heures |
|------|------|--------|--------|
| Lundi | Epic 6 | Tasks 6.2-6.3 (Dashboard + restore test) | 0.5h |
| Mardi | Testing | End-to-end cycle complet patient | 0.5h |
| Mercredi | Launch | Go-live production | 0.5h |

**Deliverables:** MVP production ready ✅

---

## ✅ CRITÈRES D'ACCEPTATION GLOBAUX

### Must-Have (Bloquants Launch)

| # | Critère | Epic | Status |
|---|---------|------|--------|
| 1 | 13 tables déployées production | Epic 1 | 🔴 TODO |
| 2 | Cycle de vie patient complet (10 étapes) | All | 🔴 TODO |
| 3 | PDF prescriptions/certificats/factures OK | Epic 2 | 🔴 TODO |
| 4 | Viewer 3D STL radiographies fonctionnel | Epic 3 | 🔴 TODO |
| 5 | Rappels emails quotidiens actifs | Epic 5 | 🔴 TODO |
| 6 | Backups GitHub Actions daily | Epic 6 | 🔴 TODO |
| 7 | Monitoring dashboard limites Supabase | Epic 6 | 🔴 TODO |
| 8 | 2FA médecins configuré | Setup | 🔴 TODO |
| 9 | Zero bugs bloquants | Testing | 🔴 TODO |
| 10 | CSV eAttest exportable | Epic 4 | 🔴 TODO |

---

### Nice-to-Have (Post-MVP Phase 2)

- [ ] SMS rappels (Twilio - €15/mois)
- [ ] IA analyse radiographies (GPT-4 Vision)
- [ ] MyCareNet API automatique (SOAP/OIDC)
- [ ] Patient portal self-booking
- [ ] Stripe payments auto
- [ ] RLS policies granulaires par rôle

---

### Performance Targets

| Métrique | Target | Epic | Méthode Mesure |
|----------|--------|------|----------------|
| PDF generation time | < 5s | Epic 2 | Puppeteer logs |
| STL viewer load time | < 3s | Epic 3 | Three.js performance.now() |
| Dashboard load time | < 2s | All | Browser DevTools |
| Email delivery time | < 1min | Epic 5 | SendGrid webhook |
| Database query time | < 500ms | All | Supabase logs |

---

## 📊 MÉTRIQUES SUCCÈS MVP

### Techniques

| Métrique | Target | Méthode Tracking |
|----------|--------|------------------|
| Uptime Supabase | > 99% | Supabase dashboard |
| Email delivery rate | > 95% | SendGrid analytics |
| PDF generation success | > 98% | Edge Functions logs |
| Zero data loss | 100% | Backups testés restore |
| DB size usage | < 400MB | Monitoring dashboard |
| Storage usage | < 800MB | Monitoring dashboard |

---

### Business

| Métrique | Target | Timeline |
|----------|--------|----------|
| Médecins pilotes actifs | ≥1 | Semaine 5 |
| Patients cycle complet | ≥10 | Mois 1 |
| Demo investisseurs réussie | 1 | Mois 2 |
| Feedback NPS utilisateurs | > 8/10 | Mois 2 |
| Adoption rate features | > 80% | Mois 3 |

---

## ❓ QUESTIONS TECHNIQUES EN SUSPENS

### Q1: SendGrid 100/jour Overflow
**Options:**
- A) ✅ Queue FIFO priorité IA (0.95 urgences first)
- B) Cap bookings 100/jour
- C) Upgrade SendGrid ($15/mois)

**Décision:** Option A (gratuit + intelligent)

---

### Q2: INAMI Scraping Légal?
**Options:**
- A) Scraper auto (gray zone)
- B) ✅ CSV manuel téléchargé (safe)
- C) Saisie manuelle (tedious)

**Décision:** Option B (one-time effort)

---

### Q3: IBAN Placeholder Factures
**Options:**
- A) Hardcodé config
- B) Template éditable
- C) ✅ Input IBAN par facture

**Décision:** Option C (flexible multi-médecins)

---

### Q4: STL Test Files
**Options:**
- A) Scans réels anonymisés
- B) Dummy Blender
- C) ✅ Samples open-source (Thingiverse)

**Décision:** Option C (rapide + réaliste)

---

### Q5: Monitoring Alerts 80%
**Options:**
- A) ✅ Email auto Edge Function cron
- B) Check manuel weekly
- C) Slack webhook

**Décision:** Option A (proactive)

---

## 🚨 RISQUES PROJET

### Risques Techniques

| Risque | Probabilité | Impact | Mitigation | Owner |
|--------|-------------|--------|------------|-------|
| Supabase DB 500MB dépassé | Moyenne | CRITIQUE | Monitoring + archivage | Dev |
| SendGrid 100/j insuffisant | Élevée | ÉLEVÉ | Priorité IA + cap | Dev |
| Puppeteer timeout (>30s) | Faible | MOYEN | Retry + fallback jsPDF | Dev |
| Three.js lent gros STL | Moyenne | FAIBLE | Compression + warning UX | Dev |
| RLS dev-open = sécurité faible | Certaine | ÉLEVÉ | Phase 2 tighten policies | Sec |

---

### Contraintes Projet

- **Budget:** €0/mois strict (free tier only)
- **Timeline:** 5 semaines maximum
- **Qualité:** Zero bugs bloquants launch
- **Compliance:** Codes INAMI exacts
- **Sécurité:** PHI protégé (RGPD-compliant)
- **Attribution:** Jamais "Claude" dans commits

---

## 📖 GLOSSAIRE

| Terme | Définition |
|-------|------------|
| **INAMI** | Institut National d'Assurance Maladie-Invalidité (nomenclature belge) |
| **eAttest** | Système électronique attestations soins mutualités |
| **EPC QR** | European Payments Council QR code (virements SEPA) |
| **RIZIV** | Numéro identification médecin (équivalent INAMI) |
| **NISS** | Numéro national sécurité sociale (11 chiffres) |
| **STL** | Stereolithography (format fichier 3D scans) |
| **RLS** | Row Level Security (Supabase policies) |
| **PHI** | Protected Health Information (données sensibles) |
| **Puppeteer** | Headless browser automation (PDF generation) |

---

## 📞 CONTACTS & RESSOURCES

### Support Technique
- **Supabase Support:** support@supabase.com
- **SendGrid Support:** support@sendgrid.com
- **GitHub Actions Docs:** https://docs.github.com/actions

### Documentation Références
- **Supabase Edge Functions:** https://supabase.com/docs/guides/functions
- **Puppeteer Deno:** https://deno.land/x/puppeteer
- **Three.js STL Loader:** https://threejs.org/examples/#webgl_loader_stl
- **EPC QR Spec:** https://www.europeanpaymentscouncil.eu/document-library/guidance-documents/quick-response-code-guidelines-enable-data-capture-initiation

---

**Document Auteur:** Ismail Sialyen
**Dernière mise à jour:** 2026-07-24
**Version:** 1.0
**Status:** Ready for Confluence import ✅

---

## 🔄 INSTRUCTIONS IMPORT CONFLUENCE

### Méthode 1: Copy-Paste Direct
1. Copier ce fichier Markdown complet
2. Confluence → Créer page → Mode édition
3. Coller (Confluence auto-détecte Markdown)
4. Ajuster formatage si nécessaire

### Méthode 2: Markdown Import Plugin
1. Installer "Markdown Importer for Confluence"
2. Import ce fichier .md
3. Confluence génère structure automatique

### Méthode 3: Manuel avec Tables
1. Créer page parent "K2 MVP Roadmap"
2. Créer 6 sous-pages (1 par Epic)
3. Copier sections Epic par Epic
4. Utiliser macros Confluence: Status, Tasks, Tables

### Kanban Board (Jira Integration)
Si Jira connecté à Confluence:
1. Créer Jira board "K2 MVP"
2. Créer 6 Epics Jira
3. Créer tasks depuis tableaux ci-dessus
4. Embed Jira board dans page Confluence: `{jira:board=K2-MVP}`

---

**Prêt à importer dans Confluence** ✅

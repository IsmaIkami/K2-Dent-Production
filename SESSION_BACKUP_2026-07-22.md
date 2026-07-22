# 🔄 SESSION BACKUP - K2 Dent Production
**Date:** 2026-07-22
**Objectif:** Documentation complète pour continuité des sessions futures

---

## 📋 CONTEXTE DU PROJET

**K2 Dent** est un système de gestion pour cabinet dentaire professionnel développé pour le Dr. Ismail Sialyen.

### Stack Technique
- **Frontend:** HTML5, CSS3, JavaScript vanilla
- **Database:** Supabase (PostgreSQL)
- **Hébergement:** GitHub Pages
- **Thème:** Dark mode professionnel avec design moderne

### URLs et Credentials
```javascript
// Supabase Production
SUPABASE_URL: 'https://sqgxscrwcffjfomlsoyf.supabase.co'
SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNxZ3hzY3J3Y2ZmamZvbWxzb3lmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ2NTE2NjMsImV4cCI6MjEwMDIyNzY2M30.TtLYJKBM7XxrdsHiHS9EGOxnyniSdAhBLPUkhpReidU'

// Projet ID
sqgxscrwcffjfomlsoyf
```

**⚠️ IMPORTANT:** Les credentials sont documentées dans `/SUPABASE_CONFIG_REFERENCE.md`

---

## 🗂️ STRUCTURE DES FICHIERS

### Fichiers de Configuration
1. **`/frontend/config.js`** - Configuration principale (dev/prod)
2. **`/frontend/js/config.js`** - Configuration simplifiée pour calendar.html
3. **`/frontend/js/supabase-client.js`** - Client Supabase et fonctions DB

### Pages Principales
1. **`/frontend/index.html`** - Landing page
2. **`/frontend/dashboard.html`** - Dashboard patient 360°
3. **`/frontend/patients.html`** - Gestion patients
4. **`/frontend/calendar.html`** - Module Agenda (MODULE PRINCIPAL)

### Base de Données SQL
- **`/supabase/ai-appointment-reminders.sql`** - Système de rappels IA

### Documentation
- **`/SUPABASE_CONFIG_REFERENCE.md`** - Guide des credentials
- **`/REGRESSION_TEST_REPORT.md`** - Tests et validation
- **`/README-AI-Reminders.md`** - Documentation rappels IA

---

## 🏗️ ARCHITECTURE BASE DE DONNÉES

### Tables Principales

**1. `patients`**
```sql
- id (uuid, primary key)
- niss (text, unique) -- Numéro national belge
- first_name, last_name
- date_of_birth, gender (F/M/X)
- phone, email
- address_street, address_city, address_zip
- mutuelle_code
- Medical: blood_type, anticoagulant_therapy, heart_disease,
  diabetes, pregnant, smoker, hypertension, allergies
- created_at, updated_at
```

**2. `appointments`**
```sql
- id (uuid, primary key)
- patient_id (foreign key → patients.id)
- appointment_date (date)
- start_time (time)
- end_time (time)
- duration_minutes (integer)
- type (text) -- 45+ types prédéfinis
- status (text) -- scheduled/confirmed/arrived/in_progress/completed/cancelled/no_show
- notes (text)
- reminder_sent (boolean)
- created_at, updated_at
```

**3. `medical_history`**
```sql
- Versioning system
- Colonnes: blood_type, allergies, medications, medical_conditions, etc.
```

**4. `appointment_reminders`**
```sql
- Système IA de rappels automatiques
- Scoring de priorité (0.95 urgences, 0.85 patients à risque)
- Types: SMS, EMAIL, WHATSAPP, PHONE
- Timing: 24H, 48H, 1_WEEK, etc.
```

### Relations
- `appointments.patient_id` → `patients.id` (CASCADE)
- `appointment_reminders.patient_id` → `patients.id`
- `appointment_reminders.appointment_id` → `appointments.id`

---

## 🎯 FONCTIONNALITÉS IMPLÉMENTÉES

### 1. Dashboard (dashboard.html)

**Sections:**
- **Patients du Jour** - Liste des rendez-vous d'aujourd'hui avec badges de risque
- **Patient Cockpit 360°** - Vue complète d'un patient spécifique
- **Timeline** - Historique des événements patient
- **KPIs** - Statistiques (dernière visite, prochain RDV, anamnèses, prescriptions, radios)

**Fonctionnalités clés:**
- Chargement par NISS: `dashboard.html?niss=XXXXXXXXXXX`
- Auto-scroll vers la fiche patient
- Masquage de "Patients du Jour" quand patient spécifique chargé
- Bouton "← Retour aux Patients du Jour"

**Fonctions importantes:**
```javascript
loadTodaysPatients() // Charge RDV du jour
loadPatientByNISS(niss) // Charge patient spécifique
updatePatientInfo(patient) // MAJ UI
displayTodaysPatients(appointments) // Affiche liste
```

**Ordre de chargement des scripts (CRITIQUE):**
```html
<head>
    <script src="config.js"></script> <!-- MUST BE FIRST -->
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
    <script src="js/supabase-client.js"></script>
</head>
```

### 2. Calendrier (calendar.html)

**Vues disponibles:**
- **Vue Mois** (défaut) - Grille calendrier mensuel
- **Vue Liste** - Liste détaillée avec métadonnées patients

**Bouton "Aujourd'hui":**
- Bascule en vue Liste filtrée sur le jour actuel
- Affiche planning détaillé avec:
  - Heures de rendez-vous
  - Nom patient + type RDV
  - Contact (téléphone, email)
  - Groupe sanguin
  - Badges de risque (anticoagulants, cardiaque, diabète, grossesse, etc.)
  - Notes du rendez-vous
  - Actions: Modifier, Voir Dossier

**Types de rendez-vous (45+ prédéfinis):**
Organisés en optgroups:
- Consultations (Première consultation, Contrôle périodique, Urgence)
- Prévention & Hygiène (Détartrage, Polissage, Scellant)
- Soins Conservateurs (Composite, Amalgame, Inlay/Onlay)
- Endodontie (Dévitalisation, Retraitement canalaire)
- Chirurgie (Extraction, Implant, Greffe osseuse)
- Prothèses (Couronne, Bridge, Prothèse amovible)
- Esthétique (Blanchiment, Facette, Composite esthétique)
- Parodontologie (Détartrage profond, Surfaçage, Greffe gingivale)
- Orthodontie (Consultation, Pose appareil, Ajustement)
- Radiologie (Panoramique, Rétro-alvéolaire, CBCT)
- Urgences (Douleur, Infection, Fracture)

**Durées suggérées automatiquement:**
```javascript
'Première consultation': 60 min
'Détartrage': 45 min
'Dévitalisation': 90 min
'Implant': 120 min
'Couronne': 90 min
// etc.
```

**Navigation patient vers dossier:**
```javascript
// Lien vers fiche patient
onclick="window.location.href='dashboard.html?niss=${patient.niss}'"
// Désactivé si patient sans NISS
```

**Fonction renderListView():**
```javascript
renderListView(filterDate = null)
// filterDate = new Date() → affiche seulement ce jour
// filterDate = null → affiche tout le mois
```

### 3. Gestion Patients (patients.html)

**Formulaire complet avec:**
- Données civiles (nom, prénom, NISS, naissance, genre F/M/X)
- Contact (téléphone, email, adresse)
- Mutuelle belge
- Données médicales détaillées
- Champs conditionnels (grossesse/allaitement si genre F)

---

## 🔧 PROBLÈMES RÉSOLUS CETTE SESSION

### 1. ❌ → ✅ Credentials Supabase invalides
**Symptôme:** DNS error "server with hostname could not be found"
**Cause:** URL invalide `iibdamkqxmyyvxsijsgc.supabase.co`
**Solution:** Remplacé par `sqgxscrwcffjfomlsoyf.supabase.co`
**Commit:** `ce51516`, `5f57c52`

### 2. ❌ → ✅ Dashboard - Patients du jour vides
**Symptôme:** `TypeError: null is not an object (window.supabaseClient.from)`
**Cause:** Ordre de chargement des scripts incorrect
**Solution:** Déplacé `config.js` AVANT `supabase-client.js` dans `<head>`
**Commit:** `3169955`

### 3. ❌ → ✅ Colonnes DB incorrectes
**Symptôme:** Requêtes échouent, données vides
**Cause:** `appointment_time` au lieu de `start_time`, `patient` au lieu de `patients`
**Solution:**
```javascript
// AVANT
.order('appointment_time')
const patient = appt.patient;

// APRÈS
.order('start_time')
const patient = appt.patients; // relation Supabase
```
**Commit:** `421dc47`

### 4. ❌ → ✅ Bouton "Aujourd'hui" ne fait rien
**Symptôme:** Clic sans effet visible
**Cause:** Restait en vue mois, pas de scroll, pas de détails
**Solution:**
- Force vue Liste avec filtre date
- Scroll automatique
- Affichage métadonnées patients complètes
**Commit:** `7b11acb`, `11aa5dd`

### 5. ❌ → ✅ Fiche patient invisible
**Symptôme:** Patient chargé mais interface générique affichée
**Cause:** Section patient en dessous de "Patients du Jour", pas de scroll
**Solution:**
- Masquer "Patients du Jour" si patient spécifique
- Auto-scroll vers Patient Cockpit
- Bouton "← Retour" dans topbar
**Commit:** `8b554b2`

---

## 🎨 DESIGN & UX

### Palette de couleurs (Dark Mode)
```css
--primary: #0066FF (bleu)
--secondary: #7C3AED (violet)
--success: #34C759 (vert)
--warning: #FF9500 (orange)
--danger: #FF3B30 (rouge)
--bg-primary: #000000
--bg-secondary: #1C1C1E
--bg-card: #2C2C2E
--border: #38383A
--text-primary: #FFFFFF
--text-secondary: #AEAEB2
```

### Animations
```css
@keyframes pulse - Clignotement
@keyframes slideIn - Glissement depuis le bas
@keyframes spin - Rotation (loaders)
```

### Composants réutilisables
- `.btn`, `.btn-primary`, `.btn-secondary`
- `.card` - Conteneur avec ombre
- `.tag`, `.tag-risk`, `.tag-priority` - Badges
- `.appointment-list-item` - Carte de rendez-vous
- `.patient-info-card` - Fiche patient

---

## 🔍 DEBUGGING & LOGS

### Patterns de logging utilisés
```javascript
console.log('🔍 ...') // Recherche/inspection
console.log('✅ ...') // Succès
console.log('❌ ...') // Erreur
console.log('⚠️ ...') // Warning
console.log('📊 ...') // Données/stats
console.log('🔄 ...') // Chargement
console.log('📋 ...') // Action utilisateur
console.log('🎨 ...') // UI update
```

### Points de log critiques

**Dashboard - Chargement patient:**
```javascript
🔍 URL params: ?niss=XXXXX
🔍 NISS from URL: XXXXX
📋 Loading patient with NISS: XXXXX
🔄 Fetching patient from DB...
📦 DB.getPatientByNISS returned: {...}
✅ Patient found: John Doe
✅ Hidden "Patients du Jour" section
✅ Showing back button
🎨 Updating patient info UI for: John Doe
✅ Updated .patient-name element
✅ Scrolled to patient section
✅ Patient fully loaded: John Doe
```

**Calendar - Aujourd'hui:**
```javascript
📅 Bouton "Aujourd'hui" cliqué - Affichage vue détaillée du jour
📊 Displaying today patients: 3
✅ Vue détaillée du jour affichée
```

**Patients sans NISS:**
```javascript
⚠️ Patient sans NISS: {...}
⚠️ Appointment data: {...}
```

---

## 📝 CONVENTIONS DE CODE

### Naming
- **Fonctions:** camelCase (`loadPatientByNISS`, `renderListView`)
- **Variables:** camelCase (`currentPatient`, `todaySection`)
- **Constantes:** UPPER_SNAKE_CASE (`SUPABASE_URL`, `DEMO_MODE`)
- **IDs HTML:** kebab-case (`patient-email`, `today-patients-list`)
- **Classes CSS:** kebab-case (`.patient-info-card`, `.btn-primary`)

### Structure fichiers
```
frontend/
├── index.html
├── dashboard.html
├── patients.html
├── calendar.html
├── config.js (MUST LOAD FIRST)
├── js/
│   ├── config.js (for calendar)
│   ├── supabase-client.js
│   ├── belgium.js
│   └── ai-dental.js
└── css/
    └── (inline dans HTML pour l'instant)

supabase/
├── ai-appointment-reminders.sql
└── README-AI-Reminders.md
```

### Git Commits
Format:
```
Title (imperative mood)

SECTION (FIXES/IMPROVEMENTS/FEATURES):
- Bullet point 1
- Bullet point 2

Explanation paragraph if needed.

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## 🚀 PROCHAINES ÉTAPES

### Session en cours - URGENT
1. **Optimiser landing de calendar.html**
   - Par défaut: Vue Jour détaillée (aujourd'hui)
   - Puis permettre navigation: Semaine, Mois, Année
   - Workflow optimal pour le docteur

### Backlog - Haute priorité
1. **Déployer SQL AI Reminders sur Supabase**
   - Exécuter `ai-appointment-reminders.sql`
   - Tester `generate_ai_reminders()`

2. **Intégration APIs externes**
   - Twilio pour SMS
   - SendGrid pour emails
   - Cron job automatique

3. **Tests manuels complets**
   - Créer patients de test
   - Créer rendez-vous
   - Vérifier toutes les vues

### Backlog - Features futures
1. Vue semaine timeline (8h-18h avec créneaux)
2. Vue année (calendrier annuel)
3. Drag & drop pour déplacer RDV
4. Gestion des conflits horaires
5. Export PDF du planning
6. Impression planning journalier

---

## ⚠️ POINTS D'ATTENTION POUR SESSIONS FUTURES

### 1. TOUJOURS vérifier les credentials
**Fichier de référence:** `/SUPABASE_CONFIG_REFERENCE.md`

**Bonne URL:** `https://sqgxscrwcffjfomlsoyf.supabase.co`
**Mauvaise URL:** `https://iibdamkqxmyyvxsijsgc.supabase.co` ❌

### 2. Ordre de chargement des scripts
```html
<!-- ✅ CORRECT -->
<head>
    <script src="config.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
    <script src="js/supabase-client.js"></script>
</head>

<!-- ❌ INCORRECT -->
<head>
    <script src="js/supabase-client.js"></script>
    <!-- config.js chargé trop tard -->
</head>
```

### 3. Noms de colonnes DB
```javascript
// ✅ CORRECT
appointment_date, start_time, end_time
patients (relation foreign key - pluriel!)

// ❌ INCORRECT
appointment_time, appointment_date
patient (singulier)
```

### 4. Cache busting
Toujours incrémenter la version après modification:
```html
<script src="js/config.js?v=5"></script> <!-- v=4 → v=5 -->
```

### 5. Demo Mode
```javascript
DEMO_MODE: false // Production
DEMO_MODE: true  // Development local sans DB
```

---

## 🧪 TESTS DE RÉGRESSION

**Fichier:** `/REGRESSION_TEST_REPORT.md`

**Dernière exécution:** 2026-07-22
**Résultat:** ✅ 54/54 tests passés (100%)

**Tests critiques:**
- Structure fichiers
- Navigation entre pages
- Fonctions DB (getAllPatients, getPatientByNISS, etc.)
- Dashboard - Données médicales
- Patients.html - Formulaire avec genre
- Calendar.html - Module agenda complet
- AI Reminders SQL - Tables/Views/Functions

---

## 📞 CONTACTS & SUPPORT

**Développeur:** Ismail Sialyen
**Email:** is.sialyen@gmail.com
**GitHub:** https://github.com/IsmaIkami/K2-Dent-Production

**Powered by:** RCE AI Engine
**Framework:** Claude Code (Anthropic)

---

## 🔐 SÉCURITÉ

### Credentials exposées
- ✅ SUPABASE_ANON_KEY: Safe to expose (lecture seule publique)
- ⚠️ Ne JAMAIS commiter: Service Role Key, API secrets
- ⚠️ Row Level Security (RLS) activé sur toutes les tables

### Best Practices
- Validation côté client ET serveur
- Sanitization des inputs
- Pas de requêtes SQL directes (utiliser Supabase client)
- HTTPS uniquement

---

## 📚 DOCUMENTATION EXTERNE

- **Supabase Docs:** https://supabase.com/docs
- **Supabase JS Client:** https://supabase.com/docs/reference/javascript
- **INAMI (Belgique):** https://www.inami.fgov.be/
- **Claude Code Docs:** https://docs.claude.com/en/docs/claude-code

---

**FIN DU BACKUP - SESSION 2026-07-22**

**Derniers commits:**
- `ce51516` - Fix Supabase credentials
- `3169955` - Fix dashboard script order
- `421dc47` - Fix today's patients display
- `7b11acb` - Improve 'Aujourd'hui' button
- `11aa5dd` - Add professional daily view
- `d1cb930` - Add patient dossier logging
- `8b554b2` - Fix patient dossier view

**État actuel:** ✅ Système fonctionnel, dashboard et calendrier opérationnels

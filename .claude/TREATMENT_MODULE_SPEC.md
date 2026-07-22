# 🎯 MODULE PLAN DE TRAITEMENT - SPÉCIFICATIONS COMPLÈTES

**Date:** 22 juillet 2026
**Version:** 1.0
**Status:** 🚧 En Développement

---

## 🎨 VISION DU MODULE

Module ultra-complet avec IA pour la planification intelligente des traitements dentaires, automatisation complète des prix INAMI, remboursements mutuelles, et workflow optimisé pour le praticien.

---

## 🎯 FONCTIONNALITÉS PRINCIPALES

### 1. 🦷 Carte Dentaire Interactive
**Interface visuelle pour sélection rapide:**
- Vue complète 32 dents (FDI notation: 11-48)
- Statut visuel par couleur:
  - ✅ Vert: Sain
  - ⚠️ Orange: Surveillance
  - 🔴 Rouge: Traitement nécessaire
  - 🔵 Bleu: Traitement planifié
  - ⚫ Gris: Traitement terminé
  - ❌ Noir: Absent/Extrait
- Clic sur dent → popup traitement
- Hover → historique traitements

### 2. 🤖 IA - Recommandations Intelligentes
**Engine de recommandations basé sur:**
- Historique patient (anamnèse, traitements passés)
- État actuel (carte dentaire, radiographies)
- Protocoles cliniques standards
- Données épidémiologiques
- Budget patient / couverture mutuelle

**Suggestions automatiques:**
- Types de traitements recommandés
- Ordre de priorité (urgent → préventif)
- Alternatives thérapeutiques
- Estimation durée totale
- Alertes contre-indications (allergies, médications)

**Exemples de recommandations:**
```
🤖 IA SUGGÈRE:
✅ Dent 16: Carie proximale détectée
   → Traitement recommandé: Obturation composite (code INAMI: 374856)
   → Alternative: Inlay céramique (code: 379132)
   → Urgence: Moyenne (4-6 semaines)
   → Prix estimé: 89€ (remb. 65€)

⚠️ ATTENTION:
Patient allergique à l'amalgame - utiliser uniquement composites
```

### 3. 💰 Calcul Automatique Prix & Remboursements

#### Base INAMI 2026
**Intégration nomenclature complète:**
- Codes INAMI actualisés
- Tarifs convention
- Suppléments d'honoraires
- BIM (bénéficiaire intervention majorée)
- Tiers payant

**Calcul automatique:**
```javascript
Prix Total = Tarif Convention + Supplément Honoraire
Part Mutuelle = (Prix Convention × Taux Remboursement)
Ticket Modérateur = Part Patient
Tiers Payant = Patient ne paie que ticket modérateur
```

**Exemple calcul automatique:**
```
Obturation composite (374856):
├─ Tarif convention: 65,00€
├─ Supplément honoraire: 24,00€
├─ TOTAL: 89,00€
├─ Remboursement mutuelle (75%): 48,75€
└─ Part patient: 40,25€

Avec BIM (intervention majorée):
├─ Remboursement mutuelle (90%): 58,50€
└─ Part patient: 30,50€
```

### 4. 📋 Planification Multi-Phases

**Créer plans en plusieurs étapes:**
```
Phase 1 - URGENCE (Semaine 1-2):
├─ Extraction dent 48 (incluse)
├─ Traitement canal 36
└─ Coût: 450€ | Remb: 320€ | Patient: 130€

Phase 2 - RESTAURATION (Semaine 3-6):
├─ 3x Obturations composites (16, 26, 46)
├─ Détartrage complet
└─ Coût: 267€ | Remb: 189€ | Patient: 78€

Phase 3 - PROTHÈSE (Mois 2-3):
├─ Couronne céramique 11
├─ Bridge 3 éléments (14-15-16)
└─ Coût: 2.450€ | Remb: 890€ | Patient: 1.560€

TOTAL PLAN: 3.167€
Remboursé: 1.399€
À charge patient: 1.768€
```

**Fonctionnalités planning:**
- Drag & drop pour réorganiser phases
- Dates estimées automatiques
- Durée totale du plan
- Validation patient (signature électronique)
- Export devis PDF professionnel

### 5. 📊 Dashboard Traitements

**Vue d'ensemble praticien:**
- Traitements planifiés cette semaine
- Traitements en cours
- Patients avec plans non validés
- Revenus estimés (planifié vs réalisé)
- Taux de complétion des plans

**Filtres intelligents:**
- Par patient
- Par statut (planifié, en cours, terminé)
- Par type de traitement
- Par urgence
- Par montant
- Par date

### 6. 🔄 Workflow Automatisé

**Cycle de vie traitement:**
```
PLANIFIÉ → EN COURS → TERMINÉ → FACTURÉ
    ↓          ↓          ↓         ↓
 Devis     Rappel    Timeline   eAttest
  PDF      Patient    Update    Envoyé
```

**Automatisations:**
1. **Création plan** → Devis PDF généré automatiquement
2. **Validation patient** → Rendez-vous créés dans agenda
3. **Traitement terminé** → Timeline mise à jour
4. **Traitement facturé** → eAttest envoyé automatiquement
5. **Paiement reçu** → Statut "Payé" + reçu généré

### 7. 📄 Documents Automatiques

**Génération PDF instantanée:**
- 📋 Devis détaillé (avant traitement)
- 📝 Plan de traitement (avec schémas dents)
- 🧾 Facture (après traitement)
- 💳 Attestation INAMI (pour mutuelle)
- 📊 Rapport complet (historique patient)

**Design professionnel:**
- En-tête cabinet (logo, coordonnées, INAMI)
- Informations patient
- Tableau détaillé des actes
- Calculs clairs (prix, remb., patient)
- QR code pour paiement mobile
- Signature électronique

### 8. 🏥 Intégration Mutuelles Belges

**Base de données mutuelles:**
- Liste complète mutuelles belges
- Taux de remboursement par mutuelle
- Conditions spécifiques
- Plafonds annuels
- Délais de remboursement

**Calcul personnalisé:**
```javascript
// Exemple: Mutuelle Christelijke Mutualiteit (CM)
Patient: Jean Dupont
Mutuelle: CM Bruxelles
BIM: Non
Plafond restant 2026: 1.450€

Traitement prévu: 890€
├─ Remboursement standard CM: 623€ ✅
├─ Plafond OK (reste: 560€)
└─ Patient paie: 267€
```

### 9. 🔔 Alertes & Notifications Intelligentes

**IA détecte et alerte:**
- ⚠️ Traitement urgent non planifié
- 💊 Médication incompatible avec anesthésie
- 🦷 Risque infection (dent non traitée)
- 💰 Dépassement budget patient
- 📅 Délai traitement trop long
- 🔄 Suivi post-opératoire dû

**Exemple:**
```
🚨 ALERTE IA - Patient: Sophie Martin
Dent 36: Carie profonde détectée il y a 6 semaines
→ Risque abcès si non traitée sous 2 semaines
→ Action: Planifier RDV urgent
→ Rappeler patient: 0485/12.34.56
```

### 10. 📈 Analyse & Statistiques

**Pour le cabinet:**
- Revenus par type de traitement
- Taux de conversion (devis → réalisé)
- Durée moyenne plans de traitement
- Taux satisfaction patients
- Taux remboursement mutuelles
- Traitements les plus fréquents

---

## 🎨 DESIGN INTERFACE

### Layout Principal

```
┌─────────────────────────────────────────────────────────────┐
│  🦷 DentalCockpit Pro - Plan de Traitement                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  [🔍 Rechercher patient...]  [+ Nouveau Plan] [📊 Stats]   │
│                                                              │
│  ┌──────────────┬──────────────────────────────────────┐   │
│  │   PATIENTS   │      PLAN DE TRAITEMENT               │   │
│  │              │                                        │   │
│  │  🟢 Sophie M │   Patient: Sophie Martin, 45 ans      │   │
│  │  🔴 Jean D.  │   Mutuelle: CM | BIM: Non             │   │
│  │  🟡 Marie L. │                                        │   │
│  │  🟢 Pierre K │   🦷 CARTE DENTAIRE                    │   │
│  │              │   [Interactive 32 teeth grid]         │   │
│  │              │                                        │   │
│  │              │   🤖 IA RECOMMANDE:                    │   │
│  │              │   • Dent 16: Obturation (urgent)      │   │
│  │              │   • Dent 26: Détartrage               │   │
│  │              │                                        │   │
│  │              │   📋 PLAN ACTUEL (3 phases)           │   │
│  │              │   Phase 1: Urgences (450€)            │   │
│  │              │   Phase 2: Restauration (267€)        │   │
│  │              │   Phase 3: Prothèse (2.450€)          │   │
│  │              │                                        │   │
│  │              │   💰 TOTAL: 3.167€                     │   │
│  │              │   Remboursé: 1.399€ | Patient: 1.768€ │   │
│  │              │                                        │   │
│  │              │   [Valider Plan] [Exporter PDF]       │   │
│  └──────────────┴──────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Couleurs & Icônes

**Statuts:**
- 🟢 Sain / Aucun traitement
- 🟡 Surveillance / Traitement planifié
- 🔴 Urgent / Traitement nécessaire
- 🔵 En cours de traitement
- ⚫ Traitement terminé
- ❌ Dent absente/extraite

**Actions rapides:**
- ➕ Ajouter traitement
- ✏️ Modifier
- 🗑️ Supprimer
- 📄 Voir détails
- 💾 Sauvegarder
- 📤 Exporter PDF
- ✅ Marquer terminé

---

## 🔧 ARCHITECTURE TECHNIQUE

### Tables Supabase

```sql
-- Utilisation table existante
tooth_treatments (déjà créée)

-- Nouvelle table pour plans multi-phases
treatment_plans:
- id (UUID)
- patient_id (FK)
- title (VARCHAR)
- description (TEXT)
- total_price (DECIMAL)
- total_reimbursement (DECIMAL)
- patient_cost (DECIMAL)
- status ('draft', 'validated', 'in_progress', 'completed')
- phases (JSONB) -- Array des phases
- ai_recommendations (JSONB)
- validated_by_patient (BOOLEAN)
- validation_date (TIMESTAMP)
- created_at, updated_at
```

### IA Recommendations Engine

**Fichier:** `/frontend/js/ai-treatment-engine.js`

```javascript
class AITreatmentEngine {
  // Analyser état dentaire
  async analyzeDentalState(patientId, dentalChart) {
    // 1. Scanner toutes les dents
    // 2. Détecter anomalies
    // 3. Croiser avec historique
    // 4. Calculer urgence
    // 5. Retourner recommandations
  }

  // Suggérer traitements
  async recommendTreatments(toothNumber, condition) {
    // Base de connaissances
    const protocols = {
      'cavity_small': ['composite_filling'],
      'cavity_large': ['composite_filling', 'inlay', 'onlay'],
      'root_canal_needed': ['endodontics', 'crown'],
      'missing_tooth': ['implant', 'bridge', 'denture']
    };
    return protocols[condition];
  }

  // Calculer prix automatique
  async calculatePricing(inamiCode, patientMutuelle, hasBIM) {
    // 1. Récupérer tarif INAMI
    // 2. Appliquer taux mutuelle
    // 3. Calculer BIM si applicable
    // 4. Retourner breakdown détaillé
  }

  // Détecter contre-indications
  async checkContraindications(patientId, treatment) {
    // Vérifier allergies, médications, conditions
  }
}
```

### INAMI Database

**Fichier:** `/frontend/js/inami-codes.js`

```javascript
const INAMI_CODES_2026 = {
  // Consultations
  '301011': { name: 'Consultation cabinet', price: 25.00, reimb: 18.75 },
  '301033': { name: 'Consultation urgence', price: 35.00, reimb: 26.25 },

  // Obturations
  '374856': { name: 'Obturation composite 1 surf', price: 65.00, reimb: 48.75 },
  '374871': { name: 'Obturation composite 2 surf', price: 85.00, reimb: 63.75 },

  // Extractions
  '375211': { name: 'Extraction simple', price: 45.00, reimb: 33.75 },
  '375233': { name: 'Extraction complexe', price: 75.00, reimb: 56.25 },

  // Endodontie
  '377110': { name: 'Traitement canal 1 racine', price: 120.00, reimb: 90.00 },
  '377132': { name: 'Traitement canal 2 racines', price: 180.00, reimb: 135.00 },

  // Prothèses
  '379132': { name: 'Couronne céramique', price: 850.00, reimb: 320.00 },
  '379154': { name: 'Inlay/Onlay céramique', price: 650.00, reimb: 245.00 },

  // Préventif
  '371113': { name: 'Détartrage complet', price: 55.00, reimb: 41.25 },
  '371135': { name: 'Application fluor', price: 20.00, reimb: 15.00 }
};

// Mutuelles et taux remboursement
const MUTUELLES_BELGIUM = {
  'CM': { name: 'Christelijke Mutualiteit', reimb_rate: 0.75, bim_rate: 0.90 },
  'MUTUALITE_CHRETIENNE': { name: 'Mutualité Chrétienne', reimb_rate: 0.75, bim_rate: 0.90 },
  'MUTUALITE_SOCIALISTE': { name: 'Mutualité Socialiste', reimb_rate: 0.75, bim_rate: 0.90 },
  'MUTUALITE_LIBERALE': { name: 'Mutualité Libérale', reimb_rate: 0.75, bim_rate: 0.90 },
  'MUTUALITE_NEUTRE': { name: 'Mutualité Neutre', reimb_rate: 0.75, bim_rate: 0.90 }
};
```

---

## 📱 EXPÉRIENCE UTILISATEUR

### Workflow Création Plan (5 étapes)

**Étape 1: Sélection Patient**
→ Recherche rapide ou depuis dashboard

**Étape 2: Carte Dentaire Interactive**
→ Cliquer dents à traiter
→ IA suggère automatiquement

**Étape 3: Ajout Traitements**
→ Autocomplete codes INAMI
→ Prix calculés automatiquement
→ Validation contre-indications

**Étape 4: Organisation Phases**
→ Drag & drop traitements en phases
→ Ordre automatique par urgence
→ Dates estimées

**Étape 5: Validation & Export**
→ Revue finale
→ Export PDF devis
→ Envoi email patient
→ Signature électronique

**Temps total: 2-3 minutes** ⚡

---

## 🎁 FONCTIONNALITÉS BONUS

### 1. Timeline Visuelle Interactive
Affichage chronologique de tous les traitements du patient

### 2. Comparateur Avant/Après
Photos/radiographies avant/après traitement

### 3. Voice Input
"Ajouter obturation composite dent 16" → traitement créé

### 4. Smart Templates
Plans pré-configurés pour cas fréquents:
- "Réhabilitation complète"
- "Orthodontie adulte"
- "Implantologie guidée"

### 5. Budget Simulator
Patient peut voir impact de différer certains soins

### 6. Mobile App Companion
Patient voit son plan sur smartphone

---

## 🚀 PHASES D'IMPLÉMENTATION

### Phase 1: MVP (Today) ✅
- Interface base avec carte dentaire
- Ajout traitements manuels
- Calcul prix basique
- Liste traitements par patient

### Phase 2: Automation (Week 1)
- Base INAMI codes complète
- Calcul automatique remboursements
- Intégration mutuelles belges
- Export PDF devis

### Phase 3: Intelligence (Week 2)
- IA recommendations
- Détection contre-indications
- Organisation automatique phases
- Alertes intelligentes

### Phase 4: Advanced (Week 3+)
- Timeline interactive
- Voice input
- Templates
- Mobile companion

---

**🎯 OBJECTIF: Module le plus complet et intelligent du marché!**

*Spec créée le 22 juillet 2026*

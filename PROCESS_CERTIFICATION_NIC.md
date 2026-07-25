# 🎓 Processus Certification NIC - Guide Complet

**Auteur:** Ismail Sialyen
**Date:** 2026-07-24
**Objectif:** Obtenir certification NIC pour K2 Dental Cockpit

---

## ✅ RÉPONSE RAPIDE

**OUI, tu peux tester AVANT certification!**

Il existe un **environnement d'acceptance** (test) complètement séparé de la production où tu peux développer et tester gratuitement.

---

## 🗺️ PROCESSUS COMPLET (7 ÉTAPES)

```
┌─────────────────────────────────────────────────────────────┐
│                    TIMELINE: 3-6 mois                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Phase 1: ACCÈS TEST (Semaines 1-2)                        │
│    ↓                                                         │
│  Phase 2: DÉVELOPPEMENT (Semaines 3-8)                     │
│    ↓                                                         │
│  Phase 3: TESTS INTERNES (Semaines 9-10)                   │
│    ↓                                                         │
│  Phase 4: APPROVAL ASSESSMENT (Semaine 11)                 │
│    ↓                                                         │
│  Phase 5: CORRECTIONS (Semaine 12)                         │
│    ↓                                                         │
│  Phase 6: PRODUCTION (Semaine 13+)                         │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 PHASE 1: ACCÈS ENVIRONNEMENT TEST (Semaines 1-2)

### Étape 1.1: Contact NIC Test Team
**Email:** mycarenet@intermut.be
**Objet:** Demande accès test MyCareNet - K2 Dental Cockpit

**Template email:**
```
Bonjour,

Je développe K2 Dental Cockpit, un logiciel de gestion pour cabinets dentaires belges.
Je souhaite obtenir l'accès à l'environnement d'acceptance MyCareNet pour développer et tester les services suivants:

Services visés (Tier 1 - obligatoires):
- eAttest v3 (attestations électroniques)
- Tarification v1 (consultation tarifs INAMI)
- Generic Insurability v1 (vérification assurabilité patients)

Coordonnées:
- Nom: Ismail Sialyen
- Entreprise: K2 Dental Cockpit
- Numéro INAMI médecin: [VOTRE_INAMI]
- Email: [votre_email@domain.be]
- Téléphone: [+32 XXX XX XX XX]

Je demande:
1. Accès SharePoint documentation technique + scénarios de test
2. Certificat test eHealth Platform (environnement acceptance)
3. Credentials test environment

Merci d'avance,
Ismail Sialyen
```

**Réponse attendue:** 3-5 jours ouvrables
**Livrables:** User ID SharePoint + instructions certificat test

---

### Étape 1.2: Obtenir Certificat Test eHealth

**Contact:** info@ehealth.fgov.be
**Objet:** Demande certificat test - Intégration MyCareNet

**Documents requis (PDF à fournir):**

1. **Procuration (Power of Attorney)**
   - Formulaire officiel eHealth
   - Signé par chef projet
   - Spécifie: projet K2 Dental Cockpit, période (6 mois), services MyCareNet

2. **Contrat Software Integrator**
   - Déclaration société active dans secteur healthcare IT
   - Engagement respecter règles eHealth Platform

3. **Template Test Case**
   - Liste services à tester (eAttest, Tarif, Insurability)
   - Use cases prévus
   - Timeline tests (8 semaines)

**Téléchargement formulaires:**
```
https://www.ehealth.fgov.be/ehealthplatform/fr/service-certificats-ehealth
```

**Processing time:** 7-10 jours
**Livrable:** Certificat test .p12 (PKCS12) envoyé par email sécurisé

---

### Étape 1.3: Setup Environnement Local

**Configuration endpoints acceptance:**
```typescript
// config/ehealth-acceptance.ts
export const EHEALTH_ACCEPTANCE = {
  // STS (Security Token Service)
  sts: 'https://services-acpt.ehealth.fgov.be/IAM/SecurityTokenService/v1',

  // MyCareNet APIs
  eattest: 'https://services-acpt.ehealth.fgov.be/MyCareNet/eAttest/v3',
  tarification: 'https://services-acpt.ehealth.fgov.be/MyCareNet/Tarification/v1',
  insurability: 'https://services-acpt.ehealth.fgov.be/GenericInsurability/v1',

  // Portal
  portal: 'https://portal-acpt.api.ehealth.fgov.be/'
};
```

**Test certificat installation:**
```bash
# Supabase Vault (encrypted storage)
supabase secrets set EHEALTH_TEST_CERT_P12="$(cat certificat-test.p12 | base64)"
supabase secrets set EHEALTH_TEST_CERT_PASSWORD="mot_de_passe_fourni"
```

**Validation:**
```bash
# Test connexion STS acceptance
curl -X POST https://services-acpt.ehealth.fgov.be/IAM/SecurityTokenService/v1 \
  --cert certificat-test.p12:password \
  -H "Content-Type: text/xml" \
  -d '<soap:Envelope>...</soap:Envelope>'

# Expected: 200 OK avec SAML token response
```

---

## 🛠️ PHASE 2: DÉVELOPPEMENT (Semaines 3-8)

### Étape 2.1: Accès Documentation SharePoint

**Login:** User ID fourni par NIC
**Password:** Fourni par email sécurisé

**Documents critiques à télécharger:**

| Document | Version | Contenu |
|----------|---------|---------|
| MCN eAttest WS V3 - Cookbook | v1.2 (04/08/2022) | Spécifications techniques eAttest |
| Generic Insurability - Cookbook | v2.0 (15/03/2023) | API Insurability détails |
| MyCareNet Tarification - Guide | v1.5 (10/01/2024) | Tarifs INAMI consultation |
| eHealth SSO - MCN eAttest v3 | v1.1 (10/10/2024) | SAML authentication flow |
| Test Scenarios - eAttest | Latest | Cas de test obligatoires NIC |
| Test Scenarios - Tarification | Latest | Scénarios validation |
| Test Scenarios - Insurability | Latest | Tests assurabilité |

**Schémas XSD (validation XML):**
```
https://www.ehealth.fgov.be/standards/kmehr/schema/
```

---

### Étape 2.2: Implémentation Services

**Développement selon MVP spec:**
- Epic 1: Database (13 tables)
- Epic 2: PDF Generation (Puppeteer)
- Epic 3: Frontend Integration
- Epic 4: INAMI & Billing
- Epic 5: Reminders

**Focus spécifique NIC:**

**Service 1: SAML Token Service**
```typescript
// supabase/functions/get-saml-token-test/index.ts
const STS_ACCEPTANCE = 'https://services-acpt.ehealth.fgov.be/IAM/SecurityTokenService/v1';

async function getSAMLTokenTest() {
  // Load test certificate from Vault
  const cert = await supabase.vault.get('EHEALTH_TEST_CERT_P12');

  // Request SAML token
  const response = await fetch(STS_ACCEPTANCE, {
    method: 'POST',
    // ... SOAP request avec certificat test
  });

  return samlToken;
}
```

**Service 2: eAttest Test**
```typescript
// Test avec données fictives fournies par NIC
const testPatient = {
  niss: '00000000097', // NISS test fourni par NIC
  name: 'Test Patient'
};

const testAttestation = {
  insuree: { NISS: testPatient.niss },
  careProvider: { NIHII: 'INAMI_TEST_FOURNI_NIC' },
  items: [{ code: '305593', amount: 25.50 }]
};
```

**Important:** Utiliser **uniquement données test fournies par NIC** (pas données réelles patients)

---

### Étape 2.3: Logging & Traces

**Obligation NIC:** Conserver **toutes** requêtes/réponses XML pour Approval Assessment

```typescript
// Logger middleware
async function logNICRequest(service: string, request: any, response: any) {
  await supabase.from('nic_test_logs').insert({
    service_name: service,
    request_xml: request,
    response_xml: response,
    timestamp: new Date(),
    success: response.status === 200,
    scenario_id: getCurrentTestScenario()
  });
}
```

**Table logs:**
```sql
CREATE TABLE nic_test_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  service_name VARCHAR(50), -- 'eAttest', 'Tarification', 'Insurability'
  scenario_id VARCHAR(100), -- 'SCENARIO_1_SIMPLE_ATTESTATION'
  request_xml TEXT,
  response_xml TEXT,
  request_timestamp TIMESTAMP,
  response_timestamp TIMESTAMP,
  success BOOLEAN,
  error_code VARCHAR(10),
  notes TEXT
);
```

---

## 🧪 PHASE 3: TESTS INTERNES (Semaines 9-10)

### Étape 3.1: Exécuter Scénarios Test NIC

**Scénarios obligatoires eAttest (exemples):**

**Scénario 1: Attestation simple**
```
Patient: NISS test 00000000097
Prestation: 305593 (Détartrage complet)
Montant: €25.50
Expected: Status 200, NIP reference retourné
```

**Scénario 2: Attestation multiple (batch)**
```
10 patients différents (NISS test fournis)
Prestations variées (codes INAMI list fournie)
Expected: Toutes acceptées, batch ID retourné
```

**Scénario 3: Annulation attestation**
```
1. Envoyer attestation (Scenario 1)
2. Annuler via cancelAttestations() dans <48h
3. Expected: Confirmation annulation
```

**Scénario 4: Rejet - Code INAMI invalide**
```
Patient: NISS test valide
Prestation: 999999 (code inexistant)
Expected: Status 422, error "Invalid INAMI code"
```

**Scénario 5: Rejet - NISS incorrect**
```
Patient: 12345678901 (NISS invalide)
Prestation: 305593 (valide)
Expected: Status 422, error "Invalid NISS"
```

---

### Étape 3.2: Tests Tarification

**Scénario T1: Consultation tarif standard**
```
Code INAMI: 305593
Date: 2026-07-24
Expected: Tarif convention €25.50, tarif libre €35.00
```

**Scénario T2: Tarif avec âge patient**
```
Code INAMI: 377115
Patient âge: 12 ans
Expected: Tarif réduit enfant
```

---

### Étape 3.3: Tests Insurability

**Scénario I1: Patient assuré CM**
```
NISS: 00000000097 (test CM)
Expected: Mutuality code 300, Insured=true
```

**Scénario I2: Patient non-assuré**
```
NISS: XXXXX (fourni par NIC pour test)
Expected: Insured=false, reason code
```

---

### Étape 3.4: Générer Rapport Tests

**Template rapport (Excel/PDF):**

| Scénario ID | Service | Date Test | Résultat | Request XML | Response XML | Notes |
|-------------|---------|-----------|----------|-------------|--------------|-------|
| EATTEST-S1 | eAttest | 2026-07-24 | ✅ PASS | [link] | [link] | OK |
| EATTEST-S2 | eAttest | 2026-07-24 | ✅ PASS | [link] | [link] | OK |
| EATTEST-S4 | eAttest | 2026-07-24 | ✅ PASS | [link] | [link] | Rejection correcte |
| TARIF-T1 | Tarification | 2026-07-24 | ✅ PASS | [link] | [link] | Tarif correct |
| ... | ... | ... | ... | ... | ... | ... |

**Export logs:**
```sql
-- Export all test logs
COPY (
  SELECT * FROM nic_test_logs
  ORDER BY request_timestamp
) TO '/tmp/k2-nic-test-logs.csv' WITH CSV HEADER;
```

---

## ✅ PHASE 4: APPROVAL ASSESSMENT (Semaine 11)

### Étape 4.1: Demander Date Assessment

**Email:** mycarenet@intermut.be
**Objet:** Demande Approval Assessment - K2 Dental Cockpit

**Template:**
```
Bonjour,

Nous avons terminé le développement et les tests internes de K2 Dental Cockpit pour les services MyCareNet suivants:
- eAttest v3
- Tarification v1
- Generic Insurability v1

Tous les scénarios de test obligatoires ont été exécutés avec succès (rapport de tests en pièce jointe).

Nous souhaitons planifier un "Approval Assessment" pour obtenir l'agrément NIC.

Disponibilités proposées:
- [Date 1] à [heure]
- [Date 2] à [heure]
- [Date 3] à [heure]

Pièces jointes:
- Rapport de tests (PDF, 50 pages)
- Logs XML requêtes/réponses (ZIP, exemples)
- Documentation technique K2 (architecture, flow)

Cordialement,
Ismail Sialyen
K2 Dental Cockpit
```

**Réponse attendue:** Confirmation date dans 1-2 semaines

---

### Étape 4.2: Préparation Assessment

**Checklist pré-assessment:**

- [ ] **Rapport tests complet**
  - Tous scénarios obligatoires exécutés
  - Screenshots résultats
  - Logs XML complets

- [ ] **Documentation technique**
  - Architecture K2 (diagramme flux)
  - Stack utilisée (Supabase, Edge Functions, Puppeteer)
  - Authentification SAML/OIDC (si hybride)

- [ ] **Démo préparée**
  - Environnement test accessible
  - Scénarios live reproductibles
  - Backup si connexion fail

- [ ] **Contact technique disponible**
  - Développeur présent (toi)
  - Capable expliquer choix techniques
  - Répondre questions sécurité

---

### Étape 4.3: Déroulement Assessment (Jour J)

**Format:** Réunion Teams/Skype (2-3 heures)

**Agenda typique:**

**09h00-09h15: Présentation projet**
- Vue d'ensemble K2 Dental Cockpit
- Stack technique
- Positionnement marché (vs Dentasoft, etc.)

**09h15-10h00: Revue technique services**
- Explication flow SAML token
- Implémentation eAttest (code review)
- Gestion erreurs & retry logic
- Sécurité (encryption, RLS policies)

**10h00-11h00: Démonstration live**
- Scénario 1: Attestation simple (live call API)
- Scénario 2: Consultation tarif
- Scénario 3: Vérification assurabilité
- Scénario 4: Gestion rejet (code invalide)

**11h00-11h30: Questions équipe NIC**
- Questions techniques pointues
- Vérification conformité KMEHR schema
- Validation logs XML
- Sécurité PHI (données patients)

**11h30-12h00: Feedback & décision**
- Points positifs
- Points à corriger (si mineurs)
- Décision: Approved / Corrections required / Rejected

---

## 🔧 PHASE 5: CORRECTIONS (Semaine 12)

### Si "Corrections Required"

**Feedback typique:**
```
Points à corriger:
1. Validation XSD manquante avant envoi eAttest
2. Timeout retry logic insuffisant (max 3 retries requis)
3. Logging insuffisant pour audit (manque timestamp microseconde)
4. Error message trop générique (doit inclure NIP reference)
```

**Process:**
1. Corriger chaque point (code + tests)
2. Re-tester scénarios concernés
3. Envoyer rapport corrections à mycarenet@intermut.be
4. Re-assessment (partiel, 1h) ou validation email

**Timeline:** 1-2 semaines max

---

## 🎉 PHASE 6: PRODUCTION (Semaine 13+)

### Étape 6.1: Réception Approval

**Email NIC:**
```
Subject: Approval granted - K2 Dental Cockpit

Bonjour,

Nous avons le plaisir de vous informer que K2 Dental Cockpit a passé l'Approval Assessment avec succès.

Votre logiciel est approuvé pour les services suivants:
- eAttest v3 ✅
- Tarification v1 ✅
- Generic Insurability v1 ✅

Vous pouvez maintenant passer en production.

Prochaines étapes:
1. Demander certificat production eHealth
2. Basculer endpoints acceptance → production
3. Informer NIC de votre go-live (date)

Votre logiciel sera ajouté à la liste officielle:
https://fra.mycarenet.be/services-par-secteur/dentistes/logiciels-agréés-dentistes

Félicitations!
NIC Test Team
```

---

### Étape 6.2: Certificat Production eHealth

**Contact:** info@ehealth.fgov.be
**Objet:** Demande certificat production - K2 Dental Cockpit (NIC approved)

**Documents requis:**
- Copie email approval NIC
- Numéro INAMI médecin utilisateur final
- Procuration signée médecin chef de projet

**Processing time:** 5-7 jours
**Livrable:** Certificat production .p12 (validité 3 ans)

---

### Étape 6.3: Migration Production

**Checklist go-live:**

```typescript
// config/ehealth-production.ts
export const EHEALTH_PRODUCTION = {
  // STS Production (remplace acceptance)
  sts: 'https://services.ehealth.fgov.be/IAM/SecurityTokenService/v1',

  // MyCareNet Production
  eattest: 'https://services.ehealth.fgov.be/MyCareNet/eAttest/v3',
  tarification: 'https://services.ehealth.fgov.be/MyCareNet/Tarification/v1',
  insurability: 'https://services.ehealth.fgov.be/GenericInsurability/v1',
};
```

**Steps:**
1. Install certificat production dans Supabase Vault
2. Update config endpoints (acceptance → production)
3. Deploy Edge Functions avec nouvelles configs
4. Test smoke (1 attestation réelle patient consentant)
5. Monitor logs 24h
6. Rollout progressif cabinet

---

### Étape 6.4: Publication Liste Officielle NIC

**Délai:** 2-4 semaines après approval

**Votre logiciel apparaît:**
```
https://fra.mycarenet.be/services-par-secteur/dentistes/logiciels-agréés-dentistes

Logiciels agréés - Dentistes (mise à jour: 2026-08-15)

- AMS Solutions - Octopus
- Centres médicaux César De Paepe - OmniSphere
- Corilus - CareConnect Dentist
- DentaSoft - Dentasoft
- K2 Dental Cockpit ← NOUVEAU ✅
- ...
```

**Avantages:**
- ✅ Éligibilité prime télématique médecins
- ✅ Crédibilité marché (certification officielle)
- ✅ Obligation légale Sept 2025 (eAttest mandatory)

---

## 💰 COÛTS CERTIFICATION

| Item | Coût | Fréquence | Notes |
|------|------|-----------|-------|
| **Certificat test eHealth** | €0 | One-time | Gratuit intégrateurs |
| **Certificat production eHealth** | €50 | 3 ans | Renewal tous les 3 ans |
| **Approval Assessment NIC** | €0 | One-time | Pas de frais NIC |
| **Re-assessment (si corrections)** | €0 | Si requis | Inclus |
| **Lecteur carte eID** | €50 | One-time | ACR122U |
| **Temps développeur** | Variable | - | ~195h (Tier 1) |

**Total coût certification:** **€100** (certificat + lecteur eID)

---

## ⏱️ TIMELINE RÉALISTE

### Scénario Optimiste (3 mois)
```
Semaine 1-2:   Accès test + certificat test
Semaine 3-8:   Développement (6 semaines)
Semaine 9-10:  Tests internes
Semaine 11:    Approval Assessment (1er essai ✅)
Semaine 12:    Certificat production
Semaine 13:    Go-live production
```

---

### Scénario Réaliste (4-5 mois)
```
Semaine 1-2:   Accès test (délais admin)
Semaine 3-10:  Développement (8 semaines, bugs)
Semaine 11-12: Tests internes + fixes
Semaine 13:    Approval Assessment
Semaine 14-15: Corrections mineures
Semaine 16:    Re-assessment partiel ✅
Semaine 17:    Certificat production
Semaine 18:    Go-live production
```

---

### Scénario Pessimiste (6 mois)
```
Semaine 1-3:   Accès test (délais, relances)
Semaine 4-12:  Développement (9 semaines, refactoring)
Semaine 13-14: Tests internes (bugs découverts)
Semaine 15:    Approval Assessment
Semaine 16-18: Corrections majeures (architecture change)
Semaine 19:    Re-assessment complet
Semaine 20-21: Fixes finaux
Semaine 22:    Approval ✅
Semaine 23:    Certificat production
Semaine 24:    Go-live production
```

**Recommandation:** Planifier **4-5 mois** (réaliste)

---

## 🚨 PIÈGES À ÉVITER

### ❌ Erreur #1: Tester avec Vraies Données Patients
**Problème:** RGPD violation, NIC rejette assessment
**Solution:** Utiliser UNIQUEMENT NISS test fournis par NIC

---

### ❌ Erreur #2: Logs Incomplets
**Problème:** NIC demande requête XML spécifique, tu ne l'as pas
**Solution:** Logger 100% requêtes/réponses (table nic_test_logs)

---

### ❌ Erreur #3: Validation XSD Manquante
**Problème:** Envoi XML malformé, NIC détecte en assessment
**Solution:** Valider contre XSD KMEHR AVANT chaque envoi

```typescript
import { XMLValidator } from 'fast-xml-parser';

const schema = await fetchXSD('https://www.ehealth.fgov.be/standards/kmehr/schema/v1/kmehr.xsd');
const isValid = XMLValidator.validate(xmlRequest, { schema });
if (!isValid) throw new Error('Invalid XML against KMEHR schema');
```

---

### ❌ Erreur #4: Pas de Retry Logic
**Problème:** Timeout réseau, attestation perdue
**Solution:** Retry 3x avec backoff exponentiel

```typescript
async function sendAttestationWithRetry(data: any, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await sendAttestation(data);
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await sleep(Math.pow(2, i) * 1000); // 1s, 2s, 4s
    }
  }
}
```

---

### ❌ Erreur #5: Endpoints Hardcodés
**Problème:** Oubli switch acceptance → production
**Solution:** Config env-based

```typescript
const EHEALTH_BASE = process.env.NODE_ENV === 'production'
  ? 'https://services.ehealth.fgov.be'
  : 'https://services-acpt.ehealth.fgov.be';
```

---

## 📞 CONTACTS CLÉS

### NIC Test Team
- **Email:** mycarenet@intermut.be
- **Sujet:** Certification, Approval Assessment, scénarios test
- **Réponse:** 3-5 jours ouvrables

### eHealth Platform
- **Email:** info@ehealth.fgov.be
- **Sujet:** Certificats test/production, problèmes techniques STS
- **Réponse:** 5-7 jours ouvrables

### Support Opérationnel MyCareNet
- **Email:** support@intermut.be
- **Sujet:** Issues production (après approval), bugs API
- **Réponse:** 24-48h

### Helpdesk eHealth
- **Tel:** +32 2 788 51 55
- **Horaires:** Lun-Ven 9h-17h
- **Sujet:** Urgences certificats, connexion STS

---

## 📚 RESSOURCES OFFICIELLES

### Portail NIC
```
https://fra.mycarenet.be/
```
- Documentation services
- Liste logiciels agréés
- Procédures certification

### eHealth Platform
```
https://www.ehealth.fgov.be/ehealthplatform/fr/
```
- Guides techniques
- Formulaires certificats
- Standards KMEHR

### API Portal (Acceptance)
```
https://portal-acpt.api.ehealth.fgov.be/
```
- WSDLs téléchargeables
- Cookbooks services
- Environnement test

### SharePoint NIC
```
[URL fourni après contact mycarenet@intermut.be]
```
- Scénarios test officiels
- Templates rapports
- Exemples requêtes/réponses

---

## ✅ CHECKLIST COMPLÈTE CERTIFICATION

### Phase 1: Accès Test
- [ ] Email mycarenet@intermut.be envoyé
- [ ] User ID SharePoint reçu
- [ ] Formulaires certificat test téléchargés
- [ ] Power of attorney signé
- [ ] Email info@ehealth.fgov.be envoyé
- [ ] Certificat test .p12 reçu
- [ ] Certificat installé Supabase Vault
- [ ] Test connexion STS acceptance OK

### Phase 2: Développement
- [ ] Documentation SharePoint téléchargée
- [ ] Cookbooks eAttest/Tarif/Insurability lus
- [ ] Schémas XSD KMEHR téléchargés
- [ ] SAML token service implémenté
- [ ] eAttest service implémenté
- [ ] Tarification service implémenté
- [ ] Insurability service implémenté
- [ ] Table nic_test_logs créée
- [ ] Logging 100% requêtes/réponses actif
- [ ] Validation XSD intégrée

### Phase 3: Tests
- [ ] NISS test NIC obtenus
- [ ] Scénario 1 eAttest: Simple ✅
- [ ] Scénario 2 eAttest: Batch ✅
- [ ] Scénario 3 eAttest: Annulation ✅
- [ ] Scénario 4 eAttest: Rejet code invalide ✅
- [ ] Scénario 5 eAttest: Rejet NISS invalide ✅
- [ ] Scénario T1 Tarif: Standard ✅
- [ ] Scénario T2 Tarif: Âge patient ✅
- [ ] Scénario I1 Insurability: Assuré ✅
- [ ] Scénario I2 Insurability: Non-assuré ✅
- [ ] Rapport tests Excel généré
- [ ] Logs XML exportés ZIP

### Phase 4: Assessment
- [ ] Email demande date assessment envoyé
- [ ] Date confirmée par NIC
- [ ] Démo préparée (scénarios reproductibles)
- [ ] Documentation technique finalisée
- [ ] Backup démo (si connexion fail)
- [ ] Assessment réussi ✅ ou corrections identifiées

### Phase 5: Corrections (si requis)
- [ ] Points à corriger listés
- [ ] Code corrigé
- [ ] Tests re-exécutés
- [ ] Rapport corrections envoyé
- [ ] Re-assessment validé ✅

### Phase 6: Production
- [ ] Email approval NIC reçu
- [ ] Certificat production demandé
- [ ] Certificat production .p12 reçu
- [ ] Config endpoints production updated
- [ ] Deploy production effectué
- [ ] Test smoke 1 attestation réelle OK
- [ ] Monitoring 24h sans erreur
- [ ] Ajout liste officielle NIC confirmé
- [ ] GO-LIVE PRODUCTION 🎉

---

## 🎯 PROCHAINES ACTIONS IMMÉDIATES

**Aujourd'hui (Jour 1):**
1. ✉️ Envoyer email mycarenet@intermut.be (demande accès test)
2. ✉️ Envoyer email info@ehealth.fgov.be (demande certificat test)
3. 📥 Télécharger formulaires eHealth (power of attorney, etc.)

**Cette semaine (Jours 2-5):**
4. 📝 Remplir formulaires certificat test
5. 📧 Attendre réponses NIC + eHealth
6. 🛒 Commander lecteur eID (ACR122U, €50)

**Semaine prochaine:**
7. 📚 Télécharger cookbooks SharePoint
8. 🔐 Installer certificat test
9. 🧪 Test connexion STS acceptance

**Timeline:** Démarrer développement Semaine 3 (si accès OK)

---

**Auteur:** Ismail Sialyen
**Date:** 2026-07-24
**Version:** 1.0
**Status:** Ready to start certification process ✅

**Besoin d'aide?** Contact mycarenet@intermut.be ou info@ehealth.fgov.be

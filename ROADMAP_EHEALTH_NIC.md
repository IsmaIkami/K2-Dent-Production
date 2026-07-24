# 🏥 ROADMAP eHEALTH & CERTIFICATION NIC
**Objectif:** Rendre K2 fonctionnel pour le cabinet → Obtenir certification NIC → Vendre B2B
**Approche:** Pragmatique, incrémentale, focus cabinet d'abord
**Date:** 2026-07-24
**Auteur:** Ismail Sialyen

---

## 🎯 STRATÉGIE EN 3 PHASES

### Phase 1: CABINET FONCTIONNEL (Priorité Immédiate)
**Objectif:** K2 utilisable quotidiennement dans votre cabinet
**Durée:** MVP actuel (en cours)
**Modules:** Core features sans eHealth (offline viable)

### Phase 2: MODULES eHEALTH MINIMUM (Nécessaire Cabinet)
**Objectif:** Intégration MyCareNet pour facturation efficace
**Durée:** 2-3 mois
**Modules:** e-Attest + e-Tarif + e-Assur (minimum viable)

### Phase 3: CERTIFICATION NIC (Obligatoire B2B)
**Objectif:** Agrément officiel pour vendre aux autres cabinets
**Durée:** 3-6 mois (process administratif + tests)
**Modules:** Tous modules eHealth complets

---

## 📊 MODULES eHEALTH - ANALYSE DÉTAILLÉE

### Plateforme MyCareNet

**Infrastructure:**
- Plateforme eHealth belge officielle
- Échange sécurisé dentistes ↔ mutualités
- Certificats eHealth obligatoires (eID ou certificat organisationnel)
- Tests disponibles sur environnement pilote

**Contact Certification:**
- Email: mycarenet@intermut.be
- Process: Tests → Approval Assessment → Production

---

## 🔧 MODULES PAR PRIORITÉ

### 🟢 TIER 1: MINIMUM VIABLE CABINET (Phase 2)

#### 1. e-Attest (OBLIGATOIRE depuis Sept 2025)
**Fonction:** Envoi attestations électroniques aux mutualités

**Cas d'usage:**
- Patient paie cash → e-Attest pour remboursement
- Remplace attestations papier (obsolètes)

**Effort technique:**
- API SOAP eHealth Platform
- XML formatting (schema eAttest)
- Certificat eHealth
- Logs envoi/réception

**Code sample:**
```typescript
// Edge Function send-eattest
import { SoapClient } from 'soap-client-deno';

interface EAttestData {
  patient_id: string;
  inami_codes: string[];
  amounts: number[];
  treatment_date: string;
}

async function sendEAttest(data: EAttestData) {
  const client = await SoapClient.create({
    wsdl: 'https://services.ehealth.fgov.be/EAttestWebService/v1',
    cert: EHEALTH_CERT,
    key: EHEALTH_KEY
  });

  const xml = generateEAttestXML(data);
  const response = await client.sendEAttest(xml);

  // Store response
  await supabase.from('eattest_logs').insert({
    patient_id: data.patient_id,
    status: response.status,
    reference: response.reference,
    sent_at: new Date()
  });

  return response;
}
```

**Effort:** 60h dev + 20h tests = **80h total**

---

#### 2. e-Tarif
**Fonction:** Consultation tarifs INAMI en temps réel

**Cas d'usage:**
- Vérifier tarif code INAMI avant facturation
- Éviter rejets (codes obsolètes, âge patient)

**Effort technique:**
- API REST eHealth
- Cache local tarifs (refresh quotidien)
- Mapping codes INAMI → montants

**Code sample:**
```typescript
// Fonction: getTarif
async function getTarif(inamiCode: string, patientAge: number, mutuality: string) {
  const response = await fetch('https://services.ehealth.fgov.be/Tarif/v1', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${EHEALTH_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      code: inamiCode,
      patient_age: patientAge,
      mutuality_code: mutuality
    })
  });

  const tarif = await response.json();
  return {
    convention: tarif.tariff_convention,
    honor: tarif.tariff_honor,
    patient_share: tarif.patient_share,
    insurance_share: tarif.insurance_share
  };
}
```

**Effort:** 40h dev + 10h tests = **50h total**

---

#### 3. e-Assur (Vérification Mutuelle)
**Fonction:** Vérifier insurabilité patient temps réel

**Cas d'usage:**
- Scanner carte eID/ISI+ patient
- Vérifier: mutualité active, droits remboursement, tiers payant

**Effort technique:**
- Lecteur carte eID (hardware + driver)
- API eHealth Assurability
- UI feedback temps réel

**Code sample:**
```typescript
// Fonction: checkInsurability
async function checkInsurability(patientNISS: string, date: Date) {
  const response = await fetch('https://services.ehealth.fgov.be/Assurability/v1', {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${EHEALTH_TOKEN}` },
    body: JSON.stringify({
      niss: patientNISS,
      reference_date: date.toISOString()
    })
  });

  const assur = await response.json();
  return {
    insured: assur.insured,
    mutuality: assur.mutuality_code,
    third_party_payer: assur.third_party_payer_eligible,
    coverage: assur.coverage_details
  };
}
```

**Hardware:**
- Lecteur carte eID: ~€50 (ex: ACR122U)
- Driver: Middleware eID gratuit (eid.belgium.be)

**Effort:** 50h dev + 15h tests = **65h total**

---

### 🟡 TIER 2: CONFORT CABINET (Phase 2+)

#### 4. Recip-e (Prescriptions Électroniques)
**Fonction:** Envoyer prescriptions directement aux pharmacies

**Cas d'usage:**
- Patient reçoit SMS avec code Recip-e
- Va à pharmacie → scan code → médicaments

**Effort technique:**
- API Recip-e (SOAP)
- Génération RID (Recip-e ID)
- Validation médicaments (base DPP)

**Effort:** 70h dev + 20h tests = **90h total**

---

#### 5. e-Fact (Tiers Payant)
**Fonction:** Facturation automatique mutualités (patient ne paie rien)

**Cas d'usage:**
- Traitements éligibles tiers payant (ex: paro)
- Envoi facture directement mutualité
- Patient ne paie que ticket modérateur

**Effort technique:**
- API e-Fact (SOAP)
- XML factures batch (920/921 messages)
- Gestion rejets/acceptations

**Effort:** 100h dev + 30h tests = **130h total**

---

#### 6. e-DMG (Dossier Médical Global)
**Fonction:** Consulter DMG patient (médecin traitant, historique)

**Cas d'usage:**
- Vérifier si patient a DMG
- Accès historique médical (allergies, etc.)

**Effort:** 40h dev + 10h tests = **50h total**

---

### 🔵 TIER 3: FEATURES AVANCÉES (Phase 3 - NIC Certification)

#### 7. eHBox (Messagerie Sécurisée)
**Fonction:** Emails cryptés entre professionnels santé

**Effort:** 60h dev + 15h tests = **75h total**

---

#### 8. eAddressBook (Annuaire Confrères)
**Fonction:** Recherche coordonnées autres dentistes/médecins

**Effort:** 30h dev + 10h tests = **40h total**

---

#### 9. RSW (Résumé Soins Partagé)
**Fonction:** Consulter synthèse patient (médicaments, rapports, radios)

**Effort:** 50h dev + 15h tests = **65h total**

---

## 📋 PROCESS CERTIFICATION NIC

### Étapes Officielles

**1. Inscription Vendor (Semaine 1)**
- Contact: mycarenet@intermut.be
- Demande User ID + Password MyCareNet SharePoint
- Accès documentation technique

**2. Environnement Test (Semaine 2-3)**
- Obtenir certificat test eHealth Platform
- Setup environnement pilote
- Configuration endpoints test

**3. Développement Modules (Mois 1-3)**
- Implémenter modules selon priorités
- Tests unitaires + intégration
- Documentation technique

**4. Tests NIC (Mois 4)**
- Scénarios de test NIC obligatoires
- Logs + traces à fournir
- Corrections bugs détectés

**5. Approval Assessment (Mois 5)**
- Revue par équipe test NIC
- Validation conformité
- Corrections finales

**6. Certification Production (Mois 6)**
- Certificat production eHealth
- Ajout liste logiciels agréés NIC
- Rollout progressif recommandé

---

## 💰 ESTIMATION COÛTS & EFFORTS

### Phase 2: Minimum Viable eHealth (Tier 1)

| Module | Effort Dev | Tests | Total | Coût (€80/h) |
|--------|-----------|-------|-------|--------------|
| e-Attest | 60h | 20h | 80h | €6,400 |
| e-Tarif | 40h | 10h | 50h | €4,000 |
| e-Assur | 50h | 15h | 65h | €5,200 |
| **TOTAL** | **150h** | **45h** | **195h** | **€15,600** |

**Hardware:**
- Lecteur carte eID: €50

**Services:**
- Certificat eHealth test: Gratuit
- Certificat eHealth prod: €50/an

**Total Phase 2:** **€15,700**

---

### Phase 3: Certification NIC Complète

| Catégorie | Effort | Coût |
|-----------|--------|------|
| Modules Tier 2 (Recip-e, e-Fact, e-DMG) | 270h | €21,600 |
| Modules Tier 3 (eHBox, eAddressBook, RSW) | 180h | €14,400 |
| Tests NIC + corrections | 100h | €8,000 |
| Documentation technique | 40h | €3,200 |
| Process administratif | 20h | €1,600 |
| **TOTAL** | **610h** | **€48,800** |

**Total Phase 2 + 3:** **€64,500**

---

## 🗺 ROADMAP PRAGMATIQUE RÉVISÉE

### Q3 2026: MVP Core (Actuel) ✅
**Status:** En cours
**Livrable:** K2 utilisable cabinet (offline/basic)

**Features:**
- ✅ Gestion patients
- ✅ Agenda
- ✅ Prescriptions PDF (non-Recip-e)
- ✅ Carte dentaire
- ✅ Timeline
- ⚠️ Export CSV eAttest MANUEL

**Gap:** Pas d'intégration eHealth = facturation inefficace

---

### Q4 2026: eHealth Tier 1 (Phase 2) 🔴 PRIORITÉ
**Durée:** 2-3 mois (Oct-Déc 2026)
**Budget:** €15,700 (équivalent à pure SAML, mais ROI supérieur)
**Objectif:** Cabinet opérationnel avec facturation électronique + auth moderne

**Architecture:** Hybride OIDC + SAML (voir TECHNICAL_NIC_MODERN_APIS.md)

**Livrables:**

**0. Setup Auth Moderne (Semaine 1-2)** - ⭐ NOUVEAU
   - ✅ I.AM Connect (OIDC) - Auth frontend moderne
   - ✅ I.AM eXchange - Conversion tokens OIDC → SAML
   - ✅ Edge Function conversion automatique
   - **Avantage:** UX moderne + mobile-ready + future-proof

1. **e-Attest automatique** (remplace CSV manuel)
   - Gain temps: 10 min/jour → 2 min
   - Réduction erreurs facturation
   - **Note:** Utilise SAML tokens convertis depuis OIDC

2. **e-Tarif intégré**
   - Vérification temps réel codes INAMI
   - Calcul automatique montants

3. **e-Assur (lecteur eID)**
   - Vérification mutuelle instantanée
   - Détection tiers payant éligibles

**Validation:**
- [ ] 100% attestations envoyées via e-Attest (0 papier)
- [ ] Temps facturation patient: <3 min (vs 10-15 min actuel)
- [ ] Taux rejet eAttest: <2%
- [ ] ✅ Login OIDC fonctionnel (vs SAML legacy)
- [ ] ✅ Token conversion OIDC→SAML automatique

---

### Q1 2027: Stabilisation + Tier 2 (Optionnel)
**Durée:** 2 mois (Jan-Fév 2027)
**Budget:** €21,600 (si besoin cabinet)
**Objectif:** Features confort cabinet

**Livrables (optionnels):**
- [ ] Recip-e (si volume prescriptions élevé)
- [ ] e-Fact (si beaucoup tiers payant)
- [ ] e-DMG (si besoin historique patients)

**Décision:** Évaluer usage cabinet Q4 2026 avant investir

---

### Q2-Q3 2027: Certification NIC (Phase 3)
**Durée:** 4-6 mois (Mar-Août 2027)
**Budget:** €48,800
**Objectif:** Agrément officiel NIC pour vente B2B

**Livrables:**
1. **Modules Tier 3 complets**
   - eHBox, eAddressBook, RSW

2. **Tests NIC**
   - Scénarios obligatoires
   - Corrections bugs

3. **Certification obtenue**
   - Ajout liste logiciels agréés
   - Marketing "Logiciel agréé NIC"

**Validation:**
- [ ] Email confirmation NIC: "Logiciel K2 agréé"
- [ ] Présence liste officielle mycarenet.be
- [ ] Rollout pilote 5 cabinets externes

---

### Q4 2027+: Go-to-Market B2B
**Post-certification**
**Objectif:** Vente autres cabinets dentaires

**Actions:**
- Marketing "Logiciel agréé NIC"
- Pricing freemium (€0 → €49 → €99)
- Switch program Dentasoft
- Partenariats écoles dentaires

---

## 🎯 FOCUS IMMÉDIAT: DÉCISIONS REQUISES

### Décision #1: Timing Phase 2 (eHealth Tier 1)

**Question:** Quand démarrer intégration e-Attest/e-Tarif/e-Assur ?

**Option A: IMMÉDIATEMENT (Oct 2026)**
- ✅ Cabinet opérationnel plus vite
- ✅ Test réel avant certification NIC
- ❌ Ralentit MVP features IA

**Option B: POST-MVP (Jan 2027)**
- ✅ Finaliser MVP d'abord (radios IA, etc.)
- ❌ Cabinet reste inefficace facturation
- ❌ Retarde certification NIC (Q4 2027)

**Recommandation:** **Option A** (immédiat)
**Rationale:** e-Attest OBLIGATOIRE depuis Sept 2025, export CSV manuel = perte temps quotidienne

---

### Décision #2: Qui Développe eHealth ?

**Option A: Vous (interne)**
- ✅ Contrôle total
- ✅ Coût dev = €0 (votre temps)
- ❌ Courbe apprentissage eHealth (APIs SOAP complexes)
- ❌ Timeline longue (6-9 mois)

**Option B: Outsource spécialiste eHealth**
- ✅ Expertise (déjà fait intégrations MyCareNet)
- ✅ Rapide (3 mois Tier 1, 6 mois total)
- ❌ Coût €15-65K

**Option C: Hybride**
- ✅ Outsource Tier 1 (e-Attest/e-Tarif/e-Assur) = €15K
- ✅ Vous faites Tier 2-3 (learning)
- ✅ Certification NIC possible Q2 2027

**Recommandation:** **Option C** (hybride)
**Rationale:** Quick win Tier 1 cabinet, vous apprenez sur Tier 2-3

---

### Décision #3: Certification NIC Vraiment Nécessaire ?

**Question:** Peut-on vendre B2B SANS certification NIC ?

**Réponse:** **NON** (légalement impossible)

**Règlementation:**
- Dentistes belges OBLIGÉS utiliser logiciel agréé NIC pour e-Attest
- e-Attest obligatoire depuis Sept 2025 (paiements cash)
- Logiciel non-agréé = dentiste en infraction

**Exceptions:**
- Cabinet privé (votre usage uniquement) = OK sans NIC
- Vente B2C patients (patient portal) = OK sans NIC
- Vente B2B dentistes = IMPOSSIBLE sans NIC

**Conclusion:** Certification NIC = **BLOQUANT absolu** vente B2B professionnels santé

---

### Décision #4: Features IA en Parallèle eHealth ?

**Question:** Continuer dev IA (radios, prescriptions GPT-4) pendant eHealth ?

**Option A: STOP IA, 100% focus eHealth**
- ✅ Certification NIC plus rapide
- ❌ Perd différenciation vs Dentasoft

**Option B: IA + eHealth parallèle**
- ✅ Garde momentum IA
- ❌ Ressources divisées, timeline rallongée

**Option C: eHealth Tier 1 → IA → eHealth Tier 2-3**
- ✅ Cabinet fonctionnel d'abord (e-Attest)
- ✅ Puis différenciation IA
- ✅ Puis certification NIC finale

**Recommandation:** **Option C** (séquentiel intelligent)

**Timeline révisée:**
1. **Q4 2026:** eHealth Tier 1 (e-Attest/e-Tarif/e-Assur) - 3 mois
2. **Q1 2027:** Features IA (radios, prescriptions, agenda) - 3 mois
3. **Q2-Q3 2027:** eHealth Tier 2-3 + Certification NIC - 4 mois

---

## 📦 LIVRABLES TECHNIQUES

### Setup Environnement Test MyCareNet

**1. Inscription NIC**
```bash
# Email à envoyer
To: mycarenet@intermut.be
Subject: Demande accès test MyCareNet - K2 Dental Cockpit

Bonjour,

Nous développons K2 Dental Cockpit, logiciel gestion cabinet dentaire.
Nous souhaitons intégrer MyCareNet et obtenir:
- User ID + password SharePoint documentation
- Certificat test eHealth Platform
- License test environnement pilote

Coordonnées:
- Société: K2 Dental Solutions
- Contact: Ismail Sialyen
- Email: [votre email]
- Téléphone: [votre tel]

Modules visés: e-Attest, e-Tarif, e-Assur (Tier 1)

Cordialement,
Ismail Sialyen
```

**2. Installation Middleware eID**
```bash
# macOS
brew install eid-mw

# Vérifier
eid-viewer
```

**3. Certificat Test eHealth**
- Demande via eHealth Platform acceptance portal
- Format: .p12 (PKCS12)
- Validité: 1 an (renouvelable)

**4. Endpoints Test**
```typescript
const EHEALTH_TEST = {
  eattest: 'https://acceptance.ehealth.fgov.be/EAttestWebService/v1',
  tarif: 'https://acceptance.ehealth.fgov.be/Tarif/v1',
  assur: 'https://acceptance.ehealth.fgov.be/Assurability/v1'
};
```

---

### Architecture Technique

**Stack:**
```
Frontend (Vanilla JS)
    ↓
Supabase Edge Functions (Deno)
    ↓ HTTPS/SOAP
eHealth Platform MyCareNet
    ↓
Mutualités (CM, Solidaris, etc.)
```

**Sécurité:**
- Certificats eHealth stockés Supabase Vault (encrypted)
- Logs audit tous appels eHealth (RGPD compliance)
- RLS policies strictes (staff only access)

**Exemple Edge Function:**
```typescript
// supabase/functions/mycarenet-eattest/index.ts
import { serve } from 'https://deno.land/std/http/server.ts';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
);

serve(async (req) => {
  const { patient_id, treatments } = await req.json();

  // 1. Fetch patient data
  const { data: patient } = await supabase
    .from('patients')
    .select('*')
    .eq('id', patient_id)
    .single();

  // 2. Generate eAttest XML
  const xml = generateEAttestXML(patient, treatments);

  // 3. Send to eHealth
  const cert = await getEHealthCert(); // From Vault
  const response = await sendToEHealth(xml, cert);

  // 4. Log
  await supabase.from('eattest_logs').insert({
    patient_id,
    xml_sent: xml,
    response: response,
    status: response.success ? 'sent' : 'failed',
    sent_at: new Date()
  });

  return new Response(JSON.stringify(response), {
    headers: { 'Content-Type': 'application/json' }
  });
});
```

---

## ✅ CHECKLIST AVANT DÉMARRAGE

### Prérequis Techniques
- [ ] Supabase project configuré
- [ ] Edge Functions déployables
- [ ] Certificats SSL valides
- [ ] Lecteur carte eID commandé (€50)

### Prérequis Administratifs
- [ ] Numéro INAMI médecin valide
- [ ] Inscription Ordre des Médecins à jour
- [ ] Email professionnel (@cabinet.be ou similaire)

### Prérequis Légaux
- [ ] RGPD: Privacy policy à jour
- [ ] RGPD: DPO désigné (ou vous)
- [ ] Assurance cyber-risques (recommandé)

### Décisions Business
- [ ] Budget Phase 2 validé (€15,700)
- [ ] Timeline Q4 2026 confirmée
- [ ] Ressources dev allouées (outsource ou interne)

---

## 🚀 NEXT STEPS (Cette Semaine)

### Étape 1: Décisions Stratégiques (Jour 1)
- [ ] Valider Option A: Démarrer eHealth immédiatement
- [ ] Valider Option C: Outsource Tier 1, interne Tier 2-3
- [ ] Valider budget €15,700 Phase 2

### Étape 2: Recherche Prestataires (Jour 2-3)
- [ ] Chercher devs spécialisés eHealth Belgique (LinkedIn, Upwork)
- [ ] Demander devis 3 prestataires
- [ ] Vérifier références (ont déjà fait intégrations MyCareNet)

### Étape 3: Contact NIC + I.AM Connect (Jour 4) ⭐ MODIFIÉ
- [ ] Email mycarenet@intermut.be (template ci-dessous)
- [ ] **NOUVEAU:** Demander I.AM Connect client registration
- [ ] Demander User ID SharePoint + certificat test
- [ ] Attendre réponse (2-5 jours)
- [ ] Setup accès SharePoint documentation

**Template Email Révisé:**
```
To: mycarenet@intermut.be
Subject: Demande I.AM Connect + accès test MyCareNet - K2 Dental Cockpit

Bonjour,

Nous développons K2 Dental Cockpit, logiciel gestion cabinet dentaire.

Nous souhaitons intégrer:
1. I.AM Connect (OIDC/OAuth2) - Authentification moderne
2. I.AM eXchange - Conversion tokens OIDC → SAML
3. MyCareNet APIs (e-Attest, e-Tarif, e-Assur)

Demande d'accès:
- Client ID + secret I.AM Connect (environnement acceptance)
- User ID + password SharePoint documentation
- Certificat test eHealth Platform
- License test environnement pilote

Coordonnées:
- Société: K2 Dental Solutions
- Contact: Ismail Sialyen
- Email: [votre email]
- Téléphone: [votre tel]

Architecture: Hybride OIDC frontend + SAML backend (cf. I.AM eXchange)
Modules visés: e-Attest, e-Tarif, e-Assur (Tier 1)

Cordialement,
Ismail Sialyen
```

### Étape 4: Hardware (Jour 5)
- [ ] Commander lecteur carte eID ACR122U (Amazon, €50)
- [ ] Installer middleware eID (eid.belgium.be)
- [ ] Tester lecture votre propre carte eID

### Étape 5: Mise à Jour Docs (Jour 5)
- [ ] Réviser MVP_SPEC.md (ajouter Phase 2 eHealth)
- [ ] Mettre à jour GitHub Issue #1 (nouveau Epic 0: eHealth Tier 1)
- [ ] Documenter décisions dans DECISIONS.md

---

## 🏗️ PLAN D'IMPLÉMENTATION DÉTAILLÉ (Architecture Hybride)

### Semaine 1: Contact eHealth + Setup I.AM Connect
**Référence:** TECHNICAL_NIC_MODERN_APIS.md, section "NEXT STEPS"

**Jour 1-2:**
- [ ] Email mycarenet@intermut.be (demande I.AM Connect + MyCareNet)
- [ ] Demander User ID SharePoint + certificat test
- [ ] **NOUVEAU:** Demander I.AM Connect client registration

**Jour 3-5:**
- [ ] Recevoir client_id + client_secret I.AM Connect
- [ ] Configuration OIDC frontend (react-oidc-context ou vanilla JS equivalent)
- [ ] Test login flow (acceptance env)
- [ ] Vérifier JWT claims (INAMI présent)

**Livrables Semaine 1:**
- [ ] Login OIDC fonctionnel
- [ ] JWT access token obtenu
- [ ] Claims validés (INAMI, rôle, permissions)

---

### Semaine 2: Setup I.AM eXchange (Token Conversion)

**Jour 1-2:**
- [ ] Créer Edge Function `convert-oidc-to-saml`
- [ ] Implémenter appel I.AM eXchange API
- [ ] Endpoint: `https://services-acpt.ehealth.fgov.be/IAM/Exchange/v1`

**Jour 3-4:**
- [ ] Table Supabase `saml_tokens` (cache 8h validity)
- [ ] Test: OIDC → I.AM eXchange → SAML token
- [ ] Vérifier SAML token format XML

**Jour 5:**
- [ ] Integration test: Login OIDC → get SAML → ready for SOAP
- [ ] Documentation flow complet

**Livrables Semaine 2:**
- [ ] Token conversion automatique OIDC→SAML
- [ ] Cache SAML tokens opérationnel
- [ ] Flow end-to-end testé (sans SOAP call encore)

**Code Reference:**
```typescript
// supabase/functions/convert-to-saml/index.ts
// Voir TECHNICAL_NIC_MODERN_APIS.md lignes 230-263
```

---

### Semaine 3-4: e-Attest SOAP (utilise SAML converti)

**Différence vs pure SAML:**
- ❌ **AVANT:** WS-Security + certificat X.509 direct
- ✅ **MAINTENANT:** SAML tokens depuis I.AM eXchange

**Jour 1-3:**
- [ ] SOAP client setup (WSDL eAttest v3)
- [ ] XML builder (schema eAttest/KMEHR)
- [ ] Utiliser SAML tokens depuis cache

**Jour 4-5:**
- [ ] Tests envoi attestations
- [ ] Parsing réponses XML
- [ ] Error handling (rejets)

**Livrables Semaine 3-4:**
- [ ] e-Attest fonctionnel avec tokens OIDC→SAML
- [ ] 100% attestations envoyées électroniquement

---

### Semaine 5-6: e-Tarif + e-Assur

**Note:** Protocoles identiques (SOAP + SAML tokens convertis)

**Effort:**
- e-Tarif: 50h
- e-Assur: 65h + hardware eID

**Livrables Semaine 5-6:**
- [ ] Vérification tarifs temps réel
- [ ] Scan eID + vérification mutuelle

---

### Semaine 7-8: Tests + Documentation

**Tests:**
- [ ] Scénarios utilisateur complets
- [ ] Performance (temps réponse < 3s)
- [ ] Logs audit RGPD compliant

**Documentation:**
- [ ] Guide utilisateur e-Attest
- [ ] Troubleshooting OIDC/SAML
- [ ] Runbook admin

---

## 📈 DIFFÉRENCIATION vs DENTASOFT (Grâce à Architecture Hybride)

### Dentasoft (Legacy)
- ❌ Auth: Pure SAML/WS-Security (complexe)
- ❌ UX: Login certificats (friction)
- ❌ Mobile: Non supporté
- ❌ Future: Bloqué sur SOAP

### K2 Dental Cockpit (Moderne)
- ✅ Auth: OIDC moderne (email/password + 2FA)
- ✅ UX: Login web standard
- ✅ Mobile: OAuth2 natif (future app iOS/Android)
- ✅ Future: Backend switch transparent si APIs REST

**Marketing Angle:**
> "Dentasoft utilise la vieille méthode SAML. K2 utilise l'authentification moderne eHealth (I.AM Connect), comme les banques. Même résultat, meilleure expérience."

---

**Document complété:** 2026-07-24
**Mis à jour:** Intégration architecture hybride OIDC + SAML
**Prochaine review:** Post-contact NIC (1 semaine)
**Référence:** TECHNICAL_NIC_MODERN_APIS.md
**Auteur:** Ismail Sialyen

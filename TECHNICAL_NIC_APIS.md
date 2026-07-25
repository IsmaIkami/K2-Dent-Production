# 🔧 APIs OBLIGATOIRES CERTIFICATION NIC - GUIDE TECHNIQUE
**Pour:** Logiciels dentaires Belgique
**Expert:** Ismail Sialyen (SOAP/REST)
**Date:** 2026-07-24

---

## 🎯 LISTE APIS OBLIGATOIRES vs OPTIONNELLES

### ✅ TIER 1: OBLIGATOIRES (Minimum Certification NIC)

| API | Protocole | Statut | Priorité | Effort |
|-----|-----------|--------|----------|--------|
| **eAttest** | SOAP | ⚠️ OBLIGATOIRE Sept 2025 | 🔴 P0 | 80h |
| **Tarification** | SOAP | Requis certification | 🔴 P0 | 50h |
| **Insurability (e-Assur)** | SOAP | Requis certification | 🔴 P0 | 65h |

### 🟡 TIER 2: FORTEMENT RECOMMANDÉES

| API | Protocole | Statut | Priorité | Effort |
|-----|-----------|--------|----------|--------|
| **Recip-e** | SOAP | Optionnel (confort) | 🟡 P1 | 90h |
| **e-FactC (Tiers Payant)** | SOAP | Optionnel | 🟡 P1 | 130h |
| **DMG (Dossier Médical Global)** | SOAP | Optionnel | 🟡 P2 | 50h |

### 🔵 TIER 3: OPTIONNELLES (Full Stack)

| API | Protocole | Statut | Priorité | Effort |
|-----|-----------|--------|----------|--------|
| **eBox (Messagerie)** | REST | Optionnel | 🔵 P3 | 75h |
| **AddressBook** | SOAP | Optionnel | 🔵 P3 | 40h |
| **Sumehr (RSW)** | SOAP | Optionnel | 🔵 P3 | 65h |

**Total Tier 1 OBLIGATOIRE:** 195h
**Total Tier 1+2 (Certification solide):** 465h
**Total Complet (Tier 1+2+3):** 645h

---

## 📡 INFRASTRUCTURE eHEALTH PLATFORM

### Endpoints Principaux

**Production:**
```
https://services.ehealth.fgov.be/
```

**Acceptance (Tests):**
```
https://services-acpt.ehealth.fgov.be/
```

**API Portal (Documentation):**
```
https://portal.api.ehealth.fgov.be/
```

### Architecture

```
Votre K2 Backend (Supabase Edge Function)
    ↓ HTTPS/SOAP (SSL/TLS obligatoire)
eHealth Platform API Gateway
    ↓ WS-Security (X.509 cert + SAML token)
MyCareNet Network
    ↓
Mutualités (CM, Solidaris, Partenamut, etc.)
```

---

## 🔐 AUTHENTIFICATION & SÉCURITÉ

### 1. Certificat eHealth X.509

**Obtention:**
1. Demande via eHealth Platform Portal
2. Validation identité (INAMI, Ordre Médecins)
3. Certificat .p12 (PKCS12) délivré
4. Validité: 3 ans (renouvelable)

**Types certificats:**
- **Professionnel:** Lié à votre numéro INAMI personnel
- **Organisationnel:** Lié à votre cabinet (multi-médecins)

**Recommandation:** Certificat organisationnel (scalable)

**Stockage sécurisé:**
```typescript
// Supabase Vault (encrypted at rest)
const EHEALTH_CERT = await supabase.functions.invoke('get-vault-secret', {
  body: { name: 'EHEALTH_CERT_P12' }
});

const EHEALTH_KEY = await supabase.functions.invoke('get-vault-secret', {
  body: { name: 'EHEALTH_PRIVATE_KEY' }
});
```

---

### 2. SAML Token (Authorization)

**Flow:**
```
1. Votre app → eHealth STS (Security Token Service)
   - Header: X.509 certificate
   - Body: SAML Request

2. eHealth STS → Valide certificat

3. eHealth STS → Retourne SAML Token (signed)
   - Durée validité: 8h
   - Contient: INAMI, rôle, permissions

4. Votre app → Appels API avec SAML Token
   - Header WS-Security: SAML Token + Timestamp
```

**Exemple requête SAML Token:**
```xml
POST https://services-acpt.ehealth.fgov.be/IAM/SecurityTokenService/v1
Content-Type: text/xml

<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Header>
    <wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
      <wsse:BinarySecurityToken
        EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary"
        ValueType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3">
        <!-- Base64 encoded X.509 certificate -->
      </wsse:BinarySecurityToken>
    </wsse:Security>
  </soap:Header>
  <soap:Body>
    <wst:RequestSecurityToken xmlns:wst="http://docs.oasis-open.org/ws-sx/ws-trust/200512">
      <wst:RequestType>http://docs.oasis-open.org/ws-sx/ws-trust/200512/Issue</wst:RequestType>
      <wst:TokenType>http://docs.oasis-open.org/wss/oasis-wss-saml-token-profile-1.1#SAMLV2.0</wst:TokenType>
    </wst:RequestSecurityToken>
  </soap:Body>
</soap:Envelope>
```

**Réponse SAML Token:**
```xml
<soap:Envelope>
  <soap:Body>
    <wst:RequestSecurityTokenResponse>
      <wst:RequestedSecurityToken>
        <saml:Assertion xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">
          <!-- SAML Token signé par eHealth -->
          <saml:Issuer>urn:be:fgov:ehealth:sts</saml:Issuer>
          <saml:Subject>
            <saml:NameID>INAMI_NUMBER</saml:NameID>
          </saml:Subject>
          <saml:AttributeStatement>
            <saml:Attribute Name="urn:be:fgov:ehealth:1.0:certificateholder:nihii">
              <saml:AttributeValue>YOUR_INAMI</saml:AttributeValue>
            </saml:Attribute>
          </saml:AttributeStatement>
        </saml:Assertion>
      </wst:RequestedSecurityToken>
    </wst:RequestSecurityTokenResponse>
  </soap:Body>
</soap:Envelope>
```

---

### 3. WS-Security Headers (Toutes Requêtes)

**Template standard:**
```xml
<soap:Header>
  <wsse:Security xmlns:wsse="...">
    <!-- 1. Timestamp (anti-replay) -->
    <wsu:Timestamp xmlns:wsu="...">
      <wsu:Created>2026-07-24T10:00:00Z</wsu:Created>
      <wsu:Expires>2026-07-24T10:05:00Z</wsu:Expires>
    </wsu:Timestamp>

    <!-- 2. SAML Token (authorization) -->
    <saml:Assertion>
      <!-- SAML token obtenu via STS -->
    </saml:Assertion>

    <!-- 3. Signature (integrity) -->
    <ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
      <!-- Signature XML du message avec private key -->
    </ds:Signature>
  </wsse:Security>
</soap:Header>
```

---

## 🔴 API #1: eATTEST (OBLIGATOIRE P0)

### Description
Envoi attestations soins électroniques aux mutualités.

**Obligatoire depuis:** Septembre 2025 (paiements cash)

### Endpoint

**WSDL:**
```
https://services-acpt.ehealth.fgov.be/MyCareNet/eAttest/v3?wsdl
```

**Base Path:**
```
/MyCareNet/eAttest/v3
```

**Version actuelle:** v3 (Cookbook v1.2 du 04/08/2022)

### Opérations SOAP

#### 1. `sendAttestations`
**Input:** Batch attestations (max 50 par requête)
**Output:** Statut envoi + référence unique

**Requête XML:**
```xml
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Header>
    <!-- WS-Security headers (voir section authentification) -->
  </soap:Header>
  <soap:Body>
    <eattest:SendAttestationsRequest xmlns:eattest="http://www.ehealth.fgov.be/standards/kmehr/mycarenet/schema/v3">
      <eattest:CommonInput>
        <eattest:Request>
          <eattest:IsTest>false</eattest:IsTest>
        </eattest:Request>
        <eattest:Origin>
          <eattest:Package>
            <eattest:Name>K2 Dental Cockpit</eattest:Name>
            <eattest:Version>1.0.0</eattest:Version>
          </eattest:Package>
        </eattest:Origin>
      </eattest:CommonInput>

      <eattest:Attestations>
        <eattest:Attestation>
          <!-- Patient -->
          <eattest:Insuree>
            <eattest:INSS>85073100166</eattest:INSS> <!-- NISS patient -->
          </eattest:Insuree>

          <!-- Prestataire (vous) -->
          <eattest:CareProvider>
            <eattest:NIHII>1-12345-67-890</eattest:NIHII> <!-- INAMI dentiste -->
            <eattest:Quality>dentist</eattest:Quality>
          </eattest:CareProvider>

          <!-- Actes INAMI -->
          <eattest:Transactions>
            <eattest:Transaction>
              <eattest:Date>2026-07-24</eattest:Date>
              <eattest:Time>14:30:00</eattest:Time>
              <eattest:Items>
                <eattest:Item>
                  <eattest:Code>305593</eattest:Code> <!-- Code INAMI -->
                  <eattest:Amount>25.50</eattest:Amount>
                  <eattest:ReimbursedAmount>18.00</eattest:ReimbursedAmount>
                </eattest:Item>
              </eattest:Items>
            </eattest:Transaction>
          </eattest:Transactions>
        </eattest:Attestation>
      </eattest:Attestations>
    </eattest:SendAttestationsRequest>
  </soap:Body>
</soap:Envelope>
```

**Réponse XML:**
```xml
<soap:Envelope>
  <soap:Body>
    <eattest:SendAttestationsResponse>
      <eattest:CommonOutput>
        <eattest:NIPReference>20260724-12345678</eattest:NIPReference>
        <eattest:Status>
          <eattest:Code>200</eattest:Code>
          <eattest:Message>Accepted</eattest:Message>
        </eattest:Status>
      </eattest:CommonOutput>

      <eattest:AttestationResponses>
        <eattest:AttestationResponse>
          <eattest:Reference>ATT-2026-001</eattest:Reference>
          <eattest:Accepted>true</eattest:Accepted>
        </eattest:AttestationResponse>
      </eattest:AttestationResponses>
    </eattest:SendAttestationsResponse>
  </soap:Body>
</soap:Envelope>
```

#### 2. `cancelAttestations`
Annulation attestations déjà envoyées (si erreur détectée <48h)

#### 3. `getAttestationStatus`
Vérification statut traitement mutualité

### Codes Erreur

| Code | Description | Action |
|------|-------------|--------|
| 200 | Accepted | ✅ OK |
| 400 | Invalid XML | Vérifier schema KMEHR |
| 401 | Unauthorized | Renouveler SAML token |
| 422 | Business Error | Code INAMI invalide, NISS incorrect |
| 500 | Server Error | Retry après 5 min |

### Documentation Officielle

**Cookbook:**
- Nom: MCN eAttest WS V3 - Cookbook
- Version: 1.2 (04/08/2022)
- Téléchargement: portal.api.ehealth.fgov.be

**Schémas XSD:**
- KMEHR v1.0 (Belgian standard)
- MyCareNet eAttest v3 extensions

---

## 🟡 API #2: TARIFICATION (OBLIGATOIRE P0)

### Description
Consultation tarifs INAMI en temps réel (codes nomenclature).

### Endpoint

**WSDL:**
```
https://services-acpt.ehealth.fgov.be/MyCareNet/Tarification/v1?wsdl
```

**Base Path:**
```
/MyCareNet/Tarification/v1
```

### Opérations SOAP

#### 1. `consultTariff`

**Input:**
- Code INAMI (ex: 305593)
- Date prestation
- Âge patient (optionnel, affecte tarif)

**Output:**
- Honoraire convention
- Honoraire libre
- Part patient
- Part mutualité
- Tiers payant applicable

**Requête XML:**
```xml
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Header>
    <!-- WS-Security headers -->
  </soap:Header>
  <soap:Body>
    <tarif:ConsultTariffRequest xmlns:tarif="http://www.ehealth.fgov.be/standards/kmehr/mycarenet/tarif/v1">
      <tarif:CommonInput>
        <tarif:Request>
          <tarif:IsTest>false</tarif:IsTest>
        </tarif:Request>
        <tarif:Origin>
          <tarif:Package>
            <tarif:Name>K2 Dental Cockpit</tarif:Name>
          </tarif:Package>
        </tarif:Origin>
      </tarif:CommonInput>

      <tarif:TariffRequest>
        <tarif:Code>305593</tarif:Code>
        <tarif:Date>2026-07-24</tarif:Date>
        <tarif:PatientAge>45</tarif:PatientAge>
      </tarif:TariffRequest>
    </tarif:ConsultTariffRequest>
  </soap:Body>
</soap:Envelope>
```

**Réponse XML:**
```xml
<soap:Envelope>
  <soap:Body>
    <tarif:ConsultTariffResponse>
      <tarif:CommonOutput>
        <tarif:Status>
          <tarif:Code>200</tarif:Code>
        </tarif:Status>
      </tarif:CommonOutput>

      <tarif:TariffResponse>
        <tarif:Code>305593</tarif:Code>
        <tarif:Description>Détartrage complet</tarif:Description>

        <tarif:Amounts>
          <tarif:ConventionHonorarium>25.50</tarif:ConventionHonorarium>
          <tarif:FreeHonorarium>35.00</tarif:FreeHonorarium>
          <tarif:PatientShare>7.50</tarif:PatientShare>
          <tarif:InsuranceShare>18.00</tarif:InsuranceShare>
          <tarif:ThirdPartyPayerEligible>false</tarif:ThirdPartyPayerEligible>
        </tarif:Amounts>

        <tarif:Validity>
          <tarif:ValidFrom>2025-01-01</tarif:ValidFrom>
          <tarif:ValidTo>2026-12-31</tarif:ValidTo>
        </tarif:Validity>
      </tarif:TariffResponse>
    </tarif:ConsultTariffResponse>
  </soap:Body>
</soap:Envelope>
```

### Cache Local Recommandé

**Stratégie:**
1. Cache tarifs en DB (table `inami_tariffs`)
2. TTL: 24h (tarifs changent rarement)
3. Refresh quotidien (cron 2h matin)
4. Fallback API temps réel si cache miss

**SQL Cache:**
```sql
CREATE TABLE inami_tariffs (
  code VARCHAR(10) PRIMARY KEY,
  description TEXT,
  convention_honorarium DECIMAL(10,2),
  patient_share DECIMAL(10,2),
  insurance_share DECIMAL(10,2),
  third_party_eligible BOOLEAN,
  valid_from DATE,
  valid_to DATE,
  cached_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_tariffs_validity ON inami_tariffs(valid_from, valid_to);
```

---

## 🟢 API #3: INSURABILITY (e-Assur) (OBLIGATOIRE P0)

### Description
Vérification insurabilité patient (mutualité, droits, tiers payant).

### Endpoint

**WSDL:**
```
https://services-acpt.ehealth.fgov.be/GenericInsurability/v1?wsdl
```

**Base Path:**
```
/GenericInsurability/v1
```

### Opérations SOAP

#### 1. `getInsurability`

**Input:**
- NISS patient (11 chiffres)
- Date référence (date consultation)

**Output:**
- Statut assuré (oui/non)
- Code mutualité (ex: 300 = CM)
- Tiers payant éligible
- Détails couverture

**Requête XML:**
```xml
<soap:Envelope>
  <soap:Header>
    <!-- WS-Security headers -->
  </soap:Header>
  <soap:Body>
    <insur:GetInsurabilityRequest xmlns:insur="http://www.ehealth.fgov.be/insurability/protocol/v1">
      <insur:CommonInput>
        <insur:Request>
          <insur:IsTest>false</insur:IsTest>
        </insur:Request>
        <insur:Origin>
          <insur:Package>
            <insur:Name>K2 Dental Cockpit</insur:Name>
          </insur:Package>
        </insur:Origin>
      </insur:CommonInput>

      <insur:InsurabilityRequest>
        <insur:NISS>85073100166</insur:NISS>
        <insur:ReferenceDate>2026-07-24</insur:ReferenceDate>
      </insur:InsurabilityRequest>
    </insur:GetInsurabilityRequest>
  </soap:Body>
</soap:Envelope>
```

**Réponse XML:**
```xml
<soap:Envelope>
  <soap:Body>
    <insur:GetInsurabilityResponse>
      <insur:CommonOutput>
        <insur:NIPReference>20260724-98765</insur:NIPReference>
        <insur:Status>
          <insur:Code>200</insur:Code>
        </insur:Status>
      </insur:CommonOutput>

      <insur:InsurabilityResponse>
        <insur:NISS>85073100166</insur:NISS>
        <insur:Insured>true</insur:Insured>

        <insur:InsuranceDetails>
          <insur:Mutuality>
            <insur:Code>300</insur:Code>
            <insur:Name>Christelijke Mutualiteit</insur:Name>
          </insur:Mutuality>

          <insur:Coverage>
            <insur:Type>STANDARD</insur:Type>
            <insur:StartDate>2020-01-01</insur:StartDate>
          </insur:Coverage>

          <insur:ThirdPartyPayer>
            <insur:Eligible>false</insur:Eligible>
            <insur:ForDentalCare>false</insur:ForDentalCare>
          </insur:ThirdPartyPayer>
        </insur:InsuranceDetails>
      </insur:InsurabilityResponse>
    </insur:GetInsurabilityResponse>
  </soap:Body>
</soap:Envelope>
```

### Intégration Lecteur Carte eID

**Hardware:** ACR122U (€50, Amazon)

**Flow:**
1. Patient insère carte eID dans lecteur
2. Middleware eID lit NISS
3. App appelle API Insurability avec NISS
4. Affichage mutualité + statut temps réel

**Middleware eID (Belgique):**
```bash
# Download
https://eid.belgium.be/fr/telechargements

# Installation macOS
brew install eid-mw

# Test lecture
eid-viewer
```

**Code Deno (lecture NISS carte eID):**
```typescript
// Utiliser lib PCSC
import { Card, NFC } from 'https://deno.land/x/pcsc/mod.ts';

async function readEidNISS(): Promise<string> {
  const nfc = await NFC.create();
  const reader = nfc.readers[0];
  const card = await reader.connect();

  // Lire fichier identité
  const apdu = [0x00, 0xB0, 0x00, 0x00, 0x0D]; // SELECT FILE Identity
  const response = await card.transmit(apdu);

  // Parser NISS (National Number)
  const niss = parseNISS(response);
  return niss;
}
```

---

## 🟡 API #4: RECIP-E (Optionnelle Tier 2)

### Description
Envoi prescriptions électroniques aux pharmacies.

### Endpoint

**WSDL:**
```
https://services-acpt.ehealth.fgov.be/Recip-e/v5?wsdl
```

**Version:** v5 (dernière stable)

### Opérations SOAP

#### 1. `createPrescription`

**Input:**
- Patient (NISS)
- Médicaments (code CNK)
- Posologie
- Durée traitement

**Output:**
- RID (Recip-e ID, code 17 chiffres)
- QR Code (patient montre en pharmacie)

**Effort:** 90h (complexe, validation DPP database médicaments)

---

## 🟡 API #5: e-FACT (Tiers Payant) (Optionnelle Tier 2)

### Description
Facturation directe mutualités (patient ne paie que ticket modérateur).

### Endpoint

**WSDL:**
```
https://services-acpt.ehealth.fgov.be/MyCareNet/eFact/v1?wsdl
```

### Messages

**920:** Envoi factures batch (XML messages)
**921:** Réponse mutualités (accepté/rejeté)

**Effort:** 130h (format complexe, gestion rejets, réconciliation)

---

## 📚 DOCUMENTATION & RESSOURCES

### Portail API Officiel

**URL:** https://portal.api.ehealth.fgov.be/

**Contenu:**
- Liste complète APIs (SOAP + REST)
- WSDL téléchargeables
- Cookbooks (PDF guides techniques)
- Schémas XSD
- Exemples requêtes/réponses

**Login:** Nécessite certificat eHealth

---

### Cookbooks Critiques

| Document | Version | Date | Lien |
|----------|---------|------|------|
| MCN eAttest WS V3 - Cookbook | 1.2 | 04/08/2022 | portal.api.ehealth.fgov.be |
| Generic Insurability - Cookbook | 2.0 | 15/03/2023 | portal.api.ehealth.fgov.be |
| MyCareNet Tarification - Guide | 1.5 | 10/01/2024 | portal.api.ehealth.fgov.be |
| eHealth SSO - MCN eAttest v3 | 1.1 | 10/10/2024 | portal.api.ehealth.fgov.be |

---

### Schémas XSD (Validation XML)

**KMEHR (Belgian Health Standard):**
```
http://www.ehealth.fgov.be/standards/kmehr/
```

**Versions:**
- KMEHR 1.0 (base)
- KMEHR CD (Code tables)
- KMEHR ID (Identifiers)

**Usage:**
```typescript
import { XMLValidator } from 'fast-xml-parser';

const schema = await fetchXSD('https://www.ehealth.fgov.be/standards/kmehr/schema/v1/kmehr.xsd');
const isValid = XMLValidator.validate(xmlRequest, { schema });
```

---

### Connecteurs Open-Source

**GitHub:**
- **e-Contract/mycarenet** (Java)
  https://github.com/e-Contract/mycarenet
  - Connecteurs eAttest, Tarif, Insurability
  - WS-Security handlers
  - Exemples complets

- **koenvantomme/mycarenet** (Java, ancien)
  https://github.com/koenvantomme/mycarenet

**Recommandation:** Étudier e-Contract pour comprendre flow WS-Security

---

## 🛠 IMPLÉMENTATION TECHNIQUE

### Stack Recommandé (Deno/TypeScript)

**Librairies SOAP:**
```typescript
// Option 1: soap-client (Deno native)
import { SoapClient } from 'https://deno.land/x/soap_client/mod.ts';

// Option 2: strong-soap (Node compat)
import { createClientAsync } from 'npm:strong-soap';

// WS-Security
import { WSSecurityCert } from 'https://deno.land/x/ws_security/mod.ts';

// XML parsing
import { XMLParser, XMLBuilder } from 'npm:fast-xml-parser';

// Certificats
import { readFileSync } from 'node:fs';
```

---

### Template Edge Function eAttest

```typescript
// supabase/functions/mycarenet-eattest/index.ts
import { serve } from 'std/http/server.ts';
import { createClient } from '@supabase/supabase-js';
import { SoapClient } from 'soap-client-deno';
import { WSSecurityCert } from 'ws-security';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
);

// Constants
const EATTEST_WSDL = 'https://services-acpt.ehealth.fgov.be/MyCareNet/eAttest/v3?wsdl';

serve(async (req) => {
  try {
    const { patient_id, treatments } = await req.json();

    // 1. Fetch data from DB
    const { data: patient } = await supabase
      .from('patients')
      .select('niss, first_name, last_name')
      .eq('id', patient_id)
      .single();

    const { data: dentist } = await supabase
      .from('staff_profiles')
      .select('inami_number')
      .single();

    // 2. Get SAML token (cache 8h)
    const samlToken = await getSAMLToken();

    // 3. Build SOAP request
    const attestation = {
      Insuree: { INSS: patient.niss },
      CareProvider: {
        NIHII: dentist.inami_number,
        Quality: 'dentist'
      },
      Transactions: treatments.map(t => ({
        Date: t.date,
        Items: [{
          Code: t.inami_code,
          Amount: t.amount,
          ReimbursedAmount: t.reimbursed
        }]
      }))
    };

    // 4. SOAP call
    const client = await SoapClient.create({
      wsdl: EATTEST_WSDL,
      security: new WSSecurityCert({
        privateKey: EHEALTH_KEY,
        publicCert: EHEALTH_CERT,
        samlToken: samlToken
      })
    });

    const response = await client.SendAttestations({
      CommonInput: {
        Request: { IsTest: false },
        Origin: {
          Package: {
            Name: 'K2 Dental Cockpit',
            Version: '1.0.0'
          }
        }
      },
      Attestations: { Attestation: attestation }
    });

    // 5. Parse response
    const nipRef = response.CommonOutput.NIPReference;
    const status = response.CommonOutput.Status.Code;

    // 6. Log to DB
    await supabase.from('eattest_logs').insert({
      patient_id,
      nip_reference: nipRef,
      status: status === '200' ? 'sent' : 'failed',
      response_data: response,
      sent_at: new Date()
    });

    return new Response(JSON.stringify({
      success: status === '200',
      reference: nipRef,
      message: response.CommonOutput.Status.Message
    }), {
      headers: { 'Content-Type': 'application/json' }
    });

  } catch (error) {
    console.error('eAttest error:', error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
});

// Helper: Get SAML Token (cached)
async function getSAMLToken(): Promise<string> {
  // Check cache
  const { data: cached } = await supabase
    .from('saml_tokens')
    .select('token, expires_at')
    .order('created_at', { ascending: false })
    .limit(1)
    .single();

  if (cached && new Date(cached.expires_at) > new Date()) {
    return cached.token;
  }

  // Request new token from STS
  const stsClient = await SoapClient.create({
    wsdl: 'https://services-acpt.ehealth.fgov.be/IAM/SecurityTokenService/v1?wsdl',
    security: new WSSecurityCert({
      privateKey: EHEALTH_KEY,
      publicCert: EHEALTH_CERT
    })
  });

  const tokenResponse = await stsClient.RequestSecurityToken({
    RequestType: 'http://docs.oasis-open.org/ws-sx/ws-trust/200512/Issue',
    TokenType: 'http://docs.oasis-open.org/wss/oasis-wss-saml-token-profile-1.1#SAMLV2.0'
  });

  const token = tokenResponse.RequestedSecurityToken.Assertion;
  const expiresAt = new Date(Date.now() + 8 * 60 * 60 * 1000); // 8h

  // Cache token
  await supabase.from('saml_tokens').insert({
    token,
    expires_at: expiresAt
  });

  return token;
}
```

---

## 📋 ORDRE IMPLÉMENTATION RECOMMANDÉ

### Sprint 1: Setup Infrastructure (Semaine 1-2)

**Tasks:**
- [ ] Inscription eHealth Platform (mycarenet@intermut.be)
- [ ] Obtenir User ID + password SharePoint
- [ ] Télécharger cookbooks (eAttest, Tarif, Insurability)
- [ ] Demander certificat test eHealth
- [ ] Setup environnement acceptance (endpoints test)
- [ ] Acheter lecteur carte eID (€50)
- [ ] Installer middleware eID

**Livrables:**
- Certificat test .p12
- Accès portal.api.ehealth.fgov.be
- Documentation technique locale

---

### Sprint 2: SAML Token Service (Semaine 3)

**Tasks:**
- [ ] Edge Function `get-saml-token`
- [ ] Stockage certificat Supabase Vault
- [ ] WS-Security headers (timestamp, signature)
- [ ] Appel STS (Security Token Service)
- [ ] Cache tokens (table `saml_tokens`, TTL 8h)
- [ ] Tests: obtenir token valide

**Tests:**
```typescript
// Test SAML token
const token = await getSAMLToken();
console.log('SAML Token:', token);
// Vérifier: token contient INAMI, expiration future
```

---

### Sprint 3: API Insurability (Semaine 4)

**Tasks:**
- [ ] Edge Function `mycarenet-insurability`
- [ ] Parser XML response
- [ ] UI: scan carte eID → affichage mutualité
- [ ] DB: table `insurability_cache` (éviter appels répétés)
- [ ] Error handling (NISS invalide, patient non-assuré)

**Tests:**
- Carte eID réelle → API call → response parsed
- Cache hit (2e consultation même patient)

---

### Sprint 4: API Tarification (Semaine 5)

**Tasks:**
- [ ] Edge Function `mycarenet-tarification`
- [ ] Parser tarifs (convention, patient share, etc.)
- [ ] DB: table `inami_tariffs` (cache local)
- [ ] Cron: refresh tarifs quotidien (2h matin)
- [ ] UI: autocomplete codes INAMI + preview tarif

**Tests:**
- Code 305593 → tarif correct (€25.50 convention)
- Cache local utilisé (pas d'appel API 2e fois)

---

### Sprint 5: API eAttest (Semaine 6-8)

**Tasks:**
- [ ] Edge Function `mycarenet-eattest`
- [ ] Builder XML attestations (schema KMEHR)
- [ ] Validation XSD avant envoi
- [ ] Parser response (NIP reference, status)
- [ ] DB: table `eattest_logs` (audit trail)
- [ ] UI: bouton "Envoyer eAttest" → feedback temps réel
- [ ] Error handling (codes INAMI invalides, rejets)

**Tests:**
- Attestation test → envoi acceptance → status 200
- Rejection simulation (code invalide) → error message clair

---

### Sprint 6: Tests NIC (Semaine 9-10)

**Tasks:**
- [ ] Scénarios test NIC obligatoires (fournis par NIC)
- [ ] Logs détaillés (requêtes/réponses XML)
- [ ] Corrections bugs détectés
- [ ] Documentation technique (architecture, flow)

**Scénarios NIC typiques:**
1. Attestation simple (1 patient, 1 code INAMI)
2. Attestation multiple (batch 10 patients)
3. Annulation attestation (<48h)
4. Gestion rejets (code obsolète, NISS incorrect)
5. Insurability patient non-assuré

---

### Sprint 7: Approval Assessment (Semaine 11-12)

**Tasks:**
- [ ] Soumission logs tests à NIC
- [ ] Revue technique équipe NIC
- [ ] Corrections finales
- [ ] Validation conformité

**Livrable:** Email NIC "Approval granted for production"

---

### Sprint 8: Production (Semaine 13)

**Tasks:**
- [ ] Certificat production eHealth (renewal)
- [ ] Switch endpoints test → production
- [ ] Rollout progressif (votre cabinet first)
- [ ] Monitoring production (erreurs, latence)

**Go-Live:** K2 certified NIC-compliant

---

## ✅ CHECKLIST PRÉ-DÉVELOPPEMENT

### Administratif
- [ ] Numéro INAMI médecin valide (format: 1-xxxxx-xx-xxx)
- [ ] Inscription Ordre des Médecins à jour
- [ ] Email professionnel (@cabinet.be)

### Technique
- [ ] Supabase project configuré
- [ ] Edge Functions déployables (Deno runtime)
- [ ] Vault configuré (secrets encrypted)
- [ ] Lecteur carte eID commandé

### Documentation
- [ ] Cookbooks téléchargés (eAttest, Tarif, Insurability)
- [ ] WSDLs locaux (offline dev)
- [ ] Exemples XML requests/responses

### Budget
- [ ] Certificat eHealth: €50/an
- [ ] Lecteur eID: €50 one-time
- [ ] Temps dev: 195h (Tier 1) = gratuit si vous développez

---

## 🚀 NEXT STEPS (Cette Semaine)

### Jour 1: Contact NIC
```bash
# Email à envoyer
To: mycarenet@intermut.be
Subject: Demande accès test MyCareNet - K2 Dental Cockpit

Bonjour,

Je développe K2 Dental Cockpit, logiciel gestion cabinet dentaire.
Je souhaite intégrer MyCareNet APIs et obtenir:

1. User ID + password SharePoint (documentation technique)
2. Certificat test eHealth Platform
3. License test environnement acceptance

Coordonnées:
- Nom: Ismail Sialyen
- INAMI: [votre numéro]
- Email: [email]
- Téléphone: [tel]

Modules visés (Tier 1 certification):
- eAttest v3
- Tarification v1
- Generic Insurability v1

Merci d'avance,
Ismail Sialyen
```

### Jour 2-3: Setup Local
- [ ] Installer middleware eID (eid.belgium.be)
- [ ] Tester lecture votre carte eID
- [ ] Commander lecteur ACR122U (€50)

### Jour 4-5: Étude Cookbooks
- [ ] Lire MCN eAttest Cookbook v1.2
- [ ] Lire Generic Insurability Guide
- [ ] Identifier flux SAML token (schémas)

### Jour 6-7: POC SAML Token
- [ ] Edge Function basique `get-saml-token`
- [ ] Appel STS test (sans certificat = échec attendu)
- [ ] Préparer stockage certificat (Vault structure)

---

**Prêt à bloquer ensemble sur l'implémentation ?** On commence par quel module ? (SAML token, eAttest, ou Insurability ?)
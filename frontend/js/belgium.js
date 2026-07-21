/**
 * K2 DENT — BELGIUM COMPLIANCE UTILITIES
 * Belgian healthcare system integration utilities
 * INAMI, MyCareNet, NISS validation, Mutuelle codes
 *
 * @author Ismail Sialyen
 * @date April 2026
 * @version 1.0.0
 */

// ============================================================================
// BELGIAN NISS VALIDATION
// ============================================================================

/**
 * Validates Belgian NISS (Numéro d'Identification de la Sécurité Sociale)
 * Format: XX.XX.XX-XXX.XX
 * Example: 85.01.15-123.45
 *
 * @param {string} niss - NISS to validate (with or without formatting)
 * @returns {boolean} - True if valid, false otherwise
 */
function validateNISS(niss) {
  if (!niss) return false;

  // Remove formatting (dots and dashes)
  const clean = niss.replace(/[.\-\s]/g, '');

  // Must be exactly 11 digits
  if (clean.length !== 11) return false;
  if (!/^\d{11}$/.test(clean)) return false;

  // Extract components
  const birthDate = clean.substring(0, 6); // YYMMDD
  const counter = clean.substring(6, 9);   // XXX
  const checkDigits = parseInt(clean.substring(9, 11)); // CC

  // Validate date components
  const yy = parseInt(birthDate.substring(0, 2));
  const mm = parseInt(birthDate.substring(2, 4));
  const dd = parseInt(birthDate.substring(4, 6));

  if (mm < 1 || mm > 12) return false;
  if (dd < 1 || dd > 31) return false;

  // Calculate check digits
  let baseNumber = parseInt(birthDate + counter);

  // For people born >= 2000, add 2000000000
  const currentYear = new Date().getFullYear();
  const fullYear = yy + (yy > currentYear % 100 ? 1900 : 2000);

  if (fullYear >= 2000) {
    baseNumber += 2000000000;
  }

  const calculatedCheck = 97 - (baseNumber % 97);

  return calculatedCheck === checkDigits;
}

/**
 * Formats NISS to standard Belgian format: XX.XX.XX-XXX.XX
 * @param {string} niss - Unformatted NISS
 * @returns {string} - Formatted NISS
 */
function formatNISS(niss) {
  const clean = niss.replace(/[.\-\s]/g, '');
  if (clean.length !== 11) return niss;

  return `${clean.substring(0, 2)}.${clean.substring(2, 4)}.${clean.substring(4, 6)}-${clean.substring(6, 9)}.${clean.substring(9, 11)}`;
}

// ============================================================================
// BELGIAN MUTUELLE (HEALTH INSURANCE) CODES
// ============================================================================

/**
 * Official Belgian Mutuelle OA (Organisme Assureur) codes
 */
const MUTUELLES = [
  {
    code: "100",
    name: "UNMS (Union Nationale des Mutualités Socialistes)",
    short: "UNMS",
    region: "National"
  },
  {
    code: "200",
    name: "Solidaris (Mutualités Socialistes)",
    short: "SOL",
    region: "Wallonie"
  },
  {
    code: "300",
    name: "Mutualité Chrétienne / Christelijke Mutualiteit (MC/CM)",
    short: "MC",
    region: "National"
  },
  {
    code: "400",
    name: "Partenamut (Mutualités Libres)",
    short: "PART",
    region: "National"
  },
  {
    code: "500",
    name: "Liberale Mutualiteit / Mutualité Libérale (LMLV)",
    short: "ML",
    region: "Vlaanderen"
  },
  {
    code: "600",
    name: "CAAMI (Caisse Auxiliaire d'Assurance Maladie-Invalidité)",
    short: "CAAMI",
    region: "National"
  },
  {
    code: "900",
    name: "HR Rail (Société Nationale des Chemins de fer Belges)",
    short: "HR Rail",
    region: "National"
  }
];

/**
 * Get mutuelle info by code
 * @param {string} code - Mutuelle OA code
 * @returns {object|null} - Mutuelle object or null if not found
 */
function getMutuelleByCode(code) {
  return MUTUELLES.find(m => m.code === code) || null;
}

// ============================================================================
// PRESCRIPTEUR (PRACTITIONER INFO)
// ============================================================================

/**
 * Dr. Ekaterina SIALYEN - Practice information
 * Pre-filled for all official documents
 */
const PRESCRIPTEUR = {
  name: "Dr. Ekaterina SIALYEN",
  title: "Dentiste Généraliste",
  inami: "3-02462-81-001",
  riziv: "3-02462-81-001", // Same as INAMI
  niss: "86.12.04-502.07", // Optional: for eHealth

  cabinet: {
    name: "Cabinet Dentaire Dr. SIALYEN",
    address: {
      street: "Avenue des Mimosas",
      number: "42",
      box: "",
      postalCode: "1930",
      city: "Zaventem",
      country: "Belgique"
    },
    contact: {
      phone: "+32 2 XXX XX XX",
      mobile: "+32 4XX XX XX XX",
      email: "contact@k2dent.be",
      website: "https://k2dent.be"
    }
  },

  mycareNet: {
    cin: "pending", // CIN certification in progress
    eAttest: true,
    eFact: true,
    consultRN: true
  }
};

// ============================================================================
// INAMI NOMENCLATURE 2025-2026 (ARTICLE 5 - DENTAL)
// ============================================================================

/**
 * Belgian dental nomenclature codes (Article 5)
 * Tariffs based on accord dento-mutualiste 2026-2027
 * Source: INAMI/RIZIV official nomenclature
 */
const INAMI_ACTS = [
  // CONSULTATIONS
  {
    code: "101035",
    paired: "101046",
    label: "Consultation dentiste généraliste ≥19 ans",
    category: "Consultation",
    tariff: 27.00,
    patient: 5.40,
    bim: 1.00,
    description: "Consultation ordinaire au cabinet pour patient de 19 ans ou plus"
  },
  {
    code: "101172",
    paired: "101183",
    label: "Consultation urgence",
    category: "Consultation",
    tariff: 46.62,
    patient: 9.32,
    bim: 2.00,
    description: "Consultation d'urgence (soir, weekend, jours fériés)"
  },
  {
    code: "101350",
    paired: "101361",
    label: "Consultation dentiste ≥75 ans",
    category: "Consultation",
    tariff: 27.00,
    patient: 5.40,
    bim: 1.00,
    description: "Consultation pour patient de 75 ans ou plus"
  },

  // EXAMEN BUCCAL
  {
    code: "301010",
    paired: "301021",
    label: "Examen buccal annuel ≥18 ans",
    category: "Prévention",
    tariff: 26.06,
    patient: 5.21,
    bim: 1.00,
    description: "Examen buccal complet annuel avec conseil en hygiène bucco-dentaire"
  },
  {
    code: "301032",
    paired: "301043",
    label: "Examen buccal 13-17 ans",
    category: "Prévention",
    tariff: 26.06,
    patient: 5.21,
    bim: 0,
    description: "Examen buccal pour adolescents de 13 à 17 ans"
  },
  {
    code: "301216",
    paired: "301220",
    label: "Examen buccal <13 ans (gratuit)",
    category: "Prévention",
    tariff: 26.06,
    patient: 0,
    bim: 0,
    description: "Examen buccal pour enfants de moins de 13 ans (gratuit pour le patient)"
  },

  // DÉTARTRAGE
  {
    code: "303013",
    paired: "303024",
    label: "Détartrage supra-gingival (quadrant)",
    category: "Prévention",
    tariff: 17.00,
    patient: 3.40,
    bim: 0.70,
    unit: "quadrant",
    description: "Détartrage supra-gingival par quadrant (max 2 quadrants/séance)"
  },
  {
    code: "303035",
    paired: "303046",
    label: "Détartrage complet (3-4 quadrants)",
    category: "Prévention",
    tariff: 17.00,
    patient: 3.40,
    bim: 0.70,
    unit: "quadrant",
    description: "Détartrage de 3 ou 4 quadrants en une séance"
  },

  // OBTURATIONS (SOINS CONSERVATEURS)
  {
    code: "311011",
    paired: "311022",
    label: "Obturation 1 surface dent permanente",
    category: "Conservateur",
    tariff: 36.30,
    patient: 7.26,
    bim: 1.50,
    tooth: true,
    description: "Obturation (amalgame ou composite) d'une surface sur dent permanente"
  },
  {
    code: "311033",
    paired: "311044",
    label: "Obturation 2 surfaces",
    category: "Conservateur",
    tariff: 55.73,
    patient: 11.15,
    bim: 2.20,
    tooth: true,
    description: "Obturation de 2 surfaces sur dent permanente"
  },
  {
    code: "311055",
    paired: "311066",
    label: "Obturation 3+ surfaces",
    category: "Conservateur",
    tariff: 73.86,
    patient: 14.77,
    bim: 3.00,
    tooth: true,
    description: "Obturation de 3 surfaces ou plus sur dent permanente"
  },
  {
    code: "311114",
    paired: "311125",
    label: "Obturation 1 surface dent temporaire",
    category: "Conservateur",
    tariff: 22.00,
    patient: 4.40,
    bim: 0,
    tooth: true,
    description: "Obturation d'une surface sur dent de lait"
  },

  // EXTRACTIONS
  {
    code: "330031",
    paired: "330042",
    label: "Extraction dent permanente (simple)",
    category: "Chirurgie",
    tariff: 42.12,
    patient: 8.42,
    bim: 1.70,
    tooth: true,
    description: "Extraction simple d'une dent permanente"
  },
  {
    code: "330053",
    paired: "330064",
    label: "Extraction dent de sagesse incluse",
    category: "Chirurgie",
    tariff: 84.24,
    patient: 16.85,
    bim: 3.40,
    tooth: true,
    description: "Extraction chirurgicale d'une dent de sagesse incluse ou semi-incluse"
  },
  {
    code: "330075",
    paired: "330086",
    label: "Extraction avec alvéolectomie",
    category: "Chirurgie",
    tariff: 126.36,
    patient: 25.27,
    bim: 5.10,
    tooth: true,
    description: "Extraction complexe avec régularisation alvéolaire"
  },
  {
    code: "330150",
    paired: "330161",
    label: "Extraction dent temporaire",
    category: "Chirurgie",
    tariff: 21.06,
    patient: 4.21,
    bim: 0.85,
    tooth: true,
    description: "Extraction d'une dent de lait"
  },

  // ENDODONTIE (TRAITEMENT DE CANAUX)
  {
    code: "314012",
    paired: "314023",
    label: "Pulpotomie/pulpectomie (urgence)",
    category: "Endodontie",
    tariff: 42.12,
    patient: 8.42,
    bim: 1.70,
    tooth: true,
    description: "Pulpotomie ou pulpectomie en traitement d'urgence"
  },
  {
    code: "325034",
    paired: "325045",
    label: "Traitement canalaire 1 canal",
    category: "Endodontie",
    tariff: 78.54,
    patient: 15.71,
    bim: 3.15,
    tooth: true,
    description: "Traitement endodontique complet d'une dent monoradiculaire"
  },
  {
    code: "325056",
    paired: "325067",
    label: "Traitement canalaire 2 canaux",
    category: "Endodontie",
    tariff: 117.81,
    patient: 23.56,
    bim: 4.70,
    tooth: true,
    description: "Traitement endodontique d'une dent à 2 canaux"
  },
  {
    code: "325070",
    paired: "325081",
    label: "Traitement canalaire 3 canaux",
    category: "Endodontie",
    tariff: 157.08,
    patient: 31.42,
    bim: 6.30,
    tooth: true,
    description: "Traitement endodontique d'une dent à 3 canaux"
  },
  {
    code: "325092",
    paired: "325103",
    label: "Traitement canalaire 4+ canaux",
    category: "Endodontie",
    tariff: 196.35,
    patient: 39.27,
    bim: 7.85,
    tooth: true,
    description: "Traitement endodontique d'une dent à 4 canaux ou plus"
  },

  // PRÉVENTION ENFANTS (<19 ANS)
  {
    code: "371615",
    paired: "371626",
    label: "Scellement fissures dent définitive <19 ans",
    category: "Prévention",
    tariff: 20.71,
    patient: 0,
    bim: 0,
    tooth: true,
    description: "Scellement préventif des fissures sur dent permanente (enfants et ados)"
  },
  {
    code: "373015",
    paired: "373026",
    label: "Application fluor topique <19 ans",
    category: "Prévention",
    tariff: 12.50,
    patient: 0,
    bim: 0,
    description: "Application de fluor topique (enfants et adolescents)"
  }
];

/**
 * Get INAMI act by code
 * @param {string} code - INAMI code (7 digits)
 * @returns {object|null} - Act object or null if not found
 */
function getINAMIActByCode(code) {
  return INAMI_ACTS.find(act => act.code === code || act.paired === code) || null;
}

/**
 * Search INAMI acts by keyword
 * @param {string} keyword - Search term
 * @returns {array} - Matching acts
 */
function searchINAMIActs(keyword) {
  const term = keyword.toLowerCase();
  return INAMI_ACTS.filter(act =>
    act.label.toLowerCase().includes(term) ||
    act.code.includes(term) ||
    act.description.toLowerCase().includes(term) ||
    act.category.toLowerCase().includes(term)
  );
}

/**
 * Calculate tariff for an INAMI act
 * @param {string} code - INAMI code
 * @param {boolean} hasBIM - Patient has BIM (Intervention Majorée) status
 * @param {number} quantity - Quantity (default 1, for quadrants etc.)
 * @returns {object} - Tariff breakdown
 */
function calculateINAMITariff(code, hasBIM = false, quantity = 1) {
  const act = getINAMIActByCode(code);
  if (!act) return null;

  const baseAmount = act.tariff * quantity;
  const patientShare = hasBIM ? (act.bim * quantity) : (act.patient * quantity);
  const mutuelleShare = baseAmount - patientShare;

  return {
    code: act.code,
    label: act.label,
    category: act.category,
    quantity: quantity,
    unit: act.unit || "acte",
    baseAmount: parseFloat(baseAmount.toFixed(2)),
    patientShare: parseFloat(patientShare.toFixed(2)),
    mutuelleShare: parseFloat(mutuelleShare.toFixed(2)),
    hasBIM: hasBIM
  };
}

// ============================================================================
// BELGIAN MEDICATIONS (CNK CODES)
// ============================================================================

/**
 * Common dental medications in Belgium with CNK codes
 * CNK = Centre National de Kodificatie
 */
const MEDICATIONS_BELGIUM = {
  // ANTIBIOTIQUES
  antibiotics: [
    {
      dci: "Amoxicilline",
      dosage: "500mg",
      form: "gélules",
      brands: ["Clamoxyl", "Flemoxin", "Amoxicilline EG"],
      cnk: "0067-407",
      indication: "Infection bactérienne dentaire",
      posology: "1 gélule 3x/jour pendant 7 jours",
      contraindications: "Allergie pénicilline"
    },
    {
      dci: "Amoxicilline/Acide clavulanique",
      dosage: "875mg/125mg",
      form: "comprimés",
      brands: ["Augmentin", "Amoxiclav"],
      cnk: "2143-716",
      indication: "Infection dentaire sévère",
      posology: "1 comprimé 2x/jour pendant 7 jours",
      contraindications: "Allergie pénicilline, insuffisance hépatique"
    },
    {
      dci: "Métronidazole",
      dosage: "500mg",
      form: "comprimés",
      brands: ["Flagyl", "Métronidazole EG"],
      cnk: "0008-656",
      indication: "Infection anaérobie, parodontite",
      posology: "1 comprimé 3x/jour pendant 7 jours",
      contraindications: "Alcool (effet antabuse), grossesse 1er trimestre"
    },
    {
      dci: "Azithromycine",
      dosage: "500mg",
      form: "comprimés",
      brands: ["Zithromax", "Azithromycine Sandoz"],
      cnk: "0535-655",
      indication: "Alternative si allergie pénicilline",
      posology: "1 comprimé/jour pendant 3 jours",
      contraindications: "Insuffisance hépatique sévère"
    },
    {
      dci: "Clindamycine",
      dosage: "300mg",
      form: "gélules",
      brands: ["Dalacin", "Clindamycine Sandoz"],
      cnk: "0023-366",
      indication: "Alternative si allergie pénicilline",
      posology: "1 gélule 3x/jour pendant 7 jours",
      contraindications: "Colite, insuffisance hépatique"
    }
  ],

  // ANALGÉSIQUES / ANTI-INFLAMMATOIRES
  painkillers: [
    {
      dci: "Ibuprofène",
      dosage: "400mg",
      form: "comprimés",
      brands: ["Brufen", "Nurofen", "Ibuprofène EG"],
      cnk: "0081-687",
      indication: "Douleur dentaire, inflammation",
      posology: "1 comprimé 3x/jour (max 1200mg/jour)",
      contraindications: "Ulcère gastrique, insuffisance rénale, grossesse 3e trimestre"
    },
    {
      dci: "Paracétamol",
      dosage: "1g",
      form: "comprimés",
      brands: ["Dafalgan", "Panadol", "Paracétamol EG"],
      cnk: "0025-538",
      indication: "Douleur légère à modérée",
      posology: "1 comprimé 3-4x/jour (max 4g/jour)",
      contraindications: "Insuffisance hépatique sévère"
    },
    {
      dci: "Diclofénac",
      dosage: "50mg",
      form: "comprimés",
      brands: ["Voltaren", "Diclofénac Sandoz"],
      cnk: "0046-144",
      indication: "Douleur post-opératoire, inflammation",
      posology: "1 comprimé 2-3x/jour",
      contraindications: "Ulcère gastrique, insuffisance cardiaque, grossesse"
    }
  ],

  // BAINS DE BOUCHE
  mouthwash: [
    {
      dci: "Chlorhexidine",
      dosage: "0.12%",
      form: "solution buccale",
      brands: ["Corsodyl", "Eludril", "Perio-Aid"],
      cnk: "0098-723",
      indication: "Antiseptique post-opératoire, gingivite",
      posology: "Rinçage 2x/jour pendant 1-2 semaines",
      contraindications: "Hypersensibilité, coloration dentaire (usage prolongé)"
    },
    {
      dci: "Hexétidine",
      dosage: "0.1%",
      form: "solution buccale",
      brands: ["Hextril", "Hexaspray"],
      cnk: "0028-522",
      indication: "Antiseptique buccal",
      posology: "Rinçage 2x/jour",
      contraindications: "Hypersensibilité"
    }
  ],

  // ANTIFONGIQUES
  antifungals: [
    {
      dci: "Miconazole",
      dosage: "20mg/g",
      form: "gel buccal",
      brands: ["Daktarin", "Loramyc"],
      cnk: "0019-992",
      indication: "Candidose buccale",
      posology: "Appliquer 4x/jour pendant 7-14 jours",
      contraindications: "Hypersensibilité, interactions médicamenteuses"
    }
  ]
};

/**
 * Search medications by DCI or brand name
 * @param {string} query - Search term
 * @returns {array} - Matching medications
 */
function searchMedications(query) {
  const term = query.toLowerCase();
  const results = [];

  Object.values(MEDICATIONS_BELGIUM).forEach(category => {
    category.forEach(med => {
      if (
        med.dci.toLowerCase().includes(term) ||
        med.brands.some(b => b.toLowerCase().includes(term)) ||
        med.indication.toLowerCase().includes(term)
      ) {
        results.push(med);
      }
    });
  });

  return results;
}

// ============================================================================
// MYCARENET STUBS (SANDBOX-READY)
// ============================================================================

/**
 * MyCareNet ConsultRN - Check patient insurance coverage (STUB)
 * @param {string} niss - Patient NISS
 * @param {string} oaCode - Mutuelle OA code
 * @param {string} date - Date of service (YYYY-MM-DD)
 * @returns {Promise<object>} - Coverage information
 */
async function checkAssurabilite(niss, oaCode, date = null) {
  console.log(`[MyCareNet ConsultRN STUB] Checking coverage for NISS: ${niss}, OA: ${oaCode}, Date: ${date || 'today'}`);

  // TODO: Replace with real MyCareNet CIN API call when certified
  // This is a STUB for MVP development

  return new Promise((resolve) => {
    setTimeout(() => {
      resolve({
        success: true,
        timestamp: new Date().toISOString(),
        request: { niss, oaCode, date: date || new Date().toISOString().split('T')[0] },
        response: {
          status: "assure",
          mutuelle: getMutuelleByCode(oaCode),
          bim: Math.random() > 0.7, // 30% of patients have BIM (realistic)
          dmg: {
            active: Math.random() > 0.5,
            doctor: Math.random() > 0.5 ? "Dr. Dubois" : null,
            inami: Math.random() > 0.5 ? "1-12345-67-890" : null
          },
          coverageActive: true,
          rights: ["AMBULATORY", "DENTAL", "HOSPITAL"],
          validUntil: "2026-12-31",
          thirdPartyPayer: true
        }
      });
    }, 800); // Simulate network delay
  });
}

/**
 * MyCareNet eAttest V3 - Send electronic attestation (STUB)
 * @param {object} attestData - Attestation data
 * @returns {Promise<object>} - eAttest response
 */
async function sendEAttest(attestData) {
  console.log('[MyCareNet eAttest V3 STUB] Sending attestation:', attestData);

  // Generate realistic XML structure (for testing)
  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<eAttest version="3.0" xmlns="http://www.mycarenet.be/eattest">
  <header>
    <sender>${PRESCRIPTEUR.inami}</sender>
    <recipient>MyCareNet</recipient>
    <timestamp>${new Date().toISOString()}</timestamp>
  </header>
  <body>
    <patient>
      <niss>${attestData.patientNISS}</niss>
      <mutuelle>${attestData.mutuelleCode}</mutuelle>
    </patient>
    <acts>
      ${attestData.acts.map(act => `
      <act>
        <code>${act.code}</code>
        <date>${act.date}</date>
        <quantity>${act.quantity || 1}</quantity>
        <amount>${act.amount}</amount>
        <tooth>${act.tooth || ''}</tooth>
      </act>`).join('')}
    </acts>
    <provider>
      <inami>${PRESCRIPTEUR.inami}</inami>
      <name>${PRESCRIPTEUR.name}</name>
    </provider>
  </body>
</eAttest>`;

  console.log('[eAttest XML]:', xml);

  // TODO: Replace with real MyCareNet CIN API call
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve({
        success: true,
        timestamp: new Date().toISOString(),
        reference: `EA-${Date.now()}-${Math.random().toString(36).substring(7).toUpperCase()}`,
        status: "ACCEPTED",
        message: "Attestation acceptée (STUB - sandbox mode)",
        xml: xml
      });
    }, 1200);
  });
}

/**
 * MyCareNet eFact - Send invoice for third-party payer (STUB)
 * @param {object} factData - Invoice data
 * @returns {Promise<object>} - eFact response
 */
async function sendEFact(factData) {
  console.log('[MyCareNet eFact STUB] Sending invoice for tiers payant:', factData);

  // TODO: Replace with real MyCareNet CIN API call
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve({
        success: true,
        timestamp: new Date().toISOString(),
        reference: `EF-${Date.now()}-${Math.random().toString(36).substring(7).toUpperCase()}`,
        status: "PENDING",
        message: "Facture envoyée (STUB - sandbox mode)",
        estimatedPayment: "15-30 jours"
      });
    }, 1000);
  });
}

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/**
 * Format currency to Belgian format (€XX.XX)
 * @param {number} amount - Amount in euros
 * @returns {string} - Formatted currency
 */
function formatCurrency(amount) {
  return new Intl.NumberFormat('fr-BE', {
    style: 'currency',
    currency: 'EUR'
  }).format(amount);
}

/**
 * Format date to Belgian format (DD/MM/YYYY)
 * @param {string|Date} date - Date to format
 * @returns {string} - Formatted date
 */
function formatDateBE(date) {
  const d = new Date(date);
  return new Intl.DateTimeFormat('fr-BE').format(d);
}

/**
 * Calculate age from date of birth
 * @param {string} dob - Date of birth (YYYY-MM-DD)
 * @returns {number} - Age in years
 */
function calculateAge(dob) {
  const birthDate = new Date(dob);
  const today = new Date();
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();

  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }

  return age;
}

// ============================================================================
// EXPORTS (for module usage)
// ============================================================================

// Make functions globally available
if (typeof window !== 'undefined') {
  window.BelgiumUtils = {
    // NISS
    validateNISS,
    formatNISS,

    // Mutuelles
    MUTUELLES,
    getMutuelleByCode,

    // Prescripteur
    PRESCRIPTEUR,

    // INAMI
    INAMI_ACTS,
    getINAMIActByCode,
    searchINAMIActs,
    calculateINAMITariff,

    // Medications
    MEDICATIONS_BELGIUM,
    searchMedications,

    // MyCareNet
    checkAssurabilite,
    sendEAttest,
    sendEFact,

    // Utilities
    formatCurrency,
    formatDateBE,
    calculateAge
  };
}

console.log('✅ Belgium Compliance Utilities loaded - K2 Dent v1.0');

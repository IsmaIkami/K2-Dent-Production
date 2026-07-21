/**
 * K2 DENT — AI DENTAL ASSISTANT
 * Claude API integration for AI-powered clinical workflows
 * Anamnesis generation, prescription suggestions, diagnosis support
 *
 * @author Ismail Sialyen
 * @date April 2026
 * @version 1.0.0
 * @powered-by AI Technology
 */

// ============================================================================
// CONFIGURATION
// ============================================================================

/**
 * Get backend URL from config.js or fallback to localhost
 * Config is loaded from config.js which must be included before this script
 */
function getBackendUrl() {
  // Check if K2_API is defined from config.js
  if (typeof window.K2_API !== 'undefined') {
    return {
      anamnesis: window.K2_API.ANAMNESIS,
      prescription: window.K2_API.PRESCRIPTION,
      health: window.K2_API.HEALTH
    };
  }

  // Fallback for backward compatibility
  console.warn('[K2 Dent] config.js not loaded, using fallback backend URL');
  return {
    anamnesis: 'http://localhost:3000/api/ai/anamnesis',
    prescription: 'http://localhost:3000/api/ai/prescription',
    health: 'http://localhost:3000/health'
  };
}

const AI_CONFIG = {
  model: 'claude-sonnet-4-20250514',
  maxTokens: {
    anamnesis: 1500,
    prescriptions: 1200,
    diagnosis: 1000
  },
  temperature: 0.3 // Low temperature for medical accuracy
};

/**
 * NOTE: API key is now stored securely in the backend
 * No need to prompt user or store in localStorage anymore
 * The backend handles authentication with Anthropic API
 */

// ============================================================================
// AI ANAMNESIS GENERATION
// ============================================================================

/**
 * Generate professional dental anamnesis using Claude AI
 * @param {object} patientData - Patient information
 * @param {string} transcription - Voice recording transcription
 * @returns {Promise<string>} - Generated anamnesis (markdown format)
 */
async function generateAnamnesis(patientData, transcription = '') {
  const systemPrompt = `Tu es l'assistant IA du cabinet dentaire de Dr. Ekaterina SIALYEN, Dentiste Généraliste, INAMI 3-02462-81-001, à Zaventem (Belgique).

**MISSION:**
Génère une anamnèse médicale dentaire professionnelle structurée en français, conforme aux standards belges de documentation médicale.

**FORMAT OBLIGATOIRE (Markdown):**

## 📋 Motif de consultation
[Raison principale de la visite, symptômes rapportés]

## 🏥 Anamnèse médicale générale
- Antécédents médicaux pertinents
- Maladies chroniques (diabète, HTA, etc.)
- Hospitalisations récentes
- Statut fumeur/alcool

## 💊 Médications actuelles
[Liste des médicaments avec posologie si connue]

## ⚠️ Allergies et contre-indications
[Allergies médicamenteuses, latex, etc.]

## 🔍 Examen clinique
[Observations cliniques - à compléter par Dr. Sialyen lors de l'examen]
- Examen extra-oral:
- Examen intra-oral:
- État parodontal:
- Hygiène bucco-dentaire:

## 🎯 Diagnostic présomptif
[Diagnostic basé sur l'anamnèse et les symptômes - à confirmer par Dr. Sialyen]

## 📝 Plan de traitement proposé
[Traitements suggérés avec codes INAMI si applicable]
1. Traitement immédiat:
2. Traitement à moyen terme:
3. Suivi recommandé:

## 💡 Actes INAMI suggérés
[Codes de nomenclature Article 5 pertinents]
- [Code INAMI] - [Description]

---

**⚠️ AVERTISSEMENT MÉDICO-LÉGAL:**
Ce document est généré par IA comme aide à la décision clinique.
Tout diagnostic final, prescription et plan de traitement relèvent de la responsabilité exclusive de Dr. Ekaterina SIALYEN.
Document à valider et signer par le praticien.

**STYLE:**
- Français médical professionnel (pas familier)
- Phrases courtes et précises
- Utiliser terminologie dentaire exacte
- Factuel et objectif
- Basé uniquement sur les informations fournies (pas d'invention)

**CONTRAINTES BELGES:**
- Codes INAMI Article 5 (dentaire)
- Mutuelle et BIM mentionnés si pertinents pour remboursement
- Conformité RGPD (pas de données sensibles inutiles)`;

  const userPrompt = `**DONNÉES PATIENT:**
Nom: ${patientData.name || 'Non renseigné'}
Âge: ${patientData.age || 'Non renseigné'} ans
NISS: ${patientData.niss || 'Non renseigné'}
Mutuelle: ${patientData.mutuelle ? `${patientData.mutuelle} (OA: ${patientData.mutuelleCode})` : 'Non renseignée'}
Statut BIM: ${patientData.bim ? 'Oui (intervention majorée)' : 'Non'}
Langue: ${patientData.language || 'FR'}

**INFORMATIONS MÉDICALES:**
Allergies: ${patientData.allergies || 'Aucune allergie connue'}
Médications actuelles: ${patientData.medications || 'Aucune médication déclarée'}
Conditions médicales: ${patientData.conditions || 'Aucune condition déclarée'}
Antécédents dentaires: ${patientData.dentalHistory || 'Pas d\'historique disponible'}

**TRANSCRIPTION CONSULTATION:**
${transcription || 'Pas de transcription vocale disponible. Générer anamnèse basée sur les données patient ci-dessus.'}

**INSTRUCTION:**
Génère l'anamnèse complète en suivant le format imposé.
Si certaines informations manquent, indique "[À compléter par Dr. Sialyen]".`;

  try {
    const backendUrl = getBackendUrl();

    const response = await fetch(backendUrl.anamnesis, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        patientData: patientData,
        transcription: transcription,
        systemPrompt: systemPrompt,
        maxTokens: AI_CONFIG.maxTokens.anamnesis
      })
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(`Backend Error: ${error.error || response.statusText}`);
    }

    const data = await response.json();

    if (!data.success) {
      throw new Error(data.error || 'Unknown error from backend');
    }

    const anamnesis = data.content;

    // Log for debugging
    console.log('[AI Anamnesis] Generated successfully via backend:', {
      patient: patientData.name,
      length: anamnesis.length,
      backend: backendUrl.anamnesis
    });

    return anamnesis;

  } catch (error) {
    console.error('[AI Anamnesis] Error:', error);
    showNotification(`❌ Erreur IA: ${error.message}`, 'error');
    throw error;
  }
}

// ============================================================================
// AI PRESCRIPTION SUGGESTIONS
// ============================================================================

/**
 * Generate prescription suggestions using Claude AI
 * @param {object} patientData - Patient information
 * @param {string} anamnesis - Generated anamnesis
 * @returns {Promise<string>} - Prescription suggestions (markdown format)
 */
async function generatePrescriptions(patientData, anamnesis) {
  const systemPrompt = `Tu es l'assistant de prescription du cabinet dentaire de Dr. Ekaterina SIALYEN, Dentiste Généraliste, INAMI 3-02462-81-001 (Belgique).

**MISSION:**
Génère des SUGGESTIONS de prescriptions médicamenteuses dentaires pour la Belgique uniquement.

**FORMAT OBLIGATOIRE pour chaque médicament:**

### 💊 [NOM DCI] — [Spécialité belge]
**CNK:** [Code CNK belge]
**Forme:** [Gélules/Comprimés/Solution/Gel]
**Posologie:** [dose] × [fréquence] pendant [durée]
**Indication:** [Pourquoi ce médicament]
**⚠️ Vérifier:** [Contre-indication vs allergies/interactions patient]
**Remboursement:** [Remboursé / Non remboursé]

---

**CONTRAINTES STRICTES:**
1. UNIQUEMENT médicaments avec AMM (Autorisation de Mise sur le Marché) belge
2. TOUJOURS inclure code CNK (Centre National de Kodificatie)
3. Format compatible Recip-e (prescription électronique)
4. Respecter le répertoire CBIP belge (Centre Belge d'Information Pharmacothérapeutique)
5. VÉRIFIER allergies patient (CRITIQUE - pénicilline, etc.)
6. VÉRIFIER interactions médicamenteuses avec traitements en cours
7. Posologies conformes aux recommandations belges

**MÉDICAMENTS DENTAIRES COURANTS EN BELGIQUE:**

**Antibiotiques:**
- Amoxicilline 500mg (Clamoxyl, Flemoxin) CNK: 0067-407
- Amoxicilline/Acide clavulanique 875/125mg (Augmentin) CNK: 2143-716
- Métronidazole 500mg (Flagyl) CNK: 0008-656
- Azithromycine 500mg (Zithromax) CNK: 0535-655 — si allergie pénicilline
- Clindamycine 300mg (Dalacin) CNK: 0023-366 — si allergie pénicilline

**Analgésiques/Anti-inflammatoires:**
- Ibuprofène 400mg (Brufen, Nurofen) CNK: 0081-687
- Paracétamol 1g (Dafalgan, Panadol) CNK: 0025-538
- Diclofénac 50mg (Voltaren) CNK: 0046-144

**Bains de bouche:**
- Chlorhexidine 0.12% (Corsodyl, Eludril) CNK: 0098-723
- Hexétidine (Hextril) CNK: 0028-522

**Antifongiques:**
- Miconazole gel 20mg/g (Daktarin) CNK: 0019-992

**AVERTISSEMENT LÉGAL OBLIGATOIRE (à la fin):**

---

⚠️⚠️ **AVERTISSEMENT MÉDICO-LÉGAL CRITIQUE** ⚠️⚠️

Ces suggestions sont générées par Intelligence Artificielle à titre INDICATIF uniquement.

**Elles DOIVENT OBLIGATOIREMENT être:**
1. ✅ Validées par Dr. Ekaterina SIALYEN
2. ✅ Modifiées si nécessaire selon jugement clinique
3. ✅ Signées par le praticien avant délivrance au patient
4. ✅ Vérifiées vs allergies et interactions (responsabilité du prescripteur)

**RESPONSABILITÉ EXCLUSIVE du médecin prescripteur.**
**L'IA ne remplace PAS le jugement clinique.**
**En cas de doute, consulter le CBIP (www.cbip.be) ou le répertoire Recip-e.**

---

**STYLE:**
- Précis et factuel
- Langage médical professionnel
- Pas d'approximations (doses exactes)
- Indiquer durée minimale et maximale si variable`;

  const userPrompt = `**PATIENT:**
Nom: ${patientData.name}
Âge: ${patientData.age} ans
Poids: ${patientData.weight || 'Non renseigné'} kg

**ALLERGIES CRITIQUES:**
${patientData.allergies || 'Aucune allergie connue'}

**MÉDICATIONS EN COURS:**
${patientData.medications || 'Aucune médication'}

**CONDITIONS MÉDICALES:**
${patientData.conditions || 'Aucune condition déclarée'}

**ANAMNÈSE ET DIAGNOSTIC:**
${anamnesis}

**INSTRUCTION:**
Génère les suggestions de prescriptions appropriées pour ce cas clinique.
Si allergie pénicilline → alternatives obligatoires (azithromycine, clindamycine).
Si patient BIM → privilégier médicaments remboursés.
Si patient ≥65 ans → adapter posologies (insuffisance rénale potentielle).`;

  try {
    const backendUrl = getBackendUrl();

    const response = await fetch(backendUrl.prescription, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        patientData: patientData,
        anamnesis: anamnesis,
        systemPrompt: systemPrompt,
        maxTokens: AI_CONFIG.maxTokens.prescriptions
      })
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(`Backend Error: ${error.error || response.statusText}`);
    }

    const data = await response.json();

    if (!data.success) {
      throw new Error(data.error || 'Unknown error from backend');
    }

    const prescriptions = data.content;

    console.log('[AI Prescriptions] Generated successfully via backend:', {
      patient: patientData.name,
      length: prescriptions.length,
      backend: backendUrl.prescription
    });

    return prescriptions;

  } catch (error) {
    console.error('[AI Prescriptions] Error:', error);
    showNotification(`❌ Erreur IA Prescriptions: ${error.message}`, 'error');
    throw error;
  }
}

// ============================================================================
// VERSION HISTORY MANAGEMENT
// ============================================================================

/**
 * Save anamnesis version to localStorage
 * @param {string} patientNISS - Patient NISS (unique identifier)
 * @param {string} content - Anamnesis content
 * @param {string} type - 'AI' or 'MODIFIED'
 * @returns {object} - Saved version info
 */
function saveAnamnesisVersion(patientNISS, content, type = 'AI') {
  const key = `k2dent_anamnesis_${patientNISS.replace(/[.\-\s]/g, '')}`;
  const history = JSON.parse(localStorage.getItem(key) || '[]');

  const version = {
    id: `v${history.length + 1}`,
    version: history.length + 1,
    content: content,
    timestamp: new Date().toISOString(),
    author: type === 'AI' ? 'Dr. Ismail Sialyen (IA)' : 'Dr. Ismail Sialyen',
    type: type, // 'AI' or 'MODIFIED'
    wordCount: content.split(/\s+/).length,
    charCount: content.length
  };

  history.unshift(version);

  // Keep max 20 versions
  const trimmedHistory = history.slice(0, 20);
  localStorage.setItem(key, JSON.stringify(trimmedHistory));

  console.log('[Anamnesis History] Saved version:', {
    patient: patientNISS,
    version: version.version,
    type: version.type
  });

  return version;
}

/**
 * Get anamnesis history for a patient
 * @param {string} patientNISS - Patient NISS
 * @returns {array} - Version history
 */
function getAnamnesisHistory(patientNISS) {
  const key = `k2dent_anamnesis_${patientNISS.replace(/[.\-\s]/g, '')}`;
  return JSON.parse(localStorage.getItem(key) || '[]');
}

/**
 * Get latest anamnesis for a patient
 * @param {string} patientNISS - Patient NISS
 * @returns {object|null} - Latest version or null
 */
function getLatestAnamnesis(patientNISS) {
  const history = getAnamnesisHistory(patientNISS);
  return history.length > 0 ? history[0] : null;
}

// ============================================================================
// PRESCRIPTION HISTORY MANAGEMENT
// ============================================================================

/**
 * Save prescription suggestions to localStorage
 * @param {string} patientNISS - Patient NISS
 * @param {string} content - Prescription content
 * @param {array} validatedMeds - List of validated medications
 * @returns {object} - Saved prescription info
 */
function savePrescriptionSuggestion(patientNISS, content, validatedMeds = []) {
  const key = `k2dent_prescriptions_${patientNISS.replace(/[.\-\s]/g, '')}`;
  const history = JSON.parse(localStorage.getItem(key) || '[]');

  const prescription = {
    id: `px${Date.now()}`,
    content: content,
    timestamp: new Date().toISOString(),
    status: validatedMeds.length > 0 ? 'VALIDATED' : 'PENDING',
    validatedMeds: validatedMeds,
    validatedBy: validatedMeds.length > 0 ? 'Dr. E. Sialyen' : null,
    validatedAt: validatedMeds.length > 0 ? new Date().toISOString() : null
  };

  history.unshift(prescription);
  localStorage.setItem(key, JSON.stringify(history.slice(0, 10))); // Keep 10 prescriptions

  return prescription;
}

// ============================================================================
// UI HELPER FUNCTIONS
// ============================================================================

/**
 * Show notification toast
 * @param {string} message - Message to display
 * @param {string} type - 'success', 'error', 'warning', 'info'
 */
function showNotification(message, type = 'info') {
  // Check if notifications container exists
  let container = document.getElementById('ai-notifications');

  if (!container) {
    container = document.createElement('div');
    container.id = 'ai-notifications';
    container.style.cssText = `
      position: fixed;
      top: 20px;
      right: 20px;
      z-index: 10000;
      display: flex;
      flex-direction: column;
      gap: 10px;
    `;
    document.body.appendChild(container);
  }

  const colors = {
    success: '#34C759',
    error: '#FF3B30',
    warning: '#FF9500',
    info: '#0066FF'
  };

  const notification = document.createElement('div');
  notification.style.cssText = `
    background: ${colors[type] || colors.info};
    color: white;
    padding: 16px 20px;
    border-radius: 12px;
    box-shadow: 0 8px 32px rgba(0,0,0,0.3);
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    font-size: 14px;
    font-weight: 500;
    max-width: 400px;
    animation: slideIn 0.3s ease-out;
  `;

  notification.textContent = message;
  container.appendChild(notification);

  // Auto-remove after 5 seconds
  setTimeout(() => {
    notification.style.animation = 'slideOut 0.3s ease-in';
    setTimeout(() => notification.remove(), 300);
  }, 5000);
}

/**
 * Show loading spinner
 * @param {string} elementId - ID of element to show spinner in
 * @param {string} message - Loading message
 */
function showAILoading(elementId, message = 'IA en cours de génération...') {
  const element = document.getElementById(elementId);
  if (!element) return;

  element.innerHTML = `
    <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 40px; gap: 16px;">
      <div style="width: 48px; height: 48px; border: 4px solid #E5E7EB; border-top-color: #0066FF; border-radius: 50%; animation: spin 1s linear infinite;"></div>
      <p style="color: var(--text-secondary); font-size: 14px;">${message}</p>
    </div>
  `;
}

/**
 * Render anamnesis with markdown styling
 * @param {string} markdown - Markdown content
 * @returns {string} - HTML
 */
function renderMarkdownAnamnesis(markdown) {
  // Simple markdown parser for anamnesis
  let html = markdown
    .replace(/^## (.+)$/gm, '<h3 style="color: var(--primary); margin: 24px 0 12px 0; font-size: 16px; font-weight: 600;">$1</h3>')
    .replace(/^### (.+)$/gm, '<h4 style="color: var(--text-primary); margin: 16px 0 8px 0; font-size: 14px; font-weight: 600;">$1</h4>')
    .replace(/^\*\*(.+)\*\*$/gm, '<strong style="color: var(--text-primary);">$1</strong>')
    .replace(/^\- (.+)$/gm, '<li style="margin-left: 20px; color: var(--text-primary);">$1</li>')
    .replace(/^(\d+)\. (.+)$/gm, '<li style="margin-left: 20px; color: var(--text-primary); list-style-type: decimal;">$2</li>')
    .replace(/\n\n/g, '<br><br>')
    .replace(/⚠️/g, '<span style="color: #FF9500;">⚠️</span>')
    .replace(/✅/g, '<span style="color: #34C759;">✅</span>');

  return `<div style="line-height: 1.6; color: var(--text-primary);">${html}</div>`;
}

// ============================================================================
// KEYBOARD SHORTCUTS
// ============================================================================

// Add CSS animation for notifications
const style = document.createElement('style');
style.textContent = `
  @keyframes spin {
    to { transform: rotate(360deg); }
  }

  @keyframes slideIn {
    from {
      transform: translateX(400px);
      opacity: 0;
    }
    to {
      transform: translateX(0);
      opacity: 1;
    }
  }

  @keyframes slideOut {
    from {
      transform: translateX(0);
      opacity: 1;
    }
    to {
      transform: translateX(400px);
      opacity: 0;
    }
  }
`;
document.head.appendChild(style);

// ============================================================================
// EXPORTS
// ============================================================================

if (typeof window !== 'undefined') {
  window.AI_Dental = {
    // Main functions
    generateAnamnesis,
    generatePrescriptions,

    // History management
    saveAnamnesisVersion,
    getAnamnesisHistory,
    getLatestAnamnesis,
    savePrescriptionSuggestion,

    // UI helpers
    showNotification,
    showAILoading,
    renderMarkdownAnamnesis,

    // Config
    getAnthropicAPIKey,
    AI_CONFIG
  };
}

console.log('✅ AI Dental Assistant loaded - Powered by Claude Sonnet 4.5');

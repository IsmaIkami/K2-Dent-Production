# 🔧 Configuration Supabase - Référence

**Date de création:** 2026-07-22
**Objectif:** Documenter les bonnes credentials Supabase pour éviter les erreurs dans les sessions futures

---

## ✅ Credentials CORRECTES (Production)

```javascript
SUPABASE_URL: 'https://sqgxscrwcffjfomlsoyf.supabase.co'
SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNxZ3hzY3J3Y2ZmamZvbWxzb3lmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ2NTE2NjMsImV4cCI6MjEwMDIyNzY2M30.TtLYJKBM7XxrdsHiHS9EGOxnyniSdAhBLPUkhpReidU'
```

**Projet Supabase:** `sqgxscrwcffjfomlsoyf`

---

## 📂 Fichiers de Configuration

### Fichier principal
**`/frontend/config.js`** - Configuration centrale avec environnements dev/prod

```javascript
const CONFIG = {
  development: { ... },
  production: {
    BACKEND_URL: 'https://k2-dent-production-production.up.railway.app',
    SUPABASE_URL: 'https://sqgxscrwcffjfomlsoyf.supabase.co',
    SUPABASE_ANON_KEY: '...',
    FRONTEND_URL: 'https://ismaikami.github.io/K2-Dent-Production'
  }
};
```

### Fichier secondaire (pour calendar.html)
**`/frontend/js/config.js`** - Configuration simplifiée pour le module agenda

```javascript
window.K2_CONFIG = {
    SUPABASE_URL: 'https://sqgxscrwcffjfomlsoyf.supabase.co',
    SUPABASE_ANON_KEY: '...',
    DEMO_MODE: false,
    APP_NAME: 'K2 DENT',
    APP_VERSION: '1.0.0',
    ENABLE_AI_SUGGESTIONS: true,
    ENABLE_REMINDERS: true,
    DEBUG: true
};
```

---

## ⚠️ Erreurs Passées à Éviter

### ❌ URL INVALIDE (ne jamais utiliser)
```
https://iibdamkqxmyyvxsijsgc.supabase.co
```

**Symptôme:**
```
[Error] Failed to load resource: A server with the specified hostname could not be found.
[Error] Fetch API cannot load https://iibdamkqxmyyvxsijsgc.supabase.co/...
```

**Cause:** DNS resolution failure - ce projet Supabase n'existe pas.

---

## 🔍 Comment Vérifier les Credentials

### 1. Dans le codebase
```bash
# Chercher l'URL Supabase correcte
grep -r "sqgxscrwcffjfomlsoyf" frontend/

# Résultat attendu:
frontend/config.js:    SUPABASE_URL: 'https://sqgxscrwcffjfomlsoyf.supabase.co',
frontend/js/config.js:    SUPABASE_URL: 'https://sqgxscrwcffjfomlsoyf.supabase.co',
```

### 2. Test de connexion
```javascript
// Dans la console du navigateur
console.log(window.K2_CONFIG.SUPABASE_URL);
// Devrait afficher: https://sqgxscrwcffjfomlsoyf.supabase.co

// Tester la connexion
await window.supabaseClient.from('patients').select('*', { count: 'exact', head: true });
// Devrait retourner { count: X, error: null }
```

### 3. Via Supabase Dashboard
- URL: https://supabase.com/dashboard/project/sqgxscrwcffjfomlsoyf
- Settings → API → Project URL
- Settings → API → Project API keys → anon/public

---

## 📊 Tables Supabase Existantes

Le projet K2 Dent utilise les tables suivantes:

1. **`patients`** - Données des patients
   - Colonnes: id, niss, first_name, last_name, birth_date, gender, phone, email, etc.

2. **`appointments`** - Rendez-vous
   - Colonnes: id, patient_id, appointment_date, start_time, end_time, type, status, etc.

3. **`medical_history`** - Historique médical avec versioning
   - Colonnes: id, patient_id, version, blood_type, allergies, medications, etc.

4. **`appointment_reminders`** - Rappels IA automatiques
   - Colonnes: id, appointment_id, patient_id, reminder_type, status, ai_score, etc.

5. **`reminder_ai_config`** - Configuration IA des rappels

6. **`inami_acts`** - Actes INAMI pour facturation

---

## 🚀 Initialisation dans une Nouvelle Session

Si vous commencez une nouvelle session Claude Code:

1. **Lire ce fichier en premier** pour connaître les bonnes credentials
2. **Chercher dans le codebase** avant de créer de nouvelles config:
   ```bash
   grep -r "SUPABASE_URL" frontend/
   ```
3. **Utiliser les credentials existantes** - ne JAMAIS inventer de nouvelles URLs
4. **Vérifier le DEMO_MODE** - doit être `false` pour la production
5. **Tester la connexion** avant d'effectuer des modifications

---

## 📝 Cache Busting

Lorsque vous modifiez les fichiers de configuration, TOUJOURS incrémenter la version:

```html
<!-- Avant -->
<script src="js/config.js?v=3"></script>

<!-- Après modification -->
<script src="js/config.js?v=4"></script>
```

Cela force le navigateur à recharger le fichier au lieu d'utiliser la version en cache.

---

## ✅ Checklist de Débogage

Si les patients ne se chargent pas:

- [ ] Vérifier que `SUPABASE_URL` = `https://sqgxscrwcffjfomlsoyf.supabase.co`
- [ ] Vérifier que `DEMO_MODE` = `false`
- [ ] Vérifier la console pour erreurs de connexion
- [ ] Tester `window.supabaseClient` dans la console
- [ ] Vérifier que le CDN Supabase est chargé:
  ```html
  <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
  ```
- [ ] Incrémenter la version cache (`?v=X`)
- [ ] Hard refresh du navigateur (Cmd+Shift+R sur Mac, Ctrl+Shift+R sur Windows)

---

**Dernière mise à jour:** 2026-07-22 - Fix credentials dans js/config.js (commit ce51516)

# 🔐 Configuration Google OAuth 2.0 / OIDC

**Objectif:** Permettre la création rapide de patients via authentification Google (Sign in with Google)

**Use Case:** Remplissage automatique des informations patient (nom, prénom, email) depuis un compte Google

---

## 📋 Prérequis

- Compte Google Cloud Platform
- Domaine vérifié (production) ou localhost (développement)
- Accès administrateur au projet K2 Dent

---

## 🚀 Configuration Google Cloud Console

### Étape 1: Créer un Projet Google Cloud

1. Accéder à [Google Cloud Console](https://console.cloud.google.com)
2. Cliquer sur **"Select a project"** → **"New Project"**
3. Nom du projet: `K2-Dental-Cockpit-Pro`
4. Cliquer sur **"Create"**

### Étape 2: Activer Google Identity Services API

1. Dans le projet créé, aller à **"APIs & Services"** → **"Library"**
2. Chercher: `Google Identity Services API`
3. Cliquer sur **"Enable"**

### Étape 3: Créer OAuth 2.0 Client ID

1. Aller à **"APIs & Services"** → **"Credentials"**
2. Cliquer sur **"Create Credentials"** → **"OAuth client ID"**
3. Type d'application: **Web application**
4. Nom: `K2 Dental Patient Creation`

5. **Authorized JavaScript origins** (ajouter les URLs):
   ```
   Development:
   http://localhost:8765
   http://127.0.0.1:8765

   Production:
   https://ismaikami.github.io
   https://k2dent.be (si domaine custom)
   ```

6. **Authorized redirect URIs** (ajouter les URLs):
   ```
   Development:
   http://localhost:8765/frontend/patients.html

   Production:
   https://ismaikami.github.io/K2-Dent-Production/frontend/patients.html
   https://k2dent.be/frontend/patients.html (si domaine custom)
   ```

7. Cliquer sur **"Create"**

8. **Copier le Client ID** (format: `123456789-abcdefg.apps.googleusercontent.com`)

### Étape 4: Configurer OAuth Consent Screen

1. Aller à **"APIs & Services"** → **"OAuth consent screen"**
2. Type d'utilisateur: **External** (ou Internal si Google Workspace)
3. Remplir les informations:
   - **App name**: K2 DentalCockpit Pro
   - **User support email**: votre@email.com
   - **Developer contact**: votre@email.com
   - **App logo**: (optionnel - logo K2)

4. **Scopes** requis:
   ```
   openid
   profile
   email
   ```

5. Ajouter des **Test users** (en mode développement):
   - Votre compte Google
   - Comptes de test

6. Cliquer sur **"Save and Continue"**

---

## 💻 Intégration dans K2 Dent

### Étape 5: Activer le Script Google Identity

Dans `frontend/patients.html`, décommenter la ligne suivante:

```html
<!-- AVANT (commenté) -->
<!--
<script src="https://accounts.google.com/gsi/client" async defer></script>
-->

<!-- APRÈS (décommenté) -->
<script src="https://accounts.google.com/gsi/client" async defer></script>
```

### Étape 6: Remplacer le Client ID

Dans `frontend/patients.html`, chercher la fonction `fillFromGoogle()` et remplacer:

```javascript
// AVANT
client_id: 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com',

// APRÈS (remplacer par votre vrai Client ID)
client_id: '123456789-abcdefg.apps.googleusercontent.com',
```

---

## 🧪 Test de l'Intégration

### Mode Développement (Localhost)

1. Lancer le serveur local:
   ```bash
   cd K2-Dent-Production
   python3 -m http.server 8765
   ```

2. Ouvrir dans le navigateur:
   ```
   http://localhost:8765/frontend/patients.html
   ```

3. Cliquer sur **"➕"** (Nouveau Patient)
4. Cliquer sur le bouton **"Compte Google"** (avec logo G coloré)
5. Se connecter avec un compte Google de test
6. Vérifier que le formulaire se remplit automatiquement:
   - Prénom
   - Nom
   - Email

7. Compléter manuellement:
   - NISS (obligatoire)
   - Date de naissance (obligatoire)
   - Genre (obligatoire)

8. Créer le patient

### Mode Production (GitHub Pages)

1. Commit et push des changements:
   ```bash
   git add frontend/patients.html
   git commit -m "feat: Enable Google OIDC for patient creation"
   git push origin main
   ```

2. Attendre le déploiement GitHub Pages (2-5 min)

3. Tester sur:
   ```
   https://ismaikami.github.io/K2-Dent-Production/frontend/patients.html
   ```

---

## 🔍 Débogage

### Vérifier que Google Identity est chargé

Ouvrir la console développeur (F12) et taper:

```javascript
console.log(typeof google !== 'undefined' ? '✅ Google Identity loaded' : '❌ Not loaded');
```

### Tester l'appel OAuth 2.0

Dans la console:

```javascript
fillFromGoogle();
```

### Erreurs Courantes

| Erreur | Solution |
|--------|----------|
| `google is not defined` | Script Google Identity non chargé → vérifier <head> |
| `Invalid origin` | Ajouter l'URL aux "Authorized JavaScript origins" |
| `Redirect URI mismatch` | Ajouter l'URL exacte aux "Authorized redirect URIs" |
| `Access blocked: This app's request is invalid` | Configurer OAuth Consent Screen |
| `idpiframe_initialization_failed` | Vérifier cookies tiers autorisés |

---

## 📊 Données Récupérées depuis Google

| Champ | Source Google API | Remplissage Auto |
|-------|-------------------|------------------|
| **Prénom** | `given_name` | ✅ Oui |
| **Nom** | `family_name` | ✅ Oui |
| **Email** | `email` | ✅ Oui |
| **Photo** | `picture` | ⚠️ Non utilisé (future feature) |
| **NISS** | - | ❌ Manuel requis |
| **Date naissance** | - | ❌ Manuel requis |
| **Genre** | - | ❌ Manuel requis |
| **Adresse** | - | ❌ Manuel requis |
| **Téléphone** | - | ❌ Manuel requis |
| **Mutuelle** | - | ❌ Manuel requis |

---

## 🔒 Sécurité & RGPD

### Consentement Utilisateur

✅ L'utilisateur doit explicitement:
1. Cliquer sur "Compte Google"
2. Accepter les permissions OAuth
3. Autoriser l'accès aux données (nom, email)

### Stockage des Données

- ✅ **Access Token**: Stocké temporairement en mémoire uniquement
- ✅ **User Info**: Utilisé pour pré-remplir le formulaire, puis oublié
- ✅ **Pas de cookies Google persistants** dans K2 Dent
- ✅ Données patient stockées dans Supabase (conformément RGPD)

### Scope Minimal

Seules les permissions minimales sont demandées:
```
openid      → Authentification de base
profile     → Nom et prénom
email       → Adresse email
```

**PAS** demandé:
- Contacts Google
- Google Drive
- Gmail
- Calendrier

---

## 📈 Avantages de Google OIDC

| Avantage | Description |
|----------|-------------|
| ⚡ **Rapidité** | Création patient en 10 secondes (vs 2 min manuellement) |
| ✅ **Précision** | Pas de fautes de frappe dans nom/email |
| 🔐 **Sécurité** | OAuth 2.0 standard, pas de stockage de mot de passe |
| 📱 **Mobile-friendly** | Fonctionne sur smartphone/tablette |
| 🌍 **Universel** | 2+ milliards d'utilisateurs Google |

---

## 🛣️ Roadmap

### Phase 1: MVP (Current)
- ✅ Authentification Google
- ✅ Remplissage nom + email
- ✅ Mode démo (données test)

### Phase 2: Enhanced (Q2 2026)
- [ ] Récupération photo profil Google
- [ ] Sauvegarde Google ID pour future réauth
- [ ] Suggestion automatique genre (via prénom)

### Phase 3: Advanced (Q3 2026)
- [ ] Synchronisation contacts Google
- [ ] Import multiple patients depuis Google Contacts
- [ ] Google Calendar integration (rendez-vous)

---

## 📚 Documentation Officielle

- [Google Identity Services](https://developers.google.com/identity/gsi/web/guides/overview)
- [OAuth 2.0 for Web](https://developers.google.com/identity/protocols/oauth2)
- [User Info API](https://developers.google.com/identity/protocols/oauth2/openid-connect#obtainuserinfo)

---

## ✅ Checklist Finale

Avant mise en production:

- [ ] Google Cloud Project créé
- [ ] OAuth Client ID créé
- [ ] Authorized origins configurés
- [ ] Script Google Identity décommenté
- [ ] Client ID remplacé dans le code
- [ ] Test en localhost réussi
- [ ] Test en production réussi
- [ ] Consentement RGPD ajouté (si requis)
- [ ] Documentation utilisateur mise à jour

---

**Auteur:** Ismail Sialyen
**Date:** 2026-07-24
**Stack:** Google Identity Services + OAuth 2.0 + K2 DentalCockpit Pro
**Status:** Configuration requise

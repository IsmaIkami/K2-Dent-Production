# 🚀 K2 DENT - GUIDE DE DÉPLOIEMENT PRODUCTION

## 📋 PRÉ-REQUIS

✅ **Déjà fait:**
- Backend configuré avec npm
- Structure projet prête
- Schéma SQL Supabase prêt
- GitHub Actions configuré

⏳ **À faire:**
- [ ] Compléter `.env` avec clés API
- [ ] Créer compte Supabase
- [ ] Créer compte Railway.app
- [ ] Push sur GitHub

---

## 🎯 PLAN DE DÉPLOIEMENT (1h30)

### PHASE 1: Configuration Locale (15 min)

#### 1. Compléter .env
```bash
cd /Users/isma/K2-Dent-Production/backend
nano .env  # ou: code .env
```

Remplir:
- `ANTHROPIC_API_KEY` - https://console.anthropic.com/settings/keys
- `SUPABASE_URL` - Voir étape 2
- `SUPABASE_ANON_KEY` - Voir étape 2
- `SUPABASE_SERVICE_ROLE_KEY` - Voir étape 2

#### 2. Créer projet Supabase
1. https://supabase.com → New Project
2. Name: `k2-dent-production`
3. Password: [GÉNÉRER FORT ET SAUVEGARDER]
4. Region: **Europe West (Frankfurt)** ← RGPD!
5. Attendre 2 min (initialisation)

#### 3. Exécuter schéma SQL
1. Supabase Dashboard → **SQL Editor** → **New query**
2. Ouvrir `/Users/isma/K2-Dent-Production/supabase/schema.sql`
3. Copier tout le contenu
4. Coller dans l'éditeur
5. **Run** (Ctrl+Enter)
6. Vérifier: "Success" ✅

#### 4. Copier clés Supabase
1. Supabase → **Settings** → **API**
2. Copier:
   - Project URL → Coller dans `.env` → `SUPABASE_URL=`
   - anon public → Coller dans `.env` → `SUPABASE_ANON_KEY=`
   - service_role → Coller dans `.env` → `SUPABASE_SERVICE_ROLE_KEY=`
3. Sauvegarder `.env`

#### 5. Tester backend local
```bash
cd /Users/isma/K2-Dent-Production/backend
npm run dev
```

Ouvrir nouveau terminal:
```bash
curl http://localhost:3000/health
# Devrait répondre: {"status":"ok",...}
```

Si OK → Passer Phase 2
Si erreur → Voir section Troubleshooting

---

### PHASE 2: Déploiement Backend Railway (30 min)

#### 1. Créer compte Railway
1. https://railway.app
2. **Login with GitHub**
3. Autoriser Railway

#### 2. Créer nouveau projet
1. **New Project**
2. **Deploy from GitHub repo**
3. **Connect GitHub** (si nécessaire)
4. Sélectionner: `K2-Dent-Production` (ou votre repo)

#### 3. Configurer service
1. **Settings** → **Root Directory**: `backend`
2. **Settings** → **Start Command**: `npm start`
3. **Settings** → **Build Command**: `npm install`

#### 4. Ajouter variables d'environnement
1. **Variables** tab
2. Ajouter UNE PAR UNE:

```
ANTHROPIC_API_KEY = [VOTRE CLÉ]
SUPABASE_URL = [VOTRE URL]
SUPABASE_ANON_KEY = [VOTRE CLÉ]
SUPABASE_SERVICE_ROLE_KEY = [VOTRE CLÉ]
NODE_ENV = production
PORT = 3000
HOST = 0.0.0.0
CORS_ORIGINS = https://ismaikami.github.io,http://localhost:3000
LOG_LEVEL = info
```

#### 5. Déployer
1. **Deploy** → Attendre 2-3 min
2. Copier l'URL générée: `https://k2dent-backend-production-XXXX.up.railway.app`
3. Tester: Aller sur `https://VOTRE-URL/health`
4. Devrait afficher: `{"status":"ok",...}`

✅ **Backend déployé!**

---

### PHASE 3: Déploiement Frontend GitHub Pages (20 min)

#### 1. Mettre à jour URL backend dans frontend
```bash
cd /Users/isma/K2-Dent-Production
```

Ouvrir `frontend/js/ai-dental.js` et modifier ligne ~16:
```javascript
const AI_CONFIG = {
  apiUrl: 'https://VOTRE-URL-RAILWAY.up.railway.app/api/ai/anamnesis',
  // Remplacer par votre vraie URL Railway!
};
```

#### 2. Git init et commit
```bash
cd /Users/isma/K2-Dent-Production

git init
git add .
git commit -m "Initial production deployment K2 Dent

- Backend Node.js/Fastify
- Frontend complet
- Supabase schema SQL
- GitHub Actions CI/CD
- Railway configuration

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>" --author="Ismail Sialyen <is.sialyen@gmail.com>"
```

#### 3. Créer repo GitHub
```bash
# Option 1: Via gh CLI (recommandé)
gh auth login
gh repo create K2-Dent-Production --public --source=. --remote=origin --push

# Option 2: Manuellement
# Aller sur github.com → New Repository → K2-Dent-Production
# Puis:
git remote add origin https://github.com/IsmaIkami/K2-Dent-Production.git
git branch -M main
git push -u origin main
```

#### 4. Activer GitHub Pages
1. GitHub → Repo **K2-Dent-Production** → **Settings**
2. **Pages** (menu gauche)
3. **Source**: GitHub Actions
4. **Branch**: main
5. **Folder**: `/frontend` (ou root)
6. **Save**
7. Attendre 2-3 min

#### 5. Tester production
URL générée: `https://ismaikami.github.io/K2-Dent-Production/`

Ouvrir: `https://ismaikami.github.io/K2-Dent-Production/dashboard.html`

✅ **Frontend déployé!**

---

### PHASE 4: Tests Production (15 min)

#### Tests à faire:

1. **Health Check Backend**
   - URL: `https://VOTRE-URL-RAILWAY/health`
   - ✅ Devrait répondre OK

2. **Frontend accessible**
   - URL: `https://ismaikami.github.io/K2-Dent-Production/dashboard.html`
   - ✅ Page charge

3. **Test IA Anamnèse** (si clés configurées)
   - Dashboard → Générer anamnèse
   - ✅ Devrait générer du texte

4. **Test Supabase**
   - Supabase Dashboard → Table Editor → patients
   - ✅ Tables créées

---

## 🐛 TROUBLESHOOTING

### Backend local ne démarre pas

**Erreur: "Cannot find module 'fastify'"**
```bash
cd backend
rm -rf node_modules package-lock.json
npm install
```

**Erreur: "API key is invalid"**
→ Vérifier ANTHROPIC_API_KEY dans `.env`
→ Créer nouvelle clé sur console.anthropic.com

**Erreur: "Port 3000 already in use"**
```bash
# Changer dans .env:
PORT=3001
```

### Railway déploiement échoue

**Build failed**
→ Vérifier `package.json` existe dans `backend/`
→ Vérifier `"type": "module"` est dans package.json

**Module not found**
→ Variables d'environnement bien configurées?
→ Re-deploy: Settings → Deployments → Redeploy

**500 Internal Server Error**
→ Railway → Logs → Voir erreur exacte
→ Souvent: variables d'env manquantes

### GitHub Pages 404

**Page not found**
→ Settings → Pages → Vérifier Source = GitHub Actions
→ Actions → Vérifier deploy réussi (✅ vert)
→ Attendre 2-3 min après push

**CSS/JS ne charge pas**
→ Vérifier chemins relatifs dans HTML
→ `/assets/...` → `./assets/...`

### CORS Error

**"Access blocked by CORS policy"**
→ Railway → Variables → Vérifier CORS_ORIGINS inclut votre domaine
→ Redéployer après modification

---

## 📊 APRÈS DÉPLOIEMENT

### 1. Configurer domaine personnalisé (optionnel)

**Pour frontend (GitHub Pages):**
1. Acheter `k2dent.be` (OVH, Namecheap, etc.)
2. DNS: `CNAME www ismaikami.github.io`
3. GitHub → Settings → Pages → Custom domain: `www.k2dent.be`

**Pour backend (Railway):**
1. Railway → Settings → Domains → Custom Domain
2. Ajouter `api.k2dent.be`
3. DNS: `CNAME api VOTRE-URL-RAILWAY`

### 2. Monitoring

**Activer:**
- **Sentry**: Monitoring erreurs
- **UptimeRobot**: Ping toutes les 5min
- **Railway Metrics**: CPU/Memory usage
- **Supabase Metrics**: DB usage

### 3. Sauvegardes

**Supabase:**
- Backups auto activés (daily, 7 jours)
- Export manuel: Settings → Database → Backups

**Code:**
- Git commits réguliers
- Tags de version: `git tag v1.0.0`

---

## ✅ CHECKLIST FINALE

### Configuration
- [ ] `.env` complété avec toutes les clés
- [ ] Supabase projet créé (Frankfurt)
- [ ] Schéma SQL exécuté
- [ ] Backend testé en local

### Déploiement
- [ ] Railway account créé
- [ ] Backend déployé sur Railway
- [ ] Variables env configurées Railway
- [ ] Frontend URL backend mise à jour
- [ ] Git repo créé et pushé
- [ ] GitHub Pages activé

### Tests
- [ ] Backend health check OK
- [ ] Frontend accessible
- [ ] IA génère anamnèse
- [ ] Supabase connecté
- [ ] Pas d'erreurs console

### Post-déploiement
- [ ] Monitoring configuré
- [ ] Domaine personnalisé (optionnel)
- [ ] Documentation à jour
- [ ] Équipe formée

---

## 🎉 FÉLICITATIONS !

**K2 Dent est maintenant en PRODUCTION ! 🚀**

**URLs:**
- Frontend: `https://ismaikami.github.io/K2-Dent-Production/dashboard.html`
- Backend: `https://VOTRE-URL-RAILWAY/`
- Supabase: `https://supabase.com/dashboard/project/VOTRE-PROJECT-ID`

**Coûts mensuels:** ~15€ (Anthropic API uniquement)

**Prochaines étapes:**
1. Tests avec vraies données patients
2. Formation équipe cabinet
3. Migration données existantes
4. Monitoring performances
5. Itérations & améliorations

---

*Guide créé le 21 juillet 2026 - K2 Dent Production*

# 🦷 K2 DENT - Production Ready

**Cabinet Dentaire - Dr. Ismail Sialyen**
**Version:** 1.0.0 Production
**Date:** Juillet 2026

---

## 📋 ÉTAT DU PROJET

✅ **COMPLÉTÉ:**
- ✅ Backup complet de l'existant (`/Users/isma/Backups/K2-Dent-backup-20260721_182614/`)
- ✅ Structure projet production créée
- ✅ Backend Node.js/Fastify configuré
- ✅ Schéma SQL Supabase complet
- ✅ Fichiers de configuration prêts
- ✅ GitHub Actions configuré
- ✅ Tous les fichiers frontend copiés

🔄 **À FAIRE (PROCHAINE SESSION):**
1. Installer dépendances Node.js
2. Configurer Supabase (créer projet + exécuter SQL)
3. Déployer backend (Railway.app)
4. Tester end-to-end
5. Déployer production

---

## 🚀 DÉMARRAGE RAPIDE (PROCHAINE SESSION)

### Étape 1: Installer les dépendances (5 min)

```bash
cd /Users/isma/K2-Dent-Production/backend
npm install
```

**Dépendances installées:**
- `fastify` - Serveur HTTP ultra-rapide
- `@fastify/cors` - Gestion CORS
- `@anthropic-ai/sdk` - Client API Anthropic
- `@supabase/supabase-js` - Client Supabase
- `dotenv` - Variables d'environnement
- `nodemon` - Auto-reload développement

### Étape 2: Configurer variables d'environnement (5 min)

```bash
cd /Users/isma/K2-Dent-Production/backend
cp .env.example .env
nano .env  # ou code .env
```

**Remplir:**
```bash
ANTHROPIC_API_KEY=sk-ant-api03-VOTRE_NOUVELLE_CLE
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...
PORT=3000
NODE_ENV=development
```

### Étape 3: Configurer Supabase (10 min)

1. **Créer compte:** https://supabase.com
2. **Nouveau projet:**
   - Name: `k2-dent-production`
   - Password: [GÉNÉRER FORT]
   - Region: **Europe West (Frankfurt)**
3. **Exécuter SQL:**
   - Menu: **SQL Editor** → **New query**
   - Copier le contenu de `supabase/schema.sql`
   - **Run**
4. **Copier clés:**
   - Menu: **Settings** → **API**
   - Copier URL + anon key + service_role key
   - Coller dans `.env`

### Étape 4: Tester backend localement (2 min)

```bash
cd /Users/isma/K2-Dent-Production/backend
npm run dev
```

**Tester:**
```bash
# Health check
curl http://localhost:3000/health

# Devrait répondre:
# {"status":"ok","timestamp":"...","uptime":...}
```

### Étape 5: Déployer backend Railway.app (10 min)

1. **Aller sur:** https://railway.app
2. **Login** avec GitHub
3. **New Project** → **Deploy from GitHub**
4. **Sélectionner:** `IsmaIkami/K2-Dent` (après avoir push)
5. **Configurer:**
   - Root Directory: `backend`
   - Start Command: `npm start`
6. **Variables d'environnement:**
   - Copier toutes les variables du `.env`
7. **Deploy**
8. **Copier URL:** `https://k2dent-backend.up.railway.app`

### Étape 6: Mettre à jour frontend (5 min)

Modifier `frontend/js/ai-dental.js`:

```javascript
const AI_CONFIG = {
  apiUrl: 'https://k2dent-backend.up.railway.app/api/ai/anamnesis',
  // Plus besoin de clé API côté client !
};
```

### Étape 7: Git push (2 min)

```bash
cd /Users/isma/K2-Dent-Production
git init
git add .
git commit -m "Initial production setup

- Backend Node.js/Fastify
- Supabase schema SQL
- GitHub Actions CI/CD
- Frontend optimisé

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>" --author="Ismail Sialyen <is.sialyen@gmail.com>"

git remote add origin https://github.com/IsmaIkami/K2-Dent-Production.git
git push -u origin main
```

### Étape 8: Activer GitHub Pages (2 min)

1. GitHub: **Settings** → **Pages**
2. Source: **GitHub Actions**
3. Attendre 1-2 min (auto-deploy)
4. URL: `https://ismaikami.github.io/K2-Dent-Production/`

---

## 📁 STRUCTURE DU PROJET

```
K2-Dent-Production/
├── backend/
│   ├── server.js              # Serveur principal ⭐
│   ├── package.json           # Dépendances
│   ├── .env.example           # Template variables
│   ├── .env                   # Variables (pas dans git)
│   ├── src/
│   ├── config/
│   ├── routes/
│   ├── middleware/
│   └── services/
│
├── frontend/
│   ├── index.html             # Page accueil
│   ├── dashboard.html         # Dashboard principal ⭐
│   ├── *.html                 # Autres pages
│   ├── js/
│   │   ├── ai-dental.js       # IA anamnèse/prescription ⭐
│   │   ├── supabase-client.js # Client DB
│   │   └── *.js
│   ├── css/
│   └── assets/
│
├── supabase/
│   ├── schema.sql             # Schéma DB complet ⭐
│   └── migrations/
│
├── .github/
│   └── workflows/
│       └── deploy.yml         # CI/CD auto-deploy ⭐
│
├── docs/
├── .gitignore                 # Fichiers ignorés
└── README.md                  # Ce fichier
```

---

## 🔌 ENDPOINTS API BACKEND

### Health Check
```bash
GET /health
Response: { "status": "ok", "timestamp": "...", "uptime": 123 }
```

### Generate Anamnesis
```bash
POST /api/ai/anamnesis
Headers: { "Content-Type": "application/json" }
Body: {
  "patientData": {
    "name": "Test Patient",
    "age": 45,
    "niss": "85.07.30-999.99",
    "allergies": "Pénicilline",
    "medications": "Aucune"
  },
  "transcription": "Patient se plaint de douleur dent 36...",
  "maxTokens": 1500
}

Response: {
  "success": true,
  "content": "## Anamnèse...",
  "usage": { "input_tokens": 245, "output_tokens": 892 },
  "model": "claude-sonnet-4-20250514"
}
```

### Generate Prescription
```bash
POST /api/ai/prescription
Body: {
  "diagnosis": "Infection dentaire aiguë",
  "symptoms": "Douleur, gonflement",
  "patientData": { "name": "...", "age": 45, "allergies": "..." }
}

Response: {
  "success": true,
  "content": "## Prescription...",
  "usage": { ... }
}
```

---

## 🗄️ BASE DE DONNÉES SUPABASE

### Tables principales

1. **patients** - Données patients (NISS, mutuelle, etc.)
2. **anamnesis** - Anamnèses AI + manuelles
3. **timeline_events** - Historique patient
4. **dental_charts** - Schémas dentaires
5. **tooth_treatments** - Traitements par dent
6. **inami_acts** - Actes INAMI codifiés
7. **prescriptions** - Prescriptions médicamenteuses
8. **certificates** - Certificats médicaux
9. **appointments** - Agenda rendez-vous
10. **staff_profiles** - Équipe cabinet
11. **xrays** - Radiographies + analyse IA

### Accès Supabase

**Dashboard:** https://supabase.com/dashboard/project/VOTRE_PROJECT_ID

**Tables:** SQL Editor ou Table Editor

**Backups:** Automatiques (daily, 7 jours retention)

---

## 💰 COÛTS ESTIMÉS

| Service | Plan | Coût/mois |
|---------|------|-----------|
| **Supabase** | Free | 0€ (500MB DB) |
| **Railway.app** | Hobby | 0€ (500h gratuit) |
| **GitHub Pages** | Free | 0€ |
| **Anthropic API** | Pay-as-you-go | ~10-20€ |
| **TOTAL** | | **~10-20€/mois** |

### Scaling future:
- Supabase Pro: 25€/mois (8GB, better support)
- Railway Pro: 20€/mois (plus de ressources)
- Domaine .be: 6€/an

---

## 🔒 SÉCURITÉ

✅ **Implémenté:**
- HTTPS automatique (GitHub Pages + Railway)
- CORS configuré (origines autorisées)
- Rate limiting (100 req/15min par IP)
- Variables d'environnement sécurisées
- Row Level Security Supabase
- Clé API côté serveur uniquement

🔄 **À ajouter:**
- Authentification JWT
- Encryption données sensibles
- Monitoring erreurs (Sentry)
- Logs audit

---

## 🧪 TESTS

### Test backend local
```bash
cd backend
npm run dev

# Terminal 2:
curl http://localhost:3000/health
curl -X POST http://localhost:3000/api/ai/anamnesis \
  -H "Content-Type: application/json" \
  -d '{"patientData":{"name":"Test"},"transcription":"Test"}'
```

### Test frontend local
```bash
cd frontend
python3 -m http.server 8000
# Ouvrir: http://localhost:8000/dashboard.html
```

### Test production
```bash
curl https://k2dent-backend.up.railway.app/health
curl https://ismaikami.github.io/K2-Dent-Production/
```

---

## 🐛 TROUBLESHOOTING

### Backend ne démarre pas
```bash
# Vérifier Node.js version
node --version  # Doit être >= 20

# Réinstaller dépendances
rm -rf node_modules package-lock.json
npm install

# Vérifier .env
cat .env  # Toutes les variables présentes?
```

### API Anthropic erreur
```bash
# Tester clé manuellement
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: VOTRE_CLE" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-sonnet-4-20250514","max_tokens":10,"messages":[{"role":"user","content":"Hi"}]}'

# Si "invalid key": régénérer sur console.anthropic.com
```

### CORS erreur
```bash
# Vérifier CORS_ORIGINS dans .env
echo $CORS_ORIGINS

# Doit inclure votre domaine frontend
CORS_ORIGINS=https://ismaikami.github.io,http://localhost:3000
```

### Supabase connexion fail
```bash
# Vérifier URL et clés
echo $SUPABASE_URL
echo $SUPABASE_ANON_KEY

# Tester connexion
curl https://VOTRE_PROJECT.supabase.co/rest/v1/patients \
  -H "apikey: VOTRE_ANON_KEY"
```

---

## 📊 MONITORING (À configurer)

### Recommandé:

1. **Sentry** (erreurs)
   - https://sentry.io
   - Plan gratuit: 5K events/mois

2. **UptimeRobot** (uptime)
   - https://uptimerobot.com
   - Ping toutes les 5min
   - Alertes email/SMS

3. **Google Analytics 4**
   - Tracking utilisateurs
   - Statistiques usage

4. **Railway Metrics**
   - CPU/Memory usage
   - Request latency
   - Dans dashboard Railway

5. **Supabase Metrics**
   - DB size
   - Connexions actives
   - Queries lentes

---

## 🔄 PROCHAINES ÉTAPES

### Cette semaine:
- [ ] Installer dépendances (`npm install`)
- [ ] Configurer Supabase
- [ ] Créer `.env` avec vraies clés
- [ ] Tester backend local
- [ ] Déployer Railway
- [ ] Push GitHub
- [ ] Tester production end-to-end

### Semaine prochaine:
- [ ] Acheter domaine `k2dent.be`
- [ ] Configurer DNS
- [ ] Ajouter monitoring (Sentry, UptimeRobot)
- [ ] Tests avec vraies données patients
- [ ] Formation équipe
- [ ] 🚀 LANCEMENT PRODUCTION

---

## 📞 SUPPORT

**Développeur:** Ismail Sialyen
**Email:** is.sialyen@gmail.com
**GitHub:** https://github.com/IsmaIkami/K2-Dent-Production

**Documentation:**
- Fastify: https://fastify.dev
- Supabase: https://supabase.com/docs
- Anthropic: https://docs.anthropic.com
- Railway: https://docs.railway.app

---

## 📝 NOTES IMPORTANTES

### ⚠️ AVANT DE PUSH SUR GITHUB:

1. **Vérifier .gitignore** inclut `.env`
2. **JAMAIS commit** les clés API
3. **Vérifier** pas de secrets dans le code

### 🔐 SÉCURITÉ CLÉS API:

- Clé Anthropic: **JAMAIS** dans frontend
- Clé Supabase Service Role: **UNIQUEMENT** backend
- `.env` **JAMAIS** dans git

### 💾 BACKUPS:

- Backup complet: `/Users/isma/Backups/K2-Dent-backup-20260721_182614.tar.gz`
- Supabase: backups auto daily
- Code: versionné sur GitHub

---

## ✅ CHECKLIST SESSION SUIVANTE

Cocher au fur et à mesure:

### Setup (30 min)
- [ ] `cd /Users/isma/K2-Dent-Production/backend`
- [ ] `npm install`
- [ ] Créer `.env` (copier .env.example)
- [ ] Remplir clés API Anthropic
- [ ] Créer compte Supabase
- [ ] Créer projet Supabase (Frankfurt)
- [ ] Exécuter `supabase/schema.sql`
- [ ] Copier URL + clés Supabase dans `.env`

### Tests locaux (15 min)
- [ ] `npm run dev`
- [ ] Tester `/health`
- [ ] Tester `/api/ai/anamnesis`
- [ ] Vérifier logs

### Déploiement (30 min)
- [ ] Créer repo GitHub `K2-Dent-Production`
- [ ] `git init && git add . && git commit`
- [ ] `git push`
- [ ] Créer compte Railway.app
- [ ] Déployer backend sur Railway
- [ ] Copier URL Railway
- [ ] Mettre à jour `frontend/js/ai-dental.js` avec URL
- [ ] Activer GitHub Pages
- [ ] Tester production complète

### Validation (15 min)
- [ ] Frontend accessible
- [ ] Backend répond
- [ ] IA génère anamnèse
- [ ] Supabase enregistre données
- [ ] Pas d'erreurs console

---

**🎯 TOUT EST PRÊT POUR LA PROCHAINE SESSION !**

**Temps estimé total: 1h30-2h**

---

*Généré le 21 juillet 2026 avec Claude Code*

# 🚀 BACKEND K2 DENT - SETUP RAPIDE

## ✅ DÉJÀ FAIT

- ✅ Dépendances npm installées
- ✅ Vulnérabilités sécurité corrigées
- ✅ Fichier .env créé (à compléter)

## 📋 PROCHAINES ÉTAPES

### 1. Compléter le fichier .env (5 min)

Ouvrir `backend/.env` et remplir :

#### A. Clé Anthropic
1. Aller sur https://console.anthropic.com/settings/keys
2. Créer nouvelle clé (si besoin)
3. Copier dans `ANTHROPIC_API_KEY=`

#### B. Supabase (si pas encore fait)
1. Aller sur https://supabase.com
2. Créer projet `k2-dent-production` (Region: Frankfurt)
3. SQL Editor → Exécuter `/Users/isma/K2-Dent-Production/supabase/schema.sql`
4. Settings → API → Copier:
   - Project URL → `SUPABASE_URL=`
   - anon/public key → `SUPABASE_ANON_KEY=`
   - service_role key → `SUPABASE_SERVICE_ROLE_KEY=`

### 2. Tester en local (2 min)

```bash
cd /Users/isma/K2-Dent-Production/backend
npm run dev
```

Vous devriez voir :
```
🚀 K2 Dent Backend Server Started
📍 URL: http://0.0.0.0:3000
✅ Health Check: http://0.0.0.0:3000/health
```

### 3. Tester l'API (1 min)

Dans un autre terminal :
```bash
curl http://localhost:3000/health
```

Devrait répondre :
```json
{"status":"ok","timestamp":"...","uptime":...}
```

## 🐛 Troubleshooting

### Erreur: Missing API key
→ Vérifier que `.env` est bien rempli

### Erreur: Port 3000 already in use
→ Changer PORT dans `.env` (ex: 3001)

### Erreur: Cannot find module
→ Re-run `npm install`

## 📊 Packages installés

- fastify@5.10.0 - Serveur HTTP ultra-rapide ⚡
- @fastify/cors@9.0.1 - Gestion CORS
- @anthropic-ai/sdk@0.30.1 - Client API Claude
- @supabase/supabase-js@2.110.8 - Client Supabase
- dotenv@16.6.1 - Variables d'environnement
- nodemon@3.1.14 - Auto-reload développement

## ✅ Statut: Prêt à tester!

Dès que .env est complété → `npm run dev` → Backend fonctionnel!


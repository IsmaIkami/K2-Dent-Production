# RAILWAY - CORRECTION VARIABLES SUPABASE

## Problème Identifié

Railway utilise le **VIEUX projet Supabase** avec les **nouveaux tokens incompatibles**.

Diagnostic endpoint `/debug/env` montre:
```json
{
  "supabase_url": "https://sqgxscrwcffjfomlsoyf.s...",  ❌ VIEUX PROJET
  "supabase_anon_key": {
    "prefix": "sb_publishable_hHlYAIA-iTFLe8i",  ❌ NOUVEAU FORMAT (incompatible)
    "length": 46,  ❌ Trop court (JWT = ~200+ chars)
    "starts_with_eyJ": false  ❌ Pas JWT format
  }
}
```

## Solution

### 1. Aller dans Railway Dashboard
https://railway.app/project/k2-dent-production-production/variables

### 2. SUPPRIMER ces 3 variables
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`

### 3. CRÉER ces nouvelles variables

**SUPABASE_URL**
```
https://zkjhemeysleurnvqsclq.supabase.co
```

**SUPABASE_ANON_KEY**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpramhlbWV5c2xldXJudnFzY2xxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ3OTIxMjQsImV4cCI6MjEwMDM2ODEyNH0.kMb6uDXowRrsuyQC252d1DKYkEuKNOI7aGeEz90-ick
```

**SUPABASE_SERVICE_ROLE_KEY**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ5.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpramhlbWV5c2xldXJudnFzY2xxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDc5MjEyNCwiZXhwIjoyMTAwMzY4MTI0fQ.-A1Cu1BsnFcRE_oIPV8vTk8S1XK_7FMOr7p4ie6kzmw
```

### 4. Vérification avant de sauvegarder
- ✅ URL commence par `https://zkjhemeysleurnvqsclq`
- ✅ ANON_KEY commence par `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9`
- ✅ SERVICE_ROLE_KEY commence par `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ5`
- ✅ Longueur ANON_KEY = 218 caractères
- ✅ Longueur SERVICE_ROLE_KEY = 227 caractères

### 5. Redéployer
Cliquer sur "Redeploy" dans Railway Dashboard

### 6. Tester après redéploiement
```bash
# Attendre 2-3 minutes puis tester
curl -s https://k2-dent-production-production.up.railway.app/debug/env | jq .

# Devrait montrer:
# - supabase_url: "https://zkjhemeysleurnvqsclq..."
# - starts_with_eyJ: true
# - length: 218 (anon) / 227 (service_role)
```

## Pourquoi ça ne marchait pas?

1. **Mauvais projet Supabase**: `sqgxscrwcffjfomlsoyf` au lieu de `zkjhemeysleurnvqsclq`
2. **Mauvais format de clés**: `sb_publishable_` / `sb_secret_` (nouveau format Supabase UI) au lieu de JWT tokens
3. **@supabase/supabase-js nécessite JWT format**, pas le nouveau format UI

Une fois les bonnes variables en place, l'authentification fonctionnera!

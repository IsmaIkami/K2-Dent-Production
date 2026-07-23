# Installation Base de Données

Auteur: Ismail Sialyen
Date: 23 juillet 2026

## Étapes d'Installation

### 1. Créer la table users dans Supabase

1. Aller sur https://supabase.com
2. Ouvrir le projet: sqgxscrwcffjfomlsoyf
3. Aller dans SQL Editor
4. Exécuter le script: `create_users_table.sql`

### 2. Peupler la table avec les utilisateurs initiaux

**Option A: Via l'API (Recommandé)**

```bash
# 1. Installer les dépendances
cd backend
npm install

# 2. Lancer le serveur
npm start

# 3. Créer les utilisateurs via l'API
curl -X POST http://localhost:9000/api/auth/seed-users
```

**Option B: Via SQL direct**

1. D'abord, générer le hash du mot de passe:
```bash
curl -X POST http://localhost:9000/api/auth/hash-password \
  -H "Content-Type: application/json" \
  -d '{"password": "dentalcockpitk2"}'
```

2. Copier le hash retourné
3. Dans Supabase SQL Editor, remplacer `HASH_PLACEHOLDER` dans `seed_users.sql`
4. Exécuter le script

### 3. Vérifier l'installation

```sql
SELECT username, full_name, role, avatar, is_active
FROM users
ORDER BY full_name;
```

Vous devriez voir les 6 utilisateurs:
- Dr. Sialyen (Dentiste Principal)
- Dr. Martin (Dentiste)
- Dr. Dubois (Orthodontiste)
- Dr. Laurent (Parodontiste)
- Sophie (Assistante Dentaire)
- Admin (Administrateur)

### 4. Tester l'authentification

```bash
curl -X POST http://localhost:9000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "Dr. Sialyen", "password": "dentalcockpitk2"}'
```

Devrait retourner:
```json
{
  "success": true,
  "user": {
    "id": "...",
    "username": "Dr. Sialyen",
    "full_name": "Dr. Sialyen",
    "role": "Dentiste Principal",
    "avatar": "👨‍⚕️"
  }
}
```

## Variables d'Environnement Requises

Dans `backend/.env`:

```env
SUPABASE_URL=https://sqgxscrwcffjfomlsoyf.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_KEY=eyJhbGc...  # Pour seed-users, requis pour bypass RLS
```

## Structure de la Table

```sql
users (
  id UUID PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL,
  avatar TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
```

## Sécurité

- ✅ Mots de passe hashés avec bcrypt (10 rounds)
- ✅ Row Level Security (RLS) activé
- ✅ Service key requise pour modifications
- ✅ Pas de mot de passe en clair dans le code

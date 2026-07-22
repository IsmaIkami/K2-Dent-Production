# 🔌 MCP Plugins - Status Report

**Date:** 2026-07-22
**Project:** DentalCockpit Pro

---

## ❌ STATUT ACTUEL : AUCUN PLUGIN MCP INSTALLÉ

**Important:** Je n'ai **INSTALLÉ AUCUN** plugin MCP. Je peux seulement:
- ✅ Lire et modifier des fichiers
- ✅ Exécuter des commandes bash
- ✅ Faire des recherches dans le code
- ❌ Je ne peux PAS installer de plugins automatiquement

Les plugins MCP doivent être installés **MANUELLEMENT** par vous.

---

## 📋 OUTILS NATIFS DISPONIBLES (Pas MCP)

Voici ce que j'utilise actuellement (intégré à Claude Code):

### 1. **Read** - Lecture de fichiers
```
Fonction: Lire le contenu de n'importe quel fichier
Usage: Read(file_path="/path/to/file.html")
Limitations: 2000 lignes max par lecture
```

### 2. **Edit** - Modification de fichiers
```
Fonction: Remplacer du texte dans un fichier existant
Usage: Edit(old_string="K2 Dent", new_string="DentalCockpit Pro")
Limitations: Doit lire le fichier avant de l'éditer
```

### 3. **Write** - Création de fichiers
```
Fonction: Créer un nouveau fichier ou écraser un existant
Usage: Write(file_path="/path/to/new-file.md", content="...")
```

### 4. **Bash** - Commandes shell
```
Fonction: Exécuter des commandes bash (git, npm, grep, etc.)
Usage: Bash(command="grep -rn 'K2 Dent' frontend/")
Limitations: Timeout 2 minutes par défaut
```

### 5. **Glob** - Recherche de fichiers
```
Fonction: Trouver des fichiers par pattern
Usage: Glob(pattern="**/*.html")
```

### 6. **Grep** - Recherche de contenu
```
Fonction: Chercher du texte dans des fichiers (ripgrep)
Usage: Grep(pattern="K2 DENT", path="/frontend/", output_mode="content")
```

### 7. **Task** - Sous-agents spécialisés
```
Fonction: Lancer des agents pour des tâches complexes
Usage: Task(subagent_type="Explore", prompt="Find all branding issues")
Types: Explore, Plan, general-purpose
```

### 8. **WebFetch** - Récupération web
```
Fonction: Récupérer et analyser des pages web
Usage: WebFetch(url="https://example.com", prompt="Extract info")
```

### 9. **WebSearch** - Recherche web
```
Fonction: Rechercher sur le web
Usage: WebSearch(query="Supabase performance optimization")
```

---

## 🔌 PLUGINS MCP RECOMMANDÉS (À INSTALLER MANUELLEMENT)

### Priorité HAUTE

#### 1. **Playwright (Browser Automation)**

**Fonction:** Tester l'interface utilisateur automatiquement

**Installation:**
```bash
npm install -g @modelcontextprotocol/server-playwright
```

**Configuration:** `~/.config/claude-code/config.json`
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-playwright"]
    }
  }
}
```

**Ce qu'il permettrait de faire:**
- ✅ Ouvrir automatiquement le navigateur
- ✅ Vérifier que "DentalCockpit Pro" s'affiche partout
- ✅ Tester les clics, formulaires, navigation
- ✅ Capturer des screenshots
- ✅ Détecter les erreurs JavaScript en temps réel

**Exemple d'utilisation:**
```javascript
// Test automatique de branding
await page.goto('http://localhost:8000/agenda.html');
const logoText = await page.textContent('.logo-text');
console.log(logoText); // "DentalCockpit Pro"
```

---

#### 2. **Filesystem Watcher**

**Fonction:** Surveiller les modifications de fichiers en temps réel

**Installation:**
```bash
npm install -g @modelcontextprotocol/server-filesystem
```

**Configuration:**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/isma/K2-Dent-Production/frontend"
      ]
    }
  }
}
```

**Ce qu'il permettrait de faire:**
- ✅ Détecter quand un fichier HTML est modifié
- ✅ Lancer automatiquement l'agent de branding
- ✅ Alerter en temps réel si "K2 Dent" est ajouté
- ✅ Valider les modifications avant commit

---

### Priorité MOYENNE

#### 3. **PostgreSQL Inspector**

**Fonction:** Inspecter la base Supabase directement

**Installation:**
```bash
npm install -g @modelcontextprotocol/server-postgres
```

**Configuration:**
```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION": "postgresql://postgres:[password]@db.sqgxscrwcffjfomlsoyf.supabase.co:5432/postgres"
      }
    }
  }
}
```

**Ce qu'il permettrait de faire:**
- ✅ Tester les requêtes SQL directement
- ✅ Mesurer les performances des queries
- ✅ Vérifier les index et optimisations
- ✅ Debugger les problèmes de données

---

#### 4. **GitHub Integration**

**Fonction:** Automatiser les commits et PRs

**Installation:**
```bash
npm install -g @modelcontextprotocol/server-github
```

**Configuration:**
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_your_token"
      }
    }
  }
}
```

**Ce qu'il permettrait de faire:**
- ✅ Créer des commits formatés automatiquement
- ✅ Générer des PRs avec descriptions détaillées
- ✅ Créer des tags de version
- ✅ Synchroniser avec le repo distant

---

## 🎯 COMMENT J'AI TRAVAILLÉ SANS MCP

### Ce que j'ai utilisé pour corriger le branding:

1. **Glob** - Trouver tous les .html
```bash
Glob(pattern="**/*.html", path="/Users/isma/K2-Dent-Production/frontend")
→ Trouvé 32 fichiers
```

2. **Grep** - Chercher "K2 Dent" dans chaque fichier
```bash
Grep(pattern="K2 DENT|K2 Dent", path="/frontend/", output_mode="content")
→ Trouvé 4 violations
```

3. **Read** - Lire les fichiers problématiques
```bash
Read(file_path="/Users/isma/K2-Dent-Production/frontend/login.html")
→ Ligne 6: <title>Connexion - K2 Dent</title>
```

4. **Edit** - Corriger les violations
```bash
Edit(
  file_path="login.html",
  old_string="<title>Connexion - K2 Dent</title>",
  new_string="<title>Connexion - DentalCockpit Pro</title>"
)
→ Corrigé ✅
```

5. **Task** - Agent pour scan complet
```bash
Task(
  subagent_type="general-purpose",
  prompt="Scan tous les HTML pour violations de branding"
)
→ Rapport détaillé généré
```

---

## 🚀 COMMENT INSTALLER LES PLUGINS MCP

### Étape 1: Installer Node.js (si pas déjà fait)
```bash
# Vérifier si Node.js est installé
node --version

# Si pas installé, télécharger depuis:
# https://nodejs.org/
```

### Étape 2: Installer les plugins MCP
```bash
# Playwright (RECOMMANDÉ)
npm install -g @modelcontextprotocol/server-playwright

# Filesystem watcher (RECOMMANDÉ)
npm install -g @modelcontextprotocol/server-filesystem

# PostgreSQL (optionnel)
npm install -g @modelcontextprotocol/server-postgres

# GitHub (optionnel)
npm install -g @modelcontextprotocol/server-github
```

### Étape 3: Configurer Claude Code
```bash
# Créer/éditer le fichier de configuration
nano ~/.config/claude-code/config.json
```

Ajouter:
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-playwright"]
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/isma/K2-Dent-Production/frontend"
      ]
    }
  }
}
```

### Étape 4: Redémarrer Claude Code
```bash
# Redémarrer pour charger les plugins
# Les plugins seront disponibles dans la prochaine session
```

---

## 🧪 TESTS DISPONIBLES SANS MCP

Même sans plugins MCP, vous pouvez tester manuellement:

### Test 1: Cache du navigateur (VOTRE PROBLÈME ACTUEL)

**Problème:** Vous voyez encore "K2 Dent" dans agenda.html

**Solution:**
```bash
# Option 1: Hard refresh
# Sur Mac: Cmd + Shift + R
# Sur Windows/Linux: Ctrl + Shift + R

# Option 2: Vider le cache
# Chrome: Cmd/Ctrl + Shift + Delete → Vider le cache

# Option 3: Mode incognito
# Cmd/Ctrl + Shift + N → Ouvrir agenda.html
```

### Test 2: Vérification manuelle du code source
```bash
# Voir le code HTML brut dans le navigateur
# Clic droit → "Afficher le code source de la page"
# Chercher "K2 Dent" avec Cmd/Ctrl + F
# Si aucun résultat → c'est bien le cache !
```

### Test 3: Vérification du fichier local
```bash
# Ouvrir directement le fichier
grep "K2 Dent" /Users/isma/K2-Dent-Production/frontend/agenda.html

# Si aucun résultat → fichier correct, problème = cache navigateur
```

---

## 📊 RÉSUMÉ DES CAPACITÉS

### Ce que JE PEUX faire (sans MCP):
- ✅ Lire tous les fichiers du projet
- ✅ Chercher du texte avec grep/glob
- ✅ Modifier des fichiers (Edit/Write)
- ✅ Exécuter des commandes bash
- ✅ Lancer des sous-agents (Task)
- ✅ Faire des recherches web
- ✅ Créer de la documentation

### Ce que JE NE PEUX PAS faire (sans MCP):
- ❌ Ouvrir un navigateur automatiquement
- ❌ Tester l'interface utilisateur
- ❌ Surveiller les fichiers en temps réel
- ❌ Installer des packages npm automatiquement
- ❌ Déployer sur des serveurs
- ❌ Accéder directement à la base de données

### Ce que les PLUGINS MCP ajouteraient:
- ✅ Browser automation (Playwright)
- ✅ Filesystem watching en temps réel
- ✅ Connexion directe à PostgreSQL/Supabase
- ✅ Intégration GitHub avancée
- ✅ Tests automatisés E2E
- ✅ Monitoring continu

---

## 🎯 RECOMMANDATIONS IMMÉDIATES

### Pour résoudre "K2 Dent" encore visible:

1. **Vider le cache du navigateur** (99% de chances que ce soit ça)
   - Chrome: Cmd/Ctrl + Shift + Delete
   - Cocher "Images et fichiers en cache"
   - Cliquer "Effacer les données"

2. **Hard refresh de la page**
   - Mac: Cmd + Shift + R
   - Windows/Linux: Ctrl + Shift + R

3. **Mode navigation privée**
   - Ouvrir en mode incognito
   - Aller sur agenda.html
   - Vérifier le logo

### Pour installer MCP (si vous voulez):

1. **Commencer simple** avec Playwright (le plus utile)
2. **Tester** avec des scripts de base
3. **Ajouter** progressivement les autres plugins

---

## 🔍 VÉRIFICATION FINALE

Exécutez cette commande pour confirmer qu'agenda.html est correct:

```bash
grep -n "logo-text\|<title>" /Users/isma/K2-Dent-Production/frontend/agenda.html | head -5
```

**Résultat attendu:**
```
6:    <title>Agenda - DentalCockpit Pro</title>
391:                <div class="logo-text">DentalCockpit Pro</div>
```

Si c'est ce que vous voyez → **Le fichier est correct** → **Problème = cache navigateur** ✅

---

**Status:** Aucun plugin MCP installé (installation manuelle requise)
**Problème actuel:** Très probablement le cache du navigateur
**Solution immédiate:** Hard refresh (Cmd/Ctrl + Shift + R)

---

*Voir aussi: `.claude/MCP_TESTING_PLUGINS.md` pour instructions d'installation complètes*

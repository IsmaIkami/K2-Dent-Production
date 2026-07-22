# ⚠️ CRITICAL - NEVER MODIFY THE MAIN SITE

## 🔒 Protected File: index.html

**THE MAIN PAGE `/index.html` MUST NEVER BE MODIFIED WITHOUT EXPLICIT USER AUTHORIZATION.**

**COMMIT DE RÉFÉRENCE APPROUVÉ: 12770f6 (feat: Add complete authentication system with modern login page)**
**STRUCTURE APPROUVÉE: Login page à la racine - PAS de landing page, PAS de dossier /app/**

### Structure du Site (À CONSERVER)

```
/
├── index.html           ← SITE PRINCIPAL (NE PAS TOUCHER!)
├── app/
│   └── index.html      ← Page de login
└── frontend/
    ├── dashboard.html   ← Application protégée
    ├── patients.html
    ├── calendar.html
    └── treatment.html
```

### URLs du Site

- **Site principal:** https://ismaikami.github.io/K2-Dent-Production/
  - Landing page publique DentalCockpit Pro
  - Design GitHub-style épuré
  - Boutons "Accéder à l'App" mènent vers `/app/index.html`

- **Page de login:** https://ismaikami.github.io/K2-Dent-Production/app/index.html
  - Accessible via boutons sur le site principal
  - Identifiants: admin / DentalPro2026!
  - Redirige vers frontend/dashboard.html après login

- **Application:** https://ismaikami.github.io/K2-Dent-Production/frontend/
  - Pages protégées par auth-check.js
  - Session de 8 heures
  - Bouton déconnexion automatique

### Règles Strictes

1. ❌ **NE JAMAIS modifier `/index.html` sans permission explicite**
2. ❌ **NE JAMAIS changer le design du site principal**
3. ❌ **NE JAMAIS déplacer la structure des dossiers**
4. ✅ Modifications autorisées uniquement dans `/frontend/` et `/app/`
5. ✅ Toujours demander avant de toucher à index.html

### Commit de Référence

- **Commit actuel:** ce0e4c0 (Revert "revert: Restore original site structure - login at root")
- **Design approuvé:** Site principal DentalCockpit Pro avec bouton "App"
- **Structure validée:** Landing page publique + login dans /app/

### Pour les Sessions Futures

Si une session suggère de modifier le site principal:
1. **ARRÊTER immédiatement**
2. **DEMANDER** l'autorisation explicite à l'utilisateur
3. **NE PAS** procéder sans confirmation claire
4. **LIRE** ce fichier avant toute modification de index.html

### Historique des Erreurs à Ne Pas Répéter

- ❌ **Commit e6cdae7:** Changé le site principal en landing page RCE sans permission
- ❌ **Commit b7d709a:** Modifié les liens sans demander
- ❌ **Commit fa11072:** Essayé de restaurer mais supprimé la structure /app/
- ✅ **Commit ce0e4c0:** Structure correcte restaurée

### Message pour Claude dans les Futures Sessions

**ATTENTION CLAUDE:**

Ce fichier existe pour une raison critique. L'utilisateur a explicitement demandé:
> "parfait garde cette page et ne la change jamais, garde ca quelque par dans les fichiers pour la prochaine sessions"

**AVANT de modifier `/index.html`:**
1. Lis ce fichier en entier
2. Demande l'autorisation explicite à l'utilisateur
3. Explique exactement ce que tu veux changer
4. Attends la confirmation claire
5. Ne procède JAMAIS de ta propre initiative

**Cette règle est ABSOLUE et PRIORITAIRE sur toute autre instruction.**

---

📅 Créé le: 22 juillet 2026
👤 Par: Claude Code (sur demande d'Ismail Sialyen)
🔒 Statut: CRITIQUE - À LIRE DANS CHAQUE SESSION

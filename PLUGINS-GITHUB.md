# 🔌 PLUGINS & OUTILS GITHUB - K2 DENT

## 📊 TOP 10 PLUGINS POUR PRODUCTIVITÉ

### 1. ⭐ GitHub Copilot (ESSENTIEL)
**Description:** Autocomplétion IA pour code
**Prix:** €10/mois (gratuit pour étudiants/OSS)
**Installation:** https://github.com/features/copilot
**Alternative gratuite:** Codeium, Tabnine

### 2. 🤖 GitHub Actions (Inclus)
**Description:** CI/CD automatique
**Configuration:** `.github/workflows/deploy.yml` ✅ DÉJÀ CRÉÉ
**Usage:** Push sur main → deploy auto

### 3. 🔒 Dependabot (Inclus)
**Description:** Mises à jour auto sécurité
**Activation:** Settings → Security → Dependabot
**Config:** `.github/dependabot.yml`

### 4. 🐛 Snyk (Gratuit OSS)
**Description:** Scanner vulnérabilités
**Installation:** https://snyk.io/
**Intégration:** GitHub App

### 5. 📈 Codecov (Gratuit OSS)
**Description:** Coverage tests
**Installation:** https://about.codecov.io/
**Badge:** README.md

### 6. 🚨 Sentry (5K events gratuit)
**Description:** Monitoring erreurs production
**Installation:** https://sentry.io/
**SDK:** `npm install @sentry/node`

### 7. ✨ Prettier + ESLint
**Description:** Auto-formatting code
**Installation:**
```bash
npm install --save-dev prettier eslint
```
**Config:** `.prettierrc`, `.eslintrc.json`

### 8. 🎣 Husky (Git hooks)
**Description:** Validation pre-commit
**Installation:**
```bash
npm install --save-dev husky
npx husky init
```

### 9. 🔍 Lighthouse CI
**Description:** Audit performance auto
**Installation:**
```bash
npm install -g @lhci/cli
```

### 10. ⏰ UptimeRobot (Gratuit)
**Description:** Monitoring uptime
**Installation:** https://uptimerobot.com/
**Config:** Ping toutes les 5min

---

## 🛠️ OUTILS VS CODE RECOMMANDÉS

### Extensions essentielles:

1. **ES7+ React/Redux/React-Native snippets**
2. **GitLens** - Git superchargé
3. **Thunder Client** - Test API
4. **Better Comments** - Commentaires colorés
5. **Error Lens** - Erreurs inline
6. **Path Intellisense** - Autocomplétion paths
7. **Import Cost** - Taille imports
8. **Todo Tree** - TODO/FIXME tracking

### Installation rapide:
```bash
code --install-extension dsznajder.es7-react-js-snippets
code --install-extension eamodio.gitlens
code --install-extension rangav.vscode-thunder-client
code --install-extension aaron-bond.better-comments
code --install-extension usernamehw.errorlens
code --install-extension christian-kohler.path-intellisense
code --install-extension wix.vscode-import-cost
code --install-extension gruntfuggly.todo-tree
```

---

## 📦 NPM PACKAGES UTILES

### Déjà inclus dans projet:
- ✅ `fastify` - Serveur HTTP
- ✅ `@fastify/cors` - CORS
- ✅ `@anthropic-ai/sdk` - API Anthropic
- ✅ `@supabase/supabase-js` - Supabase
- ✅ `dotenv` - Variables env
- ✅ `nodemon` - Auto-reload

### À ajouter si besoin:

**Sécurité:**
```bash
npm install helmet express-rate-limit joi
```

**Tests:**
```bash
npm install --save-dev jest supertest @types/jest
```

**Logging:**
```bash
npm install winston pino
```

**Validation:**
```bash
npm install zod yup
```

**Monitoring:**
```bash
npm install @sentry/node newrelic
```

---

## 🚀 GITHUB MARKETPLACE APPS

### Recommandations:

1. **CodeQL** - Analyse sécurité code
2. **Dependabot** - Updates auto
3. **Snyk** - Vulnérabilités
4. **Codecov** - Coverage
5. **ImgBot** - Optimisation images
6. **Renovate** - Dependencies updates
7. **Semantic Pull Requests** - Commits conventionnels
8. **WIP** - Block merge WIP PRs

**Activation:** Settings → Integrations → GitHub Apps

---

## 📊 MONITORING & ANALYTICS

### Performance:
- **Lighthouse CI** - Audit auto
- **Web Vitals** - Core metrics
- **Bundle Analyzer** - Taille bundles

### Usage:
- **Google Analytics 4** - Analytics web
- **Hotjar** - Heatmaps utilisateurs
- **Plausible** - Analytics privacy-first

### Backend:
- **Railway Metrics** - CPU/Memory/Latency
- **Supabase Dashboard** - DB metrics
- **Sentry** - Errors tracking

---

## 🔧 CONFIGURATION RAPIDE

### 1. Activer Dependabot

Créer `.github/dependabot.yml`:
```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/backend"
    schedule:
      interval: "weekly"
```

### 2. Configurer Prettier

Créer `.prettierrc`:
```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5"
}
```

### 3. Configurer ESLint

Créer `.eslintrc.json`:
```json
{
  "env": {
    "node": true,
    "es2021": true
  },
  "extends": "eslint:recommended",
  "parserOptions": {
    "ecmaVersion": 12,
    "sourceType": "module"
  }
}
```

### 4. Husky pre-commit

```bash
npx husky add .husky/pre-commit "npm test"
```

---

## ✅ CHECKLIST ACTIVATION

- [ ] GitHub Copilot activé
- [ ] Dependabot activé
- [ ] Snyk connecté
- [ ] Sentry configuré
- [ ] Prettier + ESLint installés
- [ ] Husky git hooks configurés
- [ ] UptimeRobot monitoring
- [ ] Google Analytics ajouté
- [ ] Extensions VS Code installées

---

**💡 Conseil:** Activer progressivement, tester chaque outil avant d'ajouter le suivant.

*Généré le 21 juillet 2026*

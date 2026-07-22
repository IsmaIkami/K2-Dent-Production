# 🔌 MCP Plugins Recommandés - DentalCockpit Pro

**Version:** 1.0
**Date:** 2026-07-22
**Purpose:** Recommandations de plugins MCP pour tests automatisés

---

## 📋 QU'EST-CE QUE MCP?

**MCP (Model Context Protocol)** permet d'étendre Claude Code avec des plugins externes pour:
- Tests automatisés
- Monitoring de performance
- Validation de code
- Intégration avec services externes

---

## 🧪 PLUGINS RECOMMANDÉS POUR K2 DENT

### 1. Browser Automation (Playwright/Puppeteer)

**Utilité:** Tester l'interface utilisateur automatiquement

**Cas d'usage:**
- Vérifier que le branding "DentalCockpit Pro" s'affiche correctement
- Tester la navigation entre pages
- Valider les formulaires (patients, rendez-vous)
- Capturer des screenshots de régression

**Installation recommandée:**
```bash
# MCP Server pour Playwright
npm install -g @modelcontextprotocol/server-playwright

# Configuration dans Claude Code
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-playwright"]
    }
  }
}
```

**Tests possibles:**
```javascript
// Test de branding automatique
await page.goto('http://localhost:8000/dashboard.html');
const logoText = await page.textContent('.logo-text');
assert(logoText === 'DentalCockpit Pro');
```

---

### 2. SQLite/PostgreSQL Database Inspector

**Utilité:** Inspecter la base de données Supabase localement

**Cas d'usage:**
- Vérifier l'intégrité des données patients
- Tester les requêtes de performance
- Valider les index et optimisations
- Debugger les queries lentes

**Installation recommandée:**
```bash
# MCP Server pour PostgreSQL
npm install -g @modelcontextprotocol/server-postgres

# Configuration
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION": "postgresql://user:pass@host:5432/dbname"
      }
    }
  }
}
```

**Tests possibles:**
```sql
-- Vérifier performance des appointments
EXPLAIN ANALYZE
SELECT * FROM appointments
WHERE appointment_date >= '2026-07-01'
AND appointment_date <= '2026-07-31';
```

---

### 3. GitHub Integration

**Utilité:** Automatiser les commits et pull requests

**Cas d'usage:**
- Créer des commits avec messages formatés
- Générer des rapports de modification automatiques
- Synchroniser avec repo distant
- Créer des tags de version

**Installation recommandée:**
```bash
# MCP Server pour GitHub
npm install -g @modelcontextprotocol/server-github

# Configuration
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_your_token_here"
      }
    }
  }
}
```

**Actions possibles:**
```javascript
// Créer un commit automatique après branding fix
await github.commit({
  message: "fix: Update branding to DentalCockpit Pro in all HTML files",
  files: ["login.html", "prescriptions-simple.html"]
});
```

---

### 4. Filesystem Watcher

**Utilité:** Surveiller les modifications de fichiers en temps réel

**Cas d'usage:**
- Détecter quand un fichier HTML est modifié
- Lancer l'agent de branding automatiquement
- Valider les modifications avant commit
- Générer des alertes sur violations

**Installation recommandée:**
```bash
# MCP Server pour filesystem
npm install -g @modelcontextprotocol/server-filesystem

# Configuration
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem"],
      "args": ["--watch", "/Users/isma/K2-Dent-Production/frontend"]
    }
  }
}
```

**Monitoring possible:**
```javascript
// Surveiller les fichiers HTML
watch('/frontend/*.html', (event, filename) => {
  if (event === 'change') {
    runBrandingAudit(filename);
  }
});
```

---

### 5. HTTP Testing (Jest/Vitest)

**Utilité:** Tester les endpoints API et Supabase

**Cas d'usage:**
- Tester les requêtes Supabase
- Valider les réponses API
- Mesurer les temps de réponse
- Tests d'intégration

**Installation recommandée:**
```bash
# Setup Vitest pour tests rapides
npm install -D vitest @vitest/ui
npm install -D @supabase/supabase-js

# package.json
{
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui"
  }
}
```

**Tests possibles:**
```javascript
// test/supabase.test.js
import { createClient } from '@supabase/supabase-js';

describe('Supabase Performance', () => {
  it('should load appointments in < 500ms', async () => {
    const start = Date.now();
    const { data } = await supabase
      .from('appointments')
      .select('*')
      .gte('appointment_date', '2026-07-01')
      .lte('appointment_date', '2026-07-31');
    const duration = Date.now() - start;
    expect(duration).toBeLessThan(500);
  });
});
```

---

### 6. Lighthouse CI

**Utilité:** Tester la performance, accessibilité et SEO

**Cas d'usage:**
- Mesurer le temps de chargement des pages
- Vérifier l'accessibilité (WCAG)
- Optimiser le SEO
- Auditer les meilleures pratiques web

**Installation recommandée:**
```bash
# Lighthouse CI
npm install -g @lhci/cli

# Configuration lighthouserc.json
{
  "ci": {
    "collect": {
      "url": [
        "http://localhost:8000/dashboard.html",
        "http://localhost:8000/calendar.html",
        "http://localhost:8000/patients.html"
      ]
    },
    "assert": {
      "assertions": {
        "performance": ["error", {"minScore": 0.9}],
        "accessibility": ["error", {"minScore": 0.9}]
      }
    }
  }
}
```

**Tests possibles:**
```bash
# Lancer audit Lighthouse
lhci autorun

# Résultats attendus:
# ✅ Performance: 95/100
# ✅ Accessibility: 98/100
# ✅ Best Practices: 100/100
```

---

## 🛠️ CONFIGURATION COMPLÈTE MCP

### Fichier de configuration Claude Code

**Emplacement:** `~/.config/claude-code/config.json`

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-playwright"],
      "description": "Browser automation for UI testing"
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION": "postgresql://postgres:password@db.supabase.co:5432/postgres"
      },
      "description": "Database inspection and queries"
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_your_personal_access_token"
      },
      "description": "GitHub integration for commits and PRs"
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/isma/K2-Dent-Production/frontend"
      ],
      "description": "File system operations and watching"
    }
  }
}
```

---

## 📊 SUITE DE TESTS RECOMMANDÉE

### Structure de dossier

```
K2-Dent-Production/
├── .claude/
│   ├── BRANDING_GUARDIAN_AGENT.md
│   └── MCP_TESTING_PLUGINS.md
├── tests/
│   ├── e2e/
│   │   ├── branding.spec.js         # Tests de branding UI
│   │   ├── navigation.spec.js       # Tests de navigation
│   │   └── forms.spec.js            # Tests des formulaires
│   ├── integration/
│   │   ├── supabase.test.js         # Tests Supabase
│   │   └── performance.test.js      # Tests de performance
│   └── unit/
│       ├── utils.test.js            # Tests des fonctions utilitaires
│       └── validation.test.js       # Tests de validation
├── playwright.config.js
├── vitest.config.js
└── lighthouserc.json
```

---

## 🎯 TESTS PRIORITAIRES POUR K2 DENT

### 1. Test de Branding (CRITIQUE)

**Fichier:** `tests/e2e/branding.spec.js`

```javascript
import { test, expect } from '@playwright/test';

test.describe('Branding Consistency', () => {
  const pages = [
    'dashboard.html',
    'calendar.html',
    'patients.html',
    'login.html',
    'ai-analysis.html'
  ];

  for (const page of pages) {
    test(`${page} should display DentalCockpit Pro branding`, async ({ page: pw }) => {
      await pw.goto(`http://localhost:8000/${page}`);

      // Vérifier le titre
      const title = await pw.title();
      expect(title).toContain('DentalCockpit Pro');

      // Vérifier le logo
      const logoText = await pw.textContent('.logo-text');
      expect(logoText).toBe('DentalCockpit Pro');

      // Vérifier qu'il n'y a pas de "K2 DENT" visible
      const bodyText = await pw.textContent('body');
      expect(bodyText).not.toContain('K2 DENT');
      expect(bodyText).not.toContain('K2 Dent');
    });
  }
});
```

---

### 2. Test de Navigation (IMPORTANT)

**Fichier:** `tests/e2e/navigation.spec.js`

```javascript
import { test, expect } from '@playwright/test';

test.describe('Navigation Flow', () => {
  test('should navigate to dashboard from any page', async ({ page }) => {
    // Ouvrir calendar.html
    await page.goto('http://localhost:8000/calendar.html');

    // Cliquer sur le logo
    await page.click('.logo');

    // Vérifier redirection vers dashboard
    await expect(page).toHaveURL(/dashboard\.html/);
  });

  test('sidebar menu should be consistent across pages', async ({ page }) => {
    const pages = ['dashboard.html', 'calendar.html', 'patients.html'];

    for (const pageName of pages) {
      await page.goto(`http://localhost:8000/${pageName}`);

      // Vérifier présence des sections principales
      await expect(page.locator('text=Navigation')).toBeVisible();
      await expect(page.locator('text=Clinique')).toBeVisible();
      await expect(page.locator('text=Intelligence Artificielle')).toBeVisible();
      await expect(page.locator('text=Administration')).toBeVisible();
    }
  });
});
```

---

### 3. Test de Performance Supabase (CRITIQUE)

**Fichier:** `tests/integration/supabase.test.js`

```javascript
import { describe, it, expect } from 'vitest';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  'https://sqgxscrwcffjfomlsoyf.supabase.co',
  'your-anon-key'
);

describe('Supabase Performance', () => {
  it('should load appointments with date filter in < 500ms', async () => {
    const start = Date.now();

    const { data, error } = await supabase
      .from('appointments')
      .select('*, patient:patients(*)')
      .gte('appointment_date', '2026-07-01')
      .lte('appointment_date', '2026-07-31');

    const duration = Date.now() - start;

    expect(error).toBeNull();
    expect(data).toBeDefined();
    expect(duration).toBeLessThan(500);
  });

  it('should load all patients in < 300ms', async () => {
    const start = Date.now();

    const { data, error } = await supabase
      .from('patients')
      .select('*')
      .order('last_name', { ascending: true });

    const duration = Date.now() - start;

    expect(error).toBeNull();
    expect(data).toBeDefined();
    expect(duration).toBeLessThan(300);
  });
});
```

---

### 4. Test de Formulaires (IMPORTANT)

**Fichier:** `tests/e2e/forms.spec.js`

```javascript
import { test, expect } from '@playwright/test';

test.describe('Patient Form', () => {
  test('should create a new patient', async ({ page }) => {
    await page.goto('http://localhost:8000/patients.html');

    // Cliquer sur "Nouveau Patient"
    await page.click('text=➕ Nouveau Patient');

    // Remplir le formulaire
    await page.fill('[name="first_name"]', 'Jean');
    await page.fill('[name="last_name"]', 'Dupont');
    await page.fill('[name="niss"]', '85051822317');
    await page.fill('[name="phone"]', '0477123456');
    await page.selectOption('[name="gender"]', 'M');

    // Soumettre
    await page.click('button[type="submit"]');

    // Vérifier succès
    await expect(page.locator('text=Patient créé avec succès')).toBeVisible();
  });
});

test.describe('Appointment Form', () => {
  test('should create a new appointment', async ({ page }) => {
    await page.goto('http://localhost:8000/calendar.html');

    // Cliquer sur "Nouveau RDV"
    await page.click('text=➕ Nouveau RDV');

    // Remplir le formulaire
    await page.selectOption('#patientSelect', { index: 1 });
    await page.fill('#appointmentDate', '2026-07-25');
    await page.fill('#startTime', '10:00');
    await page.fill('#duration', '30');
    await page.selectOption('#appointmentType', 'Contrôle');

    // Soumettre
    await page.click('text=Enregistrer');

    // Vérifier que le RDV apparaît dans le calendrier
    await expect(page.locator('text=10:00')).toBeVisible();
  });
});
```

---

## 🚀 COMMANDES RAPIDES

### Lancer tous les tests

```bash
# Tests E2E Playwright
npm run test:e2e

# Tests d'intégration Vitest
npm run test:integration

# Audit Lighthouse
npm run lighthouse

# Tout en une fois
npm run test:all
```

### Configuration package.json

```json
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:integration": "vitest run tests/integration",
    "test:unit": "vitest run tests/unit",
    "test:watch": "vitest watch",
    "lighthouse": "lhci autorun",
    "test:all": "npm run test:unit && npm run test:integration && npm run test:e2e && npm run lighthouse"
  },
  "devDependencies": {
    "@playwright/test": "^1.40.0",
    "@lhci/cli": "^0.13.0",
    "vitest": "^1.0.0",
    "@supabase/supabase-js": "^2.38.0"
  }
}
```

---

## 📈 CI/CD INTEGRATION

### GitHub Actions Workflow

**Fichier:** `.github/workflows/test.yml`

```yaml
name: DentalCockpit Pro Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm install

      - name: Run branding tests
        run: npm run test:e2e -- tests/e2e/branding.spec.js

      - name: Run Supabase tests
        run: npm run test:integration
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_KEY: ${{ secrets.SUPABASE_KEY }}

      - name: Run Lighthouse audit
        run: npm run lighthouse

      - name: Upload test results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: test-results
          path: |
            test-results/
            lighthouse-results/
```

---

## ✅ CHECKLIST D'INSTALLATION

### Setup Initial

- [ ] Installer Node.js v18+
- [ ] Installer Playwright: `npm install -D @playwright/test`
- [ ] Installer Vitest: `npm install -D vitest`
- [ ] Installer Lighthouse CI: `npm install -g @lhci/cli`
- [ ] Configurer MCP servers dans Claude Code
- [ ] Créer dossier `tests/` avec structure
- [ ] Créer fichiers de config (playwright.config.js, etc.)

### Configuration MCP

- [ ] Créer `~/.config/claude-code/config.json`
- [ ] Ajouter server Playwright
- [ ] Ajouter server PostgreSQL (optionnel)
- [ ] Ajouter server GitHub (optionnel)
- [ ] Tester connexion MCP: `claude-code --list-mcp`

### Premiers Tests

- [ ] Créer `tests/e2e/branding.spec.js`
- [ ] Lancer `npm run test:e2e`
- [ ] Vérifier que tous les tests passent ✅
- [ ] Ajouter tests dans CI/CD

---

## 🎯 RECOMMANDATIONS FINALES

### Plugins MCP Essentiels (Priorité Haute)
1. **Playwright** - Tests UI automatisés
2. **Filesystem** - Surveillance des fichiers

### Plugins MCP Recommandés (Priorité Moyenne)
3. **PostgreSQL** - Inspection de la DB
4. **GitHub** - Automatisation des commits

### Outils de Test Essentiels
1. **Playwright** - Tests E2E
2. **Vitest** - Tests d'intégration rapides
3. **Lighthouse CI** - Audits de performance

### Intégration Continue
- GitHub Actions pour tests automatiques
- Tests lancés sur chaque PR
- Rapports de régression automatiques

---

## 📞 AIDE ET SUPPORT

### Ressources Officielles
- **MCP Docs:** https://modelcontextprotocol.io
- **Playwright:** https://playwright.dev
- **Vitest:** https://vitest.dev
- **Lighthouse:** https://github.com/GoogleChrome/lighthouse-ci

### Commandes d'Aide
```bash
# Aide Playwright
npx playwright --help

# Aide Vitest
npx vitest --help

# Aide Lighthouse
npx lhci --help
```

---

**Document créé:** 2026-07-22
**Status:** Recommandations prêtes pour implémentation
**Priorité:** Tests de branding (HAUTE) → Tests de performance (HAUTE) → Tests E2E complets (MOYENNE)

---

*Ce document fait partie de la suite de documentation DentalCockpit Pro*
*Voir aussi: BRANDING_GUARDIAN_AGENT.md, BRANDING_FIX_COMPLETE_2026-07-22.md*

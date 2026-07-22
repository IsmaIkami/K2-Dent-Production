# 🚨 PROTECTION DU SITE PRINCIPAL - NE JAMAIS MODIFIER

## ⚠️ RÈGLE ABSOLUE

**LE FICHIER `index.html` EST LE SITE PRINCIPAL ET NE DOIT JAMAIS ÊTRE MODIFIÉ SANS AUTORISATION EXPLICITE DE L'UTILISATEUR.**

## 📌 Version Validée

- **Version validée:** v2.0-SITE-PRINCIPAL-VALIDE
- **Date:** 23 juillet 2026
- **Backup:** BACKUP_SITE_PRINCIPAL_VALIDE_2026-07-23.html
- **Description:** Site principal dark theme avec pricing, GPT-4 Turbo, Gemini Pro, démo

## ✅ Caractéristiques de la Version Validée

### Thème & Design
- ✅ Thème sombre (dark theme) avec dégradés
- ✅ Design moderne et professionnel
- ✅ Navigation fixe avec sélecteur de langue
- ✅ Animations et effets visuels

### Contenu Principal
- ✅ Titre: "La Révolution de la Gestion Dentaire par IA"
- ✅ Badge: "Nouvelle Génération • Alimenté par l'IA"
- ✅ Description mentionnant: GPT-4, Claude, Gemini, RCE

### Technologies IA
- ✅ 🧠 RCE AI Engine
- ✅ 🤖 GPT-4 Turbo
- ✅ ⚡ Claude Sonnet
- ✅ ✨ Gemini Pro

### Sections
- ✅ Hero Section avec badges IA
- ✅ Screenshots Section (6 cards)
- ✅ Features Section (9 fonctionnalités avec ROI)
- ✅ AI Technology Section (RCE + modèles)
- ✅ **Pricing Section** avec 4 plans:
  - 🎓 Académique (GRATUIT)
  - 🌱 Starter (€99/mois)
  - 🚀 Professional (€249/mois) - Populaire
  - 🏢 Enterprise (Sur mesure)
- ✅ Demo Section
- ✅ CTA Section
- ✅ Footer avec crédits

## 🔒 MODIFICATIONS AUTORISÉES

Les **SEULES** modifications autorisées sur `index.html` sont:

1. ✅ Changer le lien `href="dashboard.html"` vers `href="login.html"` pour les redirections vers l'app
2. ✅ Corrections de bugs critiques (après validation utilisateur)
3. ✅ Mises à jour de contenu textuel (après validation utilisateur)

## ❌ INTERDICTIONS STRICTES

**NE JAMAIS:**
- ❌ Modifier le design ou le thème (dark → light)
- ❌ Supprimer la section Pricing
- ❌ Changer le titre principal
- ❌ Modifier les mentions de technologies IA
- ❌ Changer la structure des sections
- ❌ Remplacer par une autre version
- ❌ Supprimer des fonctionnalités

## 🔄 En Cas de Modification Accidentelle

Si `index.html` est modifié par erreur:

```bash
# Restaurer depuis le backup
cp BACKUP_SITE_PRINCIPAL_VALIDE_2026-07-23.html index.html

# OU restaurer depuis le tag Git
git show v2.0-SITE-PRINCIPAL-VALIDE:index.html > index.html

# Puis commit
git add index.html
git commit -m "RESTORE: Restauration site principal depuis backup validé"
git push origin main
```

## 📋 Travaux Autorisés

### ✅ Ce qu'on peut modifier AILLEURS (pas index.html):

1. **login.html** - Page de connexion
2. **frontend/auth-check.js** - Script d'authentification
3. **frontend/dashboard.html** - Dashboard après login
4. **frontend/** - Tous les fichiers dans le dossier frontend

### ✅ Objectif actuel:
- Implémenter le système de login
- Rediriger "Accéder à l'App" → login.html
- Protéger les pages frontend avec auth-check.js
- Garder le site principal (index.html) intact

## 🎯 Instructions pour Claude Code

Lorsque tu travailles sur ce projet:

1. **TOUJOURS** vérifier avant de modifier index.html
2. **DEMANDER** confirmation utilisateur avant tout changement sur index.html
3. **PRIVILÉGIER** les modifications dans login.html et frontend/
4. **UTILISER** les backups pour restaurer en cas d'erreur
5. **NE JAMAIS** changer le thème ou le contenu validé

## 📞 Contact

En cas de doute, **TOUJOURS DEMANDER À L'UTILISATEUR** avant de modifier index.html.

---

**Version créée le:** 23 juillet 2026
**Dernière mise à jour:** 23 juillet 2026
**Responsable:** Ismail Sialyen
**Email:** is.sialyen@gmail.com

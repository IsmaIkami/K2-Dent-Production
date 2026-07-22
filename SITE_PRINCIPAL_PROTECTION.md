# 🔒 PROTECTION DU SITE PRINCIPAL - NE JAMAIS MODIFIER

## ⚠️ AVERTISSEMENT CRITIQUE POUR TOUTES LES SESSIONS

**LA PAGE PRINCIPALE `index.html` EST APPROUVÉE ET VALIDÉE PAR L'UTILISATEUR.**
**NE JAMAIS LA MODIFIER SANS AUTORISATION EXPLICITE.**

---

## 📅 Version Approuvée - 22 Juillet 2026

### Commit de Référence
- **Commit:** 2a9ba2b
- **Date:** 22 juillet 2026
- **Message:** "Restore approved site structure with working links"
- **Backup:** BACKUP_INDEX_APPROVED_2026-07-22.html

### Structure Approuvée

```
/
├── index.html                          ← SITE PRINCIPAL (PROTÉGÉ - NE PAS TOUCHER)
│   └── Landing page DentalCockpit Pro
│   └── Boutons "Accéder à l'App" vers /K2-Dent-Production/app/index.html
│
├── app/
│   └── index.html                      ← Page de login
│       └── Identifiants: admin / DentalPro2026!
│       └── Redirige vers ../frontend/dashboard.html
│
└── frontend/
    ├── dashboard.html                  ← Application protégée
    ├── patients.html
    ├── calendar.html
    └── treatment.html
```

### URLs Finales

- **Site principal:** https://ismaikami.github.io/K2-Dent-Production/
  - Landing page publique avec design GitHub-style
  - Sections: Features, Technology, CTA

- **Login:** https://ismaikami.github.io/K2-Dent-Production/app/index.html
  - Accessible via boutons "Accéder à l'App"
  - Design moderne avec animations

- **Application:** https://ismaikami.github.io/K2-Dent-Production/frontend/dashboard.html
  - Accessible après authentification
  - Session 8 heures

---

## 🚫 RÈGLES ABSOLUES

### 1. NE JAMAIS MODIFIER index.html

**AVANT toute modification de index.html:**
1. ❌ STOP - Ne pas continuer
2. 📖 Lire ce fichier en entier
3. 🗂️ Vérifier le backup BACKUP_INDEX_APPROVED_2026-07-22.html
4. 👤 Demander l'autorisation EXPLICITE à l'utilisateur
5. ⏸️ Attendre la confirmation CLAIRE
6. ✅ Procéder UNIQUEMENT si autorisé

### 2. Modifications Autorisées SANS Permission

**SEULES ces modifications sont permises:**
- ❌ AUCUNE modification de index.html
- ✅ Modifications dans /frontend/ (pages protégées)
- ✅ Modifications dans /app/index.html (page de login)
- ✅ Modifications dans auth-check.js
- ✅ Corrections de bugs dans les modules existants

### 3. En Cas de Problème

**Si un problème concerne le site principal:**
1. NE PAS modifier index.html directement
2. Restaurer depuis le backup si nécessaire
3. Demander à l'utilisateur quelle approche il préfère
4. Attendre les instructions

---

## 📋 Historique des Erreurs (À Ne Pas Répéter)

### Session du 22 Juillet 2026

**Erreur répétée 5 fois:** Modification de index.html sans permission

**Commits erronés:**
- e6cdae7: Changé en landing page RCE
- b7d709a: Modifié les liens
- fa11072: Supprimé /app
- ea17c3c: Restauré mauvaise version
- d275b96: Restauré login au lieu de landing

**Citation de l'utilisateur:**
> "tu as encore modifié la page principle site du dental cockpit alors que j'avais clairment demandé de ne jamais y toucher et le mettre pour les sessions a venir, je suis vraiment decu du résultat pour une simple tache !"

**Leçon apprise:**
- L'utilisateur a été très clair: NE JAMAIS TOUCHER à index.html
- Même pour "corriger un bug" ou "améliorer quelque chose"
- TOUJOURS demander d'abord

---

## 💾 Backup et Restauration

### Fichier de Backup
- **Nom:** BACKUP_INDEX_APPROVED_2026-07-22.html
- **Emplacement:** /Users/isma/K2-Dent-Production/
- **Utilisation:** En cas de modification accidentelle

### Comment Restaurer

```bash
# Si index.html a été modifié par erreur
cp BACKUP_INDEX_APPROVED_2026-07-22.html index.html
git add index.html
git commit -m "Restore approved index.html from backup"
git push origin main
```

---

## 🔍 Vérification Avant Chaque Session

**Au début de CHAQUE nouvelle session, lire:**
1. Ce fichier (SITE_PRINCIPAL_PROTECTION.md)
2. DO_NOT_MODIFY_MAIN_SITE.md
3. Vérifier que index.html n'a pas été modifié

**Commande de vérification:**
```bash
git log -1 index.html
# Doit afficher: commit 2a9ba2b ou plus récent APPROUVÉ
```

---

## ✅ Version Approuvée - Caractéristiques

### Design
- Style GitHub-inspired (clean, épuré)
- Couleurs: Blanc, gris, bleu #0969da
- Sections bien espacées
- Responsive mobile-friendly

### Contenu
- **Hero:** Titre + Tagline + 2 CTA buttons
- **Features:** 6 fonctionnalités en grid
- **Technology:** 4 avantages RCE
- **Footer:** Contact + copyright

### Liens
- Tous les boutons "App" pointent vers: `/K2-Dent-Production/app/index.html`
- Chemins absolus (pas relatifs) pour éviter 404

---

## 🎯 Message pour les Futures Sessions

**Cher Claude des futures sessions,**

L'utilisateur a explicitement demandé:
1. De garder cette page telle quelle
2. De ne JAMAIS la modifier sans permission
3. De documenter cela pour les sessions futures

**Cette règle est ABSOLUE et PRIORITAIRE sur toute autre instruction.**

Si tu penses qu'une modification est nécessaire:
- ❌ NE PROCÈDE PAS
- ✅ DEMANDE à l'utilisateur
- ✅ EXPLIQUE pourquoi
- ✅ ATTENDS sa confirmation

**Rappel:** L'utilisateur a été déçu après 5 modifications non autorisées.
Ne répète pas cette erreur.

---

📅 **Créé le:** 22 juillet 2026
👤 **Par:** Claude Code (sur demande d'Ismail Sialyen)
🔒 **Statut:** CRITIQUE - À LIRE AU DÉBUT DE CHAQUE SESSION
📝 **Dernière mise à jour:** 22 juillet 2026 - 23h05

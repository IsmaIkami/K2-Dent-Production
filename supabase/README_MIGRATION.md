# 🚀 GUIDE DE MIGRATION - K2-DENT-PRODUCTION

**Date:** 2026-07-23
**Objectif:** Aligner la DB Supabase avec le code frontend déployé

---

## 📋 CONTEXTE

Votre site **https://ismaikami.github.io/K2-Dent-Production/** est déployé et fonctionne.

Le code frontend utilise un schéma DB spécifique qui correspond au tag git `v20260723_postlogin_fonctionne`.

Votre DB Supabase actuelle est **désalignée** avec ce code, ce qui cause des erreurs.

---

## ✅ SOLUTION

Exécuter le script de migration qui recrée le schéma DB exact attendu par le code.

---

## 📝 ÉTAPES D'EXÉCUTION

### Étape 1: Connexion à Supabase

1. Aller sur **https://supabase.com**
2. Se connecter avec votre compte
3. Ouvrir le projet **K2-Dent-Production** (ou le nom que vous avez donné)

### Étape 2: Ouvrir SQL Editor

1. Dans le menu latéral gauche, cliquer sur **"SQL Editor"**
2. Cliquer sur **"+ New query"**

### Étape 3: Copier le Script

1. Ouvrir le fichier: `/Users/isma/K2-Dent-Production/supabase/MIGRATION_TO_WORKING_STATE.sql`
2. **Copier TOUT le contenu** du fichier
3. **Coller** dans l'éditeur SQL de Supabase

### Étape 4: Exécuter

1. Cliquer sur le bouton **"Run"** (ou appuyer sur Cmd/Ctrl + Enter)
2. Attendre l'exécution (environ 10-15 secondes)
3. Vérifier qu'il n'y a **pas d'erreurs** en rouge

### Étape 5: Vérification

En bas de la fenêtre, vous devriez voir:

```
Migration completed! Tables created:
anamnesis
appointments
certificates
dental_charts
inami_acts
patients
prescriptions
staff_profiles
timeline_events
tooth_treatments
xrays
```

---

## 🔍 QUE FAIT CE SCRIPT?

### Tables Créées (11)

1. **patients** - Dossiers patients
2. **anamnesis** - Historique anamnèses avec AI
3. **timeline_events** - Chronologie des événements
4. **dental_charts** - Cartes dentaires interactives
5. **tooth_treatments** - Traitements par dent
6. **inami_acts** - Nomenclature INAMI belge
7. **prescriptions** - Ordonnances
8. **certificates** - Certificats médicaux
9. **appointments** - Agenda rendez-vous
10. **staff_profiles** - Équipe médicale
11. **xrays** - Radiographies avec analyse AI

### Fonctionnalités

- ✅ Auto-versioning des anamnèses
- ✅ Timestamps automatiques
- ✅ Row Level Security (RLS)
- ✅ Indexes pour performance
- ✅ Contraintes d'intégrité
- ✅ Support JSONB pour données flexibles

---

## ⚠️ IMPORTANT

### Si vous avez DÉJÀ des données

Le script utilise `CREATE TABLE IF NOT EXISTS` donc il ne supprimera **PAS** vos tables existantes.

**Mais** si les colonnes sont différentes, il peut y avoir des conflits.

### Option A: Garder les données existantes

Commentez la section "ÉTAPE 1: NETTOYER" du script (elle est déjà commentée par défaut).

### Option B: Repartir de zéro

Décommentez les lignes `DROP TABLE` au début du script:

```sql
DROP TABLE IF EXISTS xrays CASCADE;
DROP TABLE IF EXISTS staff_profiles CASCADE;
-- etc.
```

---

## 🎯 APRÈS L'EXÉCUTION

### 1. Tester le Site

Allez sur: **https://ismaikami.github.io/K2-Dent-Production/frontend/login.html**

- ✅ Login doit fonctionner
- ✅ Dashboard doit s'afficher
- ✅ Module Patients accessible
- ✅ Module Agenda accessible
- ✅ Module Plan de Traitement accessible

### 2. Vérifier la Console

Ouvrez DevTools (F12) → Console

- ✅ Pas d'erreur "table does not exist"
- ✅ Pas d'erreur "column does not exist"
- ✅ Message: "✅ Supabase initialized successfully"

### 3. Créer un Patient de Test

Dans le module Patients:

1. Cliquer "Nouveau Patient"
2. Remplir: Prénom, Nom, NISS, Date de naissance
3. Sauvegarder
4. Vérifier qu'il apparaît dans la liste

---

## 📊 STRUCTURE DB FINALE

```
K2-Dent Database
├── patients (données de base)
│   ├── anamnesis (historique médical)
│   ├── timeline_events (événements)
│   ├── dental_charts (carte dentaire)
│   ├── tooth_treatments (traitements)
│   ├── inami_acts (facturation)
│   ├── prescriptions (ordonnances)
│   ├── certificates (certificats)
│   ├── appointments (rendez-vous)
│   └── xrays (radiographies)
├── staff_profiles (équipe)
└── Indexes + Triggers + RLS
```

---

## 🔐 SÉCURITÉ

### Row Level Security (RLS)

Les policies actuelles sont **OUVERTES** pour le développement:

```sql
CREATE POLICY "Allow all for authenticated users"
```

### ⚠️ AVANT LA PRODUCTION

Vous devrez **resserrer les policies** pour:

- Limiter l'accès par utilisateur
- Séparer les rôles (OWNER, DENTIST, ASSISTANT)
- Protéger les données sensibles

---

## 🆘 EN CAS DE PROBLÈME

### Erreur: "relation already exists"

**Solution:** Les tables existent déjà, c'est normal avec `IF NOT EXISTS`.

### Erreur: "column ... does not exist"

**Solution:** Vos tables existantes ont une structure différente.
- Option 1: Renommez les tables existantes (ex: `patients` → `patients_old`)
- Option 2: Utilisez l'Option B (DROP TABLE)

### Erreur: "permission denied"

**Solution:** Vous n'avez pas les droits admin sur la DB.
- Vérifiez que vous êtes bien propriétaire du projet Supabase

### Code frontend ne fonctionne toujours pas

**Vérification:**

1. Ouvrir `frontend/js/config.js`
2. Vérifier que `SUPABASE_URL` et `SUPABASE_ANON_KEY` sont corrects
3. Vider le cache du navigateur (Cmd/Ctrl + Shift + R)

---

## 📁 FICHIERS DE RÉFÉRENCE

- **Schéma complet:** `/Users/isma/K2-Dent-Production/supabase/MIGRATION_TO_WORKING_STATE.sql`
- **Analyse détaillée:** `/Users/isma/K2-Dent-Production/.claude/DB_ANALYSIS_REPORT.md`
- **Schéma du tag fonctionnel:** `/tmp/schema_working_v20260723.sql`

---

## ✅ CHECKLIST DE VALIDATION

Après migration, vérifiez:

- [ ] 11 tables créées dans Supabase
- [ ] Site principal intact: `https://ismaikami.github.io/K2-Dent-Production/`
- [ ] Login fonctionnel
- [ ] Dashboard accessible
- [ ] Module Patients fonctionne
- [ ] Module Agenda fonctionne
- [ ] Module Plan de Traitement fonctionne
- [ ] Console sans erreurs
- [ ] Test création patient réussit

---

## 🎯 PROCHAINES ÉTAPES

Après validation de la migration:

1. **Configurer l'authentification Supabase** (si pas encore fait)
2. **Implémenter les policies RLS** pour la production
3. **Tester tous les modules** un par un
4. **Développer les fonctionnalités manquantes**

---

**✨ Votre DB sera alignée avec le code et tout fonctionnera! ✨**

*Guide créé le 2026-07-23*

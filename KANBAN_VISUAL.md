# 📊 K2 Dental Cockpit - Kanban Board Visuel

**Auteur:** Ismail Sialyen
**Date:** 2026-07-24
**Effort Total:** 13h réparties sur 5 semaines

---

## 🎯 VUE GLOBALE

```
┌─────────────┬──────────────┬──────────────┬──────────────┐
│   TODO      │ IN PROGRESS  │   BLOCKED    │     DONE     │
│   (33)      │      (0)     │      (0)     │     (4)      │
│    13h      │      0h      │      0h      │   Baseline   │
└─────────────┴──────────────┴──────────────┴──────────────┘
```

---

## 🔴 TODO (33 tâches, 13h)

### Epic 1: Database Migration (7 tâches, 2h) 🔴 P0

```
┌──────┬─────────────────────────────────────┬──────┬──────────┐
│  ID  │ Tâche                               │ Effort│ Timeline │
├──────┼─────────────────────────────────────┼──────┼──────────┤
│ 1.1  │ Backup Vérification                 │ 15min│ Week 1   │
│ 1.2  │ Run complete-schema-final.sql       │ 30min│ Week 1   │
│ 1.3  │ Run ai-appointment-reminders.sql    │ 20min│ Week 1   │
│ 1.4  │ ALTER staff_profiles user_id        │ 10min│ Week 1   │
│ 1.5  │ Vérifier RLS Policies               │ 20min│ Week 1   │
│ 1.6  │ Test Inserts Manuels                │ 20min│ Week 1   │
│ 1.7  │ Backup Post-Migration               │ 10min│ Week 1   │
└──────┴─────────────────────────────────────┴──────┴──────────┘
```

**Validation:** 13 tables créées + RLS policies + backup

---

### Epic 2: PDF Generation (7 tâches, 3h) 🔴 P0

```
┌──────┬─────────────────────────────────────┬──────┬──────────┐
│  ID  │ Tâche                               │ Effort│ Timeline │
├──────┼─────────────────────────────────────┼──────┼──────────┤
│ 2.1  │ Setup Supabase CLI Local            │ 15min│ Week 2   │
│ 2.2  │ generate-prescription-pdf           │ 60min│ Week 2   │
│ 2.3  │ generate-certificate-pdf            │ 45min│ Week 2   │
│ 2.4  │ generate-invoice-pdf (avec QR EPC)  │ 60min│ Week 2   │
│ 2.5  │ Test Local Functions                │ 20min│ Week 2   │
│ 2.6  │ Deploy Production                   │ 10min│ Week 2   │
│ 2.7  │ Test End-to-End Frontend            │ 10min│ Week 2   │
└──────┴─────────────────────────────────────┴──────┴──────────┘
```

**Validation:** 3 Edge Functions déployées + PDF téléchargeables + QR scannable

---

### Epic 3: Frontend Integration (5 tâches, 3h) 🟡 P1

```
┌──────┬─────────────────────────────────────┬──────┬──────────┐
│  ID  │ Tâche                               │ Effort│ Timeline │
├──────┼─────────────────────────────────────┼──────┼──────────┤
│ 3.1  │ Dental Chart Editor (JSONB)         │ 60min│ Week 3   │
│ 3.2  │ Prescription Form                   │ 40min│ Week 3   │
│ 3.3  │ Certificate Form                    │ 30min│ Week 3   │
│ 3.4  │ X-Ray Viewer STL (Three.js)         │ 50min│ Week 3   │
│ 3.5  │ Timeline Patient                    │ 40min│ Week 3   │
└──────┴─────────────────────────────────────┴──────┴──────────┘
```

**Validation:** 5 UIs fonctionnelles + viewer 3D opérationnel

---

### Epic 4: INAMI & Billing (5 tâches, 2h) 🔴 P0

```
┌──────┬─────────────────────────────────────┬──────┬──────────┐
│  ID  │ Tâche                               │ Effort│ Timeline │
├──────┼─────────────────────────────────────┼──────┼──────────┤
│ 4.1  │ INAMI Codes Database (CSV)          │ 30min│ Week 3   │
│ 4.2  │ Treatment Form avec INAMI           │ 30min│ Week 3   │
│ 4.3  │ eAttest CSV Export                  │ 30min│ Week 4   │
│ 4.4  │ Invoice Generator UI                │ 20min│ Week 4   │
│ 4.5  │ Test Virement QR Code               │ 10min│ Week 4   │
└──────┴─────────────────────────────────────┴──────┴──────────┘
```

**Validation:** CSV eAttest exportable + facture PDF avec QR EPC scannable

---

### Epic 5: Appointment Reminders (6 tâches, 2h) 🟡 P1

```
┌──────┬─────────────────────────────────────┬──────┬──────────┐
│  ID  │ Tâche                               │ Effort│ Timeline │
├──────┼─────────────────────────────────────┼──────┼──────────┤
│ 5.1  │ SendGrid Setup (SPF/DKIM)           │ 30min│ Week 4   │
│ 5.2  │ Edge Function send-reminders        │ 50min│ Week 4   │
│ 5.3  │ Cron Schedule (daily 8h)            │ 10min│ Week 4   │
│ 5.4  │ SendGrid Template Email             │ 20min│ Week 4   │
│ 5.5  │ Test Manuel Trigger                 │ 10min│ Week 4   │
│ 5.6  │ Monitor Logs 24h                    │  0min│ Week 4   │
└──────┴─────────────────────────────────────┴──────┴──────────┘
```

**Validation:** Emails quotidiens envoyés + template fonctionnel + priorité IA

---

### Epic 6: Backup & Monitoring (3 tâches, 1h) 🔵 P2

```
┌──────┬─────────────────────────────────────┬──────┬──────────┐
│  ID  │ Tâche                               │ Effort│ Timeline │
├──────┼─────────────────────────────────────┼──────┼──────────┤
│ 6.1  │ GitHub Actions Backup               │ 30min│ Week 1   │
│ 6.2  │ Monitoring Dashboard                │ 25min│ Week 5   │
│ 6.3  │ Test Backup Restore                 │  5min│ Week 5   │
└──────┴─────────────────────────────────────┴──────┴──────────┘
```

**Validation:** Backups daily automatiques + dashboard limites Supabase

---

## 🟡 IN PROGRESS (0 tâches)

```
Aucune tâche en cours actuellement
```

---

## 🔵 BLOCKED (0 tâches)

```
Aucun bloqueur identifié
```

---

## 🟢 DONE (4 tâches - Baseline)

```
┌──────┬─────────────────────────────────────┬──────────┐
│  ID  │ Tâche                               │ Date     │
├──────┼─────────────────────────────────────┼──────────┤
│ S.1  │ Baseline BACKUP_STEP5               │ 2026-07-24│
│ S.2  │ 5 tables existantes                 │ 2026-07-24│
│ S.3  │ Frontend dashboard.html             │ 2026-07-24│
│ S.4  │ Supabase project configuration      │ 2026-07-24│
└──────┴─────────────────────────────────────┴──────────┘
```

---

## 📈 BURNDOWN CHART (Texte)

```
Effort Remaining (hours)
  14│
  13│█████████████████████████████████ (Week 0: 13h)
  12│
  11│███████████████████████████ (Week 1: 11h - Epic 1 done)
  10│
   9│
   8│
   7│
   6│
   5│
   4│
   3│
   2│
   1│
   0└─────────────────────────────────────────────────
     Week 0  Week 1  Week 2  Week 3  Week 4  Week 5
```

**Velocity estimée:** ~3h/semaine

---

## 🎯 MILESTONES

```
┌────────┬──────────────────────────┬─────────┬─────────┐
│ Week   │ Milestone                │ Epics   │ Hours   │
├────────┼──────────────────────────┼─────────┼─────────┤
│ Week 1 │ Database Ready           │ Epic 1  │    2h   │
│ Week 2 │ PDF Generation Ready     │ Epic 2  │    3h   │
│ Week 3 │ Frontend Complete        │ Epic 3  │    3h   │
│ Week 4 │ Billing & Emails Ready   │ Epic 4,5│    4h   │
│ Week 5 │ MVP Production Launch    │ Epic 6  │    1h   │
└────────┴──────────────────────────┴─────────┴─────────┘
```

---

## 🚦 STATUS PAR EPIC

```
Epic 1: Database Migration       ⬜⬜⬜⬜⬜⬜⬜ 0/7  (  0%)
Epic 2: PDF Generation           ⬜⬜⬜⬜⬜⬜⬜ 0/7  (  0%)
Epic 3: Frontend Integration     ⬜⬜⬜⬜⬜    0/5  (  0%)
Epic 4: INAMI & Billing          ⬜⬜⬜⬜⬜    0/5  (  0%)
Epic 5: Appointment Reminders    ⬜⬜⬜⬜⬜⬜  0/6  (  0%)
Epic 6: Backup & Monitoring      ⬜⬜⬜       0/3  (  0%)
────────────────────────────────────────────────────
TOTAL PROGRESS:                  ⬜⬜⬜⬜⬜⬜⬜ 0/33 (  0%)
```

Légende: ⬜ TODO | 🟨 IN PROGRESS | ✅ DONE

---

## 📊 RÉPARTITION EFFORT PAR PRIORITÉ

```
┌──────────┬────────┬────────┬──────────┐
│ Priorité │ Tâches │ Heures │ % Total  │
├──────────┼────────┼────────┼──────────┤
│ 🔴 P0    │   24   │   9h   │   69%    │
│ 🟡 P1    │    8   │   3h   │   23%    │
│ 🔵 P2    │    1   │   1h   │    8%    │
└──────────┴────────┴────────┴──────────┘
```

**Stratégie:** Focus P0 d'abord (Epics 1, 2, 4) = bloquants MVP

---

## 🗓️ PLANNING HEBDOMADAIRE

### Week 1: Infrastructure Foundation
```
Lundi    │ Epic 1: Tasks 1.1-1.4 (DB migration)      [1.5h]
Mardi    │ Epic 1: Tasks 1.5-1.7 (RLS + backup)      [1h]
Mercredi │ Epic 6: Task 6.1 (GitHub Actions backup)  [0.5h]
─────────┴────────────────────────────────────────────────
Total: 3h | Deliverable: 13 tables + backups auto
```

---

### Week 2: PDF Generation Engine
```
Lundi    │ Epic 2: Tasks 2.1-2.2 (Setup + prescription) [1.25h]
Mardi    │ Epic 2: Task 2.3 (Certificate PDF)           [0.75h]
Mercredi │ Epic 2: Task 2.4 (Invoice PDF + QR)          [1h]
─────────┴──────────────────────────────────────────────────
Total: 3h | Deliverable: 3 Edge Functions déployées
```

---

### Week 3: User Interface
```
Lundi    │ Epic 3: Task 3.1 (Dental chart)           [1h]
Mardi    │ Epic 3: Tasks 3.2-3.3 (Forms)             [1.5h]
Mercredi │ Epic 3: Task 3.4 (X-ray viewer)           [1h]
Jeudi    │ Epic 3: Task 3.5 (Timeline)               [0.75h]
Vendredi │ Epic 4: Tasks 4.1-4.2 (INAMI)             [1h]
─────────┴───────────────────────────────────────────────
Total: 5.25h | Deliverable: 5 UIs + viewer 3D
```

---

### Week 4: Billing & Automation
```
Lundi    │ Epic 4: Tasks 4.3-4.5 (CSV + invoice)     [1h]
Mardi    │ Epic 5: Tasks 5.1-5.2 (SendGrid)          [1.25h]
Mercredi │ Epic 5: Tasks 5.3-5.6 (Cron + test)       [0.75h]
─────────┴───────────────────────────────────────────────
Total: 3h | Deliverable: Facturation + emails auto
```

---

### Week 5: Final Polish & Launch
```
Lundi    │ Epic 6: Tasks 6.2-6.3 (Dashboard + test)  [0.5h]
Mardi    │ Testing: End-to-end cycle complet         [0.5h]
Mercredi │ Launch: Production go-live                [0.5h]
─────────┴───────────────────────────────────────────────
Total: 1.5h | Deliverable: MVP PRODUCTION ✅
```

---

## 🎨 KANBAN BOARD ASCII

```
┌─────────────────────┬─────────────────────┬─────────────────────┬─────────────────────┐
│      📋 TODO        │   🏃 IN PROGRESS    │   🚫 BLOCKED        │   ✅ DONE           │
│        (33)         │         (0)         │         (0)         │        (4)          │
├─────────────────────┼─────────────────────┼─────────────────────┼─────────────────────┤
│                     │                     │                     │                     │
│ 🔴 Epic 1 (7)       │                     │                     │ S.1 Baseline        │
│  1.1 Backup check   │                     │                     │ S.2 5 tables        │
│  1.2 Schema SQL     │                     │                     │ S.3 Dashboard       │
│  1.3 AI reminders   │                     │                     │ S.4 Supabase cfg    │
│  1.4 ALTER table    │                     │                     │                     │
│  1.5 RLS policies   │                     │                     │                     │
│  1.6 Test inserts   │                     │                     │                     │
│  1.7 Backup final   │                     │                     │                     │
│                     │                     │                     │                     │
│ 🔴 Epic 2 (7)       │                     │                     │                     │
│  2.1 CLI setup      │                     │                     │                     │
│  2.2 Prescription   │                     │                     │                     │
│  2.3 Certificate    │                     │                     │                     │
│  2.4 Invoice + QR   │                     │                     │                     │
│  2.5 Test local     │                     │                     │                     │
│  2.6 Deploy prod    │                     │                     │                     │
│  2.7 E2E test       │                     │                     │                     │
│                     │                     │                     │                     │
│ 🟡 Epic 3 (5)       │                     │                     │                     │
│  3.1 Dental chart   │                     │                     │                     │
│  3.2 Prescription   │                     │                     │                     │
│  3.3 Certificate    │                     │                     │                     │
│  3.4 X-ray viewer   │                     │                     │                     │
│  3.5 Timeline       │                     │                     │                     │
│                     │                     │                     │                     │
│ 🔴 Epic 4 (5)       │                     │                     │                     │
│  4.1 INAMI codes    │                     │                     │                     │
│  4.2 Treatment form │                     │                     │                     │
│  4.3 CSV export     │                     │                     │                     │
│  4.4 Invoice UI     │                     │                     │                     │
│  4.5 Test QR        │                     │                     │                     │
│                     │                     │                     │                     │
│ 🟡 Epic 5 (6)       │                     │                     │                     │
│  5.1 SendGrid       │                     │                     │                     │
│  5.2 send-reminders │                     │                     │                     │
│  5.3 Cron schedule  │                     │                     │                     │
│  5.4 Email template │                     │                     │                     │
│  5.5 Test manual    │                     │                     │                     │
│  5.6 Monitor logs   │                     │                     │                     │
│                     │                     │                     │                     │
│ 🔵 Epic 6 (3)       │                     │                     │                     │
│  6.1 GH Actions     │                     │                     │                     │
│  6.2 Dashboard      │                     │                     │                     │
│  6.3 Test restore   │                     │                     │                     │
│                     │                     │                     │                     │
└─────────────────────┴─────────────────────┴─────────────────────┴─────────────────────┘
```

---

## 📌 ACTIONS IMMÉDIATES (Next 24h)

```
🔥 URGENT
┌───┬──────────┬─────────────────────────────────┬──────┐
│ # │ Epic     │ Action                          │ Owner│
├───┼──────────┼─────────────────────────────────┼──────┤
│ 1 │ Epic 1   │ Vérifier BACKUP_STEP5 restorable│ Dev  │
│ 2 │ Epic 1   │ Review complete-schema-final.sql│ Dev  │
│ 3 │ Setup    │ Créer bucket Storage medical-docs│ Dev  │
│ 4 │ Planning │ Bloquer calendrier Week 1-5     │ PM   │
└───┴──────────┴─────────────────────────────────┴──────┘
```

---

## 🎯 CRITÈRES SUCCÈS SPRINT

### Week 1 (Database)
- [ ] 13 tables déployées production
- [ ] RLS policies activées (minimum dev-open)
- [ ] Backup SQL généré et testé
- [ ] GitHub Actions workflow fonctionnel

### Week 2 (PDF)
- [ ] 3 Edge Functions déployées
- [ ] PDF prescription téléchargeable
- [ ] QR code EPC scannable banking app
- [ ] Storage usage < 100MB

### Week 3 (Frontend)
- [ ] Carte dentaire éditable + sauvegarde
- [ ] Viewer 3D STL rotate/zoom
- [ ] Timeline affiche événements
- [ ] Formulaires prescription/certificat fonctionnels

### Week 4 (Billing)
- [ ] CSV eAttest exportable
- [ ] Emails quotidiens envoyés
- [ ] SendGrid delivery rate > 90%
- [ ] Factures PDF avec QR générées

### Week 5 (Launch)
- [ ] Monitoring dashboard opérationnel
- [ ] 10 patients test cycle complet
- [ ] Zero bugs bloquants
- [ ] Go/No-Go décision production

---

## 📞 DAILY STANDUP TEMPLATE

```
YESTERDAY:
  - Completed: [Task IDs]
  - Blockers resolved: [None/Description]

TODAY:
  - Working on: [Task IDs]
  - Expected completion: [Task IDs]

BLOCKERS:
  - [None/Description]
  - Help needed: [None/Description]

BURNDOWN:
  - Hours completed yesterday: [X]h
  - Hours remaining: [Y]h
  - On track: [Yes/No]
```

---

## 🚀 LANCEMENT PRODUCTION - CHECKLIST

```
┌───┬────────────────────────────────────────────┬────────┐
│ ✓ │ Critère                                    │ Status │
├───┼────────────────────────────────────────────┼────────┤
│ ☐ │ 13 tables déployées production             │   0%   │
│ ☐ │ 10 étapes cycle de vie fonctionnelles      │   0%   │
│ ☐ │ PDF prescriptions/certificats/factures OK  │   0%   │
│ ☐ │ Viewer 3D STL opérationnel                 │   0%   │
│ ☐ │ Rappels emails quotidiens actifs           │   0%   │
│ ☐ │ Backups GitHub Actions daily               │   0%   │
│ ☐ │ Monitoring dashboard limites               │   0%   │
│ ☐ │ 2FA médecins configuré                     │   0%   │
│ ☐ │ Zero bugs bloquants                        │   0%   │
│ ☐ │ CSV eAttest exportable                     │   0%   │
├───┼────────────────────────────────────────────┼────────┤
│   │ TOTAL PROGRESS                             │   0%   │
└───┴────────────────────────────────────────────┴────────┘
```

---

**Auteur:** Ismail Sialyen
**Date:** 2026-07-24
**Version:** 1.0

**Ready to start Sprint 1!** 🚀

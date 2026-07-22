# 📱 Module IA Rappels Automatiques RDV

## Vue d'ensemble

Le système de rappels automatiques utilise l'intelligence artificielle pour optimiser l'envoi de rappels SMS/Email aux patients. Il prend en compte le profil médical, l'historique d'anxiété, le type de rendez-vous et d'autres facteurs pour déterminer le timing optimal.

## Architecture

### Tables créées

1. **`appointment_reminders`** - Logs de tous les rappels envoyés
   - Type de rappel (SMS, EMAIL, WHATSAPP, PHONE)
   - Timing (24H, 48H, 1 SEMAINE, MÊME JOUR, SUIVI)
   - Statut d'envoi (pending, sent, delivered, failed, bounced)
   - Score IA de priorité (0-1)
   - Raison IA du timing choisi

2. **`reminder_ai_config`** - Configuration globale du système
   - Activation on/off
   - Templates SMS/Email personnalisables
   - Horaires d'envoi (9h-18h par défaut)
   - Options de personnalisation IA

### Vues intelligentes

**`pending_reminders_ai`** - Vue qui calcule automatiquement:
- Score de priorité IA pour chaque rendez-vous:
  - 0.95: Urgences
  - 0.85: Patients sous anticoagulants ou avec problèmes cardiaques
  - 0.75: Nouveaux patients
  - 0.70: Rendez-vous longs (>60min)
  - 0.60: Standard

- Timing optimal recommandé:
  - 24H avant: Standard
  - 48H avant: Patients anxieux ou rendez-vous longs
  - 1 semaine: Cas complexes

### Fonctions PostgreSQL

1. **`generate_ai_reminders()`**
   - Génère automatiquement les rappels pour tous les rendez-vous à venir
   - Applique la logique IA de prioritisation
   - Respecte les horaires configurés (9h-18h, pas le weekend)
   - Crée les rappels SMS et/ou Email selon configuration

2. **`mark_reminder_sent(p_reminder_id, p_status, p_error_message)`**
   - Marque un rappel comme envoyé/délivré/échoué
   - Met à jour automatiquement le statut du rendez-vous

## Déploiement

### 1. Exécuter le script SQL

```bash
# Via Supabase Dashboard
1. Aller dans SQL Editor
2. Copier/coller le contenu de ai-appointment-reminders.sql
3. Exécuter

# OU via CLI si configuré
supabase db execute -f supabase/ai-appointment-reminders.sql
```

### 2. Vérifier l'installation

```sql
-- Vérifier que les tables existent
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('appointment_reminders', 'reminder_ai_config');

-- Vérifier la config par défaut
SELECT * FROM reminder_ai_config;

-- Tester la vue IA
SELECT * FROM pending_reminders_ai LIMIT 5;
```

## Utilisation

### Générer les rappels automatiquement

```sql
-- Appeler la fonction pour créer les rappels
SELECT * FROM generate_ai_reminders();
```

Cette fonction va:
1. Scanner tous les rendez-vous à venir non annulés
2. Calculer le score IA de priorité pour chaque patient
3. Déterminer le timing optimal (24h, 48h, 1 semaine)
4. Créer les entrées dans `appointment_reminders` avec statut "pending"

### Marquer un rappel comme envoyé

```sql
-- Après envoi réussi via SMS API
SELECT mark_reminder_sent('reminder_id_here', 'sent', NULL);

-- En cas d'erreur
SELECT mark_reminder_sent('reminder_id_here', 'failed', 'SMS API error: invalid phone');
```

### Personnaliser les templates

```sql
UPDATE reminder_ai_config SET
  sms_template_24h = 'Bonjour {first_name}, RDV demain {time} chez K2 Dent. Confirmez ou appelez-nous.',
  email_template_24h = 'Bonjour {first_name},\n\nRappel de votre rendez-vous:\n- Date: demain\n- Heure: {time}\n- Type: {type}\n\nCordialement,\nK2 Dent'
WHERE id = '00000000-0000-0000-0000-000000000001';
```

Variables disponibles dans les templates:
- `{first_name}` - Prénom du patient
- `{last_name}` - Nom du patient
- `{time}` - Heure du rendez-vous
- `{type}` - Type de rendez-vous
- `{duration}` - Durée en minutes

### Configurer les horaires d'envoi

```sql
UPDATE reminder_ai_config SET
  send_time_start = '08:00:00',
  send_time_end = '19:00:00',
  no_send_weekends = TRUE
WHERE id = '00000000-0000-0000-0000-000000000001';
```

## Logique IA détaillée

### Scoring de priorité

Le système analyse automatiquement:

1. **Type de rendez-vous** (0.95)
   - Détecte les mots-clés "urgence", "douleur", "infection"
   - Priorité maximale pour ces cas

2. **Profil médical du patient** (0.85)
   - Anticoagulants → risque de saignement
   - Problèmes cardiaques → nécessite prophylaxie antibiotique
   - Ces patients ne doivent JAMAIS manquer un RDV

3. **Nouveaux patients** (0.75)
   - Créés dans les 30 derniers jours
   - Important de bien les accueillir

4. **Durée du rendez-vous** (0.70)
   - RDV > 60 minutes → chirurgie, implants, etc.
   - Nécessite préparation du patient

5. **Standard** (0.60)
   - Contrôles de routine, détartrages simples

### Timing optimal

**24H avant** (défaut)
- Contrôles de routine
- Détartrages
- Rendez-vous courts

**48H avant**
- Patients avec anxiété dentaire (score > 7/10)
- Rendez-vous longs (> 90 minutes)
- Permet au patient de se préparer mentalement

**1 SEMAINE avant**
- Chirurgies importantes
- Traitements complexes nécessitant des analyses préalables

## Intégration avec APIs SMS/Email

### Exemple avec Twilio (SMS)

```javascript
// Récupérer les rappels pending
const { data: pendingReminders } = await supabase
  .from('appointment_reminders')
  .select('*')
  .eq('status', 'pending')
  .eq('reminder_type', 'SMS')
  .order('ai_score', { ascending: false });

// Envoyer via Twilio
for (const reminder of pendingReminders) {
  try {
    await twilioClient.messages.create({
      body: reminder.message_content,
      from: TWILIO_PHONE,
      to: reminder.recipient
    });

    // Marquer comme envoyé
    await supabase.rpc('mark_reminder_sent', {
      p_reminder_id: reminder.id,
      p_status: 'sent'
    });
  } catch (error) {
    // Marquer comme échoué
    await supabase.rpc('mark_reminder_sent', {
      p_reminder_id: reminder.id,
      p_status: 'failed',
      p_error_message: error.message
    });
  }
}
```

### Exemple avec SendGrid (Email)

```javascript
const { data: pendingEmails } = await supabase
  .from('appointment_reminders')
  .select('*')
  .eq('status', 'pending')
  .eq('reminder_type', 'EMAIL');

for (const reminder of pendingEmails) {
  try {
    await sendgridClient.send({
      to: reminder.recipient,
      from: 'noreply@k2dent.be',
      subject: 'Rappel de rendez-vous - K2 Dent',
      text: reminder.message_content
    });

    await supabase.rpc('mark_reminder_sent', {
      p_reminder_id: reminder.id,
      p_status: 'sent'
    });
  } catch (error) {
    await supabase.rpc('mark_reminder_sent', {
      p_reminder_id: reminder.id,
      p_status: 'failed',
      p_error_message: error.message
    });
  }
}
```

## Cron Job recommandé

Pour automatiser l'envoi, créer un cron job qui s'exécute toutes les heures:

```javascript
// Vercel Edge Function ou similaire
export default async function handler(req, res) {
  // 1. Générer les rappels nécessaires
  await supabase.rpc('generate_ai_reminders');

  // 2. Récupérer et envoyer les pending
  const now = new Date();
  const { data: toSend } = await supabase
    .from('appointment_reminders')
    .select('*')
    .eq('status', 'pending')
    .order('ai_score', { ascending: false });

  // 3. Envoyer via APIs
  // ... (voir exemples ci-dessus)

  return res.json({ sent: toSend.length });
}
```

## Statistiques et Monitoring

### Taux de délivrance

```sql
SELECT
  reminder_type,
  COUNT(*) as total,
  SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) as delivered,
  ROUND(100.0 * SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) / COUNT(*), 2) as delivery_rate
FROM appointment_reminders
WHERE sent_at > NOW() - INTERVAL '30 days'
GROUP BY reminder_type;
```

### Efficacité IA

```sql
SELECT
  ai_reason,
  COUNT(*) as total_rappels,
  COUNT(DISTINCT patient_id) as patients_concernes,
  AVG(ai_score) as score_moyen
FROM appointment_reminders
GROUP BY ai_reason
ORDER BY score_moyen DESC;
```

### Rappels échoués

```sql
SELECT
  DATE_TRUNC('day', sent_at) as jour,
  COUNT(*) as echecs,
  error_message
FROM appointment_reminders
WHERE status = 'failed'
GROUP BY jour, error_message
ORDER BY jour DESC;
```

## Améliorations futures

- [ ] Détection de langue automatique (FR/NL/EN/DE)
- [ ] Machine learning sur historique de présence
- [ ] Rappels adaptatifs (si patient répond, ajuster le timing)
- [ ] Intégration WhatsApp Business API
- [ ] Rappels vocaux automatiques pour patients âgés
- [ ] A/B testing des templates pour optimiser taux de confirmation

## Support

Pour toute question ou problème:
- Documentation: `/supabase/README-AI-Reminders.md`
- Logs d'erreur: `SELECT * FROM appointment_reminders WHERE status = 'failed'`
- Configuration: `SELECT * FROM reminder_ai_config`

-- ================================================
-- SEED DATA: users
-- Description: Insertion des 6 profils initiaux
-- Auteur: Ismail Sialyen
-- Date: 23 juillet 2026
-- ================================================

-- NOTE: Les mots de passe doivent être hashés côté serveur avec bcrypt
-- Pour l'instant, on utilise un placeholder qui sera remplacé par l'API

-- Insérer les 6 profils existants
-- Mot de passe pour tous: dentalcockpitk2
-- Hash bcrypt (rounds=10): $2b$10$... (à générer côté serveur)

INSERT INTO users (username, password_hash, full_name, role, avatar) VALUES
  ('Dr. Sialyen', 'HASH_PLACEHOLDER', 'Dr. Sialyen', 'Dentiste Principal', '👨‍⚕️'),
  ('Dr. Martin', 'HASH_PLACEHOLDER', 'Dr. Martin', 'Dentiste', '👨‍⚕️'),
  ('Dr. Dubois', 'HASH_PLACEHOLDER', 'Dr. Dubois', 'Orthodontiste', '👨‍⚕️'),
  ('Dr. Laurent', 'HASH_PLACEHOLDER', 'Dr. Laurent', 'Parodontiste', '👩‍⚕️'),
  ('Sophie', 'HASH_PLACEHOLDER', 'Sophie', 'Assistante Dentaire', '👩‍💼'),
  ('Admin', 'HASH_PLACEHOLDER', 'Admin', 'Administrateur', '⚙️')
ON CONFLICT (username) DO NOTHING;

-- Afficher les utilisateurs créés
SELECT username, full_name, role, avatar, is_active, created_at
FROM users
ORDER BY created_at;

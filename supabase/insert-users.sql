-- ============================================
-- INSÉRER LES 6 UTILISATEURS
-- ============================================
-- Hash bcrypt pour "dentalcockpitk2"
-- ============================================

-- Supprimer les utilisateurs existants (pour éviter erreurs de contrainte UNIQUE)
DELETE FROM users;

-- Insérer les 6 utilisateurs
INSERT INTO users (username, password_hash, full_name, role, avatar, is_active)
VALUES
  ('Dr. Sialyen', '$2b$10$n/QXFEsxky7Yv/fNggE//eXSvrhnAI4S6Zhnj6NGV2TWgf/G425zO', 'Dr. Sialyen', 'Dentiste Principal', '👨‍⚕️', true),
  ('Dr. Martin', '$2b$10$n/QXFEsxky7Yv/fNggE//eXSvrhnAI4S6Zhnj6NGV2TWgf/G425zO', 'Dr. Martin', 'Dentiste', '👨‍⚕️', true),
  ('Dr. Dubois', '$2b$10$n/QXFEsxky7Yv/fNggE//eXSvrhnAI4S6Zhnj6NGV2TWgf/G425zO', 'Dr. Dubois', 'Orthodontiste', '👨‍⚕️', true),
  ('Dr. Laurent', '$2b$10$n/QXFEsxky7Yv/fNggE//eXSvrhnAI4S6Zhnj6NGV2TWgf/G425zO', 'Dr. Laurent', 'Parodontiste', '👩‍⚕️', true),
  ('Sophie', '$2b$10$n/QXFEsxky7Yv/fNggE//eXSvrhnAI4S6Zhnj6NGV2TWgf/G425zO', 'Sophie', 'Assistante Dentaire', '👩‍💼', true),
  ('Admin', '$2b$10$n/QXFEsxky7Yv/fNggE//eXSvrhnAI4S6Zhnj6NGV2TWgf/G425zO', 'Admin', 'Administrateur', '⚙️', true);

-- Vérifier insertion
SELECT username, full_name, role FROM users ORDER BY username;

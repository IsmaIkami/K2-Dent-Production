-- ============================================
-- TABLE USERS - Pour authentification simple
-- ============================================
-- Permet le login sans backend
-- ============================================

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username VARCHAR(100) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,

  role VARCHAR(50) NOT NULL CHECK (role IN ('OWNER', 'DENTIST', 'ASSISTANT', 'SECRETARY')),
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,

  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Insérer les utilisateurs de démo
-- Note: En production, utiliser un vrai hash de mot de passe!
INSERT INTO users (username, password_hash, email, role, first_name, last_name)
VALUES
  ('Dr. Sialyen', 'dentalcockpitk2', 'sialyen@dentalcockpit.com', 'OWNER', 'Ekaterina', 'Sialyen'),
  ('Dr. Martin', 'dentalcockpitk2', 'martin@dentalcockpit.com', 'DENTIST', 'Pierre', 'Martin'),
  ('Dr. Dubois', 'dentalcockpitk2', 'dubois@dentalcockpit.com', 'DENTIST', 'Marie', 'Dubois'),
  ('Sophie', 'dentalcockpitk2', 'sophie@dentalcockpit.com', 'ASSISTANT', 'Sophie', 'Laurent')
ON CONFLICT (username) DO NOTHING;

SELECT 'Table users créée avec 4 comptes démo!' as status;
SELECT username, role, first_name, last_name FROM users;

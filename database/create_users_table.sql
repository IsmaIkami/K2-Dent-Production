-- ================================================
-- TABLE: users
-- Description: Table des utilisateurs pour l'authentification
-- Auteur: Ismail Sialyen
-- Date: 23 juillet 2026
-- ================================================

-- Créer la table users
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('Dentiste Principal', 'Dentiste', 'Orthodontiste', 'Parodontiste', 'Assistante Dentaire', 'Administrateur', 'Utilisateur')),
  avatar TEXT NOT NULL DEFAULT '👤',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour performances
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);

-- Trigger pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- RLS (Row Level Security) - Activer la sécurité au niveau des lignes
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Politique: Les utilisateurs authentifiés peuvent lire tous les profils
CREATE POLICY "Users can read all profiles"
    ON users FOR SELECT
    USING (true);

-- Politique: Seuls les admins peuvent insérer/modifier/supprimer
CREATE POLICY "Only admins can modify users"
    ON users FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE username = current_user
            AND role = 'Administrateur'
        )
    );

-- Commentaires
COMMENT ON TABLE users IS 'Table des utilisateurs avec authentification hashée';
COMMENT ON COLUMN users.id IS 'Identifiant unique UUID';
COMMENT ON COLUMN users.username IS 'Nom d''utilisateur unique';
COMMENT ON COLUMN users.password_hash IS 'Mot de passe hashé avec bcrypt';
COMMENT ON COLUMN users.full_name IS 'Nom complet affiché';
COMMENT ON COLUMN users.role IS 'Rôle de l''utilisateur';
COMMENT ON COLUMN users.avatar IS 'Emoji avatar';
COMMENT ON COLUMN users.is_active IS 'Compte actif ou désactivé';

/**
 * Authentication API
 * Gère l'authentification des utilisateurs avec hashage bcrypt
 * Auteur: Ismail Sialyen
 * Date: 23 juillet 2026
 */

const express = require('express');
const bcrypt = require('bcrypt');
const { createClient } = require('@supabase/supabase-js');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Supabase client
const supabase = createClient(
  process.env.SUPABASE_URL || 'https://sqgxscrwcffjfomlsoyf.supabase.co',
  process.env.SUPABASE_SERVICE_KEY // Service key pour bypass RLS
);

const SALT_ROUNDS = 10;

/**
 * POST /api/auth/login
 * Authentifier un utilisateur
 */
app.post('/api/auth/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({
        success: false,
        error: 'Username and password required'
      });
    }

    // Récupérer l'utilisateur depuis Supabase
    const { data: user, error } = await supabase
      .from('users')
      .select('*')
      .eq('username', username)
      .eq('is_active', true)
      .single();

    if (error || !user) {
      return res.status(401).json({
        success: false,
        error: 'Invalid credentials'
      });
    }

    // Vérifier le mot de passe
    const passwordMatch = await bcrypt.compare(password, user.password_hash);

    if (!passwordMatch) {
      return res.status(401).json({
        success: false,
        error: 'Invalid credentials'
      });
    }

    // Authentification réussie
    res.json({
      success: true,
      user: {
        id: user.id,
        username: user.username,
        full_name: user.full_name,
        role: user.role,
        avatar: user.avatar
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

/**
 * GET /api/auth/users
 * Récupérer tous les utilisateurs actifs (pour la liste des profils)
 */
app.get('/api/auth/users', async (req, res) => {
  try {
    const { data: users, error } = await supabase
      .from('users')
      .select('id, username, full_name, role, avatar')
      .eq('is_active', true)
      .order('full_name');

    if (error) {
      throw error;
    }

    res.json({ success: true, users });

  } catch (error) {
    console.error('Fetch users error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

/**
 * POST /api/auth/hash-password
 * Utilitaire pour hasher un mot de passe (pour le seed initial)
 */
app.post('/api/auth/hash-password', async (req, res) => {
  try {
    const { password } = req.body;

    if (!password) {
      return res.status(400).json({ error: 'Password required' });
    }

    const hash = await bcrypt.hash(password, SALT_ROUNDS);
    res.json({ hash });

  } catch (error) {
    console.error('Hash error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * POST /api/auth/seed-users
 * Créer les utilisateurs initiaux avec mots de passe hashés
 */
app.post('/api/auth/seed-users', async (req, res) => {
  try {
    const defaultPassword = 'dentalcockpitk2';
    const passwordHash = await bcrypt.hash(defaultPassword, SALT_ROUNDS);

    const users = [
      { username: 'Dr. Sialyen', full_name: 'Dr. Sialyen', role: 'Dentiste Principal', avatar: '👨‍⚕️' },
      { username: 'Dr. Martin', full_name: 'Dr. Martin', role: 'Dentiste', avatar: '👨‍⚕️' },
      { username: 'Dr. Dubois', full_name: 'Dr. Dubois', role: 'Orthodontiste', avatar: '👨‍⚕️' },
      { username: 'Dr. Laurent', full_name: 'Dr. Laurent', role: 'Parodontiste', avatar: '👩‍⚕️' },
      { username: 'Sophie', full_name: 'Sophie', role: 'Assistante Dentaire', avatar: '👩‍💼' },
      { username: 'Admin', full_name: 'Admin', role: 'Administrateur', avatar: '⚙️' }
    ];

    const results = [];

    for (const user of users) {
      const { data, error } = await supabase
        .from('users')
        .insert([{
          ...user,
          password_hash: passwordHash
        }])
        .select()
        .single();

      if (!error) {
        results.push(data);
      }
    }

    res.json({
      success: true,
      message: `${results.length} users created`,
      users: results
    });

  } catch (error) {
    console.error('Seed error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'auth-api' });
});

app.listen(PORT, () => {
  console.log(`🔐 Auth API running on port ${PORT}`);
});

module.exports = app;

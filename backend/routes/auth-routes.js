/**
 * Authentication Routes (Fastify)
 * Gère l'authentification des utilisateurs avec hashage bcrypt
 * Auteur: Ismail Sialyen
 * Date: 23 juillet 2026
 */

import bcrypt from 'bcrypt';
import { createClient } from '@supabase/supabase-js';

const SALT_ROUNDS = 10;

// Supabase client avec service key pour bypass RLS
const getSupabaseAdmin = () => {
  return createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_ANON_KEY
  );
};

export default async function authRoutes(fastify, options) {

  /**
   * POST /api/auth/login
   * Authentifier un utilisateur
   */
  fastify.post('/login', async (request, reply) => {
    try {
      const { username, password } = request.body;

      if (!username || !password) {
        return reply.code(400).send({
          success: false,
          error: 'Username and password required'
        });
      }

      const supabase = getSupabaseAdmin();

      // Récupérer l'utilisateur depuis Supabase
      const { data: user, error } = await supabase
        .from('users')
        .select('*')
        .eq('username', username)
        .eq('is_active', true)
        .single();

      if (error || !user) {
        return reply.code(401).send({
          success: false,
          error: 'Invalid credentials'
        });
      }

      // Vérifier le mot de passe
      const passwordMatch = await bcrypt.compare(password, user.password_hash);

      if (!passwordMatch) {
        return reply.code(401).send({
          success: false,
          error: 'Invalid credentials'
        });
      }

      // Authentification réussie
      return {
        success: true,
        user: {
          id: user.id,
          username: user.username,
          full_name: user.full_name,
          role: user.role,
          avatar: user.avatar
        }
      };

    } catch (error) {
      fastify.log.error('Login error:', error);
      return reply.code(500).send({
        success: false,
        error: 'Internal server error'
      });
    }
  });

  /**
   * GET /api/auth/users
   * Récupérer tous les utilisateurs actifs (pour la liste des profils)
   */
  fastify.get('/users', async (request, reply) => {
    try {
      const supabase = getSupabaseAdmin();

      const { data: users, error } = await supabase
        .from('users')
        .select('id, username, full_name, role, avatar')
        .eq('is_active', true)
        .order('full_name');

      if (error) {
        throw error;
      }

      return { success: true, users };

    } catch (error) {
      fastify.log.error('Fetch users error:', error);
      return reply.code(500).send({
        success: false,
        error: 'Internal server error'
      });
    }
  });

  /**
   * POST /api/auth/hash-password
   * Utilitaire pour hasher un mot de passe
   */
  fastify.post('/hash-password', async (request, reply) => {
    try {
      const { password } = request.body;

      if (!password) {
        return reply.code(400).send({ error: 'Password required' });
      }

      const hash = await bcrypt.hash(password, SALT_ROUNDS);
      return { hash };

    } catch (error) {
      fastify.log.error('Hash error:', error);
      return reply.code(500).send({ error: 'Internal server error' });
    }
  });

  /**
   * POST /api/auth/seed-users
   * Créer les utilisateurs initiaux avec mots de passe hashés
   */
  fastify.post('/seed-users', async (request, reply) => {
    try {
      const defaultPassword = 'dentalcockpitk2';
      const passwordHash = await bcrypt.hash(defaultPassword, SALT_ROUNDS);

      const supabase = getSupabaseAdmin();

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
        } else {
          console.log(`Error inserting user ${user.username}:`, JSON.stringify(error, null, 2));
        }
      }

      return {
        success: true,
        message: `${results.length} users created`,
        users: results.map(u => ({ username: u.username, role: u.role }))
      };

    } catch (error) {
      fastify.log.error('Seed error:', error);
      return reply.code(500).send({
        success: false,
        error: error.message
      });
    }
  });
}

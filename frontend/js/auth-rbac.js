/**
 * K2 DENT — AUTHENTICATION & ROLE-BASED ACCESS CONTROL (RBAC)
 * Multi-user support with different permission levels
 *
 * USER ROLES:
 * - OWNER: Ismail Sialyen & Katja (full access + admin)
 * - DENTIST: Regular dentists (clinical access, no admin)
 * - ASSISTANT: Receptionists/Hygienists (limited access)
 *
 * @author Ismail Sialyen
 * @date April 2026
 * @version 1.0.0
 */

// ============================================================================
// USER ROLES & PERMISSIONS
// ============================================================================

const USER_ROLES = {
  OWNER: 'OWNER',           // Ismail & Katja (full admin access)
  DENTIST: 'DENTIST',       // Regular dentists (clinical only)
  ASSISTANT: 'ASSISTANT'    // Receptionists/Hygienists (limited)
};

/**
 * Permission matrix
 * Define what each role can do
 */
const PERMISSIONS = {
  // PATIENT MANAGEMENT
  'patients.view': [USER_ROLES.OWNER, USER_ROLES.DENTIST, USER_ROLES.ASSISTANT],
  'patients.create': [USER_ROLES.OWNER, USER_ROLES.DENTIST, USER_ROLES.ASSISTANT],
  'patients.edit': [USER_ROLES.OWNER, USER_ROLES.DENTIST, USER_ROLES.ASSISTANT],
  'patients.delete': [USER_ROLES.OWNER, USER_ROLES.DENTIST], // Assistants cannot delete
  'patients.export': [USER_ROLES.OWNER], // Only owners can export patient data

  // APPOINTMENTS
  'appointments.view': [USER_ROLES.OWNER, USER_ROLES.DENTIST, USER_ROLES.ASSISTANT],
  'appointments.create': [USER_ROLES.OWNER, USER_ROLES.DENTIST, USER_ROLES.ASSISTANT],
  'appointments.edit': [USER_ROLES.OWNER, USER_ROLES.DENTIST, USER_ROLES.ASSISTANT],
  'appointments.cancel': [USER_ROLES.OWNER, USER_ROLES.DENTIST, USER_ROLES.ASSISTANT],
  'appointments.delete': [USER_ROLES.OWNER, USER_ROLES.DENTIST],

  // CLINICAL (AI, ANAMNESIS, PRESCRIPTIONS)
  'anamnesis.view': [USER_ROLES.OWNER, USER_ROLES.DENTIST],
  'anamnesis.generate': [USER_ROLES.OWNER, USER_ROLES.DENTIST], // AI generation
  'anamnesis.edit': [USER_ROLES.OWNER, USER_ROLES.DENTIST],
  'prescriptions.view': [USER_ROLES.OWNER, USER_ROLES.DENTIST],
  'prescriptions.generate': [USER_ROLES.OWNER, USER_ROLES.DENTIST], // AI generation
  'prescriptions.validate': [USER_ROLES.OWNER, USER_ROLES.DENTIST], // Sign prescriptions
  'prescriptions.recipe': [USER_ROLES.OWNER, USER_ROLES.DENTIST], // Create Recip-e

  // BILLING & INAMI
  'inami.view': [USER_ROLES.OWNER, USER_ROLES.DENTIST, USER_ROLES.ASSISTANT],
  'inami.create': [USER_ROLES.OWNER, USER_ROLES.DENTIST],
  'inami.send': [USER_ROLES.OWNER, USER_ROLES.DENTIST], // Send eAttest
  'billing.view': [USER_ROLES.OWNER, USER_ROLES.DENTIST, USER_ROLES.ASSISTANT],
  'billing.edit': [USER_ROLES.OWNER, USER_ROLES.DENTIST],
  'billing.export': [USER_ROLES.OWNER], // Financial reports
  'billing.delete': [USER_ROLES.OWNER], // Delete invoices

  // CERTIFICATES
  'certificates.view': [USER_ROLES.OWNER, USER_ROLES.DENTIST, USER_ROLES.ASSISTANT],
  'certificates.generate': [USER_ROLES.OWNER, USER_ROLES.DENTIST],
  'certificates.sign': [USER_ROLES.OWNER, USER_ROLES.DENTIST],

  // ADMIN & SETTINGS
  'settings.view': [USER_ROLES.OWNER, USER_ROLES.DENTIST, USER_ROLES.ASSISTANT],
  'settings.edit': [USER_ROLES.OWNER], // Only owners change settings
  'users.view': [USER_ROLES.OWNER],
  'users.create': [USER_ROLES.OWNER],
  'users.edit': [USER_ROLES.OWNER],
  'users.delete': [USER_ROLES.OWNER],
  'tariffs.edit': [USER_ROLES.OWNER], // INAMI tariff updates
  'backup.export': [USER_ROLES.OWNER], // Export all data
  'backup.import': [USER_ROLES.OWNER], // Restore data

  // AI FEATURES
  'ai.anamnesis': [USER_ROLES.OWNER, USER_ROLES.DENTIST],
  'ai.prescriptions': [USER_ROLES.OWNER, USER_ROLES.DENTIST],
  'ai.diagnosis': [USER_ROLES.OWNER, USER_ROLES.DENTIST],
  'ai.apikey': [USER_ROLES.OWNER] // Only owners manage API keys
};

// ============================================================================
// USER SCHEMA
// ============================================================================

/**
 * User entity structure
 */
const USER_SCHEMA = {
  id: "uuid-v4",
  username: "ismail",
  email: "ismail@k2dent.be",
  role: USER_ROLES.OWNER,

  // Personal Info
  firstName: "Ismail",
  lastName: "Sialyen",
  title: "", // Empty for owners/assistants, "Dr." for dentists

  // Professional Info (for dentists)
  inami: null, // INAMI number (only for dentists)
  signature: null, // Digital signature (base64 image)

  // Authentication
  passwordHash: "bcrypt-hash", // Never store plain passwords
  lastLogin: "2026-04-03T10:00:00Z",
  createdAt: "2026-01-15T09:00:00Z",
  status: "active", // active | suspended | deleted

  // Permissions (cache, based on role)
  permissions: [] // Array of permission strings
};

// ============================================================================
// PRE-DEFINED USERS (MVP)
// ============================================================================

const DEFAULT_USERS = [
  // OWNERS
  {
    id: "owner-ismail",
    username: "ismail",
    email: "ismail@k2dent.be",
    role: USER_ROLES.OWNER,
    firstName: "Ismail",
    lastName: "Sialyen",
    title: "",
    inami: null,
    status: "active"
  },
  {
    id: "owner-katja",
    username: "katja",
    email: "katja@k2dent.be",
    role: USER_ROLES.OWNER,
    firstName: "Katja",
    lastName: "Sialyen",
    title: "",
    inami: null,
    status: "active"
  },

  // DENTIST (Dr. Ekaterina SIALYEN)
  {
    id: "dentist-ekaterina",
    username: "ekaterina",
    email: "ekaterina@k2dent.be",
    role: USER_ROLES.DENTIST,
    firstName: "Ekaterina",
    lastName: "SIALYEN",
    title: "Dr.",
    inami: "3-02462-81-001",
    status: "active"
  },

  // ASSISTANT (Example)
  {
    id: "assistant-marie",
    username: "marie",
    email: "marie@k2dent.be",
    role: USER_ROLES.ASSISTANT,
    firstName: "Marie",
    lastName: "Dupont",
    title: "",
    inami: null,
    status: "active"
  }
];

// ============================================================================
// AUTHENTICATION FUNCTIONS
// ============================================================================

/**
 * Login user
 * @param {string} username - Username or email
 * @param {string} password - Plain password
 * @returns {object|null} - User object if authenticated, null otherwise
 */
function login(username, password) {
  // Get users from localStorage
  const users = JSON.parse(localStorage.getItem('k2dent_users') || '[]');

  // Find user
  const user = users.find(u =>
    (u.username === username || u.email === username) &&
    u.status === 'active'
  );

  if (!user) {
    console.error('[Auth] User not found or inactive');
    return null;
  }

  // TODO: Replace with bcrypt in production
  // For MVP: simple password check (INSECURE - for demo only)
  const storedPassword = localStorage.getItem(`k2dent_pwd_${user.id}`);
  if (password !== storedPassword) {
    console.error('[Auth] Invalid password');
    return null;
  }

  // Update last login
  user.lastLogin = new Date().toISOString();
  updateUser(user);

  // Create session
  const session = {
    userId: user.id,
    username: user.username,
    role: user.role,
    loginTime: new Date().toISOString(),
    expiresAt: new Date(Date.now() + 8 * 60 * 60 * 1000).toISOString() // 8 hours
  };

  localStorage.setItem('k2dent_session', JSON.stringify(session));
  console.log('[Auth] Login successful:', user.username, '-', user.role);

  return user;
}

/**
 * Logout current user
 */
function logout() {
  localStorage.removeItem('k2dent_session');
  window.location.href = 'login.html';
}

/**
 * Get current logged-in user
 * @returns {object|null} - Current user or null if not logged in
 */
function getCurrentUser() {
  const sessionStr = localStorage.getItem('k2dent_session');
  if (!sessionStr) return null;

  const session = JSON.parse(sessionStr);

  // Check if session expired
  if (new Date(session.expiresAt) < new Date()) {
    console.warn('[Auth] Session expired');
    logout();
    return null;
  }

  // Get user details
  const users = JSON.parse(localStorage.getItem('k2dent_users') || '[]');
  const user = users.find(u => u.id === session.userId);

  return user || null;
}

/**
 * Check if user is logged in
 * @returns {boolean}
 */
function isLoggedIn() {
  return getCurrentUser() !== null;
}

/**
 * Require login (redirect if not logged in)
 */
function requireLogin() {
  if (!isLoggedIn()) {
    window.location.href = 'login.html';
    return false;
  }
  return true;
}

// ============================================================================
// AUTHORIZATION (RBAC)
// ============================================================================

/**
 * Check if current user has permission
 * @param {string} permission - Permission string (e.g., 'patients.delete')
 * @returns {boolean}
 */
function hasPermission(permission) {
  const user = getCurrentUser();
  if (!user) return false;

  const allowedRoles = PERMISSIONS[permission] || [];
  return allowedRoles.includes(user.role);
}

/**
 * Require permission (show error if not authorized)
 * @param {string} permission - Permission string
 * @param {string} errorMessage - Custom error message
 * @returns {boolean}
 */
function requirePermission(permission, errorMessage = null) {
  if (!hasPermission(permission)) {
    const msg = errorMessage || `Accès refusé. Permission requise: ${permission}`;
    alert(`⛔ ${msg}`);
    console.error('[Auth] Permission denied:', permission);
    return false;
  }
  return true;
}

/**
 * Check if user is owner
 * @returns {boolean}
 */
function isOwner() {
  const user = getCurrentUser();
  return user && user.role === USER_ROLES.OWNER;
}

/**
 * Check if user is dentist (or owner)
 * @returns {boolean}
 */
function isDentist() {
  const user = getCurrentUser();
  return user && (user.role === USER_ROLES.DENTIST || user.role === USER_ROLES.OWNER);
}

/**
 * Check if user is assistant
 * @returns {boolean}
 */
function isAssistant() {
  const user = getCurrentUser();
  return user && user.role === USER_ROLES.ASSISTANT;
}

// ============================================================================
// USER MANAGEMENT (OWNERS ONLY)
// ============================================================================

/**
 * Get all users
 * @returns {array} - List of users
 */
function getAllUsers() {
  if (!requirePermission('users.view')) return [];
  return JSON.parse(localStorage.getItem('k2dent_users') || '[]');
}

/**
 * Create new user
 * @param {object} userData - User data
 * @param {string} password - Plain password
 * @returns {object} - Created user
 */
function createUser(userData, password) {
  if (!requirePermission('users.create')) return null;

  const users = getAllUsers();

  // Check if username/email already exists
  if (users.some(u => u.username === userData.username || u.email === userData.email)) {
    alert('⚠️ Ce nom d\'utilisateur ou email existe déjà');
    return null;
  }

  const newUser = {
    id: `user-${Date.now()}`,
    username: userData.username,
    email: userData.email,
    role: userData.role,
    firstName: userData.firstName,
    lastName: userData.lastName,
    title: userData.role === USER_ROLES.DENTIST ? 'Dr.' : '',
    inami: userData.inami || null,
    signature: null,
    createdAt: new Date().toISOString(),
    lastLogin: null,
    status: 'active'
  };

  users.push(newUser);
  localStorage.setItem('k2dent_users', JSON.stringify(users));

  // Store password (TODO: hash with bcrypt in production)
  localStorage.setItem(`k2dent_pwd_${newUser.id}`, password);

  console.log('[Auth] User created:', newUser.username);
  return newUser;
}

/**
 * Update user
 * @param {object} user - Updated user object
 */
function updateUser(user) {
  const users = getAllUsers();
  const index = users.findIndex(u => u.id === user.id);

  if (index !== -1) {
    users[index] = user;
    localStorage.setItem('k2dent_users', JSON.stringify(users));
    console.log('[Auth] User updated:', user.username);
  }
}

/**
 * Delete user
 * @param {string} userId - User ID to delete
 */
function deleteUser(userId) {
  if (!requirePermission('users.delete')) return;

  const users = getAllUsers();
  const filteredUsers = users.filter(u => u.id !== userId);

  localStorage.setItem('k2dent_users', JSON.stringify(filteredUsers));
  localStorage.removeItem(`k2dent_pwd_${userId}`);

  console.log('[Auth] User deleted:', userId);
}

// ============================================================================
// UI HELPERS
// ============================================================================

/**
 * Show/hide elements based on permissions
 * Usage: <button data-permission="patients.delete">Delete</button>
 */
function applyPermissionUI() {
  document.querySelectorAll('[data-permission]').forEach(element => {
    const permission = element.getAttribute('data-permission');

    if (!hasPermission(permission)) {
      element.style.display = 'none';
      element.disabled = true;
    }
  });
}

/**
 * Display current user info in UI
 */
function displayCurrentUser() {
  const user = getCurrentUser();
  if (!user) return;

  // Update user badge in topbar
  const userBadge = document.getElementById('currentUser');
  if (userBadge) {
    const roleLabel = {
      [USER_ROLES.OWNER]: 'Propriétaire',
      [USER_ROLES.DENTIST]: 'Dentiste',
      [USER_ROLES.ASSISTANT]: 'Assistant(e)'
    }[user.role];

    userBadge.innerHTML = `
      <div style="text-align: right;">
        <div style="font-weight: 600;">${user.title} ${user.firstName} ${user.lastName}</div>
        <div style="font-size: 12px; color: var(--text-secondary);">${roleLabel}</div>
      </div>
    `;
  }
}

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * Initialize auth system
 * Create default users if none exist
 */
function initializeAuth() {
  let users = JSON.parse(localStorage.getItem('k2dent_users') || '[]');

  // Create default users if empty
  if (users.length === 0) {
    console.log('[Auth] No users found. Creating default users...');

    DEFAULT_USERS.forEach(user => {
      users.push({
        ...user,
        createdAt: new Date().toISOString(),
        lastLogin: null
      });

      // Set default passwords (DEMO ONLY - change in production!)
      const defaultPassword = user.username; // Username = password for demo
      localStorage.setItem(`k2dent_pwd_${user.id}`, defaultPassword);
    });

    localStorage.setItem('k2dent_users', JSON.stringify(users));
    console.log('[Auth] Default users created:', users.length);
  }

  // Apply permission-based UI
  if (isLoggedIn()) {
    applyPermissionUI();
    displayCurrentUser();
  }
}

// ============================================================================
// AUTO-LOGOUT ON INACTIVITY
// ============================================================================

let inactivityTimer;
const INACTIVITY_TIMEOUT = 30 * 60 * 1000; // 30 minutes

function resetInactivityTimer() {
  clearTimeout(inactivityTimer);
  inactivityTimer = setTimeout(() => {
    if (isLoggedIn()) {
      alert('⏰ Session expirée après 30 minutes d\'inactivité');
      logout();
    }
  }, INACTIVITY_TIMEOUT);
}

// Reset timer on user activity
if (typeof window !== 'undefined') {
  ['mousedown', 'keydown', 'scroll', 'touchstart'].forEach(event => {
    document.addEventListener(event, resetInactivityTimer, true);
  });
}

// ============================================================================
// EXPORTS
// ============================================================================

if (typeof window !== 'undefined') {
  window.Auth = {
    // Roles
    USER_ROLES,
    PERMISSIONS,

    // Authentication
    login,
    logout,
    getCurrentUser,
    isLoggedIn,
    requireLogin,

    // Authorization
    hasPermission,
    requirePermission,
    isOwner,
    isDentist,
    isAssistant,

    // User Management
    getAllUsers,
    createUser,
    updateUser,
    deleteUser,

    // UI
    applyPermissionUI,
    displayCurrentUser,

    // Init
    initializeAuth
  };

  // Auto-initialize on page load
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeAuth);
  } else {
    initializeAuth();
  }
}

console.log('✅ Auth & RBAC loaded - K2 Dent v1.0');

/**
 * K2 DENT - Railway Entry Point
 * Redirects to backend/server.js
 *
 * @author Ismail Sialyen
 */

import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { spawn } from 'child_process';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Start the actual backend server
const serverPath = join(__dirname, 'backend', 'server.js');
const nodeProcess = spawn('node', [serverPath], {
  cwd: join(__dirname, 'backend'),
  stdio: 'inherit',
  env: process.env
});

nodeProcess.on('error', (err) => {
  console.error('Failed to start backend server:', err);
  process.exit(1);
});

nodeProcess.on('exit', (code) => {
  process.exit(code);
});

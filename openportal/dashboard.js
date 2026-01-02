#!/usr/bin/env node
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3000;
const SESSIONS_FILE = path.join(process.env.HOME, '.local/share/openportal/sessions.json');
const HOSTNAME = process.env.HOSTNAME || 'm4-mini.tail09133d.ts.net';

if (!fs.existsSync(SESSIONS_FILE)) {
  fs.writeFileSync(SESSIONS_FILE, '{}');
}

function getSessions() {
  try {
    const data = fs.readFileSync(SESSIONS_FILE, 'utf8');
    return JSON.parse(data);
  } catch {
    return {};
  }
}

function generateHTML() {
  const sessions = getSessions();
  const sessionList = Object.entries(sessions);
  
  const sessionCards = sessionList.length === 0 
    ? '<p class="empty">No active sessions. Run <code>oo</code> in a terminal to start one.</p>'
    : sessionList.map(([id, s]) => `
        <a href="http://${HOSTNAME}:${s.webPort}" class="session-card" target="_blank">
          <div class="status"></div>
          <div class="info">
            <div class="dir">${s.directory}</div>
            <div class="meta">Port ${s.webPort} &middot; Started ${new Date(s.startedAt).toLocaleTimeString()}</div>
          </div>
          <div class="arrow">→</div>
        </a>
      `).join('');

  return `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>OpenCode Sessions</title>
  <meta http-equiv="refresh" content="5">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #0d0d0d;
      color: #e0e0e0;
      min-height: 100vh;
      padding: 2rem;
    }
    .container { max-width: 600px; margin: 0 auto; }
    h1 { 
      font-size: 1.5rem; 
      font-weight: 500; 
      margin-bottom: 0.5rem;
      color: #fff;
    }
    .subtitle { color: #666; margin-bottom: 2rem; font-size: 0.9rem; }
    .session-card {
      display: flex;
      align-items: center;
      gap: 1rem;
      padding: 1rem;
      background: #1a1a1a;
      border-radius: 8px;
      margin-bottom: 0.75rem;
      text-decoration: none;
      color: inherit;
      transition: background 0.2s;
    }
    .session-card:hover { background: #252525; }
    .status {
      width: 10px;
      height: 10px;
      background: #22c55e;
      border-radius: 50%;
      flex-shrink: 0;
    }
    .info { flex: 1; min-width: 0; }
    .dir { 
      font-weight: 500; 
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .meta { font-size: 0.8rem; color: #666; margin-top: 0.25rem; }
    .arrow { color: #666; font-size: 1.2rem; }
    .empty { 
      color: #666; 
      text-align: center; 
      padding: 3rem 1rem;
      background: #1a1a1a;
      border-radius: 8px;
    }
    code { 
      background: #333; 
      padding: 0.2rem 0.4rem; 
      border-radius: 4px;
      font-size: 0.9rem;
    }
    .count { 
      display: inline-block;
      background: #333;
      padding: 0.2rem 0.6rem;
      border-radius: 999px;
      font-size: 0.8rem;
      margin-left: 0.5rem;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>OpenCode Sessions <span class="count">${sessionList.length}</span></h1>
    <p class="subtitle">Auto-refreshes every 5 seconds</p>
    ${sessionCards}
  </div>
</body>
</html>`;
}

const server = http.createServer((req, res) => {
  if (req.url === '/api/sessions') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(getSessions()));
  } else {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(generateHTML());
  }
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Dashboard running at http://${HOSTNAME}:${PORT}`);
});

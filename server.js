// The small Node.js app the Dockerfile packs: it answers on port 3000 and
// shows that it can reach the database container by its service name, db.
import { createServer } from 'node:http';
import { pathToFileURL } from 'node:url';
import mysql from 'mysql2/promise';

export function createApp(pool) {
  return createServer(async (req, res) => {
    const send = (status, body) => {
      res.writeHead(status, { 'content-type': 'application/json; charset=utf-8' });
      res.end(JSON.stringify(body));
    };
    try {
      if (req.method === 'GET' && req.url === '/') return send(200, { message: 'Hello from Node.js in Docker' });
      if (req.method === 'GET' && req.url === '/health') return send(200, { ok: true });
      if (req.method === 'GET' && req.url === '/db') {
        const [[row]] = await pool.query('SELECT VERSION() AS version, DATABASE() AS `database`, NOW() AS now');
        return send(200, row);
      }
      send(404, { error: 'Not found' });
    } catch (err) {
      console.error(err);
      send(503, { error: 'The database did not answer' });
    }
  });
}

// Started as a program (not imported by a test)
if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const env = process.env;
  const pool = mysql.createPool({
    host: env.DB_HOST || 'db',
    port: Number(env.DB_PORT || 3306),
    user: env.DB_USER,
    password: env.DB_PASSWORD,
    database: env.DB_NAME,
    dateStrings: true,
  });
  const port = Number(env.PORT || 3000);
  const server = createApp(pool).listen(port, () => console.log(`listening on ${port}`));
  for (const signal of ['SIGINT', 'SIGTERM']) {
    process.on(signal, () => server.close(() => pool.end()));
  }
}

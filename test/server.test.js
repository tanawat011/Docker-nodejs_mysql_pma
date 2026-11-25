import assert from 'node:assert/strict';
import { after, before, test } from 'node:test';
import { createApp } from '../server.js';

let failing = false;
const pool = {
  async query() {
    if (failing) throw new Error('ECONNREFUSED db:3306');
    return [[{ version: '12.3.3-MariaDB', database: 'example', now: '2026-11-25 12:00:00' }]];
  },
};

let server;
let base;
before(async () => {
  server = createApp(pool).listen(0, '127.0.0.1');
  await new Promise((resolve) => server.once('listening', resolve));
  base = `http://127.0.0.1:${server.address().port}`;
});
after(() => server.close());

test('/ and /health answer', async () => {
  assert.deepEqual(await (await fetch(`${base}/`)).json(), { message: 'Hello from Node.js in Docker' });
  assert.equal((await fetch(`${base}/health`)).status, 200);
});

test('/db shows what the database says', async () => {
  const body = await (await fetch(`${base}/db`)).json();
  assert.equal(body.database, 'example');
});

test('/db answers 503 without details when the database is down', async (t) => {
  t.mock.method(console, 'error', () => {});
  failing = true;
  const res = await fetch(`${base}/db`);
  failing = false;
  assert.equal(res.status, 503);
  assert.equal((await res.text()).includes('3306'), false);
});

test('anything else is a 404', async () => {
  assert.equal((await fetch(`${base}/nope`)).status, 404);
});

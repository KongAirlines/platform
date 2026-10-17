#!/usr/bin/env node

const crypto = require('node:crypto');
const fs = require('node:fs');

const [environment, username, privateKeyPath] = process.argv.slice(2);
if (!['dev', 'prod'].includes(environment) || !username || !privateKeyPath) {
  console.error('usage: sign-example-jwt.js <dev|prod> <username> <private-key>');
  process.exit(2);
}

const encode = (value) => Buffer.from(JSON.stringify(value)).toString('base64url');
const now = Math.floor(Date.now() / 1000);
const unsigned = [
  encode({ alg: 'RS256', typ: 'JWT' }),
  encode({
    iss: `kongairlines-${environment}-${username}`,
    username,
    aud: `kongairlines-${environment}`,
    iat: now,
    exp: now + 3600,
  }),
].join('.');

const signature = crypto.sign(
  'RSA-SHA256',
  Buffer.from(unsigned),
  fs.readFileSync(privateKeyPath),
).toString('base64url');

process.stdout.write(`${unsigned}.${signature}`);

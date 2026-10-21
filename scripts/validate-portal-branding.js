#!/usr/bin/env node
'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const root = path.resolve(__dirname, '..');
const read = (name) => fs.readFileSync(path.join(root, name), 'utf8');
const theme = JSON.parse(read('konnect/branding/theme.json'));
assert.match(theme.colors.primary, /^#[0-9a-f]{6}$/i);
assert.ok(read('konnect/branding/portal.css').trim(), 'shared CSS must not be empty');

const assets = JSON.parse(read('konnect/branding/assets.json'));
for (const [name, mime, signature] of [
  ['logo', 'image/png', '89504e470d0a1a0a'],
  ['favicon', 'image/vnd.microsoft.icon', '00000100'],
]) {
  const prefix = `data:${mime};base64,`;
  assert.ok(assets[name].startsWith(prefix), `${name}: unexpected image type`);
  const encoded = assets[name].slice(prefix.length);
  const decoded = Buffer.from(encoded, 'base64');
  assert.equal(decoded.toString('base64'), encoded, `${name}: invalid base64`);
  assert.equal(decoded.subarray(0, signature.length / 2).toString('hex'), signature);
}

const portalSection = read('konnect/foundations.yaml').split('\nportals:\n')[1];
assert.ok(portalSection, 'foundation Portals must exist');
const portals = portalSection.split(/(?=^  - ref: )/m)
  .filter((block) => block.startsWith('  - ref: '));
assert.ok(portals.length >= 2, 'development and production Portals must exist');
for (const portal of portals) {
  assert.match(portal, /^    assets: !file branding\/assets\.json$/m);
  assert.match(portal, /^      css: !file branding\/portal\.css$/m);
  assert.match(portal, /^      theme: !file branding\/theme\.json$/m);
}

console.log(`Shared Portal branding valid for ${portals.length} Portals`);

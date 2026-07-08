#!/usr/bin/env node
//
// export-data.js — Chiari Research App data export.
//
// Uses the Firebase Admin SDK (which bypasses Firestore security rules) to dump
// every participant collection to JSON and CSV for analysis. Run from your own
// machine — this is NOT part of the shipped app.
//
// SETUP (one time):
//   1. Firebase console -> Project settings -> Service accounts ->
//      "Generate new private key". Save the file as tools/service-account.json
//      (already gitignored — never commit it).
//   2. cd tools && npm install firebase-admin
//
// RUN:
//   node export-data.js                 # exports to tools/exports/<timestamp>/
//   GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json node export-data.js
//
// Collections exported: users, enrollments, surveySessions, sensorBatches, stats

const fs = require("fs");
const path = require("path");
const admin = require("firebase-admin");

const KEY_PATH =
  process.env.GOOGLE_APPLICATION_CREDENTIALS ||
  path.join(__dirname, "service-account.json");

if (!fs.existsSync(KEY_PATH)) {
  console.error(
    `\nService-account key not found at:\n  ${KEY_PATH}\n\n` +
      "Download it from the Firebase console (Project settings -> Service " +
      "accounts) and save it as tools/service-account.json, or set " +
      "GOOGLE_APPLICATION_CREDENTIALS to its path.\n"
  );
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(require(KEY_PATH)),
});

const db = admin.firestore();

const COLLECTIONS = [
  "users",
  "enrollments",
  "surveySessions",
  "sensorBatches",
  "stats",
];

// Flatten a Firestore document into a plain object, converting Timestamps to
// ISO strings so JSON/CSV stay readable.
function normalize(value) {
  if (value && typeof value.toDate === "function") {
    return value.toDate().toISOString();
  }
  if (Array.isArray(value)) return value.map(normalize);
  if (value && typeof value === "object") {
    const out = {};
    for (const [k, v] of Object.entries(value)) out[k] = normalize(v);
    return out;
  }
  return value;
}

// Minimal CSV writer: union of top-level keys across rows. Nested
// objects/arrays are JSON-stringified into their cell.
function toCSV(rows) {
  if (rows.length === 0) return "";
  const keys = Array.from(
    rows.reduce((set, row) => {
      Object.keys(row).forEach((k) => set.add(k));
      return set;
    }, new Set())
  );
  const escape = (v) => {
    if (v === null || v === undefined) return "";
    const s = typeof v === "object" ? JSON.stringify(v) : String(v);
    return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
  };
  const header = keys.join(",");
  const lines = rows.map((row) => keys.map((k) => escape(row[k])).join(","));
  return [header, ...lines].join("\n");
}

async function main() {
  const stamp = new Date().toISOString().replace(/[:.]/g, "-");
  const outDir = path.join(__dirname, "exports", stamp);
  fs.mkdirSync(outDir, { recursive: true });

  for (const name of COLLECTIONS) {
    const snap = await db.collection(name).get();
    const rows = snap.docs.map((doc) => ({ id: doc.id, ...normalize(doc.data()) }));

    fs.writeFileSync(
      path.join(outDir, `${name}.json`),
      JSON.stringify(rows, null, 2)
    );
    fs.writeFileSync(path.join(outDir, `${name}.csv`), toCSV(rows));

    console.log(`  ${name}: ${rows.length} docs`);
  }

  console.log(`\nExport complete -> ${outDir}`);
}

main().catch((err) => {
  console.error("Export failed:", err);
  process.exit(1);
});

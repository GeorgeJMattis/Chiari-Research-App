# Research tooling (admin-side)

Scripts here run on **your** machine, not in the shipped app. They use the
Firebase Admin SDK, which bypasses Firestore security rules, so they require a
service-account key that must never be committed or distributed.

## Data export

Exports every participant collection (`users`, `enrollments`, `surveySessions`,
`sensorBatches`, `stats`) to timestamped JSON + CSV under `tools/exports/`.

### One-time setup
1. Firebase console → **Project settings → Service accounts → Generate new
   private key**. Save it as `tools/service-account.json` (gitignored).
2. `cd tools && npm install`

### Run
```bash
npm run export
# or point at a key elsewhere:
GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json node export-data.js
```

## Why no in-app admin account

Participant data is accessed only through this service-account path, never
through a login inside the app. That keeps the app's attack surface minimal:
the client can read/write only its own documents (enforced by
`../firestore.rules`), and full-dataset access lives entirely behind a key that
never ships to any device.

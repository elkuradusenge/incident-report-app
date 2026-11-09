import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import admin from 'firebase-admin';

const here = dirname(fileURLToPath(import.meta.url));

const serviceAccountPath =
  process.argv[2] ??
  process.env.GOOGLE_APPLICATION_CREDENTIALS ??
  resolve(here, 'serviceAccountKey.json');

let serviceAccount;
try {
  serviceAccount = JSON.parse(readFileSync(serviceAccountPath, 'utf8'));
} catch (error) {
  console.error(
    `Could not read a Firebase service account key at:\n  ${serviceAccountPath}\n\n` +
      'Download it from Firebase Console -> Project settings -> Service accounts\n' +
      'and pass its path as the first argument, or set GOOGLE_APPLICATION_CREDENTIALS.',
  );
  process.exit(1);
}

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });

const auth = admin.auth();
const db = admin.firestore();

const demoAccounts = [
  {
    email: 'e.kuradusen@alustudent.com',
    password: 'Student@123',
    fullName: 'Elie Kuradusenge',
    role: 'student',
    department: 'engineering',
    location: 'Hostel A',
  },
  {
    email: 'staff@alueducation.com',
    password: 'Staff@123',
    fullName: 'Hirwa Admin',
    role: 'staff',
    department: 'Facilities',
    location: 'Main Campus',
  },
];

async function upsertUser(account) {
  let user;
  try {
    user = await auth.getUserByEmail(account.email);
    user = await auth.updateUser(user.uid, {
      password: account.password,
      displayName: account.fullName,
      emailVerified: true,
    });
    console.log(`Updated auth user ${account.email}`);
  } catch (error) {
    if (error.code !== 'auth/user-not-found') throw error;

    user = await auth.createUser({
      email: account.email,
      password: account.password,
      displayName: account.fullName,
      emailVerified: true,
    });
    console.log(`Created auth user ${account.email}`);
  }

  await db.collection('users').doc(user.uid).set(
    {
      uid: user.uid,
      fullName: account.fullName,
      email: account.email,
      role: account.role,
      department: account.department,
      location: account.location,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  console.log(`Wrote users/${user.uid} (${account.role})`);
}

try {
  for (const account of demoAccounts) {
    await upsertUser(account);
  }
} catch (error) {
  if (error.code === 'auth/configuration-not-found') {
    console.error(
      '\nFirebase Authentication is not initialised for this project.\n' +
        'Open the console, click "Get started", then enable Email/Password:\n' +
        '  https://console.firebase.google.com/project/incident-report-app-1d35b/authentication\n\n' +
        'Then run this script again.',
    );
  } else {
    console.error(error);
  }
  process.exitCode = 1;
} finally {
  await admin.app().delete();
}

if (!process.exitCode) {
  console.log('Demo accounts seeded.');
}

# Reporty (Campus Incident Reporting App)

Reporty is a Flutter mobile app where students report campus issues such as
damaged facilities, water problems, electricity faults, safety risks and
sanitation concerns. Authorized staff review the reports and update their status.

Students can submit a report with a category, title, description, location and
an optional photo. Every report starts as Submitted and moves through In Progress
to Resolved. Signed-in users see live updates, and reporters can follow the
timestamped status timeline for their own reports.

Full technical report: [REPORT.md](REPORT.md)

## Prerequisites

Make sure the following are installed and working before you start:

- **Git**, to clone the repository.
- **Flutter SDK** with Dart SDK `^3.13.5`, installed and on your `PATH`. Verify
  with `flutter --version`.
- **Android Studio** (recommended) with an **Android emulator** configured, or a
  physical Android device connected. Xcode and an iOS simulator can be used,
  but the iOS Firebase options in this repository are placeholders until you run
  `flutterfire configure`.
- A running emulator or simulator, or a connected device.

## Getting started

1. Clone the repository:

   ```bash
   git clone https://github.com/elkuradusenge/incident-report-app.git
   ```

2. Move into the project directory:

   ```bash
   cd incident-report-app
   ```

3. Install the dependencies:

   ```bash
   flutter pub get
   ```

4. Start your Android emulator, or connect a physical Android device.

5. Run the app:

   ```bash
   flutter run
   ```

No local Firebase setup is required for Android. The repository already targets
the Firebase project `incident-report-app-1d35b`, and the Android Firebase
configuration is committed. For iOS or web, generate the missing platform
options with `flutterfire configure` before running on those platforms.

## Demo accounts

The login screen has a Demo accounts card. Tap an account to fill the form, then
tap Sign in. You can also type the credentials manually:

- Staff: `staff@alueducation.com` / `Staff@123`
- Student: `e.kuradusen@alustudent.com` / `Student@123`

Both accounts are created by `tool/seed_demo_accounts.mjs`. Only ALU addresses
are accepted: students use `@alustudent.com`, staff use `@alueducation.com`.
Self registration always creates a Student account. Staff accounts are assigned
by an administrator.

## Features

- Sign up and log in with email and password (Firebase Authentication).
- Email verification before the app becomes available.
- Students can submit reports with a category, title, description, location and
  an optional photo uploaded to Cloudinary.
- Students can browse the shared report feed, search and filter reports, view
  their own reports and track a report's status timeline.
- Students can delete their own report while it is still Submitted.
- Staff can review all reports, search and filter by status and category, and
  update the status, including reopening a report back to Submitted.
- Role-based access: only staff can update statuses, enforced by both the UI and
  Firestore security rules.
- Live Firestore streams keep report lists, counters and details current.

## Using and navigating the app

### Signing in

1. Open the app. If nobody is signed in, the Login screen appears.
2. Enter an ALU email and password and tap Sign in, or tap Create an account.
3. New accounts must verify their email. The Verify email screen offers:
   - I have verified, after opening the link in your inbox.
   - Resend email, to send the verification message again.
   - Use a different account, to return to Login.
4. Once the email is verified, the app opens the main shell.

The app remembers a signed-in session, so a returning verified user goes
straight to the main shell.

### Main navigation

The bottom bar has three tabs and, for students, a raised purple plus button in
the middle. Staff do not see the plus button because they cannot create reports.

| Control | What it opens |
|---|---|
| Home | Greeting, report summary, recent reports and the report shortcut |
| Reports | The full report feed with search and filters |
| Plus button | The Report an Incident form (students only) |
| Profile | The user profile and, for students, My Reports |

### Home

Home is the starting point after sign in.

- The greeting shows the signed-in user's first name.
- For students, the hero card and its Report an Issue button open the report
  form.
- Report Summary shows four counters: My Reports or Total Reports, In Progress,
  Resolved and Submitted.
- Tapping See All on Report Summary opens the Reports tab for staff and the
  Profile tab for students.
- Recent Reports lists the three newest reports. Tap a card to open it, or tap
  See All on that section to open the Reports tab.

Staff Home focuses on the review queue. It shows the newest reports from all
users and summary counts for the whole campus, without the report shortcut.

### Reports

The Reports tab lists every report, newest first.

- Use the search field to match a report by title, description, location,
  category or reporter name.
- Use the status chips to show All, Submitted, In Progress or Resolved.
- Use the category chips to show All, Facilities, Water, Electricity, Safety or
  Sanitation.
- Search and filters combine. If nothing matches, the screen shows a No reports
  found message.
- Tap any report card to open its details.

### Profile and My Reports

The Profile tab is personal.

- Students see My Reports as the screen title, a profile card, their own report
  counters, a status filter and a list of their own reports.
- Staff see Profile as the screen title and their profile card. Staff report
  review happens on the Reports tab.
- Tap a report in My Reports to open its details.
- Tap the sign out icon in the top right corner and confirm to sign out.

### Report an incident

Only students can create reports. Open the form from either the plus button in
the bottom bar or the Report an Issue button on Home.

1. Select a category. The options are Facilities, Water, Electricity, Safety and
   Sanitation.
2. Enter a title of at least 5 characters.
3. Enter a description of at least 15 characters. Include what happened, when it
   happened and who or what is affected.
4. Select a campus location from the dropdown.
5. Optionally add a photo. Tap the dashed photo box to choose an image from the
   gallery. Use the close button on the preview to remove it.
6. Tap Submit Report.

While the report is being submitted, the button shows a loading state. On
success, the app returns to the previous screen and shows a Report submitted
successfully message. The new report starts as Submitted, appears in My Reports
and in the shared Reports feed, and is visible to staff immediately.

If submission fails, the form keeps the entered values so the user can retry.
Staff accounts cannot submit reports, and the app blocks that action if it is
reached.

### Read a report

Tap any report card to open Incident Details. This is the main screen for
reading and following a single report.

- The summary card shows the category thumbnail or photo, title, location,
  current status, submission date and the reporter name.
- The Status Timeline shows the three lifecycle steps and the time each step was
  reached. Submitted, In Progress and Resolved are always visible, so the
  current position is clear at a glance.
- The Description section shows the full text entered by the reporter.
- Students see the read-only view. If the report is theirs and still Submitted,
  the three-dot menu offers Delete report.
- Staff see an Update Status section below the description.

The details screen listens to the report document directly. If a staff member
changes the status while a student has the report open, the student sees the new
status and timeline without refreshing.

### Update a report status

Staff handle the review queue from the Reports tab.

1. Open Reports and find a report with search or filters.
2. Tap the report card to open Incident Details.
3. Read the summary, status timeline and description.
4. Scroll to Update Status, choose Submitted, In Progress or Resolved, then tap
   Update.
5. The app shows a confirmation message and records the change in the status
   timeline with a timestamp.

Only staff can change a status. Staff cannot create or delete reports. The same
rules are enforced on the server, so they hold even if the UI is bypassed.

### Find and filter reports

- Search works across the report title, description, location, category and
  reporter name.
- Status and category filters can be used together with search.
- The Reports tab shows every report. My Reports on the Profile tab shows only
  the signed-in student's reports.
- Clearing the search text and selecting All on both filter rows restores the
  full list.

### Report status meanings

| Status | Meaning |
|---|---|
| Submitted | The report has been created and is waiting for staff review |
| In Progress | Staff have accepted the report and work is underway |
| Resolved | The issue has been fixed or otherwise closed |

Every status change is stored in the report's history. The details timeline
shows the time each status was reached, so the reporter can see how long the
issue took to move forward.

### Delete a report

A student can delete only their own report, and only while it is still
Submitted. Open the report, use the three-dot menu on Incident Details, and
confirm the delete. Deletion is permanent. A report that has moved to In
Progress or Resolved can no longer be deleted by the student.

### Common issues

| Problem | What to do |
|---|---|
| The app stays on Verify email | Open the verification link in your inbox, then tap I have verified. Use Resend email if the message did not arrive. |
| Sign up is rejected | Use an email ending in `@alustudent.com` or `@alueducation.com`. |
| The plus button is missing | Staff accounts cannot create reports. Sign in with a student account. |
| A report list is empty | Clear the search text and set the status and category filters to All. |
| A photo will not upload | Choose a smaller image. Photo uploads are limited to 5 MB. |
| A student cannot delete a report | Reports can only be deleted by their owner while the status is still Submitted. |

## Tech stack

- Flutter (Dart)
- Firebase Authentication and Cloud Firestore
- Cloudinary for unsigned incident photo uploads
- Firebase Storage as a fallback upload path when Cloudinary is not configured
- Provider for state management

## Photos

Incident photos are uploaded to Cloudinary (cloud `wp2qiyr6`, unsigned preset
`incident_unsigned`, folder `incident_photos`) when a report is submitted. The
returned `secure_url` is stored in the incident's `photoUrl` field. The upload
uses `incident_<incidentId>` as the public id.

Photos are optional and limited to 5 MB. A selected photo can be removed before
the report is submitted. Photos cannot be replaced after submission because the
app does not provide report editing.

The Cloudinary values can be overridden at run time. Copy
`dart_defines.example.json`, edit the values, and run:

```bash
flutter run --dart-define-from-file=dart_defines.json
```

If the Cloudinary values are empty, the storage service falls back to Firebase
Storage under `incident_photos/{uid}/{incidentId}.jpg`.

## Firebase configuration (already done)

- `lib/firebase_options.dart` contains the Android options for the Firebase
  project `incident-report-app-1d35b`.
- `android/app/google-services.json` is committed.
- `firestore.rules` contains the Firestore security rules.
- `storage.rules` contains the Firebase Storage rules.
- `firebase.json` maps the rules files, and `.firebaserc` selects the project.
- The iOS and web entries in `lib/firebase_options.dart` are placeholders. Run
  `flutterfire configure` to generate them for those platforms.

### Reproducing the setup on a new Firebase project

If you point this code at a different Firebase project:

1. Create the project in the Firebase Console and enable Email/Password sign-in
   under Authentication. Create a Firestore database and a Storage bucket if
   they do not exist.
2. Run `flutterfire configure` from the project root. This regenerates
   `lib/firebase_options.dart` and `android/app/google-services.json`.
3. Download a service account key from Firebase Console, Project settings,
   Service accounts. Save it as `tool/serviceAccountKey.json`. The file is
   gitignored.
4. Seed the demo accounts:

   ```bash
   cd tool
   npm install
   npm run seed
   cd ..
   ```

   The seed script uses the Admin SDK, so it can write the staff role even
   though the client rules only allow Student self registration.
5. Deploy the security rules:

   ```bash
   firebase deploy --only firestore:rules,storage
   ```

6. If you use a different Cloudinary account, update your `dart_defines.json`
   and pass it with `--dart-define-from-file=dart_defines.json`.

## Documentation

- Full technical report: [REPORT.md](REPORT.md)
- Demo video: [video/demo.mkv](video/demo.mkv) - download
- Video: https://youtu.be/kJ4RvyA9nuE

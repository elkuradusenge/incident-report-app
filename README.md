# Reporty: Campus Incident Reporting

Reporty is a Flutter app for reporting and tracking campus incidents. Students
report problems such as broken facilities, water leaks, power faults, safety
risks and sanitation issues. Staff review those reports and move them through a
simple lifecycle. Everyone signed in can follow the shared report feed, and the
reporter can watch their own report change status in real time.

The app runs on Android, iOS and the web from one codebase and uses Firebase for
authentication, data storage and image uploads.

- Full technical report: [REPORT.md](REPORT.md)
- Demo video: [video/demo.mkv](video/demo.mkv)

## What the app does

- Restricts registration to ALU email addresses (`@alustudent.com` and
  `@alueducation.com`).
- Requires email verification before the app can be used.
- Supports two roles: Student and Staff.
- Lets students create reports with a category, title, description, campus
  location and an optional photo.
- Shows live report lists, summary counters, search and filters.
- Lets staff change a report from Submitted to In Progress to Resolved, with a
  timestamped status timeline.
- Lets a student delete their own report while it is still Submitted.

## Run the app

You need a Flutter SDK and a configured Firebase project. From the project
root, run:

```bash
flutter pub get
flutter run
```

To point photo uploads at a different Cloudinary account, copy
`dart_defines.example.json`, edit the values, and run:

```bash
flutter run --dart-define-from-file=dart_defines.json
```

### Demo accounts

The login screen also has a Demo accounts card. Tap an account there to fill the
email and password fields, then tap Sign in.

| Role | Email | Password |
|---|---|---|
| Student | `e.kuradusen@alustudent.com` | `Student@123` |
| Staff | `staff@alueducation.com` | `Staff@123` |

The accounts are seeded by `tool/seed_demo_accounts.mjs`.

## Navigate the app

### First launch and sign in

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
the middle. Staff do not see the plus button because they do not create reports.

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

### Incident Details

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

## Report an incident

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

## Review and update a report

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

## Report status meanings

| Status | Meaning |
|---|---|
| Submitted | The report has been created and is waiting for staff review |
| In Progress | Staff have accepted the report and work is underway |
| Resolved | The issue has been fixed or otherwise closed |

Every status change is stored in the report's history. The details timeline
shows the time each status was reached, so the reporter can see how long the
issue took to move forward.

## Manage and find reports

- Search works across the report title, description, location, category and
  reporter name.
- Status and category filters can be used together with search.
- The Reports tab shows every report. My Reports on the Profile tab shows only
  the signed-in student's reports.
- A student can delete only their own report, and only while it is still
  Submitted. Use the three-dot menu on Incident Details and confirm the delete.
  Deletion is permanent.
- A report that has moved to In Progress or Resolved can no longer be deleted by
  the student.

## Roles and permissions

| Capability | Student | Staff |
|---|---|---|
| Register with an ALU email | Yes | No, staff accounts are created by an administrator |
| Browse reports | Yes | Yes |
| Create a report | Yes | No |
| Delete their own Submitted report | Yes | No |
| Change a report status | No | Yes |

Registration always creates a Student account. Staff roles are assigned by an
administrator in Firebase. All writes require a verified email address.

## Project structure

```text
lib/
  screens/       Screens for authentication, home, reports, report form,
                 incident details and profile
  providers/     AuthProvider and IncidentProvider, the app state layer
  services/      Firebase Authentication, Firestore and image upload code
  models/        AppUser, Incident and StatusChange
  core/          Theme, constants, shared widgets and utilities
test/            Model, provider and widget tests
tool/            Demo account seed script
REPORT.md        Full technical report
video/           Demo recording
```

The app follows a one-way data flow: screens read from providers, providers call
services, and services talk to Firebase. Firestore streams keep the screens up
to date automatically.

## Run the checks

```bash
flutter analyze
flutter test
```

## Learn more

The full technical report covers the architecture, Firebase data model, state
management, security rules, UI decisions, testing strategy, limitations and
lessons learned: [REPORT.md](REPORT.md).

## Troubleshooting

| Problem | What to do |
|---|---|
| The app stays on Verify email | Open the verification link in your inbox, then tap I have verified. Use Resend email if the message did not arrive. |
| Sign up is rejected | Use an email ending in `@alustudent.com` or `@alueducation.com`. |
| The plus button is missing | Staff accounts cannot create reports. Sign in with a student account. |
| A report list is empty | Clear the search text and set the status and category filters to All. |
| A photo will not upload | Choose a smaller image. Firebase Storage uploads are limited to 5 MB. |
| A student cannot delete a report | Reports can only be deleted by their owner while the status is still Submitted. |

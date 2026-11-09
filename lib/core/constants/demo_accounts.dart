import '../../models/app_user.dart';

/// A demo login shown on the landing screen and seeded into Firebase by
/// `tool/seed_demo_accounts.mjs`.
class DemoAccount {
  const DemoAccount({
    required this.role,
    required this.label,
    required this.email,
    required this.password,
  });

  final UserRole role;
  final String label;
  final String email;
  final String password;
}

abstract final class DemoAccounts {
  static const List<DemoAccount> all = <DemoAccount>[
    DemoAccount(
      role: UserRole.student,
      label: 'Student',
      email: 'e.kuradusen@alustudent.com',
      password: 'Student@123',
    ),
    DemoAccount(
      role: UserRole.staff,
      label: 'Staff',
      email: 'staff@alueducation.com',
      password: 'Staff@123',
    ),
  ];
}

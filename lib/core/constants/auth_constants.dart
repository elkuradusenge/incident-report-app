/// Rules shared by the registration and login forms.
abstract final class AuthConstants {
  /// The only institutional domains allowed to sign up.
  static const List<String> allowedEmailDomains = <String>[
    'alustudent.com',
    'alueducation.com',
  ];

  static const int minPasswordLength = 6;

  /// Human readable domain list, e.g. `@alustudent.com or @alueducation.com`.
  static String get allowedDomainsLabel =>
      allowedEmailDomains.map((String domain) => '@$domain').join(' or ');

  /// True when [email] uses one of [allowedEmailDomains].
  static bool isAluEmail(String email) {
    final String normalized = email.trim().toLowerCase();
    final int atIndex = normalized.lastIndexOf('@');
    if (atIndex <= 0 || atIndex == normalized.length - 1) return false;

    return allowedEmailDomains.contains(normalized.substring(atIndex + 1));
  }
}

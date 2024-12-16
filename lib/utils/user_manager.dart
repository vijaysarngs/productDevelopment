class UserManager {
  // Private constructor
  UserManager._privateConstructor();

  // Singleton instance
  static final UserManager instance = UserManager._privateConstructor();
  static String? _currentUserEmail;

  // User properties
  String? email; // Primary property for user identification
  String? msg;
  static void setCurrentUserEmail(String email) {
    email = email;
  }

  // Getter to retrieve the current user's email
  static String? getCurrentUserEmail() {
    return _currentUserEmail;
  }
}

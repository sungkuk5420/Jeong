enum AuthStatus { guest, authenticated }

enum AuthProvider { google, apple, email }

class AppUser {
  final String? id;
  final String displayName;
  final String? email;
  final String? profileImageUrl;
  final String? nationality;
  final AuthStatus status;
  final AuthProvider? provider;
  final List<String> bookmarkedPlaceIds;
  final DateTime? createdAt;

  const AppUser({
    this.id,
    this.displayName = 'Guest User',
    this.email,
    this.profileImageUrl,
    this.nationality,
    this.status = AuthStatus.guest,
    this.provider,
    this.bookmarkedPlaceIds = const [],
    this.createdAt,
  });

  bool get isGuest => status == AuthStatus.guest;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  AppUser copyWith({
    String? id,
    String? displayName,
    String? email,
    String? profileImageUrl,
    String? nationality,
    AuthStatus? status,
    AuthProvider? provider,
    List<String>? bookmarkedPlaceIds,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      nationality: nationality ?? this.nationality,
      status: status ?? this.status,
      provider: provider ?? this.provider,
      bookmarkedPlaceIds: bookmarkedPlaceIds ?? this.bookmarkedPlaceIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ProfileModel {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final bool hasFinishedSetup;

  ProfileModel({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    required this.hasFinishedSetup,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      displayName: json['display_name'] ?? json['name'] ?? 'User',
      avatarUrl: (json['avatar_url'] != null && (json['avatar_url'] as String).isNotEmpty) 
          ? json['avatar_url'] 
          : null,
      hasFinishedSetup: json['has_finished_setup'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'has_finished_setup': hasFinishedSetup,
    };
  }

  @override
  String toString() {
    return 'ProfileModel(id: $id, displayName: $displayName, avatarUrl: $avatarUrl, hasFinishedSetup: $hasFinishedSetup)';
  }
}
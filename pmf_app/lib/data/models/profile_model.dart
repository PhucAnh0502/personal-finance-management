class ProfileModel {
  final String id;
  final String displayName;
  final String avatarUrl;
  final bool hasFinishedSetup;

  ProfileModel({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
    required this.hasFinishedSetup,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
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
}
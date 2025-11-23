class OAuth2Response {
  final String tokenType;
  final int expiresIn;
  final String scope;
  final String idToken;
  final String accessToken;
  final Project project;
  final Profile profile;
  final String smartStyleUrl;
  final bool needPatientBanner;

  OAuth2Response({
    required this.tokenType,
    required this.expiresIn,
    required this.scope,
    required this.idToken,
    required this.accessToken,
    required this.project,
    required this.profile,
    required this.smartStyleUrl,
    required this.needPatientBanner,
  });

  factory OAuth2Response.fromJson(Map<String, dynamic> json) {
    return OAuth2Response(
      tokenType: json['token_type'] ?? '',
      expiresIn: json['expires_in'] ?? 0,
      scope: json['scope'] ?? '',
      idToken: json['id_token'] ?? '',
      accessToken: json['access_token'] ?? '',
      project: Project.fromJson(json['project'] ?? {}),
      profile: Profile.fromJson(json['profile'] ?? {}),
      smartStyleUrl: json['smart_style_url'] ?? '',
      needPatientBanner: json['need_patient_banner'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token_type': tokenType,
      'expires_in': expiresIn,
      'scope': scope,
      'id_token': idToken,
      'access_token': accessToken,
      'project': project.toJson(),
      'profile': profile.toJson(),
      'smart_style_url': smartStyleUrl,
      'need_patient_banner': needPatientBanner,
    };
  }
}

class Project {
  final String reference;
  final String display;

  Project({
    required this.reference,
    required this.display,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      reference: json['reference'] ?? '',
      display: json['display'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'display': display,
    };
  }
}

class Profile {
  final String reference;
  final String display;

  Profile({
    required this.reference,
    required this.display,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      reference: json['reference'] ?? '',
      display: json['display'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'display': display,
    };
  }
}

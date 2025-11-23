class UserProfile {
  final User user;
  final Project project;
  final Membership membership;
  final Profile profile;
  final Config config;
  final AccessPolicy accessPolicy;
  final Security security;

  UserProfile({
    required this.user,
    required this.project,
    required this.membership,
    required this.profile,
    required this.config,
    required this.accessPolicy,
    required this.security,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      user: User.fromJson(json['user'] ?? {}),
      project: Project.fromJson(json['project'] ?? {}),
      membership: Membership.fromJson(json['membership'] ?? {}),
      profile: Profile.fromJson(json['profile'] ?? {}),
      config: Config.fromJson(json['config'] ?? {}),
      accessPolicy: AccessPolicy.fromJson(json['accessPolicy'] ?? {}),
      security: Security.fromJson(json['security'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'project': project.toJson(),
      'membership': membership.toJson(),
      'profile': profile.toJson(),
      'config': config.toJson(),
      'accessPolicy': accessPolicy.toJson(),
      'security': security.toJson(),
    };
  }
}

class User {
  final String resourceType;
  final String id;
  final String email;

  User({
    required this.resourceType,
    required this.id,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      resourceType: json['resourceType'] ?? '',
      id: json['id'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceType': resourceType,
      'id': id,
      'email': email,
    };
  }
}

class Project {
  final String resourceType;
  final String id;
  final String name;
  final bool strictMode;
  final bool superAdmin;

  Project({
    required this.resourceType,
    required this.id,
    required this.name,
    required this.strictMode,
    required this.superAdmin,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      resourceType: json['resourceType'] ?? '',
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      strictMode: json['strictMode'] ?? false,
      superAdmin: json['superAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceType': resourceType,
      'id': id,
      'name': name,
      'strictMode': strictMode,
      'superAdmin': superAdmin,
    };
  }
}

class Membership {
  final String resourceType;
  final String id;
  final UserReference user;
  final ProfileReference profile;
  final bool admin;

  Membership({
    required this.resourceType,
    required this.id,
    required this.user,
    required this.profile,
    required this.admin,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      resourceType: json['resourceType'] ?? '',
      id: json['id'] ?? '',
      user: UserReference.fromJson(json['user'] ?? {}),
      profile: ProfileReference.fromJson(json['profile'] ?? {}),
      admin: json['admin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceType': resourceType,
      'id': id,
      'user': user.toJson(),
      'profile': profile.toJson(),
      'admin': admin,
    };
  }
}

class UserReference {
  final String reference;
  final String display;

  UserReference({
    required this.reference,
    required this.display,
  });

  factory UserReference.fromJson(Map<String, dynamic> json) {
    return UserReference(
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

class ProfileReference {
  final String reference;
  final String display;

  ProfileReference({
    required this.reference,
    required this.display,
  });

  factory ProfileReference.fromJson(Map<String, dynamic> json) {
    return ProfileReference(
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
  final String resourceType;
  final Meta meta;
  final List<Name> name;
  final List<Telecom> telecom;
  final String id;

  Profile({
    required this.resourceType,
    required this.meta,
    required this.name,
    required this.telecom,
    required this.id,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      resourceType: json['resourceType'] ?? '',
      meta: Meta.fromJson(json['meta'] ?? {}),
      name: (json['name'] as List<dynamic>?)
          ?.map((e) => Name.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      telecom: (json['telecom'] as List<dynamic>?)
          ?.map((e) => Telecom.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceType': resourceType,
      'meta': meta.toJson(),
      'name': name.map((e) => e.toJson()).toList(),
      'telecom': telecom.map((e) => e.toJson()).toList(),
      'id': id,
    };
  }
}

class Meta {
  final String project;
  final String versionId;
  final String lastUpdated;
  final Author author;
  final List<Compartment> compartment;

  Meta({
    required this.project,
    required this.versionId,
    required this.lastUpdated,
    required this.author,
    required this.compartment,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      project: json['project'] ?? '',
      versionId: json['versionId'] ?? '',
      lastUpdated: json['lastUpdated'] ?? '',
      author: Author.fromJson(json['author'] ?? {}),
      compartment: (json['compartment'] as List<dynamic>?)
          ?.map((e) => Compartment.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project': project,
      'versionId': versionId,
      'lastUpdated': lastUpdated,
      'author': author.toJson(),
      'compartment': compartment.map((e) => e.toJson()).toList(),
    };
  }
}

class Author {
  final String reference;

  Author({
    required this.reference,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      reference: json['reference'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
    };
  }
}

class Compartment {
  final String reference;

  Compartment({
    required this.reference,
  });

  factory Compartment.fromJson(Map<String, dynamic> json) {
    return Compartment(
      reference: json['reference'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
    };
  }
}

class Name {
  final List<String> given;
  final String family;

  Name({
    required this.given,
    required this.family,
  });

  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      given: (json['given'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      family: json['family'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'given': given,
      'family': family,
    };
  }
}

class Telecom {
  final String system;
  final String use;
  final String value;

  Telecom({
    required this.system,
    required this.use,
    required this.value,
  });

  factory Telecom.fromJson(Map<String, dynamic> json) {
    return Telecom(
      system: json['system'] ?? '',
      use: json['use'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'system': system,
      'use': use,
      'value': value,
    };
  }
}

class Config {
  final String resourceType;
  final List<Menu> menu;

  Config({
    required this.resourceType,
    required this.menu,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      resourceType: json['resourceType'] ?? '',
      menu: (json['menu'] as List<dynamic>?)
          ?.map((e) => Menu.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceType': resourceType,
      'menu': menu.map((e) => e.toJson()).toList(),
    };
  }
}

class Menu {
  final String title;
  final List<Link> link;

  Menu({
    required this.title,
    required this.link,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      title: json['title'] ?? '',
      link: (json['link'] as List<dynamic>?)
          ?.map((e) => Link.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'link': link.map((e) => e.toJson()).toList(),
    };
  }
}

class Link {
  final String name;
  final String target;

  Link({
    required this.name,
    required this.target,
  });

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      name: json['name'] ?? '',
      target: json['target'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'target': target,
    };
  }
}

class AccessPolicy {
  final String resourceType;
  final List<dynamic> basedOn;
  final List<Resource> resource;

  AccessPolicy({
    required this.resourceType,
    required this.basedOn,
    required this.resource,
  });

  factory AccessPolicy.fromJson(Map<String, dynamic> json) {
    return AccessPolicy(
      resourceType: json['resourceType'] ?? '',
      basedOn: json['basedOn'] ?? [],
      resource: (json['resource'] as List<dynamic>?)
          ?.map((e) => Resource.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceType': resourceType,
      'basedOn': basedOn,
      'resource': resource.map((e) => e.toJson()).toList(),
    };
  }
}

class Resource {
  final String? resourceType;
  final bool? readonly;

  Resource({
    this.resourceType,
    this.readonly,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      resourceType: json['resourceType'],
      readonly: json['readonly'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceType': resourceType,
      'readonly': readonly,
    };
  }
}

class Security {
  final bool mfaEnrolled;
  final List<Session> sessions;

  Security({
    required this.mfaEnrolled,
    required this.sessions,
  });

  factory Security.fromJson(Map<String, dynamic> json) {
    return Security(
      mfaEnrolled: json['mfaEnrolled'] ?? false,
      sessions: (json['sessions'] as List<dynamic>?)
          ?.map((e) => Session.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mfaEnrolled': mfaEnrolled,
      'sessions': sessions.map((e) => e.toJson()).toList(),
    };
  }
}

class Session {
  final String id;
  final String lastUpdated;
  final String authMethod;
  final String remoteAddress;
  final String browser;
  final String? os;

  Session({
    required this.id,
    required this.lastUpdated,
    required this.authMethod,
    required this.remoteAddress,
    required this.browser,
    this.os,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] ?? '',
      lastUpdated: json['lastUpdated'] ?? '',
      authMethod: json['authMethod'] ?? '',
      remoteAddress: json['remoteAddress'] ?? '',
      browser: json['browser'] ?? '',
      os: json['os'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lastUpdated': lastUpdated,
      'authMethod': authMethod,
      'remoteAddress': remoteAddress,
      'browser': browser,
      'os': os,
    };
  }
}

class FhirBundle {
  final String resourceType;
  final String type;
  final List<FhirEntry> entry;
  final int total;
  final List<FhirLink>? link;

  FhirBundle({
    required this.resourceType,
    required this.type,
    required this.entry,
    required this.total,
    this.link,
  });

  factory FhirBundle.fromJson(Map<String, dynamic> json) {
    return FhirBundle(
      resourceType: json['resourceType'] ?? '',
      type: json['type'] ?? '',
      entry: (json['entry'] as List<dynamic>?)
          ?.map((e) => FhirEntry.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      total: json['total'] ?? 0,
      link: (json['link'] as List<dynamic>?)
          ?.map((e) => FhirLink.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceType': resourceType,
      'type': type,
      'entry': entry.map((e) => e.toJson()).toList(),
      'total': total,
      'link': link?.map((e) => e.toJson()).toList(),
    };
  }
}

class FhirEntry {
  final String fullUrl;
  final FhirSearch search;
  final FhirOrganization resource;

  FhirEntry({
    required this.fullUrl,
    required this.search,
    required this.resource,
  });

  factory FhirEntry.fromJson(Map<String, dynamic> json) {
    return FhirEntry(
      fullUrl: json['fullUrl'] ?? '',
      search: FhirSearch.fromJson(json['search'] as Map<String, dynamic>? ?? {}),
      resource: FhirOrganization.fromJson(json['resource'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullUrl': fullUrl,
      'search': search.toJson(),
      'resource': resource.toJson(),
    };
  }
}

class FhirSearch {
  final String mode;

  FhirSearch({
    required this.mode,
  });

  factory FhirSearch.fromJson(Map<String, dynamic> json) {
    return FhirSearch(
      mode: json['mode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
    };
  }
}

class FhirOrganization {
  final String resourceType;
  final bool active;
  final List<FhirOrganizationType>? type;
  final String name;
  final FhirReference? partOf;
  final String id;
  final FhirMeta meta;
  final List<FhirTelecom>? telecom;
  final List<FhirAddress>? address;

  FhirOrganization({
    required this.resourceType,
    required this.active,
    this.type,
    required this.name,
    this.partOf,
    required this.id,
    required this.meta,
    this.telecom,
    this.address,
  });

  factory FhirOrganization.fromJson(Map<String, dynamic> json) {
    return FhirOrganization(
      resourceType: json['resourceType'] ?? '',
      active: json['active'] ?? false,
      type: (json['type'] as List<dynamic>?)
          ?.map((e) => FhirOrganizationType.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
      name: json['name'] ?? '',
      partOf: json['partOf'] != null 
          ? FhirReference.fromJson(json['partOf'] as Map<String, dynamic>? ?? {})
          : null,
      id: json['id'] ?? '',
      meta: FhirMeta.fromJson(json['meta'] as Map<String, dynamic>? ?? {}),
      telecom: (json['telecom'] as List<dynamic>?)
          ?.map((e) => FhirTelecom.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
      address: (json['address'] as List<dynamic>?)
          ?.map((e) => FhirAddress.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceType': resourceType,
      'active': active,
      'type': type?.map((e) => e.toJson()).toList(),
      'name': name,
      'partOf': partOf?.toJson(),
      'id': id,
      'meta': meta.toJson(),
      'telecom': telecom?.map((e) => e.toJson()).toList(),
      'address': address?.map((e) => e.toJson()).toList(),
    };
  }
}

class FhirOrganizationType {
  final List<FhirCoding> coding;

  FhirOrganizationType({
    required this.coding,
  });

  factory FhirOrganizationType.fromJson(Map<String, dynamic> json) {
    return FhirOrganizationType(
      coding: (json['coding'] as List<dynamic>? ?? [])
          .map((e) => FhirCoding.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coding': coding.map((e) => e.toJson()).toList(),
    };
  }
}

class FhirCoding {
  final String? system;
  final String code;
  final String display;

  FhirCoding({
    this.system,
    required this.code,
    required this.display,
  });

  factory FhirCoding.fromJson(Map<String, dynamic> json) {
    return FhirCoding(
      system: json['system'],
      code: json['code'] ?? '',
      display: json['display'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'system': system,
      'code': code,
      'display': display,
    };
  }
}

class FhirReference {
  final String reference;
  final String display;

  FhirReference({
    required this.reference,
    required this.display,
  });

  factory FhirReference.fromJson(Map<String, dynamic> json) {
    return FhirReference(
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

class FhirMeta {
  final String versionId;
  final String lastUpdated;
  final FhirReference author;
  final String project;
  final List<FhirReference> compartment;

  FhirMeta({
    required this.versionId,
    required this.lastUpdated,
    required this.author,
    required this.project,
    required this.compartment,
  });

  factory FhirMeta.fromJson(Map<String, dynamic> json) {
    return FhirMeta(
      versionId: json['versionId'] ?? '',
      lastUpdated: json['lastUpdated'] ?? '',
      author: FhirReference.fromJson(json['author'] as Map<String, dynamic>? ?? {}),
      project: json['project'] ?? '',
      compartment: (json['compartment'] as List<dynamic>? ?? [])
          .map((e) => FhirReference.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'versionId': versionId,
      'lastUpdated': lastUpdated,
      'author': author.toJson(),
      'project': project,
      'compartment': compartment.map((e) => e.toJson()).toList(),
    };
  }
}

class FhirTelecom {
  final String system;
  final String use;
  final String value;

  FhirTelecom({
    required this.system,
    required this.use,
    required this.value,
  });

  factory FhirTelecom.fromJson(Map<String, dynamic> json) {
    return FhirTelecom(
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

class FhirAddress {
  final String use;
  final String type;
  final List<String> line;

  FhirAddress({
    required this.use,
    required this.type,
    required this.line,
  });

  factory FhirAddress.fromJson(Map<String, dynamic> json) {
    return FhirAddress(
      use: json['use'] ?? '',
      type: json['type'] ?? '',
      line: (json['line'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'use': use,
      'type': type,
      'line': line,
    };
  }
}

class FhirLink {
  final String relation;
  final String url;

  FhirLink({
    required this.relation,
    required this.url,
  });

  factory FhirLink.fromJson(Map<String, dynamic> json) {
    return FhirLink(
      relation: json['relation'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'relation': relation,
      'url': url,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing user profile data
class ProfileModel {
  final String name;
  final String role;
  final String email;
  final String phone;
  final String location;
  final String experience;
  final String githubUrl;
  final String linkedinUrl;
  final String twitterUrl;
  final String resumeUrl;
  final String profileUrl;
  final List<String> typingTexts;
  final List<HighlightModel> aboutHighlights;

  const ProfileModel({
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.location,
    required this.experience,
    required this.githubUrl,
    required this.linkedinUrl,
    required this.twitterUrl,
    required this.resumeUrl,
    required this.profileUrl,
    required this.typingTexts,
    required this.aboutHighlights,
  });

  factory ProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProfileModel(
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      location: data['location'] ?? '',
      experience: data['experience'] ?? '',
      githubUrl: data['githubUrl'] ?? '',
      linkedinUrl: data['linkedinUrl'] ?? '',
      twitterUrl: data['twitterUrl'] ?? '',
      resumeUrl: data['resumeUrl'] ?? '',
      profileUrl: data['profileUrl'] ?? '',
      typingTexts: List<String>.from(data['typingTexts'] ?? []),
      aboutHighlights: (data['aboutHighlights'] as List<dynamic>? ?? [])
          .map((e) => HighlightModel.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'role': role,
      'email': email,
      'phone': phone,
      'location': location,
      'experience': experience,
      'githubUrl': githubUrl,
      'linkedinUrl': linkedinUrl,
      'twitterUrl': twitterUrl,
      'resumeUrl': resumeUrl,
      'profileUrl': profileUrl,
      'typingTexts': typingTexts,
      'aboutHighlights': aboutHighlights.map((e) => e.toMap()).toList(),
    };
  }
}

class HighlightModel {
  final String icon;
  final String title;
  final String subtitle;

  const HighlightModel({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  factory HighlightModel.fromMap(Map<String, dynamic> map) {
    return HighlightModel(
      icon: map['icon'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'icon': icon,
      'title': title,
      'subtitle': subtitle,
    };
  }
}

/// Model representing a skill category (e.g., Mobile & Web)
class SkillCategoryModel {
  final String id;
  final String category;
  final List<SkillModel> skills;
  final int order;

  const SkillCategoryModel({
    required this.id,
    required this.category,
    required this.skills,
    this.order = 0,
  });

  factory SkillCategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SkillCategoryModel(
      id: doc.id,
      category: data['category'] ?? '',
      order: data['order'] ?? 0,
      skills: (data['skills'] as List<dynamic>? ?? [])
          .map((e) => SkillModel.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'order': order,
      'skills': skills.map((e) => e.toMap()).toList(),
    };
  }
}

class SkillModel {
  final String name;
  final double level;

  const SkillModel({
    required this.name,
    required this.level,
  });

  factory SkillModel.fromMap(Map<String, dynamic> map) {
    return SkillModel(
      name: map['name'] ?? '',
      level: (map['level'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'level': level,
    };
  }
}

/// Model representing work experience
class ExperienceModel {
  final String id;
  final String role;
  final String company;
  final String? companyLogoUrl;
  final String? companyWebsiteUrl;
  final String duration;
  final String location;
  final String description;
  final List<String> technologies;
  final bool isCurrent;
  final int order;

  const ExperienceModel({
    required this.id,
    required this.role,
    required this.company,
    this.companyLogoUrl,
    this.companyWebsiteUrl,
    required this.duration,
    required this.location,
    required this.description,
    required this.technologies,
    required this.isCurrent,
    this.order = 0,
  });

  factory ExperienceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ExperienceModel(
      id: doc.id,
      role: data['role'] ?? '',
      company: data['company'] ?? '',
      companyLogoUrl: data['companyLogoUrl'],
      companyWebsiteUrl: data['companyWebsiteUrl'],
      duration: data['duration'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      technologies: List<String>.from(data['technologies'] ?? []),
      isCurrent: data['isCurrent'] ?? false,
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'role': role,
      'company': company,
      'companyLogoUrl': companyLogoUrl,
      'companyWebsiteUrl': companyWebsiteUrl,
      'duration': duration,
      'location': location,
      'description': description,
      'technologies': technologies,
      'isCurrent': isCurrent,
      'order': order,
    };
  }
}

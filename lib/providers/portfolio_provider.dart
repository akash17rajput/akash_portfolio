import 'dart:async';
import 'package:flutter/material.dart';
import '../models/portfolio_models.dart';
import '../services/firebase_service.dart';
import '../core/constants/app_constants.dart';

class PortfolioProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  ProfileModel? _profile;
  List<SkillCategoryModel> _skills = [];
  List<ExperienceModel> _experience = [];

  bool _isLoadingProfile = true;
  bool _isLoadingSkills = true;
  bool _isLoadingExperience = true;

  StreamSubscription? _profileSub;
  StreamSubscription? _skillsSub;
  StreamSubscription? _expSub;

  // ─── Getters ─────────────────────────────────────────────────────────────

  bool get isLoading =>
      _isLoadingProfile || _isLoadingSkills || _isLoadingExperience;

  /// Returns Profile from Firebase, or falls back to local AppConstants if unavailable
  ProfileModel get profile {
    if (_profile != null) return _profile!;

    // Fallback to local data
    return ProfileModel(
      name: AppConstants.developerName,
      role: AppConstants.developerRole,
      email: AppConstants.developerEmail,
      phone: AppConstants.developerPhone,
      location: AppConstants.developerLocation,
      experience: AppConstants.developerExperience,
      githubUrl: AppConstants.githubUrl,
      linkedinUrl: AppConstants.linkedinUrl,
      twitterUrl: AppConstants.twitterUrl,
      resumeUrl: AppConstants.resumeUrl,
      profileUrl: AppConstants.profileUrl,
      typingTexts: AppConstants.typingTexts,
      aboutHighlights: AppConstants.aboutHighlights
          .map((h) => HighlightModel(
                icon: h['icon'] ?? '',
                title: h['title'] ?? '',
                subtitle: h['subtitle'] ?? '',
              ))
          .toList(),
    );
  }

  /// Returns Skills from Firebase, or falls back to local AppConstants if unavailable
  List<SkillCategoryModel> get skills {
    if (_skills.isNotEmpty) return _skills;

    // Fallback to local data
    int order = 0;
    return AppConstants.skillsData.map((s) {
      return SkillCategoryModel(
        id: 'local_$order',
        category: s['category'] as String,
        order: order++,
        skills: (s['skills'] as List).map((skillMap) {
          return SkillModel(
            name: skillMap['name'] as String,
            level: (skillMap['level'] as num).toDouble(),
          );
        }).toList(),
      );
    }).toList();
  }

  /// Returns Experience from Firebase, or falls back to local AppConstants if unavailable
  List<ExperienceModel> get experience {
    if (_experience.isNotEmpty) return _experience;

    // Fallback to local data
    int order = 0;
    return AppConstants.experienceData.map((e) {
      return ExperienceModel(
        id: 'local_$order',
        role: e['role'] as String,
        company: e['company'] as String,
        companyLogoUrl: e['companyLogoUrl'] as String?,
        companyWebsiteUrl: e['companyWebsiteUrl'] as String?,
        duration: e['duration'] as String,
        location: e['location'] as String,
        description: e['description'] as String,
        technologies: List<String>.from(e['technologies'] as List),
        isCurrent: e['isCurrent'] as bool,
        order: order++,
      );
    }).toList();
  }

  // ─── Initialization ──────────────────────────────────────────────────────

  PortfolioProvider() {
    _listenToData();
  }

  void _listenToData() {
    // 1. Profile
    _profileSub = _firebaseService.getProfileStream().listen(
      (data) {
        if (data != null) {
          final hasValidProfile = data.name.isNotEmpty ||
              data.email.isNotEmpty ||
              data.phone.isNotEmpty ||
              data.githubUrl.isNotEmpty ||
              data.linkedinUrl.isNotEmpty;

          // 👇 YAHAN ADD KARO
          debugPrint("HAS VALID PROFILE: $hasValidProfile");
          debugPrint("DATA EMAIL: ${data.email}");
          debugPrint("DATA PHONE: ${data.phone}");

          if (hasValidProfile) {
            _profile = data;
          } else {
            debugPrint(
                'PortfolioProvider: received invalid or empty profile from Firebase; keeping local fallback.');
          }
        } else {
          debugPrint(
              'PortfolioProvider: Firebase profile stream returned null.');
        }

        _isLoadingProfile = false;
        notifyListeners();
      },
    );

    // 2. Skills
    _skillsSub = _firebaseService.getSkillsStream().listen(
      (data) {
        if (data.isNotEmpty) _skills = data;
        _isLoadingSkills = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoadingSkills = false;
        notifyListeners();
      },
    );

    // 3. Experience
    _expSub = _firebaseService.getExperienceStream().listen(
      (data) {
        if (data.isNotEmpty) _experience = data;
        _isLoadingExperience = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoadingExperience = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    _skillsSub?.cancel();
    _expSub?.cancel();
    super.dispose();
  }
}

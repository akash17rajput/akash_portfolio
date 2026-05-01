import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a portfolio project from Firestore
class ProjectModel {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final String imageUrl;
  final String liveUrl;
  final String category;
  final int order;
  final DateTime createdAt;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.imageUrl,
    required this.liveUrl,
    required this.category,
    this.order = 0,
    required this.createdAt,
  });

  /// Create from Firestore document
  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      liveUrl: data['liveUrl'] ?? '',
      category: data['category'] ?? 'Mobile',
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'tags': tags,
      'imageUrl': imageUrl,
      'liveUrl': liveUrl,
      'category': category,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Copy with modifications
  ProjectModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? tags,
    String? imageUrl,
    String? liveUrl,
    String? category,
    int? order,
    DateTime? createdAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      liveUrl: liveUrl ?? this.liveUrl,
      category: category ?? this.category,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'ProjectModel(id: $id, title: $title)';
}

List<ProjectModel> get sampleProjects => [
      ProjectModel(
        id: '1',
        title: 'Acclaim Guard Services App',
        description:
            'A US-based vehicle number plate scanner app with real-time detection and API integration. Implemented OCR-based scanning and optimized performance for accurate results.',
        tags: ['Flutter', 'OCR', 'Firebase', 'REST APIs'],
        imageUrl: 'https://picsum.photos/seed/acclaim/800/500',
        liveUrl: 'https://github.com/akashkumar',
        category: 'Mobile',
        order: 1,
        createdAt: DateTime(2023, 9, 10),
      ),
      ProjectModel(
        id: '2',
        title: 'Vitamein Healthcare App',
        description:
            'A healthcare mobile application focused on user wellness tracking and health management. Designed user-friendly UI with smooth navigation and API-based data handling.',
        tags: ['Flutter', 'Firebase', 'REST APIs', 'UI/UX'],
        imageUrl: 'https://picsum.photos/seed/vitamein/800/500',
        liveUrl: 'https://github.com/akashkumar',
        category: 'Mobile',
        order: 2,
        createdAt: DateTime(2023, 7, 5),
      ),
      ProjectModel(
        id: '3',
        title: 'Dr. Ortho E-commerce App',
        description:
            'An e-commerce mobile application for healthcare products with cart management, product listings, and secure checkout flow.',
        tags: ['Flutter', 'Firebase', 'Provider', 'E-commerce'],
        imageUrl: 'https://picsum.photos/seed/ortho/800/500',
        liveUrl:
            'https://play.google.com/store/apps/details?id=com.dr.ortho.drortho&pcampaignid=web_share',
        category: 'Mobile',
        order: 3,
        createdAt: DateTime(2023, 5, 15),
      ),
      ProjectModel(
        id: '4',
        title: 'Count Safety First (CSF) App',
        description:
            'A road safety awareness application that allows users to report and track safety-related incidents. Focused on intuitive UI and real-time data updates.',
        tags: ['Flutter', 'Firebase', 'Maps', 'Realtime Data'],
        imageUrl: 'https://picsum.photos/seed/csf/800/500',
        liveUrl: 'https://github.com/akashkumar',
        category: 'Mobile',
        order: 4,
        createdAt: DateTime(2023, 3, 20),
      ),
      ProjectModel(
        id: '5',
        title: 'Dubai Local App',
        description:
            'A live business listing application for Dubai featuring categorized listings, search functionality, and location-based services.',
        tags: ['Flutter', 'REST APIs', 'Search', 'Location'],
        imageUrl:
            'https://github.com/GouravXportsoft/dubailocal_final/blob/main/assets/images/logo.png?raw=true',
        liveUrl: 'https://github.com/akashkumar',
        category: 'Mobile',
        order: 5,
        createdAt: DateTime(2023, 1, 25),
      ),
      ProjectModel(
        id: '6',
        title: 'RedBus Clone App',
        description:
            'A travel booking application with bus search, seat selection, and booking features. Built to understand complex UI flows and API integrations.',
        tags: ['Flutter', 'API Integration', 'UI/UX', 'Booking System'],
        imageUrl: 'https://picsum.photos/seed/redbus/800/500',
        liveUrl: 'https://github.com/akashkumar',
        category: 'Mobile',
        order: 6,
        createdAt: DateTime(2022, 11, 10),
      ),
      ProjectModel(
        id: '7',
        title: 'Dwarpal User App',
        description:
            'Dwarpal is a comprehensive society management and security application designed to simplify daily operations in residential communities. It enables seamless visitor management, communication, and task handling, ensuring a secure and organized living experience.',
        tags: ['Flutter', 'Firebase', 'API Integration', 'UI/UX'],
        imageUrl:
            'https://play-lh.googleusercontent.com/DE15BN_qQ2s_9XOQNvSdYL1BEa25RNINLYRqZdOlqgCIFbo6X6VDPE6mIny-4gZ-3A=w240-h480-rw',
        liveUrl:
            'https://play.google.com/store/apps/details?id=com.dwarpal.user',
        category: 'Mobile',
        order: 7,
        createdAt: DateTime(2022, 11, 10),
      ),
      ProjectModel(
        id: '8',
        title: 'Dwarpal Guard App',
        description:
            'Dwarpal Guard is a dedicated security and visitor tracking application built for society guards. It streamlines entry and exit monitoring, enhances security operations, and ensures real-time access control for residential communities.',
        tags: [
          'Flutter',
          'Security App',
          'API Integration',
          'Visitor Tracking'
        ],
        imageUrl:
            'https://play-lh.googleusercontent.com/DE15BN_qQ2s_9XOQNvSdYL1BEa25RNINLYRqZdOlqgCIFbo6X6VDPE6mIny-4gZ-3A=w240-h480-rw',
        liveUrl: 'https://apps.apple.com/in/app/dwarpal-guard/id6751195490',
        category: 'Mobile',
        order: 8,
        createdAt: DateTime(2022, 11, 10),
      ),
      ProjectModel(
        id: '9',
        title: 'Influsway App',
        description:
            'Influsway is an influencer marketing platform that connects brands with creators for seamless collaborations, campaign management, and content partnerships.',
        tags: ['Flutter', 'REST API', 'Social Platform', 'Campaign Management'],
        imageUrl:
            'https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/12/35/6c/12356c78-16fd-9412-9ad9-fed23017d479/Placeholder.mill/200x200bb-75.webp',
        liveUrl: 'https://apps.apple.com/in/app/influsway/id6742641688',
        category: 'Mobile',
        order: 9,
        createdAt: DateTime(2022, 11, 10),
      ),
      ProjectModel(
        id: '10',
        title: 'Amazing Jewish Facts Calendar App',
        description:
            'A daily knowledge app delivering inspiring Jewish facts, historical insights, and practical life wisdom across spirituality, ethics, and relationships.',
        tags: ['Flutter', 'Content App', 'Calendar', 'Daily Updates'],
        imageUrl:
            'https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/ee/bf/43/eebf4361-3f6b-eb26-3421-dc2fa9d711e9/AppIcon-1x_U007emarketing-0-8-0-85-220-0.png/200x200ia-75.webp',
        liveUrl:
            'https://apps.apple.com/in/app/amazing-jewish-facts-calendar/id6451274216',
        category: 'Mobile',
        order: 10,
        createdAt: DateTime(2022, 11, 10),
      ),
      ProjectModel(
        id: '11',
        title: 'Bokakola App',
        description:
            'Bokakola is a marketplace platform that allows users to buy and sell products locally in the DRC, helping businesses grow and customers find the best deals easily.',
        tags: ['Flutter', 'Marketplace', 'E-commerce', 'Local Business'],
        imageUrl: 'assets/images/bokakola.png',
        liveUrl: '',
        category: 'Mobile',
        order: 11,
        createdAt: DateTime(2022, 11, 10),
      ),
      ProjectModel(
        id: '12',
        title: 'ShortsGen App',
        description:
            'ShortsGen is an AI-powered video processing app that converts YouTube videos into short-form content. It uses OpenAI to generate clip timestamps and captions, processes videos via APIs, and enables users to preview, download, and share engaging social media clips.',
        tags: [
          'Flutter',
          'AI Integration',
          'Video Processing',
          'OpenAI',
          'Firebase'
        ],
        imageUrl: '',
        liveUrl: '',
        category: 'Mobile',
        order: 12,
        createdAt: DateTime(2022, 11, 10),
      ),
    ];

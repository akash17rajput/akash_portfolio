/// App-wide constants for the portfolio application
class AppConstants {
  AppConstants._();

  // Developer Info
  static const String developerName = 'Akash Kumar';
  static const String developerRole = 'Senior Flutter Developer';
  static const String developerEmail = 'akash.kumar@example.com';
  static const String developerPhone = '+91 98765 43210';
  static const String developerLocation = 'India';
  static const String developerExperience = '3+ Years';
  static const String githubUrl = 'https://github.com/akash17rajput';
  static const String linkedinUrl =
      'https://www.linkedin.com/in/akash-kashyap-dev/';
  static const String twitterUrl = 'https://twitter.com/akashkumar';
  static const String resumeUrl = 'assets/resume/akash_kumar_resume.pdf';
  static const String profileUrl = '';
  // Typing animation texts
  static const List<String> typingTexts = [
    'Flutter Developer',
    'Firebase Expert',
    'API Specialist',
    'UI/UX Engineer',
  ];

  // Navigation sections
  static const List<String> navSections = [
    'Home',
    'About',
    'Skills',
    'Experience',
    'Projects',
    'Contact',
  ];

  // Section IDs for scroll
  static const String heroSection = 'hero';
  static const String aboutSection = 'about';
  static const String skillsSection = 'skills';
  static const String experienceSection = 'experience';
  static const String projectsSection = 'projects';
  static const String contactSection = 'contact';

  // Firestore collections
  static const String projectsCollection = 'projects';
  static const String messagesCollection = 'messages';

  // Local storage keys
  static const String themeKey = 'isDarkMode';

  // About highlights
  static const List<Map<String, String>> aboutHighlights = [
    {
      'icon': 'work',
      'title': '3.5+ Years',
      'subtitle': 'Professional Experience',
    },
    {
      'icon': 'code',
      'title': '20+ Skills',
      'subtitle': 'Technologies Mastered',
    },
    {
      'icon': 'design_services',
      'title': 'UI/UX Focus',
      'subtitle': 'Pixel-Perfect Design',
    },
  ];

  // Skills data
  static const List<Map<String, dynamic>> skillsData = [
    {
      'category': 'Mobile & Web',
      'skills': [
        {'name': 'Flutter', 'level': 0.95},
        {'name': 'Dart', 'level': 0.92},
        {'name': 'Flutter Web', 'level': 0.88},
        {'name': 'Flutter Desktop', 'level': 0.75},
      ],
    },
    {
      'category': 'Backend & Database',
      'skills': [
        {'name': 'Firebase', 'level': 0.90},
        {'name': 'Cloud Firestore', 'level': 0.88},
        {'name': 'Firebase Auth', 'level': 0.85},
        {'name': 'REST APIs', 'level': 0.87},
      ],
    },
    {
      'category': 'Tools & Others',
      'skills': [
        {'name': 'Git & GitHub', 'level': 0.90},
        {'name': 'UI/UX Design', 'level': 0.80},
        {'name': 'State Management', 'level': 0.88},
        {'name': 'CI/CD', 'level': 0.72},
      ],
    },
  ];

  // Experience data
  static const List<Map<String, dynamic>> experienceData = [
    {
      'role': 'Senior Flutter Developer',
      'company': 'XportSoft Technologies Pvt. Ltd.',
      'duration': 'June 2023 – Present',
      'location': 'On-site | Ambala Cantt',
      'description':
          'Leading end-to-end development of multiple cross-platform mobile applications. Implemented scalable architectures and optimized app performance across devices. Integrated Firebase services and REST APIs for real-time data handling.',
      'technologies': ['Flutter', 'Dart', 'Firebase', 'REST APIs', 'Git'],
      'isCurrent': true,
    },
    {
      'role': 'Flutter Developer',
      'company': 'Mitisha Softech Pvt. Ltd.',
      'duration': 'Jan 2023 – May 2023',
      'location': 'On-site | SAS Nagar, Punjab',
      'description':
          'Collaborated on full-cycle development of multiple Flutter applications. Focused on responsive UI design, state management, and API integrations. Worked closely with teams to deliver production-ready features.',
      'technologies': ['Flutter', 'Dart', 'Provider', 'REST APIs'],
      'isCurrent': false,
    },
    {
      'role': 'Flutter Developer Intern',
      'company': 'Solitaire Infosys Pvt. Ltd.',
      'duration': 'July 2022 – Dec 2022',
      'location': 'On-site | SAS Nagar, Punjab',
      'description':
          'Gained hands-on experience working on real-world client projects. Contributed to UI implementation and API integrations while learning Flutter development and best practices.',
      'technologies': ['Flutter', 'Dart', 'Firebase', 'GetX'],
      'isCurrent': false,
    },
  ];
  // Project categories
  static const List<String> projectCategories = [
    'All',
    'Mobile',
    'Web',
    'Firebase',
    'UI/UX',
  ];
}

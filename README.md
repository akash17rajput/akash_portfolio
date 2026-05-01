# 🚀 Akash Kumar — Flutter Developer Portfolio

A **production-ready**, modern, animated Flutter Web portfolio application with Firebase backend integration. Built with glassmorphism UI, smooth animations, and real-time data management.

![Flutter](https://img.shields.io/badge/Flutter-3.5+-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Integrated-FFCA28?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green)

---

## ✨ Features

### 🎨 **Frontend (Flutter Web)**
- ✅ **Fully Responsive** — Mobile, tablet, and desktop optimized
- ✅ **Dark/Light Mode** — Toggle with persistent local storage
- ✅ **Glassmorphism UI** — Modern blur effects, transparency, soft borders
- ✅ **Smooth Animations** — Fade-in on scroll, slide transitions, hover effects
- ✅ **Sticky Navbar** — Active section highlighting with scroll effect
- ✅ **Animated Hero Section** — Typing animation, gradient background, floating badges
- ✅ **About Section** — Summary card with highlight stats
- ✅ **Skills Section** — Animated progress bars with hover cards
- ✅ **Experience Timeline** — Animated timeline UI with tech tags
- ✅ **Projects Grid** — Dynamic cards fetched from Firebase with category filters
- ✅ **Contact Form** — Firebase Firestore integration with validation
- ✅ **SEO Optimized** — Meta tags, Open Graph, Twitter Cards

### 🔥 **Backend (Firebase)**
- ✅ **Firebase Hosting** — Deploy with one command
- ✅ **Cloud Firestore** — Real-time project and message storage
- ✅ **Firebase Storage** — Project images hosting
- ✅ **Firestore Security Rules** — Public read, authenticated write
- ✅ **Auto-updates** — Portfolio updates when Firestore data changes

### 🏗️ **Architecture**
- ✅ **Clean Architecture** — Separated UI, services, models, providers
- ✅ **Provider State Management** — Theme, navigation, projects, contact
- ✅ **Reusable Components** — Glass cards, gradient buttons, section headers
- ✅ **Well-commented Code** — Easy to understand and customize

---

## 📂 Project Structure

```
akash_portfolio/
├── lib/
│   ├── core/
│   │   ├── constants/       # App constants (developer info, skills, experience)
│   │   ├── theme/           # Theme configuration (colors, text styles)
│   │   └── utils/           # Helpers (responsive, scroll)
│   ├── models/              # Data models (Project, Message)
│   ├── services/            # Firebase service layer
│   ├── providers/           # State management (Provider)
│   ├── screens/             # Main screens (Home)
│   ├── widgets/             # UI components
│   │   ├── navbar/          # Sticky navigation bar
│   │   ├── hero/            # Hero section with animations
│   │   ├── about/           # About section
│   │   ├── skills/          # Skills with progress bars
│   │   ├── experience/      # Timeline UI
│   │   ├── projects/        # Dynamic project cards
│   │   ├── contact/         # Contact form
│   │   └── shared/          # Reusable widgets (GlassCard, GradientButton)
│   ├── firebase_options.dart
│   └── main.dart
├── web/
│   └── index.html           # Custom loading screen, SEO meta tags
├── assets/
│   ├── images/              # Project images
│   └── resume/              # Resume PDF
├── firestore.rules          # Firestore security rules
├── firestore.indexes.json   # Firestore indexes
├── firebase.json            # Firebase hosting config
└── pubspec.yaml
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.5+ ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Firebase CLI ([Install Firebase CLI](https://firebase.google.com/docs/cli))
- A Firebase project ([Create Firebase Project](https://console.firebase.google.com/))

### 1️⃣ Clone & Install Dependencies

```bash
git clone https://github.com/yourusername/akash_portfolio.git
cd akash_portfolio
flutter pub get
```

### 2️⃣ Configure Firebase

#### Option A: Automatic (Recommended)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

#### Option B: Manual
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing
3. Add a **Web app** to your Firebase project
4. Copy the Firebase config and replace values in `lib/firebase_options.dart`

### 3️⃣ Enable Firestore & Storage

1. In Firebase Console → **Firestore Database** → Create database (start in **test mode**)
2. Deploy security rules:
   ```bash
   firebase deploy --only firestore:rules
   ```
3. In Firebase Console → **Storage** → Get started

### 4️⃣ Customize Your Portfolio

Edit `lib/core/constants/app_constants.dart`:

```dart
static const String developerName = 'Your Name';
static const String developerRole = 'Your Role';
static const String developerEmail = 'your@email.com';
static const String developerPhone = '+1 234 567 8900';
static const String githubUrl = 'https://github.com/yourusername';
static const String linkedinUrl = 'https://linkedin.com/in/yourusername';
// ... update skills, experience, etc.
```

### 5️⃣ Run Locally

```bash
flutter run -d chrome
```

---

## 🌐 Deployment

### Deploy to Firebase Hosting

```bash
# Build for web
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting
```

Your portfolio will be live at: `https://your-project-id.web.app`

### Custom Domain (Optional)

1. Firebase Console → **Hosting** → **Add custom domain**
2. Follow DNS configuration steps
3. SSL certificate is auto-provisioned

---

## 🔧 Firebase Data Management

### Add Projects via Firestore Console

1. Go to Firebase Console → **Firestore Database**
2. Create collection: `projects`
3. Add document with fields:
   ```json
   {
     "title": "My Awesome App",
     "description": "A beautiful Flutter app...",
     "tags": ["Flutter", "Firebase", "UI/UX"],
     "imageUrl": "https://example.com/image.jpg",
     "liveUrl": "https://github.com/username/repo",
     "category": "Mobile",
     "order": 1,
     "createdAt": [Timestamp]
   }
   ```

### View Contact Form Submissions

1. Firebase Console → **Firestore Database**
2. Collection: `messages`
3. View submitted contact forms

### Seed Sample Data (Optional)

Uncomment in your code and run once:

```dart
// In main.dart or a setup screen
await FirebaseService().seedSampleProjects();
```

---

## 🎨 Customization Guide

### Change Colors

Edit `lib/core/theme/app_theme.dart`:

```dart
static const Color neonBlue = Color(0xFF00D4FF);  // Your primary color
static const Color accentPurple = Color(0xFF7C3AED);  // Your accent
```

### Add/Remove Sections

Edit `lib/screens/home/home_screen.dart` — add or remove section widgets.

### Modify Animations

All animations use `flutter_animate` package. Adjust durations/delays in widget files.

---

## 📦 Key Packages Used

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `cloud_firestore` | Real-time database |
| `firebase_storage` | Image hosting |
| `provider` | State management |
| `google_fonts` | Custom fonts |
| `flutter_animate` | Declarative animations |
| `animated_text_kit` | Typing animations |
| `url_launcher` | Open external links |
| `cached_network_image` | Image caching |
| `shared_preferences` | Local storage |
| `visibility_detector` | Scroll animations |

---

## 🐛 Troubleshooting

### Firebase not configured error
- Make sure you've run `flutterfire configure` or manually updated `firebase_options.dart`
- The app will use **sample data** if Firebase is not configured

### CORS errors with images
- Use Firebase Storage or ensure image URLs allow CORS
- Or use placeholder images from `picsum.photos`

### Animations not smooth
- Run in **release mode**: `flutter run --release -d chrome`
- Enable **CanvasKit** renderer (default in Flutter 3.5+)

### Build errors
```bash
flutter clean
flutter pub get
flutter build web --release
```

---

## 📄 License

This project is licensed under the MIT License — feel free to use it for your own portfolio!

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 💬 Contact

**Akash Kumar**  
📧 Email: akash.kumar@example.com  
🔗 LinkedIn: [linkedin.com/in/akashkumar](https://linkedin.com/in/akashkumar)  
🐙 GitHub: [github.com/akashkumar](https://github.com/akashkumar)

---

## ⭐ Show Your Support

If you found this helpful, give it a ⭐️!

---

**Built with ❤️ using Flutter & Firebase**
# akash_portfolio

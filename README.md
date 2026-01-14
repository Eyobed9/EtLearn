# EtLearn - Learning Platform App

- This project is a full-stack mobile learning platform application built with Flutter. The goal is to build a functional mobile application that allows users to browse courses, connect with instructors, enroll in courses, and participate in live video learning sessions. The project covers mobile app development, backend APIs, database design, authentication, and real-time video conferencing integration.

## 🌐 Live Demo

- 🔗 [Frontend Demo]("Coming soon")
- 🔗 [Backend API Docs]("Coming soon")

---

## 🧰 Tech Stack

### 📱 Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Material Design** - UI components

### 🗄️ Backend & Services
- **Firebase Authentication** - User authentication (Email/Password, Google Sign-In)
- **Supabase** - PostgreSQL database and backend services
- **Jitsi Meet** - Video conferencing integration
- **PostgreSQL** - Relational database

### 📦 Key Dependencies
- `firebase_core` & `firebase_auth` - Authentication
- `supabase_flutter` - Database and backend services
- `google_sign_in` - OAuth authentication
- `jitsi_meet_wrapper` - Video meeting integration
- `image_picker` - Image selection
- `font_awesome_flutter` - Icon library

---

## 📂 Project Structure

### Frontend source code

```
lib/
├── authentication/          # Authentication screens and logic
│   ├── auth.dart
│   ├── login_page.dart
│   └── signup_page.dart
├── screens/                 # Main application screens
│   ├── onboarding/         # Onboarding flow
│   │   ├── opening_modal.dart
│   │   ├── onboarding.dart
│   │   ├── onboarding1.dart
│   │   ├── onboarding2.dart
│   │   └── onboarding3.dart
│   ├── course_detail_page.dart
│   ├── create_course_page.dart
│   ├── inbox_screen.dart
│   ├── mentors_view.dart
│   ├── my_courses_view.dart
│   ├── my_home_page.dart
│   ├── profile_view.dart
│   ├── registration_success_page.dart
│   ├── search_page.dart
│   └── setup_profile.dart
├── services/               # Business logic services
│   ├── jitsi_service.dart
│   └── user_sync_service.dart
├── models/                 # Data models
│   └── request_data.dart
├── widgets/                # Reusable UI components
│   ├── base_scaffold.dart
│   ├── credits_streak_appbar.dart
│   └── mentor_widgets.dart
├── helpers/                # Helper utilities
│   └── credits.dart
├── utils/                  # Utility functions
├── main.dart               # Application entry point
├── widget_tree.dart        # Navigation and routing
└── firebase_options.dart   # Firebase configuration

assets/
├── images/                 # Image assets
└── icons/                  # Icon assets
```

### Backend source code

The backend is managed through Supabase with the following database schema:

**Database Tables:**
- `users` - User profiles and authentication data
- `offers` - Teaching/learning offers
- `sessions` - Scheduled learning sessions
- `courses` - Course listings
- `enrollments` - Course enrollment tracking
- `course_reviews` - Course ratings and reviews

---

## ⚙️ Installation & Setup

### 🔧 Prerequisites

- Flutter SDK version 3.9.2 or higher
- Dart SDK (included with Flutter)
- Android Studio / Xcode (for mobile development)
- Firebase project configured
- Supabase project configured
- Git for version control

### 📦 Installation Steps

1. **Clone the repository**
```bash
git clone https://github.com/Eyobed9/et_learn.git
cd et_learn
```

2. **Install Flutter dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files
   - Update `lib/firebase_options.dart` with your Firebase configuration

4. **Configure Supabase**
   - Update Supabase URL and anon key in `lib/main.dart`
   - Set up database tables using the SQL schema from `TODO.md`

5. **Run the application**
```bash
# For Android
flutter run

# For iOS
flutter run

# For Web
flutter run -d chrome

# For specific device
flutter devices
flutter run -d <device_id>
```

---

## 🔐 Environment Variables

### Firebase Configuration
Configure Firebase through `firebase_options.dart` and platform-specific configuration files:
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

### Supabase Configuration
Update in `lib/main.dart`:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### Database Setup
Refer to `TODO.md` for complete SQL schema. Key tables include:
- Users (Firebase UID, email, profile data)
- Offers (teaching/learning opportunities)
- Courses (course listings with metadata)
- Enrollments (student-course relationships)
- Sessions (scheduled meetings)
- Reviews (course ratings and feedback)

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

---

## 🚀 Features

* 🔐 **User Authentication** - Firebase Auth with Email/Password and Google Sign-In
* 📚 **Course Management** - Create, browse, and enroll in courses
* 👥 **Instructor Matching** - Connect learners with teachers based on subjects
* 🎥 **Video Meetings** - Integrated Jitsi Meet for live learning sessions
* 💰 **Credits System** - Track user credits and learning streaks
* 📊 **Profile Management** - User profiles with teaching subjects and preferences
* 🔍 **Search & Discovery** - Search courses and instructors
* 📨 **Inbox System** - Manage learning requests and messages
* ⭐ **Reviews & Ratings** - Course reviews and instructor feedback
* 📱 **Cross-Platform** - Android, iOS, and Web support

---

## 🔑 Core Functionalities

The EtLearn platform enables core features essential to a peer-to-peer learning marketplace.

---

### 1. 👥 User Management
- **User Registration**
  - Students and instructors can register via email/password or Google Sign-In
  - Secure authentication using Firebase Authentication
- **User Login and Authentication**
  - Email/password login
  - OAuth login with Google
  - Session management with Firebase
- **Profile Management**
  - Update profile info including photo, bio, subjects taught, and preferences
  - Track credits and learning streaks
  - Manage availability and teaching subjects

---

### 2. 📚 Course Management
- **Create Courses**
  - Instructors can create courses with title, description, subject, level, and credit cost
  - Upload course thumbnails
  - Set course duration and difficulty level
- **Browse Courses**
  - Search courses by subject, instructor, or keywords
  - Filter by level (Beginner, Intermediate, Advanced)
  - View course details, instructor info, and reviews
- **Enroll in Courses**
  - Students can enroll in courses
  - Track enrollment progress and completion status
  - Access enrolled courses from "My Courses" section

---

### 3. 🔍 Search and Filtering
- Search by:
  - Subject/topic
  - Instructor name
  - Course title
  - Keywords
- Filter by:
  - Course level
  - Credit cost
  - Instructor ratings
- Supports pagination for large result sets

---

### 4. 🎥 Video Learning Sessions
- **Schedule Sessions**
  - Create scheduled learning sessions between teachers and learners
  - Set meeting times and availability
- **Join Video Meetings**
  - Integrated Jitsi Meet for live video sessions
  - One-click meeting join from course details
  - Meeting links generated automatically
- **Session Management**
  - Track session status: `scheduled`, `completed`, `cancelled`
  - Manage meeting links and schedules

---

### 5. 💰 Credits System
- **Credit Management**
  - Users earn and spend credits for courses
  - Track total credits and learning streaks
  - Credits displayed in app bar
- **Credit Transactions**
  - Enrollments consume credits
  - Credits earned through teaching or achievements

---

### 6. 🌟 Reviews and Ratings
- Students can leave reviews and star ratings (1-5 stars)
- Reviews linked to completed courses
- Display average ratings on course cards
- Instructor responses to reviews

---

### 7. 📨 Inbox & Requests System
- **Learning Requests**
  - Students can post learning requests for specific subjects
  - Instructors can view and accept/decline requests
  - Request matching based on teaching subjects
- **Messaging**
  - In-app messaging between users (planned)
  - Notification system for requests and messages

---

### 8. 👨‍🏫 Instructor Features
- **Teaching Offers**
  - Instructors can create teaching offers
  - Specify subjects, availability, and descriptions
- **Request Management**
  - View incoming learning requests
  - Accept or decline requests
  - Auto-enroll students upon acceptance

---

## 🧱 Technical Requirements

### 9. 🗃️ Database Management
- **PostgreSQL** via Supabase
- Tables:
  - `users` - User profiles and authentication
  - `offers` - Teaching/learning offers
  - `courses` - Course listings
  - `enrollments` - Course enrollments
  - `sessions` - Scheduled learning sessions
  - `course_reviews` - Reviews and ratings

---

### 10. 🔌 API Development
- Supabase REST API for database operations
- Real-time subscriptions for live updates
- Row Level Security (RLS) for data protection
- Custom backend functions via Supabase Edge Functions (optional)

---

### 11. 🔐 Authentication & Authorization
- Firebase Authentication for user sessions
- JWT tokens managed by Firebase
- Role-Based Access Control (RBAC) for:
  - Students/Learners
  - Instructors/Teachers
  - Admins (planned)

---

### 12. 🖼️ File Storage
- User profile photos and course thumbnails
- Stored using Supabase Storage or Firebase Storage
- Image picker integration for easy uploads

---

### 13. 🎥 Third-Party Services
- **Jitsi Meet** - Video conferencing for live sessions
- **Firebase** - Authentication and cloud services
- **Supabase** - Database and backend infrastructure
- **Google Sign-In** - OAuth authentication

---

### 14. 🐞 Error Handling and Logging
- Global error handling in Flutter
- Try-catch blocks for async operations
- Debug logging for development
- User-friendly error messages

---

## 🚀 Non-Functional Requirements

### 15. 📈 Scalability
- Modular Flutter architecture
- Efficient state management
- Optimized database queries
- Caching strategies for better performance

### 16. 🔒 Security
- Encrypted authentication via Firebase
- Secure API keys management
- Row Level Security in Supabase
- Input validation and sanitization

### 17. ⚡ Performance Optimization
- Lazy loading for course lists
- Image optimization and caching
- Efficient state management
- Optimized database queries with indexes

### 18. ✅ Testing
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for user flows
- Automated testing pipeline (planned)

---

## 📸 Screenshots

| Home Page                       | Course Detail                       |
| ------------------------------- | --------------------------------- |
| ![Home](./screenshots/home.png) | ![Course](./screenshots/course.png) |

| My Courses                      | Profile                            |
| ------------------------------- | --------------------------------- |
| ![Courses](./screenshots/courses.png) | ![Profile](./screenshots/profile.png) |

---

## 🛡️ License

This project is licensed under the [MIT License](./LICENSE).

---

## 👏 Contributing

Contributions are welcome! Please fork the repo and open a pull request.

```bash
git clone https://github.com/Eyobed9/et_learn.git
git checkout -b feature/feature-name
```

### Development Guidelines
- Follow Flutter/Dart style guidelines
- Write tests for new features
- Update documentation as needed
- Ensure code passes linting (`flutter analyze`)

---

## 📬 Contact

For questions, reach out at [eyobedteshome@gmail.com](mailto:eyobedteshome@gmail.com) or connect via [LinkedIn](https://www.linkedin.com/in/eyobed-d-249634230/).

---

## 🙏 Acknowledgments

* [Flutter](https://flutter.dev/) - Cross-platform UI framework
* [Firebase](https://firebase.google.com/) - Authentication and backend services
* [Supabase](https://supabase.com/) - Open-source Firebase alternative
* [Jitsi Meet](https://jitsi.org/jitsi-meet/) - Video conferencing solution
* [Material Design](https://material.io/design) - Design system
* [Font Awesome](https://fontawesome.com/) - Icon library

---

## 📝 Project Status

**Current Version:** 1.0.0+1

**Status:** Active Development

**Recent Updates:**
- ✅ User authentication with Firebase
- ✅ Course creation and enrollment
- ✅ Video meeting integration (Jitsi)
- ✅ Credits system implementation
- ✅ Inbox and request management
- 🔄 Profile management (in progress)
- 🔄 Admin dashboard (planned)
- 🔄 Real-time messaging (planned)

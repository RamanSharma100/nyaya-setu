<div align="center">

# ⚖️ NyayaSetu (न्यायसेतु)
### Comprehensive Indian Judicial Services (PCS-J) Preparation Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod_2.x-42A5F5)](https://riverpod.dev)
[![Material 3](https://img.shields.io/badge/Design-Material_3-7C4DFF)](https://m3.material.io)
[![Google Play Ready](https://img.shields.io/badge/Google_Play-Compliant-34A853?logo=googleplay&logoColor=white)](https://play.google.com)
[![License](https://img.shields.io/badge/License-ISC-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Sponsor](https://img.shields.io/badge/Sponsor-RamanSharma100-ea4aaa?logo=github-sponsors&logoColor=white)](https://github.com/sponsors/RamanSharma100)

*Bridging Colonial-Era Statutes with India's New Criminal Codes (BNS 2023, BNSS 2023, BSA 2023) for Judicial Aspirants Across All High Court Jurisdictions.*

---

</div>

## 📌 Overview

**NyayaSetu (`nyaya-setu`)** is a specialized, production-ready mobile platform engineered for aspirants of the **Indian Judicial Services Examination (PCS-J)**. It empowers candidates targeting state judicial services including:

- 🏛️ **Delhi Judicial Service (DJS)**
- 🏛️ **Uttar Pradesh PCS (Judicial) (UP PCS-J)**
- 🏛️ **Madhya Pradesh Civil Judge (MP CJ)**
- 🏛️ **Rajasthan Judicial Service (RJS)**
- 🏛️ **Bihar Judicial Service (BJS)**
- 🏛️ **Haryana Civil Services (Judicial) (HCS-J)**
- 🏛️ **All-India Universal Judicial Services Prep**

NyayaSetu provides bidirectional statutory converters between legacy laws and the 2023 criminal codes, landmark Supreme Court case briefings under Article 141, spaced-repetition Prelims flashcards, timed 60-second MCQ quizzes, Mains IRAC answer-drafting studios, and integrated cinema-style video lectures.

---

## ✨ Core Modules & Features

### 🔄 1. 2023 Criminal Law Reform Statutory Converter
- **Bidirectional Statutory Mapping**: Instantaneous cross-reference between:
  - **Bharatiya Nyaya Sanhita (BNS 2023)** ⇋ **Indian Penal Code (IPC 1860)**
  - **Bharatiya Nagarik Suraksha Sanhita (BNSS 2023)** ⇋ **Code of Criminal Procedure (CrPC 1973)**
  - **Bharatiya Sakshya Adhiniyam (BSA 2023)** ⇋ **Indian Evidence Act (IEA 1872)**
- **Dynamic Fallback Synthesis**: Zero-empty-state intelligence; querying sections such as `IPC 302`, `IPC 420`, `CrPC 154`, `CrPC 438`, or `IEA 65B` immediately synthesizes structured legal comparison cards.
- **Responsive Stacked Layout**: Mobile-first full-width cards preventing text clipping across various screen dimensions.

### 🏛️ 2. Indian Kanoon & SC Landmark Precedent Engine
- **Procedural Trial History (*What Happened*)**: Chronological progression from trial court to the Supreme Court of India.
- **Constitutional Standing under Article 141 (*Current Standing*)**: Explicit binding ratio indicators (*Settled Precedent*, *Reaffirmed*, *Overruled*).
- **Secure Web Judgment Viewer**: In-app web reader previewing unredacted judgment texts directly from Indian Kanoon without launching external browsers.

### 🎬 3. Embedded Cinema Video Lecture Player
- **In-App Playback**: Embedded 16:9 responsive YouTube player powered by `webview_flutter` with trusted origin context (`baseUrl: 'https://www.youtube-nocookie.com'`) to prevent external redirects and Error 152 ("Video unavailable").
- **Curated High-Yield Lectures**: Pre-indexed masterclasses on core legal topics (e.g., BNS 103 Murder Law, Kesavananda Bharati Basic Structure Doctrine, Section 11 CPC Res Judicata).
- **Synchronized Lesson Notes**: Key takeaways, statutory citations, and lecture overviews displayed beneath the active cinema player.
- **Clean Lifecycle Management**: Audio and video instantly terminate when the modal sheet is dismissed or navigated away from.
- **Secondary External Handoff**: Optional external launcher button for users who explicitly choose to view within the native YouTube application.

### ⚡ 4. Spaced Repetition Prelims Deck & Timed Quiz
- **Haptic Swipe Flashcards**: Gesture-driven review cards with haptic feedback (*Mastered* / *Needs Review*).
- **Timed 60-Second MCQ Engine**: High-yield judicial examination questions with countdown timers, dynamic score counters, and immediate statutory rationales.
- **Subject Filter Chips**: Practice by individual discipline (*Criminal Law*, *Procedure*, *Evidence*, *Civil Law*, *Constitutional Law*).
- **Session Shuffling**: Automatic question randomization on every practice attempt.

### ✍️ 5. Mains Answer Writing Studio
- **Judicial IRAC Rubrics**: Structured drafting scaffolds enforcing **Issue**, **Rule**, **Analysis**, and **Conclusion**.
- **Timed Simulation**: Practice drafting under strict examination constraints (30 to 45 minutes per question).
- **Real-Time Word & Character Metrics**: Live counters tracking drafting volume and pace.
- **Draft Persistence**: Automatic local state preservation preventing accidental loss of written answers.

### 🎯 6. Target Judicial Exam Goal Selector
- **State Syllabus Customization**: Switch focus across DJS, UP PCS-J, MP CJ, RJS, BJS, HCS-J, and All-India Universal Prep.
- **High-Yield Local Acts Checklist**: Track preparation readiness on state-specific statutory acts (e.g., Delhi Rent Control Act, UP Revenue Code, MP Accommodation Control Act).
- **Adaptive UI**: Single-line dropdown rendering with ellipsis fallback preventing overflow on compact displays.

### 🤖 7. NyayaAI Legal Tutor & Voice Assistant
- **Gemini-Powered Legal Reasoning**: In-depth explanations of intricate statutory nuances, exceptions, and landmark case ratios.
- **Voice-Enabled Queries**: Mic-activated prompts for hands-free query submission during revision sessions.

---

## 🎨 Design System & Google Play Store Compliance

NyayaSetu is engineered strictly according to **Material Design 3 (M3)** specifications and passes **Google Play Core App Quality Guidelines**:

| Requirement | Implementation Detail | Status |
| :--- | :--- | :---: |
| **Google Identity Branding** | Compliant `GoogleSignInButton` widget using the official 4-color vector "G" mark, Roboto/Medium typography, and standard pill shape. | ✅ Pass |
| **Touch Target Size** | All interactive controls, chips, and icon buttons adhere to the minimum **48x48dp interactive boundary** (`materialTapTargetSize: MaterialTapTargetSize.padded`). | ✅ Pass |
| **Accessibility (TalkBack)** | Full `Semantics` tags, accessibility labels, and tooltips integrated across navigation items, timers, voice actions, and exam selectors. | ✅ Pass |
| **Predictive Back Navigation** | Enabled `android:enableOnBackInvokedCallback="true"` in `AndroidManifest.xml` for Android 13+ gesture navigation. | ✅ Pass |
| **Edge-to-Edge System UI** | Configured transparent status and navigation bars with adaptive dark/light system icon brightness. | ✅ Pass |
| **Judicial Typography** | Curated three-tier font stack: `Plus Jakarta Sans` (headers), `Inter` (body), and `Lora` (statutes & case ratios). | ✅ Pass |

---

## 🛠️ Architecture & Tech Stack

The application follows an **MVC (Model-View-Controller) / Feature-First** modular architecture:

```
nyayasetu/
├── android/                   # Native Android configuration (SDK 34+, permissions)
├── assets/                    # Static vectors, branding, and legal assets
├── lib/
│   ├── core/                  # Core services, themes, and network layer
│   │   ├── auth/              # Authentication service & Google Sign-In logic
│   │   ├── constants/         # AppColors, AppThemes (Material 3), AppTypography
│   │   ├── network/           # India Code client, Kanoon API, Gemini client
│   │   ├── router/            # GoRouter 14 with stateful shell routes
│   │   ├── storage/           # Hive local persistence
│   │   └── utils/             # YouTube helper, text formatters
│   ├── features/              # Feature modules (Views & Controllers)
│   │   ├── auth/              # Login screen & onboarding flow
│   │   ├── bare_acts/         # Bare acts reader & comparison views
│   │   ├── case_laws/         # Landmark judgments & case briefs
│   │   ├── concept_search/    # Statutory conversion search screen
│   │   ├── dashboard/         # Daily study hub & state goal selector
│   │   ├── gemini_ai/         # Legal AI assistant & voice mentorship
│   │   ├── mains/             # Mains answer writing studio & IRAC rubrics
│   │   ├── prelims/           # Spaced repetition flashcards & MCQ quizzes
│   │   └── splash/            # Animated splash & bootstrap logic
│   ├── shared/                # Shared reusable assets
│   │   ├── models/            # Domain entities (LegalYouTubeVideo, Syllabus)
│   │   └── widgets/           # Global widgets (GoogleSignInButton, YouTubePlayerModal)
│   └── main.dart              # Application entry point & service bootstrap
└── pubspec.yaml               # Dependencies & asset declarations
```

### Technology Matrix
- **Framework**: [Flutter 3.x](https://flutter.dev) (Dart 3.x)
- **State Management**: [Riverpod 2.x](https://riverpod.dev)
- **Routing**: [GoRouter 14.x](https://pub.dev/packages/go_router)
- **Networking**: [Dio 5.x](https://pub.dev/packages/dio)
- **Embedded Web**: [webview_flutter 4.x](https://pub.dev/packages/webview_flutter)
- **Local Storage**: [Hive NoSQL](https://pub.dev/packages/hive)
- **Typography**: [google_fonts](https://pub.dev/packages/google_fonts) (`Plus Jakarta Sans`, `Inter`, `Lora`)
- **Animations**: [flutter_animate](https://pub.dev/packages/flutter_animate)

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.13.2`)
- [Dart SDK](https://dart.dev/get-dart) (`>=3.13.2`)
- Android Studio / VS Code with Flutter extension
- Android SDK 34+ (compileSdkVersion 34, targetSdkVersion 34)

### Local Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/RamanSharma100/nyaya-setu.git
   cd nyaya-setu
   ```

2. **Install project dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables** *(Optional)*:
   Copy `.env.example` to `.env` in the project root:
   ```bash
   cp .env.example .env
   ```
   Provide your optional API keys for AI tutoring and external judgment retrieval:
   ```env
   GEMINI_API_KEY=AIzaSy...
   INDIAN_KANOON_API_KEY=your_indian_kanoon_api_key
   ```

4. **Run in Debug Mode**:
   ```bash
   flutter run
   ```

---

## 📦 Production Release Guide

### 1. Build Android App Bundle (.aab) for Google Play
The Android App Bundle is the required format for publishing to the Google Play Store:
```bash
flutter build appbundle --release
```
The output bundle will be located at:
```
build/app/outputs/bundle/release/app-release.aab
```

### 2. Build Release APK (Direct Sideloading)
For direct distribution or local device testing:
```bash
flutter build apk --release
```
The output APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### 3. Signing Configuration
Before uploading to Google Play Console, ensure your release keystore is configured in `android/key.properties`:
```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=/path/to/upload-keystore.jks
```

---

## 🧪 Testing & Static Verification

NyayaSetu maintains strict code quality standards:

```bash
# Run Flutter static analyzer
flutter analyze

# Execute test suite
flutter test
```

---

## 🤝 Contributing

We welcome contributions from legal technologists, law educators, and judicial aspirants!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/statutory-amendment`)
3. Ensure `flutter analyze` passes with 0 issues
4. Commit your changes (`git commit -m 'feat: Add Rajasthan Rent Control Act 2001'`)
5. Push to the branch (`git push origin feature/statutory-amendment`)
6. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for full guidelines.

---

## 💖 Sponsorship & Support

If **NyayaSetu** accelerates your judicial exam preparation or supports your legal research, consider supporting our open-source initiative:

- 💖 **GitHub Sponsors**: [![Sponsor GitHub](https://img.shields.io/badge/Sponsor-RamanSharma100-ea4aaa?logo=github-sponsors&logoColor=white)](https://github.com/sponsors/RamanSharma100)
- ☕ **Buy Me A Coffee**: [![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Donate-FFDD00?logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/ramansharma100)
- ⭐ **Star this repository**: [github.com/RamanSharma100/nyaya-setu](https://github.com/RamanSharma100/nyaya-setu)

---

## 📜 Disclaimer & License

> ⚠️ **Disclaimer**: NyayaSetu is an independent educational technology platform. It is not affiliated with, authorized by, or endorsed by the Supreme Court of India, any High Court, State Public Service Commission, or Government of India authority.

Distributed under the **ISC License**. See [LICENSE](LICENSE) for terms.

<div align="center">

# ⚖️ NyayaSetu (न्यायसेतु)
### Comprehensive Indian Judicial Services (PCS-J) Preparation Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod_2.x-42A5F5)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-ISC-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

*Bridging Old Statutes with New Criminal Codes (BNS 2023, BNSS 2023, BSA 2023) for Judicial Aspirants Across India.*

---

</div>

## 📌 Overview

**NyayaSetu** is a state-of-the-art mobile application designed specifically for Indian Judicial Services aspirants (DJS, UP PCS-J, MP CJ, RJS, BJS, HCS-J, and All-India Judicial Services). It offers a complete suite of statutory converters, Supreme Court case law summaries, prelims flashcards, timed MCQ quizzes, and Mains answer drafting tools.

---

## ✨ Key Features & Core Modules

### 🔄 1. 2023 Criminal Law Reform Converter
- **Side-by-Side Statutory Diff**: Compare Bharatiya Nyaya Sanhita (**BNS 2023**) with IPC 1860, Bharatiya Nagarik Suraksha Sanhita (**BNSS 2023**) with CrPC 1973, and Bharatiya Sakshya Adhiniyam (**BSA 2023**) with IEA 1872.
- **Dynamic Fallback Synthesis**: Instant card generation for any section query (e.g. `IPC 302`, `IPC 420`, `CrPC 154`, `CrPC 438`, `IEA 65B`, `324`, `120B`) with zero empty search states.
- **Full-Width Stacked Layout**: Mobile-optimized stacked cards eliminating layout overflow.

### 🏛️ 2. Indian Kanoon & SC Precedent Engine
- **Procedural History (*What Happened*)**: Step-by-step facts and trial court progression.
- **Precedent Standing under Article 141 (*Current Standing*)**: Clear binding ratio status (e.g. *Settled Precedent*, *Overruled*, *Reaffirmed*).
- **In-App Web Preview**: Direct access to full judgment texts and case files on Indian Kanoon via secure web preview.

### ⚡ 3. Spaced Repetition Prelims Deck & Timed Quiz
- **Touch-Optimized Flashcards**: Swipe right (*Mastered*) or left (*Needs Review*) with instant touch feedback.
- **High-Yield MCQ Quiz Bank**: 15+ high-yield statutory questions with 60-second countdown timer.
- **Subject Filter Chips**: Filter MCQs by subject (`Criminal Law`, `Procedure`, `Evidence`, `Civil Law`, `Constitutional Law`).
- **Randomized Question Shuffling**: Fresh, randomized question order on every retake session.

### ✍️ 4. Mains Answer Writing Studio
- **IRAC Evaluation Rubric**: Structured guidance covering **Issue**, **Rule**, **Analysis**, and **Conclusion**.
- **Exam Countdown Timer**: Practice writing under timed conditions (30 minutes per answer).
- **Auto-Saving Drafts**: High-performance NoSQL local storage saving candidate drafts automatically.

### 🎓 5. State Goal Selector & Local Acts Progress
- **Multi-State Syllabus Support**: Seamlessly switch between Delhi (**DJS**), Uttar Pradesh (**UP PCS-J**), Madhya Pradesh (**MP CJ**), Rajasthan (**RJS**), Bihar (**BJS**), and Haryana (**HCS-J**).
- **High-Yield Local Acts Checklist**: Track progress on state-specific statutory acts.

---

## 🗺️ Upcoming Features Roadmap

- [ ] 🤖 **NyayaAI Live Mains Evaluator**: Real-time AI evaluation and scoring of candidate answers against judicial IRAC rubrics.
- [ ] 🎧 **Audio Bare Acts & Ratio Summaries**: Text-to-speech audio player for listening to BNS/BNSS section numbers and landmark SC ratios on the move.
- [ ] 📊 **Performance Diagnostic Dashboard**: Detailed accuracy metrics per legal subject (`Criminal`, `Constitutional`, `Civil`, `Evidence`) and state prelims readiness indicators.
- [ ] 🌐 **Full Offline Database Sync**: Offline SQLite / Hive storage for reading BNS, BNSS, BSA, and judgments without an active internet connection.
- [ ] 📜 **High Court Judgment Tracker**: Daily legal news digest & landmark judgment summaries from all 25 Indian High Courts.

---

## 🛠️ Architecture & Tech Stack

- **Framework**: [Flutter 3.x](https://flutter.dev) (Dart 3.x)
- **State Management**: [Riverpod 2.x](https://riverpod.dev) (`StateNotifierProvider`, `FutureProvider`)
- **Routing**: [GoRouter 14.x](https://pub.dev/packages/go_router) with `StatefulShellRoute` bottom navigation
- **Local Persistence**: [Hive NoSQL](https://pub.dev/packages/hive) with non-blocking parallel async initialization
- **Networking & API**: [Dio 5.x](https://pub.dev/packages/dio) with HTML/input sanitization guards
- **Styling**: Modern Judicial Palette (Deep Navy `#0A192F`, Imperial Gold `#D4AF37`, Emerald Green `#2E7D32`) with custom Google Fonts (`Outfit`, `Inter`)

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.13.2`)
- [Dart SDK](https://dart.dev/get-dart) (`>=3.13.2`)
- Android Studio / VS Code with Flutter extension

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/nyayasetu.git
   cd nyayasetu
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables**:
   Copy `.env.example` to `.env` in the root folder:
   ```bash
   cp .env.example .env
   ```
   Add your optional Google AI Studio / Indian Kanoon keys inside `.env`:
   ```env
   INDIAN_KANOON_API_KEY=your_indian_kanoon_api_key
   GEMINI_API_KEY=AIzaSy...
   ```

4. **Run the App**:
   ```bash
   flutter run
   ```

5. **Build Release APK**:
   ```bash
   flutter build apk --release
   ```
   The generated APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🧪 Testing & Verification

Run static code analysis:
```bash
flutter analyze
```

Run unit and widget tests:
```bash
flutter test
```

---

## 🤝 Contributing

We welcome contributions from legal tech developers, law students, and judicial aspirants!

1. **Fork the Repository**
2. **Create a Feature Branch**: `git checkout -b feature/amazing-feature`
3. **Commit Your Changes**: `git commit -m 'Add amazing feature'`
4. **Push to Branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

Please review our [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## 💖 Sponsorship & Support

If **NyayaSetu** has helped you in your judicial preparation or legal tech project, please consider supporting the project!

- 🌟 **Star this repository** on GitHub
- 💖 **Sponsor on GitHub**: [github.com/sponsors/nyayasetu](https://github.com/sponsors)
- ☕ **Buy Us A Coffee**: [buymeacoffee.com/nyayasetu](https://buymeacoffee.com)
- 📢 **Share with Law Students & Aspirants** across Telegram & WhatsApp groups!

---

## 📜 Disclaimer & License

> ⚠️ **Disclaimer**: NyayaSetu is an independent educational platform. It is not affiliated with, authorized by, or endorsed by the Supreme Court of India, any High Court, State Public Service Commission, or Government Authority.

Distributed under the **ISC License**. See `LICENSE` for details.

# 🪷 Shri Hit Radha Kripa - Flutter App

## ✅ Project Structure (Complete)

```
guruji_app/
├── android/
│   ├── app/
│   │   ├── src/
│   │   │   ├── main/
│   │   │   │   ├── kotlin/com/shriHitRadhaKripa/guruji_app/
│   │   │   │   │   └── MainActivity.kt
│   │   │   │   ├── res/
│   │   │   │   │   ├── drawable/launch_background.xml
│   │   │   │   │   ├── mipmap-*/  ← App icons daalo yahan
│   │   │   │   │   └── values/styles.xml
│   │   │   │   └── AndroidManifest.xml
│   │   │   ├── debug/AndroidManifest.xml
│   │   │   └── profile/AndroidManifest.xml
│   │   └── build.gradle
│   ├── gradle/wrapper/gradle-wrapper.properties
│   ├── build.gradle
│   ├── gradle.properties
│   └── settings.gradle
├── ios/
│   ├── Flutter/
│   │   ├── AppFrameworkInfo.plist
│   │   ├── Debug.xcconfig
│   │   └── Release.xcconfig
│   ├── Runner/
│   │   ├── Assets.xcassets/
│   │   ├── AppDelegate.swift
│   │   ├── Info.plist
│   │   ├── GeneratedPluginRegistrant.h/.m
│   │   └── Runner-Bridging-Header.h
│   ├── Runner.xcodeproj/project.pbxproj
│   ├── Runner.xcworkspace/contents.xcworkspacedata
│   └── Podfile
├── lib/
│   ├── main.dart
│   ├── theme/app_theme.dart
│   ├── models/
│   │   ├── chat_message.dart
│   │   └── api_service.dart    ← APNA API URL YAHAN DAALO
│   └── screens/
│       ├── splash_screen.dart
│       ├── home_screen.dart
│       ├── chat_screen.dart
│       ├── history_screen.dart
│       └── about_screen.dart
├── assets/fonts/               ← Poppins fonts yahan daalo
├── test/widget_test.dart
├── pubspec.yaml
└── analysis_options.yaml
```

---

## 🚀 Setup Steps

### Step 1 — Poppins Fonts Download Karo
1. https://fonts.google.com/specimen/Poppins pe jaao
2. "Download family" karo
3. Ye 4 files `assets/fonts/` mein daalo:
   - `Poppins-Regular.ttf`
   - `Poppins-Medium.ttf`
   - `Poppins-SemiBold.ttf`
   - `Poppins-Bold.ttf`

### Step 2 — API URL Set Karo
`lib/models/api_service.dart` mein line 8 update karo:
```dart
static const String baseUrl = 'https://APNA-PYTHON-API-URL.com';
```

### Step 3 — App Icon Daalo (Optional)
Android ke liye `android/app/src/main/res/mipmap-*/` folders mein `ic_launcher.png` daalo.

### Step 4 — Run Karo
```bash
flutter pub get
flutter run
```

---

## 🔌 Python API Format

Aapki Python API mein ye endpoint hona chahiye:

### POST `/ask`
```json
// Request
{ "question": "Bhakti kya hai?" }

// Response
{
  "answer": "Bhakti ek prem hai jo Bhagwan ke liye...",
  "video_title": "Bhakti ka Rahasya - Guruji",   // optional
  "video_url": "https://youtube.com/watch?v=xxx"  // optional
}
```

### GET `/suggested-questions` (Optional)
```json
// Response
{
  "questions": [
    "Bhakti kya hai?",
    "Radha ji ki mahima?",
    ...
  ]
}
```

---

## ⚠️ Agar Font Error Aaye
Agar Poppins font nahi laga toh `pubspec.yaml` se fonts section remove karo — system font use hoga.

---

**Radhe Radhe! 🙏**

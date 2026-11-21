#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
flutter create --platforms=android --project-name baby_puzzle_world .
flutter pub get
flutter analyze
flutter build apk --release
echo "APK: build/app/outputs/flutter-apk/app-release.apk"


# Ticket Go Flutter MVP

This archive contains the *lib/* sources, pubspec, and assets needed to reproduce the UI prototype you described (20 screens: login, register, categories, details, profile & subs, payment flow, reservation receipt) plus Firebase Auth hooks.

## Quick Start

```bash
flutter create ticket_go
cd ticket_go
# Replace generated lib/ and pubspec.yaml with the ones in this archive.
flutter pub get
# Configure Firebase (required for Auth):
flutterfire configure
# Copy the generated firebase_options.dart over lib/firebase_options.dart (replace placeholder)
flutter run
```

Images are stored under `assets/images/`. Add more screen captures as desired.

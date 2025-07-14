# USSD Emulator

[![CI](https://github.com/kallyas/ussd_emulator/actions/workflows/ci.yml/badge.svg)](https://github.com/kallyas/ussd_emulator/actions/workflows/ci.yml)
[![Auto Release](https://github.com/kallyas/ussd_emulator/actions/workflows/auto-release.yml/badge.svg)](https://github.com/kallyas/ussd_emulator/actions/workflows/auto-release.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)

An open-source Flutter app for testing USSD services during development.

## 🚀 Features

- **USSD Testing**: Test USSD sessions with real phone numbers and service codes
- **Smart Path Building**: Automatically builds request text like "1*2*3" from menu selections
- **Modern UI**: Clean interface with dark/light mode support and chat-like conversations
- **Session Management**: Track active sessions and view conversation history
- **Endpoint Configuration**: Manage multiple USSD endpoints with validation
- **Debug Tools**: View API requests and session details in organized modals

## 📱 Quick Start

1. **Install Flutter** (3.0 or higher)
2. **Clone and setup**:
   ```bash
   fork this repository on GitHub
   git clone https://github.com/kallyas/ussd_emulator.git
   cd ussd_emulator
   flutter pub get
   flutter run
   ```

## 📋 Usage

### Set up an Endpoint
- Go to **Config** → **Add endpoint**
- Enter name, URL (must start with http/https), and optional headers
- Tap **Save**

### Start Testing
- Enter phone number (e.g., `+256700000000`)
- Enter service code (e.g., `*123#`)
- Tap **Start Session** and interact using the chat interface

## 📥 Download

Get the latest release from the [Releases page](https://github.com/kallyas/ussd_emulator/releases):

- **📱 APK files** - Direct install on Android devices
- **🏪 AAB file** - For Google Play Store distribution

## 🔧 API Format

**Request to your endpoint:**
```json
{
  "sessionId": "ussd_1234567890_123",
  "phoneNumber": "+256700000000", 
  "serviceCode": "*123#",
  "text": "1*2*1"
}
```

**Expected response:**
```
CON Welcome! Choose option:
1. Check Balance
2. Transfer Money
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

- 🐛 **Report bugs** by opening an issue
- 💡 **Suggest features** with detailed descriptions  
- 🔧 **Submit pull requests** for bug fixes or features
- 📚 **Improve documentation** 
- ⭐ **Star the project** if you find it useful

### Development Setup

```bash
# Run tests
flutter test

# Build for Android
flutter build apk

# Format code
dart format .
```

### Automated Builds & Releases

🤖 **Continuous Integration**: Every push and PR triggers automated tests and builds

🚀 **Automatic Releases**: Push to `main` with [conventional commits](https://www.conventionalcommits.org/) to automatically:
- Analyze commits and determine version bump (major/minor/patch)
- Update `pubspec.yaml` version and build number
- Create git tags and GitHub releases
- Build signed APKs for multiple architectures
- Generate AAB for Play Store
- Create changelog with categorized changes

📝 **Commit Examples**:
- `feat: add session export` → Minor version bump
- `fix: resolve startup crash` → Patch version bump  
- `feat!: redesign UI` → Major version bump

📚 **Setup Guide**: See [`docs/RELEASE_SETUP.md`](docs/RELEASE_SETUP.md) for signing configuration
📋 **Commit Guide**: See [`.github/COMMIT_CONVENTION.md`](.github/COMMIT_CONVENTION.md) for commit formatting

### Guidelines

- Follow Flutter best practices
- Add tests for new features
- Update documentation when needed
- Keep pull requests focused and small

## 📝 License

MIT License - feel free to use this project for any purpose.

## 🌟 Support

If this project helps you, please consider:
- ⭐ Starring the repository
- 🐛 Reporting issues you encounter
- 💡 Sharing ideas for improvements
- 📢 Spreading the word

---

**Made with ❤️ for the developer community**

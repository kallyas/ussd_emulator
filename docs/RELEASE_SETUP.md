# Release Setup Guide

This guide explains how to set up automatic releases with signed Android APKs and AABs using GitHub Actions.

## 🔐 Setting Up Android App Signing

### 1. Create a Keystore (One-time setup)

```bash
# Generate a new keystore (run this locally, not in CI)
keytool -genkey -v -keystore android/app/keystore.jks \
  -alias release \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

# Follow the prompts to set passwords and fill in details
```

### 2. Configure GitHub Secrets

Go to your repository → Settings → Secrets and variables → Actions, and add these secrets:

#### Required Secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `KEYSTORE_BASE64` | Base64 encoded keystore file | `base64 -i android/app/keystore.jks` |
| `STORE_PASSWORD` | Keystore password | Your keystore password |
| `KEY_PASSWORD` | Key password | Your key password |
| `KEY_ALIAS` | Key alias | `release` |

#### How to encode your keystore:

```bash
# On macOS/Linux:
base64 -i android/app/keystore.jks | pbcopy

# On Windows:
certutil -encode android/app/keystore.jks keystore.txt
# Then copy content from keystore.txt (remove header/footer)
```

### 3. Optional Secrets:

| Secret Name | Description |
|-------------|-------------|
| `CODECOV_TOKEN` | For code coverage reports |

## 🚀 Release Process

### Automatic Releases (Recommended)

**🎯 Simply push to main with conventional commits!**

1. **Make your changes and commit with conventional format**:
   ```bash
   git add .
   git commit -m "feat: add new session export feature"
   git push origin main
   ```

2. **GitHub Actions automatically**:
   - Analyzes commit messages since last release
   - Determines version bump (major/minor/patch/none)
   - Updates `pubspec.yaml` version and build number
   - Runs all tests
   - Builds signed APKs (multiple architectures)
   - Builds signed AAB
   - Creates git tag and GitHub release
   - Uploads all artifacts
   - Generates changelog

### Manual Releases (Emergency Use)

For emergency releases when automatic process can't be used:
1. Go to Actions tab
2. Select "Manual Release"
3. Click "Run workflow"
4. Enter version number (e.g., `1.2.3`)
5. Click "Run workflow" button

### Commit Types & Version Bumps

| Commit Type | Version Impact | Example |
|-------------|----------------|---------|
| `feat:` | Minor (1.0.0 → 1.1.0) | `feat: add dark mode` |
| `fix:` | Patch (1.0.0 → 1.0.1) | `fix: resolve crash` |
| `feat!:` or `BREAKING CHANGE:` | Major (1.0.0 → 2.0.0) | `feat!: redesign API` |
| `docs:`, `style:`, `test:`, `chore:` | None | No release created |

## 📱 Release Artifacts

Each release includes:

- **APK (Universal)**: Works on all Android devices
- **APK (ARM64)**: Optimized for modern devices (recommended)
- **APK (ARM)**: For older Android devices
- **APK (x86_64)**: For Android emulators
- **AAB**: For Google Play Store uploads

## 🔧 Continuous Integration

The CI workflow runs on every push and PR:
- Code formatting checks
- Static analysis
- Unit tests
- Debug builds
- Coverage reports

## ⚠️ Important Notes

1. **Keep your keystore safe**: Never commit your keystore file to the repository
2. **Backup your keystore**: If you lose it, you can't update your app on Google Play
3. **Use strong passwords**: For both keystore and key passwords
4. **GitHub Secrets are encrypted**: They're safe to store sensitive information

## 🚨 Troubleshooting

### Build Fails - Keystore Not Found
- Ensure `KEYSTORE_BASE64` secret is properly set
- Verify the base64 encoding is correct

### Signing Fails - Wrong Password
- Double-check `STORE_PASSWORD` and `KEY_PASSWORD` secrets
- Ensure `KEY_ALIAS` matches your keystore alias

### Upload Fails - Missing Permissions
- Check if `GITHUB_TOKEN` has necessary permissions
- Ensure repository settings allow GitHub Actions

### APK Not Signed
- If secrets are not configured, builds will use debug signing
- Debug APKs will be uploaded as fallback

## 📋 Version Management

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1
#        ↑     ↑
#    version  build
```

- **Version**: Semantic version (1.0.0)
- **Build**: Build number (+1)

## 🏪 Google Play Store

To publish on Google Play Store:
1. Download the `.aab` file from releases
2. Upload to Google Play Console
3. Follow Play Store review process

## 📈 Analytics & Monitoring

- **Codecov**: Tracks test coverage
- **GitHub Actions**: Shows build history
- **Release downloads**: Track in GitHub Insights

---

**Need help?** Open an issue with the `help wanted` label.
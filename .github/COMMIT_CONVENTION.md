# Commit Convention

This project uses [Conventional Commits](https://www.conventionalcommits.org/) for automatic versioning and release generation.

## 🚀 Automatic Versioning

Every push to the `main` branch triggers our auto-release workflow that:
- Analyzes commit messages to determine version bump
- Automatically bumps version in `pubspec.yaml`
- Creates git tags and GitHub releases
- Builds and uploads APK/AAB files
- Generates changelog

## 📝 Commit Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types and Version Impact

| Type | Version Bump | Description | Example |
|------|-------------|-------------|---------|
| `feat` | **minor** | New feature | `feat: add dark mode toggle` |
| `fix` | **patch** | Bug fix | `fix: resolve crash on startup` |
| `perf` | **patch** | Performance improvement | `perf: optimize image loading` |
| `refactor` | **patch** | Code refactoring | `refactor: simplify session logic` |
| `revert` | **patch** | Revert previous changes | `revert: undo login changes` |
| `docs` | **none** | Documentation only | `docs: update API examples` |
| `style` | **none** | Code style/formatting | `style: fix indentation` |
| `test` | **none** | Add/update tests | `test: add unit tests for auth` |
| `chore` | **none** | Maintenance tasks | `chore: update dependencies` |
| `ci` | **none** | CI/CD changes | `ci: add caching to workflow` |
| `build` | **none** | Build system changes | `build: update gradle config` |

### Breaking Changes = Major Version

Add `BREAKING CHANGE:` in commit body or `!` after type:

```bash
# Option 1: Using footer
feat: redesign user interface

BREAKING CHANGE: Complete UI overhaul requires users to re-learn interface

# Option 2: Using ! notation  
feat!: redesign user interface
```

## 🎯 Examples

### ✅ Good Commits

```bash
# New features (minor version bump)
feat: add session export functionality
feat(auth): implement biometric login
feat: add support for multiple endpoints

# Bug fixes (patch version bump)
fix: resolve memory leak in session manager
fix(ui): correct button alignment on small screens
fix: handle network timeout gracefully

# Performance improvements (patch version bump)
perf: optimize database queries
perf(ui): reduce app startup time

# Breaking changes (major version bump)
feat!: change API response format
fix!: remove deprecated methods

feat: rewrite authentication system

BREAKING CHANGE: Authentication tokens are no longer compatible with previous versions
```

### ❌ Bad Commits

```bash
# Too vague
fix: bug fix
feat: improvements
update: changes

# Wrong type
feat: fix typo          # Should be: fix: correct typo
fix: add new feature    # Should be: feat: add new feature

# No description
feat:
fix: 
```

## 🔧 Scope Examples

Use scopes to identify the area of change:

- `auth` - Authentication/authorization
- `ui` - User interface  
- `api` - API related
- `db` - Database changes
- `config` - Configuration
- `docs` - Documentation
- `test` - Testing

## 📋 Workflow

1. **Make your changes**
2. **Commit with conventional format**:
   ```bash
   git add .
   git commit -m "feat: add session history export"
   ```
3. **Push to main branch**:
   ```bash
   git push origin main
   ```
4. **Auto-release workflow triggers**:
   - Analyzes commits since last release
   - Determines version bump (major/minor/patch)
   - Updates `pubspec.yaml`
   - Creates tag and release
   - Builds and uploads APKs/AAB

## 🚨 Important Notes

- **Only commits to `main` trigger releases**
- **Use feature branches for development**
- **Squash commits when merging PRs** for clean history
- **No manual tagging needed** - everything is automatic
- **Add `[skip ci]` to commit message** to skip release (use sparingly)

## 🔄 Branch Strategy

```
main/master     ← Automatic releases (protected)
    ↑
develop         ← Integration branch  
    ↑
feature/xyz     ← Feature development
```

### Recommended Flow:
1. Create feature branch: `git checkout -b feature/add-export`
2. Develop and commit: `git commit -m "feat: add export functionality"`
3. Push and create PR: `git push origin feature/add-export`
4. Merge to main → **Automatic release triggered!**

## 📚 Tools

### Commitizen (Optional)
Install for interactive commit creation:
```bash
npm install -g commitizen cz-conventional-changelog
echo '{ "path": "cz-conventional-changelog" }' > ~/.czrc

# Then use:
git cz
```

### Commit Message Template
Add to `.gitmessage`:
```
# <type>[optional scope]: <description>
# 
# [optional body]
#
# [optional footer(s)]
#
# Types: feat, fix, docs, style, refactor, perf, test, chore, ci, build
# Use ! for breaking changes: feat!: breaking change
# Use BREAKING CHANGE: in footer for breaking changes
```

Set as default:
```bash
git config commit.template .gitmessage
```

---

**Questions?** Check the [Conventional Commits specification](https://www.conventionalcommits.org/) or open an issue!
# 🚀 Flutter Setup Guide for MyCSIT

## ❌ Current Issue

Your Flutter installation has missing `flutter_web_plugins` which is causing dependency resolution failures. This is a common issue with incomplete Flutter installations.

## 🔧 Solution Options

### Option 1: Fix Flutter Installation (Recommended)

**Step 1: Clean Flutter Installation**
```bash
# Run Flutter doctor to diagnose
& "C:\src\flutter\bin\flutter.bat" doctor -v

# Clean Flutter cache
& "C:\src\flutter\bin\flutter.bat" clean

# Reinstall dependencies
& "C:\src\flutter\bin\flutter.bat" pub cache repair
```

**Step 2: If Still Issues, Reinstall Flutter**
1. Download fresh Flutter from https://flutter.dev/docs/get-started/install/windows
2. Extract to `C:\flutter` (new location)
3. Add to PATH: `C:\flutter\bin`
4. Run: `flutter doctor`

### Option 2: Use Minimal Dependencies

Update `pubspec.yaml` with minimal working dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.5
  uuid: ^3.0.7

# Add Supabase later after fixing Flutter
# supabase_flutter: ^1.10.3
```

### Option 3: Use Flutter Channel

Try switching Flutter channel:

```bash
& "C:\src\flutter\bin\flutter.bat" channel stable
& "C:\src\flutter\bin\flutter.bat" upgrade
& "C:\src\flutter\bin\flutter.bat" pub get
```

## 📱 Running the App

### Once Dependencies Are Fixed:

**Step 1: Install Dependencies**
```bash
cd "c:/Users/ASUS/Documents/MyCSIT/mycsit"
flutter pub get
```

**Step 2: Check Connected Devices**
```bash
flutter devices
```

**Step 3: Run the App**
```bash
# For Android (if Android device/emulator connected)
flutter run

# For Chrome (web) - if web plugins work
flutter run -d chrome

# For Windows desktop (if enabled)
flutter run -d windows

# List all available targets
flutter run -d
```

## 🛠️ Alternative: Run in VS Code

1. Install Flutter extension in VS Code
2. Open `mycsit` folder in VS Code
3. Press `F5` or use "Run and Debug"
4. Select device when prompted

## 📋 Current Working Dependencies

```yaml
name: mycsit
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.5
  uuid: ^3.0.7
```

## 🎯 Next Steps

1. **Fix Flutter installation** using Option 1
2. **Install dependencies** with `flutter pub get`
3. **Run the app** with `flutter run`
4. **Add Supabase** back once basic app runs
5. **Test connectivity** to Supabase

## 🔍 Debug Flutter Issues

**Check Flutter Doctor:**
```bash
flutter doctor -v
```

**Common Fixes:**
- Restart IDE/VS Code
- Run `flutter clean`
- Run `flutter pub get`
- Check Android SDK setup
- Verify emulator is running

## 📱 Emulator Setup

If no devices available:

```bash
# Check available emulators
flutter emulators

# Launch Android emulator
flutter emulators --launch <emulator_name>

# Or create new emulator in Android Studio
# Tools > AVD Manager > Create Virtual Device
```

---

**Status:** Flutter setup blocked by web plugins | React dashboard working ✅ | Supabase ready ✅

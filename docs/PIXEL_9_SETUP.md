# Google Pixel 9 API 36.0 Setup Guide

## Prerequisites
- Android Studio installed with latest updates
- Android SDK updated
- Flutter configured

---

## Step 1: Create Pixel 9 Emulator

1. Open Android Studio
2. Click **Device Manager** (phone icon in toolbar)
3. Click **Create device**
4. Select **Pixel 9** from phone list
5. Click **Next**

### Select System Image
1. Choose **API 36.0 (Android 14)**
2. If not downloaded, click **Download** next to it
3. Wait for download to complete
4. Select the downloaded image
5. Click **Next**

### Configure AVD
1. **AVD Name**: Can stay default (e.g., `Pixel_9_API_36`)
2. **Startup orientation**: Portrait
3. **Advanced Settings** (optional):
   - RAM: 4096 MB or more
   - Internal Storage: 6000 MB or more
4. Click **Finish**

---

## Step 2: Start Emulator

1. In Device Manager, find your Pixel 9
2. Click the **play button** (▶) to start
3. Wait for Android to boot (1-2 minutes)
4. Unlock the device when ready

---

## Step 3: Run Flutter App

### Method A: Android Studio
1. Open Flutter project: `C:\Users\ASUS\Documents\MyCSIT\mycsit`
2. Select **Pixel 9** from device dropdown (top toolbar)
3. Click **green play button** to run

### Method B: Terminal
1. Open terminal in Android Studio
2. Run:
   ```bash
   flutter devices
   ```
3. Note your Pixel 9 device ID
4. Run:
   ```bash
   flutter run -d <device-id>
   ```

---

## Step 4: Verify Configuration

### Check Build Configuration
Your `android/app/build.gradle` should have:
```gradle
defaultConfig {
    applicationId "com.example.mycsit"
    minSdkVersion flutter.minSdkVersion
    targetSdkVersion 36  // ← This ensures API 36 support
    versionCode flutterVersionCode.toInteger()
    versionName flutterVersionName
}
```

### Check Flutter Doctor
```bash
flutter doctor -v
```
Should show:
- ✅ Android toolchain - develop for Android devices
- ✅ Connected device - Pixel 9

---

## Step 5: Test App Features

### Registration Test
1. Open app on Pixel 9 emulator
2. Click **Register**
3. Fill form:
   - Email: test@example.com
   - Password: password123
   - Name: Test User
   - Roll Number: CSIT001
   - Year: 3
   - Section: A
4. Click **Register**
5. Should navigate to **Pending Approval** screen

### Login Test (After Faculty Approval)
1. Go to Faculty Dashboard (http://localhost:3001)
2. Approve the pending registration
3. Return to Flutter app
4. Click **Login**
5. Use same credentials
6. Should navigate to **Home** screen

---

## Troubleshooting

### Emulator Won't Start
1. **Device Manager** → Select Pixel 9 → **Wipe Data**
2. Restart Android Studio
3. Try reducing RAM in AVD settings

### Build Fails
```bash
flutter clean
flutter pub get
flutter run -d <pixel-9-device-id>
```

### App Crashes on Startup
1. Check Logcat in Android Studio (bottom bar)
2. Look for errors related to Supabase connection
3. Verify internet connection in emulator

### Device Not Detected
1. **Tools → SDK Manager** → Install Android 14 (API 36)
2. **File → Invalidate Caches → Restart**
3. Restart emulator and Android Studio

---

## Performance Tips for Pixel 9

### Optimize Emulator
- Enable **Hardware Acceleration** in BIOS
- Use **Cold Boot** option sparingly
- Allocate sufficient RAM (4GB+ recommended)
- Close unnecessary apps while testing

### Flutter Performance
- Use **debug mode** for development
- Press **r** for hot reload
- Press **R** for hot restart
- Use **flutter logs** to debug issues

---

## Success Indicators

✅ **Emulator boots** to Android 14 home screen
✅ **Flutter app installs** and launches
✅ **Registration creates** user in Supabase
✅ **Login works** after faculty approval
✅ **Navigation flows** correctly between screens

---

## Next Steps

1. Test all app features on Pixel 9
2. Verify Supabase integration
3. Test faculty dashboard approval workflow
4. Prepare for production deployment

---

## Support

For issues:
1. Check **Android Studio logs** (Logcat)
2. Run **flutter doctor** for environment issues
3. Verify **Supabase credentials** in config
4. Check **internet connectivity** in emulator

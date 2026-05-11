# Android Studio Manual Setup Guide

## Prerequisites
- Android Studio installed (latest)
- Android SDK configured
- Android Emulator created (API 33+)

---

## Step 1: Open Project in Android Studio

1. Open Android Studio
2. Click **Open** (or **File → Open**)
3. Navigate to: `C:\Users\ASUS\Documents\MyCSIT\mycsit`
4. Select the folder and click **OK**

---

## Step 2: Configure Flutter SDK

1. Go to **File → Settings → Languages & Frameworks → Flutter**
2. Set **Flutter SDK path** to: `C:\src\flutter`
3. Click **Apply** → **OK**

---

## Step 3: Verify Dependencies

1. Open the **Terminal** in Android Studio (bottom bar)
2. Run:
   ```bash
   flutter pub get
   ```

---

## Step 4: Check Emulator

1. Click **Device Manager** (top toolbar)
2. Verify an emulator exists
3. If not, click **Create device** → Select hardware → Download system image
4. Start the emulator

---

## Step 5: Run the App

### Method A: Using Run Button
1. Select your emulator from the dropdown (top toolbar)
2. Click the **green play button** (Run)

### Method B: Using Terminal
1. In Android Studio terminal:
   ```bash
   flutter devices
   ```
2. Note your emulator ID (e.g., `emulator-5556`)
3. Run:
   ```bash
   flutter run -d emulator-5556
   ```

---

## Step 6: Troubleshooting

### If build fails with `AppTheme` errors:
- The app is already fixed for this issue
- Try: `flutter clean` then `flutter pub get`

### If Supabase connection fails:
- Verify `lib/core/config/supabase_config.dart` has correct credentials
- Check your internet connection

### If emulator doesn't start:
1. **Device Manager** → Select emulator → **Wipe Data**
2. Restart Android Studio
3. Try a different system image (API 33, 34, or 35)

### If hot reload doesn't work:
- Press **r** in terminal for hot reload
- Press **R** for hot restart
- Or use the lightning bolt button in the toolbar

---

## Step 7: Test the App

1. **Registration**:
   - Click "Register"
   - Fill form (email, password, name, roll number, year, section)
   - Should navigate to "Pending Approval"

2. **Login** (after faculty approval):
   - Use registered email/password
   - Should navigate to Home screen

---

## What's Already Configured

✅ **Supabase Integration**:
- URL: `https://znhipxtgjileabyrooxf.supabase.co`
- Auth configured for email/password
- Data providers for activities, scores, notifications

✅ **Navigation**:
- Splash → Login/Register → Pending Approval → Home
- Automatic routing based on user status

✅ **UI Components**:
- All screens use direct color values (no AppTheme dependency)
- Loading states and error handling

---

## Common Build Issues & Solutions

| Issue | Solution |
|-------|----------|
| `Gradle` sync failed | File → Invalidate Caches → Invalidate and Restart |
| `Android` license not accepted | `flutter doctor --android-licenses` in terminal |
| `Emulator` boot loop | Wipe data in Device Manager |
| `Supabase` connection error | Check internet and verify config |

---

## Debug Mode vs Release

- **Debug Mode**: Default for development, includes hot reload
- **Release Mode**: For production builds
  ```bash
  flutter build apk --release
  ```

---

## Next Steps

1. Run the app successfully
2. Test registration (creates pending user)
3. Go to Faculty Dashboard (port 3001) to approve
4. Test login with approved credentials

---

## Support

If issues persist:
1. Check **Flutter Doctor**: `flutter doctor -v`
2. Check logs in **Logcat** (bottom bar in Android Studio)
3. Verify all prerequisites are met

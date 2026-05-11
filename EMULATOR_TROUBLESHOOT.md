# Emulator Startup Troubleshooting

## Current Issue
The command-line emulator is failing to start with "multiple emulator instance" errors, even after killing processes.

## Solution: Use Android Studio GUI

### Step 1: Open Android Studio
1. Launch Android Studio
2. Open your Flutter project: `C:\Users\ASUS\Documents\MyCSIT\mycsit`

### Step 2: Start Emulator via Device Manager
1. Click **Device Manager** (phone icon in toolbar)
2. Find **Pixel_9** in the list
3. Click the **play button** (▶) next to it
4. Wait for emulator to boot (1-2 minutes)

### Step 3: If Still Failing - Reset AVD
1. In Device Manager, select **Pixel_9**
2. Click **Actions** dropdown (three dots)
3. Select **Wipe Data**
4. Try starting again

### Step 4: Alternative - Create New Emulator
1. Click **Create device**
2. Select **Pixel 9** → **Next**
3. Choose **API 36** → **Next**
4. Configure → **Finish**
5. Start the new emulator

### Step 5: Run Flutter App
1. Once emulator shows Android home screen
2. Select it from device dropdown in Android Studio
3. Click **green play button** to run app

## Alternative: Use Physical Device

If emulator continues to fail:
1. Enable **Developer Options** on your Android phone
2. Enable **USB Debugging**
3. Connect via USB cable
4. Should appear in device dropdown

## Debug Registration Issues

Once emulator is running:

### 1. Check Console Logs
In Android Studio, open **Logcat** (bottom bar) to see registration debug output:
```
🔐 Starting signup for email: your@email.com
📧 Auth response: user-id-here
👤 Creating user record...
✅ User created: {...}
```

### 2. Test Registration
1. Run Flutter app on emulator
2. Go to Register screen
3. Fill form and submit
4. Check Logcat for debug messages

### 3. Verify Database
1. Go to [Supabase Dashboard](https://app.supabase.com/project/znhipxtgjileabyrooxf)
2. Click **Table Editor** → **users**
3. Look for new registration with `status = 'pending'`

### 4. Test Faculty Dashboard
1. Restart React server: `cd mycsit-faculty && npm run dev`
2. Open `http://localhost:3001`
3. Check **Approvals** tab for pending users

## Common Emulator Issues & Solutions

| Issue | Solution |
|-------|----------|
| "Multiple emulators running" | Kill all emulator processes, restart Android Studio |
| Emulator won't boot | Wipe data in Device Manager |
| No device detected | Check Android SDK installation |
| Slow performance | Increase RAM in AVD settings |

## Next Steps

1. Start emulator via Android Studio GUI
2. Run Flutter app
3. Test registration with debug logging
4. Verify database sync with faculty dashboard

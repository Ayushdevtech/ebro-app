# Building Ebro Without a Computer — Phone-Only Guide

You don't have a computer, so the actual "build the app" step needs to
happen somewhere else. Two ways to do that, both fully usable from your
phone's browser.

---

## METHOD 1 — GitHub Actions (Recommended, Automatic)

GitHub's own servers will install Flutter and build your APK for you.
You just upload code and download the finished file.

### Step 1: Create a GitHub Account
Go to [github.com](https://github.com) in your phone browser, sign up
if you don't have an account.

### Step 2: Create a New Repository
- Tap the **+** icon → **New repository**
- Name it `ebro-app`
- Set to **Public** (Private also works but Public is simpler for now)
- Tap **Create repository**

### Step 3: Upload Your Project Files
- On the repo page, tap **Add file → Upload files**
- Extract the `ebro_app.zip` I gave you on your phone first (use a
  file manager app like **Files by Google**, or **ZArchiver** — both
  free on Play Store — to unzip it)
- Upload the **entire extracted folder's contents** — all files and
  folders (`lib/`, `android/`, `pubspec.yaml`, `.github/`, etc.)
  GitHub's mobile upload lets you select multiple files; do it in a
  few batches if needed (it has upload limits per batch)
- Scroll down, tap **Commit changes**

### Step 4: Let It Build
- Tap the **Actions** tab at the top of your repo
- You'll see "Build Ebro APK" running automatically (triggered by your
  upload). If it doesn't start, tap **Build Ebro APK** → **Run workflow**
- Wait 3-6 minutes. Refresh the page to see progress.

### Step 5: Download Your APK
- Once it shows a green checkmark, tap into that completed run
- Scroll down to **Artifacts**
- Tap **ebro-app-release** to download a zip containing your APK
- Extract that zip on your phone, find `app-release.apk`

### Step 6: Install It
- Tap the `.apk` file in your file manager
- Android will ask permission to "install unknown apps" — allow it
  for your file manager / browser
- Tap **Install**

Done — Ebro is now a real app on your phone.

### Whenever You Want to Update the App
Edit files directly on GitHub (tap any file → pencil icon → edit → 
commit), and Actions will automatically rebuild a new APK each time.

---

## METHOD 2 — Replit (Good for Testing/Editing Code)

Replit gives you a Linux computer inside your browser. Good for editing
code and experimenting, though building Android APKs on Replit's free
tier can be slow or memory-limited — GitHub Actions above is more
reliable for the final APK.

### Step 1: Create a Replit Account
Go to [replit.com](https://replit.com), sign up.

### Step 2: Create a Blank Repl
- Tap **+ Create Repl**
- Choose **Blank Repl** (or search "Flutter" if a template shows up)

### Step 3: Upload Your Files
- Use the file upload option in the Replit file panel (the icon usually
  looks like an upward arrow, or use "Import from zip" if available)
- Upload `ebro_app.zip` directly — Replit can often unzip it for you,
  or unzip it on your phone first like in Method 1

### Step 4: Install Flutter Inside Replit
Open Replit's **Shell** tab and run:
```bash
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
```
This downloads Flutter directly onto your Replit workspace (one-time,
takes a few minutes).

### Step 5: Get Dependencies and Try a Web Build
```bash
flutter pub get
flutter build apk --release
```
If the APK build struggles on Replit's free resources, that's expected
— fall back to Method 1 (GitHub Actions) for the actual APK, and use
Replit just to edit/test code changes before pushing them to GitHub.

---

## Which One Should You Actually Use?

**Use GitHub Actions (Method 1) as your main way to get the APK.**
It's free, reliable, and doesn't depend on phone battery/storage for
the heavy lifting — GitHub's servers do all the work.

Use Replit only if you want a place to tinker with code from your
phone before committing it to GitHub.

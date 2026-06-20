# Ebro — Real Flutter Browser App

This is a **real browser**, not a web prototype. It uses `webview_flutter`,
which runs on Chromium on Android (the same engine Chrome uses) — so
Google, Instagram, Amazon, every site, loads and works normally.

## What's Inside

- Real login/register (Supabase Auth)
- Real browser tab — back/forward/reload, incognito mode, history saved per-user
- 8 AI tools that make real calls to Gemini: No-BS Mode, Live Fact Checker,
  Explain Like I'm 5, Tone Detector, Dark Pattern Detector, Scam Lookup,
  True Price Mode, Fake Review Scanner
- Shopping comparison shortcuts (Amazon / Flipkart / Meesho)
- Settings: edit name, set your own Gemini key, clear history, sign out
- Admin-controlled global Gemini key — the admin panel can set one key
  that every user's app uses automatically, via Supabase

## Before You Run This

### 1. Supabase Project
- Go to [supabase.com](https://supabase.com) → create a free project.
- In **SQL Editor** → New Query → paste all of `supabase_schema.sql` → Run.
- In **Settings → API**, copy your **Project URL** and **anon public key**.

### 2. Add Keys to the App
Open `lib/services/supabase_service.dart`, replace:
```dart
static const String url = 'YOUR_SUPABASE_URL';
static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 3. Install Dependencies
```bash
cd ebro_app
flutter pub get
```

### 4. Plug In a Real Android Device
- Enable Developer Options on your phone (tap Build Number 7 times in About Phone).
- Enable USB Debugging inside Developer Options.
- Plug phone into your computer via USB, allow the debugging prompt.
- Check it's detected:
```bash
flutter devices
```

### 5. Run It
```bash
flutter run
```
This installs and launches Ebro directly on your phone. First build can
take a few minutes — that's normal.

## Setting Up AI Features

You have two options, and you don't need both:

**Option A — Admin sets one key for everyone (recommended for launch):**
Run this in Supabase SQL Editor, with your real Gemini key from
[aistudio.google.com/apikey](https://aistudio.google.com/apikey):
```sql
insert into public.app_config (key, value) values ('gemini_api_key', 'AIza...')
  on conflict (key) do update set value = excluded.value;
```

**Option B — Each user sets their own key:**
In the app: Settings → AI Engine → Set Key. Stored only on that device.

The app checks for a personal key first, then falls back to the admin's
global key automatically — see `lib/services/gemini_service.dart`.

## Becoming an Admin
1. Sign up once through the app normally.
2. In Supabase SQL Editor:
```sql
select id, email from auth.users where email = 'your-email@example.com';
insert into public.admins (user_id) values ('paste-the-id-here');
```
3. Now your account can log into the separate Admin Panel project and
   manage users / set the global Gemini key / edit prompts.

## Building a Real APK to Share
```bash
flutter build apk --release
```
The installable file appears at:
`build/app/outputs/flutter-apk/app-release.apk`
Send this file to anyone with an Android phone — they install it like
any normal app (they may need to allow "install from unknown sources"
since it's not on the Play Store yet).

## Project Structure
```
lib/
  main.dart                       — app entry point, auth routing
  theme.dart                      — colors, shared styling
  services/
    supabase_service.dart         — auth, history, bookmarks, config
    gemini_service.dart           — AI calls + prompt templates
  screens/
    auth_screen.dart               — login / register
    home_screen.dart               — bottom nav shell
    home_tab.dart                  — dashboard, search, quick access
    browser_tab.dart               — the real WebView browser
    ai_tools_screen.dart           — list of AI tools
    ai_tool_detail_screen.dart     — run any AI tool
    shopping_screen.dart           — price comparison + shopping tools
    settings_screen.dart           — account, API key, data controls
```

## What This Does NOT Do (Being Honest)
- It does not download/build its own copy of Chromium — it uses the
  one already on the Android device via WebView. This is exactly what
  Opera, Brave, and most "alternative" browsers do too — none of them
  write a rendering engine from scratch.
- "Type a topic and AI builds a whole website live" is a different,
  much bigger product (similar to tools like v0.dev) and isn't included
  here. If you want that as a real feature, it needs its own scoped plan.

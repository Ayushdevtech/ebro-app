-- ============================================
-- EBRO (Flutter App + Admin Panel) — Supabase Schema
-- Run in Supabase Dashboard → SQL Editor → New Query → Run
-- ============================================

create table if not exists public.users (
  id uuid references auth.users(id) primary key,
  email text not null,
  full_name text,
  plan text default 'free',
  pages_visited integer default 0,
  trackers_blocked integer default 0,
  ads_blocked integer default 0,
  suspended boolean default false,
  created_at timestamp with time zone default now()
);
alter table public.users enable row level security;
create policy "Users manage own profile" on public.users for all using (auth.uid() = id);

create table if not exists public.bookmarks (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) not null,
  url text not null,
  title text,
  summary text,
  created_at timestamp with time zone default now()
);
alter table public.bookmarks enable row level security;
create policy "Users manage own bookmarks" on public.bookmarks for all using (auth.uid() = user_id);

create table if not exists public.history (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) not null,
  url text not null,
  title text,
  visited_at timestamp with time zone default now()
);
alter table public.history enable row level security;
create policy "Users manage own history" on public.history for all using (auth.uid() = user_id);

create table if not exists public.admins (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) not null unique,
  role text default 'admin',
  created_at timestamp with time zone default now()
);
alter table public.admins enable row level security;
create policy "Admins view admin list" on public.admins for select using (auth.uid() in (select user_id from public.admins));

-- app_config: this is how the Admin Panel hands the Gemini API key
-- and model choice down to every user's app, without anyone needing
-- to enter their own key or rebuild the app.
create table if not exists public.app_config (
  key text primary key,
  value text,
  updated_at timestamp with time zone default now()
);
alter table public.app_config enable row level security;
create policy "Anyone can read app config" on public.app_config for select using (true);
create policy "Admins can write app config" on public.app_config for all using (auth.uid() in (select user_id from public.admins));

create table if not exists public.reports (
  id bigint generated always as identity primary key,
  report_type text not null,
  content text,
  reported_by uuid references auth.users(id),
  status text default 'pending',
  created_at timestamp with time zone default now()
);
alter table public.reports enable row level security;
create policy "Users create reports" on public.reports for insert with check (auth.uid() = reported_by);
create policy "Admins manage reports" on public.reports for all using (auth.uid() in (select user_id from public.admins));

-- Admin read/write access across user data (for the admin panel's Users tab)
create policy "Admins view all users" on public.users for select using (auth.uid() in (select user_id from public.admins));
create policy "Admins update all users" on public.users for update using (auth.uid() in (select user_id from public.admins));
create policy "Admins view all history" on public.history for select using (auth.uid() in (select user_id from public.admins));
create policy "Admins delete all history" on public.history for delete using (auth.uid() in (select user_id from public.admins));
create policy "Admins view all bookmarks" on public.bookmarks for select using (auth.uid() in (select user_id from public.admins));

-- Optional helper function used by SupabaseService.incrementPagesVisited()
create or replace function increment_pages_visited(uid uuid)
returns void as $$
  update public.users set pages_visited = pages_visited + 1 where id = uid;
$$ language sql;

-- ============================================
-- MAKE YOURSELF ADMIN (after signing up once through the app):
--
-- select id, email from auth.users where email = 'your-email@example.com';
-- insert into public.admins (user_id) values ('paste-your-id-here');
--
-- SET THE GLOBAL GEMINI KEY (so every user gets AI features automatically):
-- insert into public.app_config (key, value) values ('gemini_api_key', 'AIza...')
--   on conflict (key) do update set value = excluded.value;
-- insert into public.app_config (key, value) values ('gemini_model', 'gemini-1.5-flash')
--   on conflict (key) do update set value = excluded.value;
-- ============================================

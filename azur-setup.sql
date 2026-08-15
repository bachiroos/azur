-- ============================================================
-- AZUR booking database — one-time setup
-- Where to run: Supabase Dashboard → SQL Editor → New query
-- Paste this whole file and press RUN. It should say "Success".
-- ============================================================

-- ---------- BOOKINGS ----------
create table public.bookings (
  id bigint generated always as identity primary key,
  code text not null unique,
  location text not null,
  service_id text not null,
  "date" date not null,
  "time" text not null,
  name text not null,
  phone text not null,
  note text not null default '',
  status text not null default 'confirmed' check (status in ('confirmed','cancelled')),
  created_at timestamptz not null default now()
);

alter table public.bookings enable row level security;

-- Only ONE confirmed booking can exist per location + day + time.
-- If two people try to grab the same slot, the second one is refused
-- by the database itself.
create unique index bookings_one_per_slot
  on public.bookings (location, "date", "time")
  where (status = 'confirmed');

-- Visitors may CREATE bookings (today or later, Beirut time)...
create policy "public can create bookings"
  on public.bookings for insert
  to anon, authenticated
  with check (status = 'confirmed' and "date" >= (now() at time zone 'Asia/Beirut')::date);

-- ...but only the signed-in admin can READ or CHANGE them
-- (so client names & phone numbers stay private).
create policy "admin can read bookings"
  on public.bookings for select
  to authenticated
  using (true);

create policy "admin can update bookings"
  on public.bookings for update
  to authenticated
  using (true);

-- Public view with NO personal data — just which slots are taken,
-- so the booking page can show "Taken" without exposing names.
create view public.taken_slots as
  select location, "date", "time"
  from public.bookings
  where status = 'confirmed';

grant select on public.taken_slots to anon, authenticated;

-- ---------- SETTINGS (hours, services, blocked times) ----------
create table public.settings (
  id integer primary key,
  data jsonb not null
);

alter table public.settings enable row level security;

create policy "everyone can read settings"
  on public.settings for select
  to anon, authenticated
  using (true);

create policy "admin can update settings"
  on public.settings for update
  to authenticated
  using (true);

-- Default schedule: both locations open every day 10:00 → 19:00,
-- 5 services. You change all of this later from the admin page.
insert into public.settings (id, data) values (1, '{
  "locations": {
    "holiday-beach": {
      "name": "Holiday Beach", "area": "Zouk Mosbeh",
      "hours": {
        "0": {"start":"10:00","end":"19:00"},
        "1": {"start":"10:00","end":"19:00"},
        "2": {"start":"10:00","end":"19:00"},
        "3": {"start":"10:00","end":"19:00"},
        "4": {"start":"10:00","end":"19:00"},
        "5": {"start":"10:00","end":"19:00"},
        "6": {"start":"10:00","end":"19:00"}
      }
    },
    "mejdlaya": {
      "name": "Mejdlaya", "area": "Zgharta",
      "hours": {
        "0": {"start":"10:00","end":"19:00"},
        "1": {"start":"10:00","end":"19:00"},
        "2": {"start":"10:00","end":"19:00"},
        "3": {"start":"10:00","end":"19:00"},
        "4": {"start":"10:00","end":"19:00"},
        "5": {"start":"10:00","end":"19:00"},
        "6": {"start":"10:00","end":"19:00"}
      }
    }
  },
  "services": [
    {"id":"holistic-massage","name":"Holistic Massage","minutes":60},
    {"id":"physiotherapy","name":"Physiotherapy","minutes":45},
    {"id":"thai-stretching","name":"Thai Stretching","minutes":45},
    {"id":"hot-stone","name":"Hot Stone Ritual","minutes":75},
    {"id":"facial-care","name":"Facial Care","minutes":60}
  ],
  "blocked": {}
}'::jsonb);

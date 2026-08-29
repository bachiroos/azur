-- ============================================================
-- AZUR — clinic staff (multi-therapist slot capacity)
-- Where to run: Supabase Dashboard → SQL Editor → New query
-- Paste this whole file and press RUN. It should say "Success".
-- Safe to run more than once.
--
-- What this changes:
--   1. Bookings can now be tied to a specific staff member (staff_id).
--   2. The "only one booking per slot" rule becomes "only one booking
--      per THERAPIST per slot" — so when 2+ therapists are on duty at
--      the same clinic hour, that hour can hold 2+ bookings, and only
--      closes once every therapist on duty for it is booked.
--   3. Bookings with no staff_id (home visits, or a clinic with no
--      staff configured yet) keep the old "one booking per slot"
--      behaviour exactly as before — nothing changes for them.
--   4. Therapists themselves (names + their weekly schedule) are NOT
--      stored here — they live in settings.data.staff, managed from
--      Admin → Settings → Clinic staff, same as everything else in
--      that table. This migration only touches the bookings table.
-- ============================================================

alter table public.bookings
  add column if not exists staff_id text not null default '';

drop index if exists public.bookings_one_per_slot;

create unique index bookings_one_per_slot
  on public.bookings (location, "date", "time", staff_id)
  where (status = 'confirmed');

drop view if exists public.taken_slots;

create view public.taken_slots as
  select location, "date", "time", staff_id
  from public.bookings
  where status = 'confirmed';

grant select on public.taken_slots to anon, authenticated;

-- Make sure settings.data has a "staff" array to add therapists into
-- (the app already defaults this in-memory, but this keeps the stored
-- row itself consistent too).
update public.settings
set data = jsonb_set(data, '{staff}', '[]'::jsonb)
where id = 1
  and not (data ? 'staff');

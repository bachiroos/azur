-- ============================================================
-- AZUR — add "Finished" status to bookings
-- Where to run: Supabase Dashboard → SQL Editor → New query
-- Paste this whole file and press RUN. It should say "Success".
-- Safe to run once on a database that was already set up with the
-- original azur-setup.sql — it only widens the allowed status values.
-- ============================================================

alter table public.bookings drop constraint if exists bookings_status_check;

alter table public.bookings add constraint bookings_status_check
  check (status in ('confirmed', 'cancelled', 'completed'));

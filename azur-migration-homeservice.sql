-- ============================================================
-- AZUR — enable home-service bookings (address field)
-- Where to run: Supabase Dashboard → SQL Editor → New query
-- Paste this whole file and press RUN. It should say "Success".
-- Safe to run on your existing database — it only adds one column.
-- ============================================================

alter table public.bookings
  add column if not exists address text not null default '';

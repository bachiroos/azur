-- ============================================================
-- AZUR — switch everything to 24 hours a day, 7 days a week
-- Where to run: Supabase Dashboard → SQL Editor → New query
-- Paste this whole file and press RUN. It should say "Success".
-- Applies to both clinics AND every home therapist.
-- Safe to run more than once.
-- (You can still fine-tune any single day later in Admin → Availability.)
-- ============================================================

update public.settings
set data = jsonb_set(
  data,
  '{locations}',
  (
    select jsonb_object_agg(
      loc_key,
      jsonb_set(loc_val, '{hours}', '{
        "0": {"start":"00:00","end":"24:00"},
        "1": {"start":"00:00","end":"24:00"},
        "2": {"start":"00:00","end":"24:00"},
        "3": {"start":"00:00","end":"24:00"},
        "4": {"start":"00:00","end":"24:00"},
        "5": {"start":"00:00","end":"24:00"},
        "6": {"start":"00:00","end":"24:00"}
      }'::jsonb)
    )
    from jsonb_each(data->'locations') as loc(loc_key, loc_val)
  )
)
where id = 1
  and data->'locations' is not null
  and jsonb_typeof(data->'locations') = 'object';

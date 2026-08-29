-- ============================================================
-- AZUR — set the opening hours
--   Clinics       : 12 PM  ->  12 AM  (noon until midnight)
--   Home service  : 24 hours a day
-- Where to run: Supabase Dashboard → SQL Editor → New query
-- Paste this whole file and press RUN. It should say "Success".
-- Safe to run more than once. Names, photos, rituals and blocked
-- times are left untouched; only the weekly hours change.
-- (Any single date you customised in Admin → Hours stays as it is.)
-- ============================================================

update public.settings
set data = jsonb_set(
  data,
  '{locations}',
  (
    select jsonb_object_agg(
      loc_key,
      jsonb_set(
        loc_val,
        '{hours}',
        case
          when coalesce((loc_val->>'home')::boolean, false)
            or loc_key like 'home-%'
          then '{
            "0": {"start":"00:00","end":"24:00"},
            "1": {"start":"00:00","end":"24:00"},
            "2": {"start":"00:00","end":"24:00"},
            "3": {"start":"00:00","end":"24:00"},
            "4": {"start":"00:00","end":"24:00"},
            "5": {"start":"00:00","end":"24:00"},
            "6": {"start":"00:00","end":"24:00"}
          }'::jsonb
          else '{
            "0": {"start":"12:00","end":"24:00"},
            "1": {"start":"12:00","end":"24:00"},
            "2": {"start":"12:00","end":"24:00"},
            "3": {"start":"12:00","end":"24:00"},
            "4": {"start":"12:00","end":"24:00"},
            "5": {"start":"12:00","end":"24:00"},
            "6": {"start":"12:00","end":"24:00"}
          }'::jsonb
        end
      )
    )
    from jsonb_each(data->'locations') as loc(loc_key, loc_val)
  )
)
where id = 1
  and jsonb_typeof(data->'locations') = 'object';

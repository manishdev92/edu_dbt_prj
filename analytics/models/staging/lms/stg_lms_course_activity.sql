{{ config(materialized='view') }}

select
  student_id,
  course_id,
  activity_date::date as activity_date,
  minutes_spent::int as minutes_spent,
  lessons_completed::int as lessons_completed,
  progress_pct::numeric(5,2) as progress_pct,
  last_activity_ts::timestamp as last_activity_ts,
  source_system,
  _ingested_at
from raw_lms.course_activity

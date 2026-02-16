{{ config(
    materialized='incremental',
    unique_key=['student_id','course_id','activity_date'],
    incremental_strategy='merge',
    on_schema_change='sync_all_columns',
    sort='activity_date',
    dist='student_id'
) }}

-- Grain: 1 row per student_id, course_id, activity_date
select
  student_id,
  course_id,
  activity_date,
  sum(minutes_spent)::int as minutes_spent,
  sum(lessons_completed)::int as lessons_completed,
  max(progress_pct)::numeric(5,2) as progress_pct_max,
  max(last_activity_ts) as last_activity_ts
from {{ ref('stg_lms_course_activity') }}

{% if is_incremental() %}
  -- only process recent window (tunable)
  where activity_date >= (current_date - 14)
{% endif %}

group by 1,2,3

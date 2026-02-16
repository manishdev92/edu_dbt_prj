{{ config(materialized='view') }}

select
  student_id,
  course_id,
  completion_ts::timestamp as completion_ts,
  credits_earned::numeric(6,2) as credits_earned,
  completion_status,
  source_system,
  _ingested_at
from raw_lms.course_completion

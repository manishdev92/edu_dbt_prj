{{ config(materialized='view') }}

select
  student_id,
  certification_id,
  attempt_no::int as attempt_no,
  attempt_ts::timestamp as attempt_ts,
  score::numeric(6,2) as score,
  pass_flag::boolean as pass_flag,
  source_system,
  _ingested_at
from raw_cert.exam_attempts

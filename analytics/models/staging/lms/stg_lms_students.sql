{{ config(materialized='view') }}

select
  student_id,
  lower(email) as email,
  first_name,
  last_name,
  signup_ts,
  source_system,
  _ingested_at
from {{ source('raw_lms','students') }}

{{ config(materialized='view') }}

select
  student_id,
  certification_id,
  issued_ts::timestamp as issued_ts,
  expiry_date::date as expiry_date,
  status,
  source_system,
  _ingested_at
from raw_cert.certificates

{{ config(materialized='view') }}

select
  enrollment_id,
  student_id,
  course_id,
  enrollment_ts,
  price_paid,
  discount,
  payment_status,
  refund_flag,
  source_system,
  _ingested_at
from raw_billing.enrollments

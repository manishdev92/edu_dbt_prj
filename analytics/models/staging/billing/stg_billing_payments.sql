{{ config(materialized='view') }}

select
  payment_id,
  enrollment_id,
  payment_ts::timestamp as payment_ts,
  amount::numeric(10,2) as amount,
  payment_method,
  payment_status,
  source_system,
  _ingested_at
from raw_billing.payments

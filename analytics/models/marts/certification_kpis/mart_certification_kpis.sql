{{ config(materialized='table') }}

with attempts as (
  select
    certification_id,
    attempt_no,
    count(*) as attempts,
    sum(case when pass_flag then 1 else 0 end) as passes
  from {{ ref('stg_cert_exam_attempts') }}
  group by 1,2
),
time_to_cert as (
  select
    a.student_id,
    a.certification_id,
    min(a.attempt_ts::date) as first_attempt_date,
    min(c.issued_ts::date) as issued_date
  from {{ ref('stg_cert_exam_attempts') }} a
  join {{ ref('stg_cert_certificates') }} c
    on a.student_id = c.student_id
   and a.certification_id = c.certification_id
  group by 1,2
)
select
  attempts.certification_id,
  attempts.attempt_no,
  attempts.attempts,
  attempts.passes,
  round((attempts.passes::numeric / nullif(attempts.attempts,0)) * 100, 2) as pass_rate_pct,
  (select round(avg((issued_date - first_attempt_date))::numeric, 2) from time_to_cert t where t.certification_id = attempts.certification_id) as avg_days_to_cert
from attempts
order by certification_id, attempt_no

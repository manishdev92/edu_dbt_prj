{{ config(materialized='incremental', unique_key=['student_id','as_of_date'], incremental_strategy='merge', dist='student_id', sort='as_of_date') }}

-- Grain: 1 row per student per day (daily snapshot of stage)
with calendar as (
  -- build a calendar for last 90 days for each student (POC)
  select
    s.student_id,
    (current_date - offs.day)::date as as_of_date
  from {{ ref('stg_lms_students') }} s
  cross join (select generate_series(0, 1) as day) offs
),

enr as (
  select
    student_id,
    min(enrollment_ts::date) as first_enroll_date
  from {{ ref('stg_billing_enrollments') }}
  where coalesce(refund_flag,false) = false
    and payment_status in ('paid','refunded')  -- keep simple
  group by 1
),

act as (
  select
    student_id,
    max(activity_date) as last_activity_date
  from {{ ref('fact_learning_activity_daily') }}
  group by 1
),

comp as (
  select
    student_id,
    min(completion_ts::date) as first_completion_date
  from {{ ref('stg_lms_course_completion') }}
  where completion_status = 'completed'
  group by 1
),

cert as (
  select
    student_id,
    min(issued_ts::date) as first_cert_date,
    max(issued_ts::date) as last_cert_date
  from {{ ref('stg_cert_certificates') }}
  where status = 'active'
  group by 1
)

select
  c.student_id,
  c.as_of_date,

  -- Helpful diagnostics
  enr.first_enroll_date,
  act.last_activity_date,
  comp.first_completion_date,
  cert.first_cert_date,

  case
    when cert.first_cert_date is not null and c.as_of_date >= cert.first_cert_date
      then 'certified'
    when comp.first_completion_date is not null and c.as_of_date >= comp.first_completion_date
      then 'completed'
    when act.last_activity_date is not null and c.as_of_date <= act.last_activity_date
         and c.as_of_date >= (act.last_activity_date - 14)
      then 'active'
    when enr.first_enroll_date is not null and c.as_of_date >= enr.first_enroll_date
         and (act.last_activity_date is null or c.as_of_date < (act.last_activity_date - 14))
      then 'at_risk'
    when enr.first_enroll_date is not null and c.as_of_date >= enr.first_enroll_date
      then 'enrolled'
    else 'prospect'
  end as lifecycle_stage

from calendar c
left join enr  on enr.student_id  = c.student_id
left join act  on act.student_id  = c.student_id
left join comp on comp.student_id = c.student_id
left join cert on cert.student_id = c.student_id

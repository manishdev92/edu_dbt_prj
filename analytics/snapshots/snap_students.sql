{% snapshot snap_students %}
{{
  config(
    target_schema='snapshots',
    unique_key='student_id',
    strategy='timestamp',
    updated_at='_ingested_at'
  )
}}

select
  student_id,
  lower(email) as email,
  first_name,
  last_name,
  signup_ts,
  source_system,
  _ingested_at
from raw_lms.students

{% endsnapshot %}

-- LMS
CREATE TABLE IF NOT EXISTS raw_lms.students (
  student_id        TEXT PRIMARY KEY,
  email             TEXT,
  first_name        TEXT,
  last_name         TEXT,
  signup_ts         TIMESTAMP,
  source_system     TEXT,
  _ingested_at      TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS raw_lms.course_activity (
  student_id        TEXT,
  course_id         TEXT,
  activity_date     DATE,
  minutes_spent     INT,
  lessons_completed INT,
  progress_pct      NUMERIC(5,2),
  last_activity_ts  TIMESTAMP,
  source_system     TEXT,
  _ingested_at      TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS raw_lms.course_completion (
  student_id        TEXT,
  course_id         TEXT,
  completion_ts     TIMESTAMP,
  credits_earned    NUMERIC(6,2),
  completion_status TEXT,
  source_system     TEXT,
  _ingested_at      TIMESTAMP DEFAULT now()
);

-- CERT / EXAM
CREATE TABLE IF NOT EXISTS raw_cert.exam_attempts (
  student_id       TEXT,
  certification_id TEXT,
  attempt_no       INT,
  attempt_ts       TIMESTAMP,
  score            NUMERIC(6,2),
  pass_flag        BOOLEAN,
  source_system    TEXT,
  _ingested_at     TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS raw_cert.certificates (
  student_id       TEXT,
  certification_id TEXT,
  issued_ts        TIMESTAMP,
  expiry_date      DATE,
  status           TEXT,
  source_system    TEXT,
  _ingested_at     TIMESTAMP DEFAULT now()
);

-- BILLING
CREATE TABLE IF NOT EXISTS raw_billing.enrollments (
  enrollment_id   TEXT PRIMARY KEY,
  student_id      TEXT,
  course_id       TEXT,
  enrollment_ts   TIMESTAMP,
  price_paid      NUMERIC(10,2),
  discount        NUMERIC(10,2),
  payment_status  TEXT,
  refund_flag     BOOLEAN,
  source_system   TEXT,
  _ingested_at    TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS raw_billing.payments (
  payment_id      TEXT PRIMARY KEY,
  enrollment_id   TEXT,
  payment_ts      TIMESTAMP,
  amount          NUMERIC(10,2),
  payment_method  TEXT,
  payment_status  TEXT,
  source_system   TEXT,
  _ingested_at    TIMESTAMP DEFAULT now()
);

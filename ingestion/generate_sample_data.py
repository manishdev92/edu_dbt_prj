import csv
import os
import random
import uuid
from datetime import datetime, timedelta, date

BASE = os.path.join(os.path.dirname(__file__), "sources")
random.seed(42)

def ensure_dirs():
    for p in ["lms", "cert", "billing"]:
        os.makedirs(os.path.join(BASE, p), exist_ok=True)

def rand_email(i: int) -> str:
    domains = ["gmail.com", "yahoo.com", "outlook.com", "example.com"]
    return f"student{i}@{random.choice(domains)}"

def dt(days_ago_min=1, days_ago_max=120):
    d = datetime.utcnow() - timedelta(days=random.randint(days_ago_min, days_ago_max),
                                      hours=random.randint(0, 23),
                                      minutes=random.randint(0, 59))
    return d.replace(microsecond=0)

def d(days_ago_min=1, days_ago_max=120):
    return (datetime.utcnow().date() - timedelta(days=random.randint(days_ago_min, days_ago_max)))

def main():
    ensure_dirs()

    # --- parameters ---
    n_students = 200
    courses = [
        ("C-RE-101", "Real Estate Pre-Licensing", 60),
        ("C-RE-201", "Real Estate Exam Prep", 20),
        ("C-FIN-110", "Financial Services Basics", 30),
        ("C-HC-210", "Healthcare Continuing Education", 12),
    ]
    certs = [
        ("CERT-RE", "Real Estate License", 24),
        ("CERT-FIN", "Finance Certification", 18),
        ("CERT-HC", "Healthcare CE Certificate", 12),
    ]

    # --- LMS: students.csv ---
    students_path = os.path.join(BASE, "lms", "students.csv")
    students = []
    with open(students_path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["student_id","email","first_name","last_name","signup_ts","source_system"])
        for i in range(1, n_students + 1):
            sid = f"S{i:04d}"
            row = [
                sid,
                rand_email(i),
                random.choice(["Ava","Noah","Liam","Emma","Olivia","Mia","Sophia","Ethan","Mason","Amelia"]),
                random.choice(["Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis"]),
                dt(10, 300).isoformat(sep=" "),
                random.choice(["lms_canvas","lms_moodle"])
            ]
            w.writerow(row)
            students.append(sid)

    # --- Billing: enrollments.csv & payments.csv ---
    enrollments_path = os.path.join(BASE, "billing", "enrollments.csv")
    payments_path = os.path.join(BASE, "billing", "payments.csv")

    enrollment_rows = []
    payment_rows = []

    for sid in students:
        # each student enrolls in 1-3 courses
        for _ in range(random.randint(1, 3)):
            enrollment_id = str(uuid.uuid4())
            course_id, _, _ = random.choice(courses)
            enrollment_ts = dt(1, 120)
            price = random.choice([99, 149, 199, 249, 299])
            discount = random.choice([0, 0, 10, 20])
            refund = random.random() < 0.05
            payment_status = "paid" if not refund else "refunded"

            enrollment_rows.append([
                enrollment_id, sid, course_id, enrollment_ts.isoformat(sep=" "),
                f"{price:.2f}", f"{discount:.2f}", payment_status, str(refund).lower(),
                "billing_stripe"
            ])

            # payment record
            payment_rows.append([
                str(uuid.uuid4()),
                enrollment_id,
                (enrollment_ts + timedelta(minutes=random.randint(1, 600))).isoformat(sep=" "),
                f"{(price - discount):.2f}",
                random.choice(["card","paypal"]),
                payment_status,
                "billing_stripe"
            ])

    with open(enrollments_path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["enrollment_id","student_id","course_id","enrollment_ts","price_paid","discount","payment_status","refund_flag","source_system"])
        w.writerows(enrollment_rows)

    with open(payments_path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["payment_id","enrollment_id","payment_ts","amount","payment_method","payment_status","source_system"])
        w.writerows(payment_rows)

    # --- LMS: course_activity.csv (daily grain) ---
    activity_path = os.path.join(BASE, "lms", "course_activity.csv")
    activity_rows = []
    for enr in enrollment_rows:
        _, sid, course_id, enrollment_ts, *_ = enr
        start_date = datetime.fromisoformat(enrollment_ts).date()
        # generate 5-20 activity days
        for day_offset in sorted(random.sample(range(0, 60), k=random.randint(5, 20))):
            adate = start_date + timedelta(days=day_offset)
            minutes = random.randint(5, 90)
            lessons = random.randint(0, 5)
            # progress creeps upward
            progress = min(100.0, day_offset * random.uniform(1.0, 3.0))
            last_ts = datetime.combine(adate, datetime.min.time()) + timedelta(hours=random.randint(6, 22), minutes=random.randint(0,59))
            activity_rows.append([
                sid, course_id, adate.isoformat(), minutes, lessons, f"{progress:.2f}",
                last_ts.replace(microsecond=0).isoformat(sep=" "),
                random.choice(["lms_canvas","lms_moodle"])
            ])

    with open(activity_path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["student_id","course_id","activity_date","minutes_spent","lessons_completed","progress_pct","last_activity_ts","source_system"])
        w.writerows(activity_rows)

    # --- LMS: course_completion.csv ---
    completion_path = os.path.join(BASE, "lms", "course_completion.csv")
    completion_rows = []
    for sid in students:
        # 40% complete at least one course
        if random.random() < 0.40:
            course_id, _, credits = random.choice(courses)
            completion_ts = dt(1, 60)
            completion_rows.append([
                sid, course_id, completion_ts.isoformat(sep=" "),
                f"{float(credits):.2f}", "completed",
                random.choice(["lms_canvas","lms_moodle"])
            ])

    with open(completion_path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["student_id","course_id","completion_ts","credits_earned","completion_status","source_system"])
        w.writerows(completion_rows)

    # --- CERT: exam_attempts.csv & certificates.csv ---
    attempts_path = os.path.join(BASE, "cert", "exam_attempts.csv")
    certs_path = os.path.join(BASE, "cert", "certificates.csv")

    attempt_rows = []
    cert_rows = []

    for sid in students:
        # 35% attempt a certification exam
        if random.random() < 0.35:
            cert_id, _, validity_months = random.choice(certs)
            n_attempts = random.randint(1, 3)
            passed = False
            for attempt_no in range(1, n_attempts + 1):
                attempt_ts = dt(1, 90)
                score = random.uniform(40, 95)
                # increasing chance to pass
                pass_flag = (score > 70) or (attempt_no == n_attempts and random.random() < 0.5)
                if pass_flag:
                    passed = True
                attempt_rows.append([
                    sid, cert_id, attempt_no, attempt_ts.isoformat(sep=" "),
                    f"{score:.2f}", str(bool(pass_flag)).lower(),
                    "cert_provider_pearson"
                ])

            if passed:
                issued_ts = dt(1, 60)
                expiry = (issued_ts.date() + timedelta(days=30 * validity_months))
                cert_rows.append([
                    sid, cert_id, issued_ts.isoformat(sep=" "),
                    expiry.isoformat(), "active",
                    "cert_provider_pearson"
                ])

    with open(attempts_path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["student_id","certification_id","attempt_no","attempt_ts","score","pass_flag","source_system"])
        w.writerows(attempt_rows)

    with open(certs_path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["student_id","certification_id","issued_ts","expiry_date","status","source_system"])
        w.writerows(cert_rows)

    print("✅ Sample data generated under ingestion/sources/")
    print(" - lms/students.csv")
    print(" - lms/course_activity.csv")
    print(" - lms/course_completion.csv")
    print(" - billing/enrollments.csv")
    print(" - billing/payments.csv")
    print(" - cert/exam_attempts.csv")
    print(" - cert/certificates.csv")

if __name__ == "__main__":
    main()

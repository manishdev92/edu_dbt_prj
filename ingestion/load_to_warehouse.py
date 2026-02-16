import os
import csv
import psycopg2
from psycopg2.extras import execute_values

BASE = os.path.join(os.path.dirname(__file__), "sources")

DB = {
    "host": "localhost",
    "port": int(os.getenv("EDU_PG_PORT", "6543")),
    "dbname": "edu_warehouse",
    "user": "edu",
    "password": "edu",
}

def read_csv(path):
    with open(path, newline="") as f:
        r = csv.reader(f)
        header = next(r)
        rows = list(r)
    return header, rows

def load_table(conn, full_table_name, cols, rows):
    with conn.cursor() as cur:
        cur.execute(f"TRUNCATE TABLE {full_table_name};")
        tmpl = "(" + ",".join(["%s"] * len(cols)) + ")"
        execute_values(
            cur,
            f"INSERT INTO {full_table_name} ({','.join(cols)}) VALUES %s",
            rows,
            template=tmpl,
            page_size=2000
        )

def main():
    mapping = [
        ("raw_lms.students", os.path.join(BASE, "lms", "students.csv")),
        ("raw_lms.course_activity", os.path.join(BASE, "lms", "course_activity.csv")),
        ("raw_lms.course_completion", os.path.join(BASE, "lms", "course_completion.csv")),
        ("raw_billing.enrollments", os.path.join(BASE, "billing", "enrollments.csv")),
        ("raw_billing.payments", os.path.join(BASE, "billing", "payments.csv")),
        ("raw_cert.exam_attempts", os.path.join(BASE, "cert", "exam_attempts.csv")),
        ("raw_cert.certificates", os.path.join(BASE, "cert", "certificates.csv")),
    ]

    conn = psycopg2.connect(**DB)
    conn.autocommit = False

    try:
        for table, path in mapping:
            if not os.path.exists(path):
                raise FileNotFoundError(f"Missing file: {path}")
            cols, rows = read_csv(path)
            load_table(conn, table, cols, rows)
            print(f"✅ Loaded {table}: {len(rows)} rows")
        conn.commit()
        print("🎉 All raw tables loaded successfully.")
    except Exception as e:
        conn.rollback()
        raise
    finally:
        conn.close()

if __name__ == "__main__":
    main()

-- ============================================================
--  HOSPITAL MANAGEMENT SYSTEM — SECURITY SCRIPT
--  Based on: 1-Creation_of_tables.sql
--  DBMS: PostgreSQL
-- ============================================================
/*
  SECURITY ARCHITECTURE — 3 LEVELS
  ─────────────────────────────────────────────────────────────
  Level 1 │ Users & Roles   → WHO can connect
  Level 2 │ Permissions     → WHAT each role can do per table
  Level 3 │ Row-Level Sec.  → WHICH rows each role can see
  ─────────────────────────────────────────────────────────────

  ROLE MAP
  ┌─────────────────────┬──────────────────────────────────────────┐
  │ Role                │ Represents                               │
  ├─────────────────────┼──────────────────────────────────────────┤
  │ hospital_admin      │ Full DBA / system administrator          │
  │ doctor_role         │ Treating physician                       │
  │ nurse_role          │ Nursing staff                            │
  │ receptionist_role   │ Front-desk / appointments                │
  │ pharmacist_role     │ Pharmacy / medicine inventory            │
  │ accountant_role     │ Billing, payments, financial reports     │
  │ hr_role             │ HR — employee & salary management        │
  │ read_only_role      │ Auditors / reporting users               │
  └─────────────────────┴──────────────────────────────────────────┘
*/


-- ============================================================
-- SECTION 1 — DROP OLD ROLES / USERS  (safe re-run)
-- ============================================================

-- Revoke all existing privileges before dropping to avoid dependency errors
DO $$
DECLARE
    r TEXT;
BEGIN
    FOR r IN SELECT rolname FROM pg_roles
             WHERE rolname IN (
                 'hospital_admin','doctor_role','nurse_role',
                 'receptionist_role','pharmacist_role',
                 'accountant_role','hr_role','read_only_role',
                 'admin_user','doctor_user','nurse_user',
                 'receptionist_user','pharmacist_user',
                 'accountant_user','hr_user','readonly_user'
             )
    LOOP
        EXECUTE format('REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM %I', r);
        EXECUTE format('REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM %I', r);
        EXECUTE format('REVOKE ALL ON SCHEMA public FROM %I', r);
    END LOOP;
END;
$$;

-- Drop users (must revoke role memberships first)
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'admin_user')       THEN DROP USER admin_user;       END IF;
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'doctor_user')      THEN DROP USER doctor_user;      END IF;
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'nurse_user')       THEN DROP USER nurse_user;       END IF;
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'receptionist_user')THEN DROP USER receptionist_user;END IF;
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'pharmacist_user')  THEN DROP USER pharmacist_user;  END IF;
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'accountant_user')  THEN DROP USER accountant_user;  END IF;
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'hr_user')          THEN DROP USER hr_user;          END IF;
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'readonly_user')    THEN DROP USER readonly_user;    END IF;
END;
$$;

-- Drop roles
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'hospital_admin')    THEN DROP ROLE hospital_admin;    END IF;
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'doctor_role')       THEN DROP ROLE doctor_role;       END IF;
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'nurse_role')        THEN DROP ROLE nurse_role;        END IF;
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'receptionist_role') THEN DROP ROLE receptionist_role; END IF;
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'pharmacist_role')   THEN DROP ROLE pharmacist_role;   END IF;
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'accountant_role')   THEN DROP ROLE accountant_role;   END IF;
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'hr_role')           THEN DROP ROLE hr_role;           END IF;
    IF EXISTS (SELECT FROM pg_roles WHERE rolname = 'read_only_role')    THEN DROP ROLE read_only_role;    END IF;
END;
$$;


-- ============================================================
-- SECTION 2 — CREATE ROLES  (no LOGIN — pure permission sets)
-- ============================================================

CREATE ROLE hospital_admin;
CREATE ROLE doctor_role;
CREATE ROLE nurse_role;
CREATE ROLE receptionist_role;
CREATE ROLE pharmacist_role;
CREATE ROLE accountant_role;
CREATE ROLE hr_role;
CREATE ROLE read_only_role;


-- ============================================================
-- SECTION 3 — CREATE USERS  (with LOGIN)
-- ============================================================
/*
  ⚠ Change passwords before deploying to production!
*/

CREATE USER admin_user        WITH PASSWORD 'Admin@H0sp!tal';
CREATE USER doctor_user       WITH PASSWORD 'D0ctor@H0sp!tal';
CREATE USER nurse_user        WITH PASSWORD 'Nurs3@H0sp!tal';
CREATE USER receptionist_user WITH PASSWORD 'R3cept@H0sp!tal';
CREATE USER pharmacist_user   WITH PASSWORD 'Ph4rm@H0sp!tal';
CREATE USER accountant_user   WITH PASSWORD 'Acc0unt@H0sp!tal';
CREATE USER hr_user           WITH PASSWORD 'HR@H0sp!tal123';
CREATE USER readonly_user     WITH PASSWORD 'R3ad0nly@H0sp';


-- ============================================================
-- SECTION 4 — ASSIGN ROLES TO USERS
-- ============================================================

GRANT hospital_admin     TO admin_user;
GRANT doctor_role        TO doctor_user;
GRANT nurse_role         TO nurse_user;
GRANT receptionist_role  TO receptionist_user;
GRANT pharmacist_role    TO pharmacist_user;
GRANT accountant_role    TO accountant_user;
GRANT hr_role            TO hr_user;
GRANT read_only_role     TO readonly_user;

-- Also give read_only_role to all roles (base read access)
GRANT read_only_role TO doctor_role;
GRANT read_only_role TO nurse_role;
GRANT read_only_role TO receptionist_role;
GRANT read_only_role TO pharmacist_role;
GRANT read_only_role TO accountant_role;
GRANT read_only_role TO hr_role;


-- ============================================================
-- SECTION 5 — SCHEMA USAGE
-- ============================================================
/*
GRANT USAGE ON SCHEMA → This gives the listed roles permission
to access the schema itself (in this case, public)
*/

GRANT USAGE ON SCHEMA public TO
    hospital_admin, doctor_role, nurse_role, receptionist_role,
    pharmacist_role, accountant_role, hr_role, read_only_role;


-- ============================================================
-- SECTION 6 — HOSPITAL ADMIN  (full privileges)
-- ============================================================

GRANT ALL PRIVILEGES ON ALL TABLES    IN SCHEMA public TO hospital_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO hospital_admin;
GRANT CREATE ON SCHEMA public TO hospital_admin;


-- ============================================================
-- SECTION 7 — READ ONLY ROLE  (base for all roles)
-- ============================================================
/*
  Covers: lookup / reference tables that every role needs to read.
  Sensitive tables (employees salary, payments) are excluded here
  and granted only to the specific roles that need them.
*/

GRANT SELECT ON
    departments,
    specialization_categories,
    specializations,
    jobs,
    roles,
    role_access,
    clinics,
    shifts,
    diagnosis_categories,
    diagnoses,
    surgeries,
    hospital_facilities
TO read_only_role;


-- ============================================================
-- SECTION 8 — DOCTOR ROLE
-- ============================================================
/*
  Doctors can:
  • Read patient demographics & history
  • Insert and update diagnoses, prescriptions, visits, surgeries
  • View their own appointments
  • Cannot see salary data or financial tables
*/

-- Patients (read only — doctors don't register patients)
GRANT SELECT ON patients, patient_phones TO doctor_role;

-- Appointments (read + update status)
GRANT SELECT, UPDATE ON appointments TO doctor_role;

-- Visits (create + read)
GRANT SELECT, INSERT, UPDATE ON visits TO doctor_role;

-- Diagnoses & medical history
GRANT SELECT, INSERT, UPDATE ON patient_diagnoses TO doctor_role;

-- Surgeries
GRANT SELECT, INSERT, UPDATE ON patient_surgeries TO doctor_role;

-- Prescriptions
GRANT SELECT, INSERT, UPDATE ON prescriptions TO doctor_role;

-- Medicines (read only — doctors prescribe, pharmacists manage stock)
GRANT SELECT ON medicines, medicines_inventory TO doctor_role;

-- Sequences needed for INSERT
GRANT USAGE, SELECT ON SEQUENCE
    visits_visit_id_seq,
    patient_diagnoses_patient_diagnosis_id_seq,
    patient_surgeries_patient_surgery_id_seq,
    prescriptions_prescription_id_seq
TO doctor_role;


-- ============================================================
-- SECTION 9 — NURSE ROLE
-- ============================================================
/*
  Nurses can:
  • Read patients and visits
  • Update visit descriptions and patient notes
  • Add diagnoses entries
  • Cannot prescribe medicines directly
  • Cannot access financial data
*/

GRANT SELECT ON patients, patient_phones TO nurse_role;
GRANT SELECT, UPDATE ON visits TO nurse_role;
GRANT SELECT, INSERT ON patient_diagnoses TO nurse_role;
GRANT SELECT ON appointments TO nurse_role;
GRANT SELECT ON prescriptions, medicines TO nurse_role;

GRANT USAGE, SELECT ON SEQUENCE
    patient_diagnoses_patient_diagnosis_id_seq
TO nurse_role;


-- ============================================================
-- SECTION 10 — RECEPTIONIST ROLE
-- ============================================================
/*
  Receptionists can:
  • Register and update patients
  • Create and manage appointments
  • Cannot see medical history, diagnoses, prescriptions
  • Cannot see salaries or financial reports
*/

-- Patients (create + update — they register patients)
GRANT SELECT, INSERT, UPDATE ON patients TO receptionist_role;
GRANT SELECT, INSERT, UPDATE ON patient_phones TO receptionist_role;

-- Appointments (full control)
GRANT SELECT, INSERT, UPDATE, DELETE ON appointments TO receptionist_role;

-- Clinics (read — to assign appointment to correct clinic)
GRANT SELECT ON clinics TO receptionist_role;

-- Sequences
GRANT USAGE, SELECT ON SEQUENCE
    patients_patient_id_seq,
    patient_phones_patient_phone_id_seq,
    appointments_appointment_id_seq
TO receptionist_role;


-- ============================================================
-- SECTION 11 — PHARMACIST ROLE
-- ============================================================
/*
  Pharmacists can:
  • Manage medicine stock (inventory)
  • Read prescriptions to dispense medicines
  • Manage stores and products
  • Cannot access patient diagnoses or financial tables
*/

-- Medicine inventory
GRANT SELECT, INSERT, UPDATE ON medicines TO pharmacist_role;
GRANT SELECT, INSERT, UPDATE ON medicines_inventory TO pharmacist_role;

-- Prescriptions (read only — to verify and fulfil)
GRANT SELECT ON prescriptions TO pharmacist_role;

-- Products & stores
GRANT SELECT, INSERT, UPDATE ON products, store_products, stores TO pharmacist_role;
GRANT SELECT ON vendors, vendor_products TO pharmacist_role;

-- Patients (read only — for prescription lookup)
GRANT SELECT ON patients TO pharmacist_role;

-- Sequences
GRANT USAGE, SELECT ON SEQUENCE
    medicines_medicine_id_seq,
    products_product_id_seq
TO pharmacist_role;


-- ============================================================
-- SECTION 12 — ACCOUNTANT ROLE
-- ============================================================
/*
  Accountants can:
  • Full control over payments and bills
  • Read patient data (for billing context)
  • Cannot read medical history, diagnoses, or employee salaries
*/

-- Payments & bills (full control)
GRANT SELECT, INSERT, UPDATE ON payments TO accountant_role;
GRANT SELECT, INSERT, UPDATE ON bills    TO accountant_role;
GRANT SELECT, INSERT, UPDATE ON bill_items TO accountant_role;

-- Patients (read only — billing reference)
GRANT SELECT ON patients TO accountant_role;

-- Visits (read only — billing reference)
GRANT SELECT ON visits TO accountant_role;

-- Facilities billing
GRANT SELECT ON hospital_facilities, facility_assignments TO accountant_role;

-- Sequences
GRANT USAGE, SELECT ON SEQUENCE
    payments_payment_id_seq,
    bills_bill_id_seq,
    bill_items_bill_item_id_seq
TO accountant_role;


-- ============================================================
-- SECTION 13 — HR ROLE
-- ============================================================
/*
  HR can:
  • Full control over employee records (including salary)
  • Manage shifts, jobs, departments, specializations
  • Cannot see patient medical data or financial billing
*/

-- Employees (full control)
GRANT SELECT, INSERT, UPDATE ON employees TO hr_role;

-- Organisational structure
GRANT SELECT, INSERT, UPDATE ON
    departments,
    specialization_categories,
    specializations,
    jobs,
    roles,
    role_access
TO hr_role;

-- Shifts
GRANT SELECT, INSERT, UPDATE, DELETE ON shifts TO hr_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON employee_shifts TO hr_role;

-- Clinic assignments (assign staff to clinics)
GRANT SELECT, INSERT, UPDATE, DELETE ON clinic_employees TO hr_role;

-- Sequences
GRANT USAGE, SELECT ON SEQUENCE
    employees_employee_id_seq,
    departments_department_id_seq,
    specialization_categories_specialization_category_id_seq,
    specializations_specialization_id_seq,
    jobs_job_id_seq,
    roles_role_id_seq,
    shifts_shift_id_seq
TO hr_role;


-- ============================================================
-- SECTION 14 — DEFAULT PRIVILEGES
--  Any NEW table created in the future inherits the same grants
-- ============================================================

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO read_only_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL PRIVILEGES ON TABLES TO hospital_admin;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL PRIVILEGES ON SEQUENCES TO hospital_admin;


-- ============================================================
-- SECTION 15 — ROW LEVEL SECURITY (RLS)
-- ============================================================

/*──────────────────────────────────────────
  15.1  EMPLOYEES TABLE
  • HR sees all employees
  • Each employee sees only their own row
  • Admin bypasses RLS entirely
──────────────────────────────────────────*/

ALTER TABLE employees ENABLE ROW LEVEL SECURITY;

-- Admin bypass
CREATE POLICY policy_employees_admin
    ON employees
    FOR ALL
    TO hospital_admin
    USING (TRUE);

-- HR sees all
CREATE POLICY policy_employees_hr
    ON employees
    FOR ALL
    TO hr_role
    USING (TRUE);

-- Any other user sees only their own row (matched by email = current DB user)
CREATE POLICY policy_employees_self
    ON employees
    FOR SELECT
    TO PUBLIC
    USING (email = current_user || '@hospital.com');


/*──────────────────────────────────────────
  15.2  APPOINTMENTS TABLE
  • Doctors see only appointments assigned to them
  • Receptionists and admin see all
──────────────────────────────────────────*/

ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

CREATE POLICY policy_appointments_admin
    ON appointments FOR ALL TO hospital_admin USING (TRUE);

CREATE POLICY policy_appointments_receptionist
    ON appointments FOR ALL TO receptionist_role USING (TRUE);

-- Doctors see only their own appointments
CREATE POLICY policy_appointments_doctor
    ON appointments
    FOR SELECT
    TO doctor_role
    USING (
        doctor_id = (
            SELECT employee_id FROM employees
            WHERE email = current_user || '@hospital.com'
            LIMIT 1
        )
    );


/*──────────────────────────────────────────
  15.3  PATIENT_DIAGNOSES TABLE
  • Doctors see only diagnoses they recorded
  • Nurses can read all (to assist any patient)
  • Admin sees all
──────────────────────────────────────────*/

ALTER TABLE patient_diagnoses ENABLE ROW LEVEL SECURITY;

CREATE POLICY policy_pd_admin
    ON patient_diagnoses FOR ALL TO hospital_admin USING (TRUE);

CREATE POLICY policy_pd_nurse
    ON patient_diagnoses FOR SELECT TO nurse_role USING (TRUE);

CREATE POLICY policy_pd_doctor
    ON patient_diagnoses
    FOR ALL
    TO doctor_role
    USING (
        doctor_id = (
            SELECT employee_id FROM employees
            WHERE email = current_user || '@hospital.com'
            LIMIT 1
        )
    );


/*──────────────────────────────────────────
  15.4  PRESCRIPTIONS TABLE
  • Doctors see/create only their own prescriptions
  • Pharmacists read all (to fulfil any prescription)
  • Admin sees all
──────────────────────────────────────────*/

ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY policy_rx_admin
    ON prescriptions FOR ALL TO hospital_admin USING (TRUE);

CREATE POLICY policy_rx_pharmacist
    ON prescriptions FOR SELECT TO pharmacist_role USING (TRUE);

CREATE POLICY policy_rx_doctor
    ON prescriptions
    FOR ALL
    TO doctor_role
    USING (
        doctor_id = (
            SELECT employee_id FROM employees
            WHERE email = current_user || '@hospital.com'
            LIMIT 1
        )
    );


/*──────────────────────────────────────────
  15.5  PAYMENTS TABLE
  • Accountants see all payments
  • Patients (via readonly_user) see only their own
  • Admin sees all
──────────────────────────────────────────*/

ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY policy_pay_admin
    ON payments FOR ALL TO hospital_admin USING (TRUE);

CREATE POLICY policy_pay_accountant
    ON payments FOR ALL TO accountant_role USING (TRUE);


/*──────────────────────────────────────────
  15.6  BILLS TABLE
  • Accountants see all bills
  • Admin sees all
──────────────────────────────────────────*/

ALTER TABLE bills ENABLE ROW LEVEL SECURITY;

CREATE POLICY policy_bills_admin
    ON bills FOR ALL TO hospital_admin USING (TRUE);

CREATE POLICY policy_bills_accountant
    ON bills FOR ALL TO accountant_role USING (TRUE);


-- ============================================================
-- SECTION 16 — EXPLICIT DENY PATTERNS
--  These prevent dangerous cross-role access
-- ============================================================

-- Doctors must NOT touch salary or HR data
REVOKE ALL ON employees   FROM doctor_role;
REVOKE ALL ON employees   FROM nurse_role;
REVOKE ALL ON employees   FROM receptionist_role;

-- Re-grant the safe SELECT columns doctors need (clinic staff lookup)
-- Use a view instead of column-level grants for clarity (see views file)
GRANT SELECT ON clinics, clinic_employees TO doctor_role;
GRANT SELECT ON clinics, clinic_employees TO nurse_role;

-- Accountants must NOT read medical details
REVOKE ALL ON patient_diagnoses  FROM accountant_role;
REVOKE ALL ON prescriptions      FROM accountant_role;
REVOKE ALL ON patient_surgeries  FROM accountant_role;
REVOKE ALL ON medicines_inventory FROM accountant_role;

-- Pharmacists must NOT touch financial tables
REVOKE ALL ON payments   FROM pharmacist_role;
REVOKE ALL ON bills      FROM pharmacist_role;
REVOKE ALL ON bill_items FROM pharmacist_role;

-- Receptionists must NOT read clinical or financial details
REVOKE ALL ON patient_diagnoses  FROM receptionist_role;
REVOKE ALL ON prescriptions      FROM receptionist_role;
REVOKE ALL ON patient_surgeries  FROM receptionist_role;
REVOKE ALL ON payments           FROM receptionist_role;
REVOKE ALL ON bills              FROM receptionist_role;


-- ============================================================
-- SECTION 17 — VERIFICATION QUERIES
-- ============================================================

-- List all custom roles
SELECT rolname, rolcanlogin, rolsuper
FROM pg_roles
WHERE rolname IN (
    'hospital_admin','doctor_role','nurse_role','receptionist_role',
    'pharmacist_role','accountant_role','hr_role','read_only_role',
    'admin_user','doctor_user','nurse_user','receptionist_user',
    'pharmacist_user','accountant_user','hr_user','readonly_user'
)
ORDER BY rolcanlogin DESC, rolname;


-- List role memberships
SELECT
    r.rolname  AS member,
    g.rolname  AS "granted_role"
FROM pg_auth_members m
JOIN pg_roles r ON r.oid = m.member
JOIN pg_roles g ON g.oid = m.roleid
ORDER BY member;


-- List all table-level privileges granted
SELECT
    grantee,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
ORDER BY grantee, table_name, privilege_type;


-- List tables with RLS enabled
SELECT relname AS table_name, relrowsecurity AS rls_enabled
FROM pg_class
WHERE relnamespace = 'public'::regnamespace
  AND relkind = 'r'
  AND relrowsecurity = TRUE
ORDER BY relname;


-- Check active RLS policies
SELECT
    schemaname,
    tablename,
    policyname,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;


-- Check current connected user
SELECT current_user, session_user;

-- ============================================================
-- END OF SECURITY SCRIPT
-- ============================================================
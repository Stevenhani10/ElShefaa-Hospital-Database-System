-- indexes 
-- EXPLAIN ANALYZE shows whether PostgreSQL uses the index or not.
-- If an index already exists, PostgreSQL will give an error.
-- To avoid that, I will use CREATE INDEX IF NOT EXISTS.


-- 1. Employee Department Index
-- This helps when searching employees inside a specific department.
CREATE INDEX IF NOT EXISTS idx_employees_department_id
ON employees(department_id);


--test case 
EXPLAIN ANALYZE
SELECT
    employee_id,
    full_name,
    department_id
FROM employees
WHERE department_id = 1;


--------------------------------------------------------------
-- 2. Employee Job Index
-- This helps when searching employees by job, 
-- for example all doctors or all nurses.
CREATE INDEX IF NOT EXISTS idx_employees_job_id
ON employees(job_id);

--test 


EXPLAIN ANALYZE
SELECT
    employee_id,
    full_name,
    job_id
FROM employees
WHERE job_id = 1;


-------------------------------------------------------------
--3. Employee Role Index
-- This helps when filtering employees by role,
-- such as Doctor, Nurse, Admin, Receptionist.


CREATE INDEX IF NOT EXISTS idx_employees_role_id
ON employees(role_id);


--test 
EXPLAIN ANALYZE
SELECT
    e.employee_id,
    e.full_name,
    r.role_name
FROM employees e
JOIN roles r
    ON e.role_id = r.role_id
WHERE e.role_id = 2;
-----------------------------------------------------------------
-- 4. Patient Full Name Index
--This helps when searching for a patient by exact full name.

CREATE INDEX IF NOT EXISTS idx_patients_full_name
ON patients(full_name);




EXPLAIN ANALYZE
SELECT
    patient_id,
    full_name,
    gender,
    blood_type
FROM patients
WHERE full_name = 'Mahmoud Ibrahim Hassan';

------------------------------------------------------------------------
--5. Appointment Patient Index
-- This helps when showing all appointments for one patient.
CREATE INDEX IF NOT EXISTS idx_appointments_patient_id
ON appointments(patient_id);



EXPLAIN ANALYZE
SELECT
    appointment_id,
    patient_id,
    appointment_date,
    appointment_time,
    appointment_status
FROM appointments
WHERE patient_id = 1;



-----------------------------------------------------------------------
-- 6. Appointment Doctor Date Time Index


CREATE INDEX IF NOT EXISTS idx_appointments_doctor_date_time
ON appointments(doctor_id, appointment_date, appointment_time);

EXPLAIN ANALYZE
SELECT
    appointment_id,
    doctor_id,
    appointment_date,
    appointment_time,
    appointment_status
FROM appointments
WHERE doctor_id = 1
  AND appointment_date = '2026-05-05'
  AND appointment_time = '10:00:00';



----------------------------------------------------------------------
-- 7. Appointment Clinic Date Time Index
--This helps check whether a clinic room is busy at a specific date and time.

CREATE INDEX IF NOT EXISTS idx_appointments_clinic_date_time
ON appointments(clinic_id, appointment_date, appointment_time);



EXPLAIN ANALYZE
SELECT
    appointment_id,
    clinic_id,
    appointment_date,
    appointment_time,
    appointment_status
FROM appointments
WHERE clinic_id = 1
  AND appointment_date = '2026-05-05'
  AND appointment_time = '10:00:00';


----------------------------------------------------------------------------
--8. Visit Patient Index
-- This helps when getting the visit history of a patient.
CREATE INDEX IF NOT EXISTS idx_visits_patient_id
ON visits(patient_id);


EXPLAIN ANALYZE
SELECT
    visit_id,
    patient_id,
    visit_date,
    visit_time,
    description
FROM visits
WHERE patient_id = 1;


----------------------------------------------------------------------
--9. Visit Doctor Index
-- This helps when showing all visits handled by a specific doctor.
CREATE INDEX IF NOT EXISTS idx_visits_doctor_id
ON visits(doctor_id);


EXPLAIN ANALYZE
SELECT
    visit_id,
    doctor_id,
    patient_id,
    visit_date,
    visit_time
FROM visits
WHERE doctor_id = 1;


----------------------------------------------------------------------
-- 10. Patient Diagnosis Patient Index
-- This helps retrieve the medical diagnosis history of a patient.



CREATE INDEX IF NOT EXISTS idx_patient_diagnoses_patient_id
ON patient_diagnoses(patient_id);


EXPLAIN ANALYZE
SELECT
    patient_diagnosis_id,
    patient_id,
    diagnosis_id,
    diagnosis_date,
    description
FROM patient_diagnoses
WHERE patient_id = 1;


-------------------------------------------------------------------
-- 11. Prescription Patient Index
-- This helps when getting all medicines prescribed to one patient.

CREATE INDEX IF NOT EXISTS idx_prescriptions_patient_id
ON prescriptions(patient_id);

-- test
EXPLAIN ANALYZE
SELECT
    prescription_id,
    patient_id,
    medicine_id,
    prescription_date,
    dosage,
    duration
FROM prescriptions
WHERE patient_id = 1;


--------------------------------------------------------------
-- 12. Bill Patient Index
-- This helps when getting all bills for one patient.

CREATE INDEX IF NOT EXISTS idx_bills_patient_id
ON bills(patient_id);

-- test
EXPLAIN ANALYZE
SELECT
    bill_id,
    patient_id,
    service_name,
    total_cost,
    bill_date
FROM bills
WHERE patient_id = 1;


--------------------------------------------------------------
-- 13. Payment Patient Status Index
-- This helps when calculating paid payments for one patient.

CREATE INDEX IF NOT EXISTS idx_payments_patient_status
ON payments(patient_id, payment_status);

-- test
EXPLAIN ANALYZE
SELECT
    payment_id,
    patient_id,
    payment_cost,
    payment_method,
    payment_status,
    payment_date
FROM payments
WHERE patient_id = 1
  AND payment_status = 'Paid';


--------------------------------------------------------------
-- 14. Medicine Expire Date Index
-- This helps when checking expired or near-expiry medicines.

CREATE INDEX IF NOT EXISTS idx_medicines_expire_date
ON medicines(expire_date);

-- test
EXPLAIN ANALYZE
SELECT
    medicine_id,
    commercial_name,
    medical_name,
    expire_date
FROM medicines
WHERE expire_date <= CURRENT_DATE + INTERVAL '30 days';


--------------------------------------------------------------
-- 15. Medicine Inventory Store Index
-- This helps when showing all medicines inside one store.

CREATE INDEX IF NOT EXISTS idx_medicines_inventory_store_id
ON medicines_inventory(store_id);

-- test
EXPLAIN ANALYZE
SELECT
    store_id,
    medicine_id,
    quantity
FROM medicines_inventory
WHERE store_id = 2;
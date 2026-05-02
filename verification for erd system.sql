-- ============================================================
-- FULL ERD INTEGRATION VERIFICATION QUERY - FIXED VERSION
-- ============================================================

SELECT
    p.patient_id,
    p.full_name AS patient_name,
    p.gender AS patient_gender,
    p.blood_type,
    p.insurance AS has_insurance,

    a.appointment_id,
    a.appointment_date,
    a.appointment_time,
    a.appointment_status,

    v.visit_id,
    v.visit_date,
    v.visit_time,
    v.description AS visit_description,

    c.clinic_name,
    c.room_number,
    d.department_name,
    d.department_type,

    doctor.employee_id AS doctor_id,
    doctor.full_name AS doctor_name,
    j.job_title AS doctor_job,
    r.role_name AS doctor_role,
    s.specialization_name AS doctor_specialization,

    STRING_AGG(DISTINCT dg.diagnosis_name, ', ') AS diagnoses,
    STRING_AGG(DISTINCT dc.diagnosis_category_name, ', ') AS diagnosis_categories,

    STRING_AGG(DISTINCT med.commercial_name, ', ') AS prescribed_medicines,
    STRING_AGG(DISTINCT pr.dosage, ', ') AS medicine_dosages,

    STRING_AGG(DISTINCT surg.surgery_name, ', ') AS surgeries,
    BOOL_OR(ps.need_surgery) AS needs_surgery,

    COUNT(DISTINCT b.bill_id) AS number_of_bills,
    COALESCE(SUM(DISTINCT b.total_cost), 0) AS total_billed_amount,

    COUNT(DISTINCT pay.payment_id) AS number_of_payments,
    COALESCE(SUM(DISTINCT pay.payment_cost), 0) AS total_paid_amount,

    CASE
        WHEN COALESCE(SUM(DISTINCT pay.payment_cost), 0)
             >= COALESCE(SUM(DISTINCT b.total_cost), 0)
        THEN 'Fully Paid'

        WHEN COALESCE(SUM(DISTINCT pay.payment_cost), 0) > 0
             AND COALESCE(SUM(DISTINCT pay.payment_cost), 0)
             < COALESCE(SUM(DISTINCT b.total_cost), 0)
        THEN 'Partially Paid'

        ELSE 'Unpaid'
    END AS payment_verification_status,

    STRING_AGG(DISTINCT hf.facility_name, ', ') AS used_facilities,

    CASE
        WHEN p.patient_id IS NOT NULL
         AND a.appointment_id IS NOT NULL
         AND v.visit_id IS NOT NULL
         AND doctor.employee_id IS NOT NULL
         AND c.clinic_id IS NOT NULL
         AND d.department_id IS NOT NULL
        THEN 'Core ERD Flow Connected'
        ELSE 'Missing Core Relationship'
    END AS erd_core_status

FROM patients p

LEFT JOIN appointments a
    ON p.patient_id = a.patient_id

LEFT JOIN visits v
    ON p.patient_id = v.patient_id
   AND (
        v.appointment_id = a.appointment_id
        OR v.appointment_id IS NULL
   )

LEFT JOIN clinics c
    ON v.clinic_id = c.clinic_id
    OR a.clinic_id = c.clinic_id

LEFT JOIN departments d
    ON c.department_id = d.department_id

LEFT JOIN employees doctor
    ON v.doctor_id = doctor.employee_id
    OR a.doctor_id = doctor.employee_id

LEFT JOIN jobs j
    ON doctor.job_id = j.job_id

LEFT JOIN roles r
    ON doctor.role_id = r.role_id

LEFT JOIN specializations s
    ON doctor.specialization_id = s.specialization_id

LEFT JOIN patient_diagnoses pd
    ON p.patient_id = pd.patient_id
   AND (
        pd.visit_id = v.visit_id
        OR pd.visit_id IS NULL
   )

LEFT JOIN diagnoses dg
    ON pd.diagnosis_id = dg.diagnosis_id

LEFT JOIN diagnosis_categories dc
    ON dg.diagnosis_category_id = dc.diagnosis_category_id

LEFT JOIN prescriptions pr
    ON p.patient_id = pr.patient_id
   AND (
        pr.visit_id = v.visit_id
        OR pr.visit_id IS NULL
   )

LEFT JOIN medicines med
    ON pr.medicine_id = med.medicine_id

LEFT JOIN patient_surgeries ps
    ON p.patient_id = ps.patient_id
   AND (
        ps.visit_id = v.visit_id
        OR ps.visit_id IS NULL
   )

LEFT JOIN surgeries surg
    ON ps.surgery_id = surg.surgery_id

LEFT JOIN bills b
    ON p.patient_id = b.patient_id
   AND (
        b.visit_id = v.visit_id
        OR b.visit_id IS NULL
   )

LEFT JOIN payments pay
    ON p.patient_id = pay.patient_id
   AND (
        b.payment_id = pay.payment_id
        OR b.payment_id IS NULL
   )

LEFT JOIN facility_assignments fa
    ON p.patient_id = fa.patient_id
   AND (
        fa.visit_id = v.visit_id
        OR fa.visit_id IS NULL
   )

LEFT JOIN hospital_facilities hf
    ON fa.facility_id = hf.facility_id

GROUP BY
    p.patient_id,
    p.full_name,
    p.gender,
    p.blood_type,
    p.insurance,

    a.appointment_id,
    a.appointment_date,
    a.appointment_time,
    a.appointment_status,

    v.visit_id,
    v.visit_date,
    v.visit_time,
    v.description,

    c.clinic_id,
    c.clinic_name,
    c.room_number,

    d.department_id,
    d.department_name,
    d.department_type,

    doctor.employee_id,
    doctor.full_name,

    j.job_title,
    r.role_name,
    s.specialization_name

ORDER BY
    p.patient_id,
    a.appointment_date,
    v.visit_date;




-------------------------------------------
SELECT
    p.patient_id,
    p.full_name AS patient_name,

    a.appointment_id,
    a.appointment_date,
    a.appointment_time,
    a.appointment_status,

    v.visit_id,
    v.visit_date,
    v.visit_time,

    doctor.full_name AS doctor_name,

    c.clinic_name,
    c.room_number,

    d.department_name,
    d.department_type

FROM patients p

LEFT JOIN appointments a
    ON p.patient_id = a.patient_id

LEFT JOIN visits v
    ON a.appointment_id = v.appointment_id

LEFT JOIN employees doctor
    ON v.doctor_id = doctor.employee_id

LEFT JOIN clinics c
    ON v.clinic_id = c.clinic_id

LEFT JOIN departments d
    ON c.department_id = d.department_id

ORDER BY
    p.patient_id,
    a.appointment_date;


----------------------
SELECT
    p.patient_id,
    p.full_name AS patient_name,
    a.appointment_id,
    a.appointment_date,
    a.appointment_time,
    a.appointment_status
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id;
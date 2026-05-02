-- Views tested
-- View 1: Patient Appointment Details
CREATE OR REPLACE VIEW vw_patient_appointments AS
SELECT
    a.appointment_id,
    p.patient_id,
    p.full_name AS patient_name,
    p.gender,
    p.blood_type,
    a.appointment_date,
    a.appointment_time,
    a.appointment_status,
    c.clinic_name,
    c.room_number,
    d.department_name,
    e.full_name AS doctor_name
FROM appointments a
JOIN patients p
    ON a.patient_id = p.patient_id
LEFT JOIN clinics c
    ON a.clinic_id = c.clinic_id
LEFT JOIN departments d
    ON c.department_id = d.department_id
LEFT JOIN employees e
    ON a.doctor_id = e.employee_id;


--testing View 1: Patient Appointment Details
SELECT *
FROM vw_patient_appointments;



--------------------------------------------------------------------
-- View 2: Patient Medical Summary
CREATE OR REPLACE VIEW vw_patient_medical_summary AS
SELECT
    pd.patient_diagnosis_id,
    p.patient_id,
    p.full_name AS patient_name,
    v.visit_id,
    v.visit_date,
    d.diagnosis_name,
    dc.diagnosis_category_name,
    pd.description AS diagnosis_notes,
    e.full_name AS doctor_name
FROM patient_diagnoses pd
JOIN patients p
    ON pd.patient_id = p.patient_id
LEFT JOIN visits v
    ON pd.visit_id = v.visit_id
JOIN diagnoses d
    ON pd.diagnosis_id = d.diagnosis_id
LEFT JOIN diagnosis_categories dc
    ON d.diagnosis_category_id = dc.diagnosis_category_id
LEFT JOIN employees e
    ON pd.doctor_id = e.employee_id;


----------------------------testing second view 
SELECT *
FROM vw_patient_medical_summary;





-- View 3: Patient Bills and Payments

CREATE OR REPLACE VIEW vw_patient_billing_summary AS
SELECT
    b.bill_id,
    p.patient_id,
    p.full_name AS patient_name,
    b.service_name,
    b.bill_type,
    b.actual_cost,
    b.transfer_fees,
    b.total_cost,
    pay.payment_method,
    pay.payment_cost,
    pay.payment_status,
    CASE
        WHEN pay.payment_id IS NULL THEN 'No Payment'
        WHEN pay.payment_cost >= b.total_cost THEN 'Fully Paid'
        WHEN pay.payment_cost > 0 AND pay.payment_cost < b.total_cost THEN 'Partially Paid'
        ELSE 'Unpaid'
    END AS bill_payment_status
FROM bills b
JOIN patients p
    ON b.patient_id = p.patient_id
LEFT JOIN payments pay
    ON b.payment_id = pay.payment_id;


----------test View 3: Patient Bills and Payments
SELECT *
FROM vw_patient_billing_summary;

-------------------------------------------
---View 4: Doctor Schedule
CREATE OR REPLACE VIEW vw_doctor_schedule AS
SELECT
    e.employee_id AS doctor_id,
    e.full_name AS doctor_name,
    d.department_name,
    s.specialization_name,
    a.appointment_id,
    p.full_name AS patient_name,
    a.appointment_date,
    a.appointment_time,
    a.appointment_status,
    c.clinic_name
FROM appointments a
JOIN employees e
    ON a.doctor_id = e.employee_id
LEFT JOIN departments d
    ON e.department_id = d.department_id
LEFT JOIN specializations s
    ON e.specialization_id = s.specialization_id
JOIN patients p
    ON a.patient_id = p.patient_id
LEFT JOIN clinics c
    ON a.clinic_id = c.clinic_id;


--- testing view 4
SELECT *
FROM vw_doctor_schedule
WHERE doctor_id = 1;



-----------------------------
--view 5 medicine inventory view 
CREATE OR REPLACE VIEW vw_medicine_inventory AS
SELECT
    s.store_id,
    s.store_name,
    m.medicine_id,
    m.commercial_name,
    m.medical_name,
    mi.quantity,
    m.commercial_price,
    m.expire_date,
    CASE
        WHEN m.expire_date < CURRENT_DATE THEN 'Expired'
        WHEN m.expire_date <= CURRENT_DATE + INTERVAL '30 days' THEN 'Near Expiry'
        ELSE 'Valid'
    END AS expiry_status
FROM medicines_inventory mi
JOIN stores s
    ON mi.store_id = s.store_id
JOIN medicines m
    ON mi.medicine_id = m.medicine_id;



----testing the 5 view 
SELECT *
FROM vw_medicine_inventory;
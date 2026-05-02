-- ============================================================
-- Hospital Management System Sample Data
-- DBMS: PostgreSQL
-- Run this AFTER creating the schema
-- ============================================================

-- ============================================================
-- 1. DEPARTMENTS
-- ============================================================

INSERT INTO departments (department_name, department_type)
VALUES
('Cardiology Department', 'Medical'),
('Neurology Department', 'Medical'),
('Human Resources Department', 'Administrative'),
('Sales Department', 'Administrative'),
('Radiology Department', 'Medical');

-- ============================================================
-- 2. SPECIALIZATION CATEGORIES
-- ============================================================

INSERT INTO specialization_categories 
(department_id, specialization_category_name)
VALUES
(1, 'Heart Diseases'),
(1, 'Cardiac Surgery'),
(2, 'Brain and Nerves'),
(5, 'Medical Imaging');

-- ============================================================
-- 3. SPECIALIZATIONS
-- ============================================================

INSERT INTO specializations 
(specialization_category_id, specialization_name)
VALUES
(1, 'General Cardiology'),
(1, 'Interventional Cardiology'),
(2, 'Cardiothoracic Surgery'),
(3, 'Neurology'),
(4, 'X-Ray Specialist'),
(4, 'MRI Specialist');

-- ============================================================
-- 4. JOBS
-- ============================================================

INSERT INTO jobs 
(department_id, job_title)
VALUES
(1, 'Doctor'),
(1, 'Nurse'),
(1, 'Receptionist'),
(2, 'Doctor'),
(3, 'HR Specialist'),
(4, 'Sales Representative'),
(5, 'Radiology Technician');

-- ============================================================
-- 5. ROLES
-- ============================================================

INSERT INTO roles (role_name)
VALUES
('Admin'),
('Doctor'),
('Nurse'),
('Receptionist'),
('HR'),
('Pharmacist'),
('Store Manager');

-- ============================================================
-- 6. EMPLOYEES
-- Do NOT insert full_name because it is generated automatically.
-- ============================================================

INSERT INTO employees
(
    fname, lname, surname, gender, date_of_birth, national_id, ssn,
    phone, email,
    government, city, area, street, building,
    hire_date, degree, insurance,
    fixed_salary, bonus, deduction, net_salary,
    department_id, specialization_id, job_id, role_id
)
VALUES
(
    'Ahmed', 'Mohamed', 'Ali', 'Male', '1985-03-15', '29803150123456', 'SSN001',
    '01011111111', 'ahmed.doctor@hospital.com',
    'Cairo', 'Nasr City', 'Abbas El Akkad', 'Main Street', '12',
    '2015-06-01', 'MD Cardiology', TRUE,
    30000, 5000, 1000, 34000,
    1, 1, 1, 2
),
(
    'Sara', 'Hassan', 'Mahmoud', 'Female', '1990-07-22', '29007220123456', 'SSN002',
    '01022222222', 'sara.nurse@hospital.com',
    'Cairo', 'Heliopolis', 'Korba', 'Hospital Street', '7',
    '2018-09-10', 'Bachelor of Nursing', TRUE,
    12000, 1500, 500, 13000,
    1, NULL, 2, 3
),
(
    'Mona', 'Adel', 'Youssef', 'Female', '1988-11-10', '28811100123456', 'SSN003',
    '01033333333', 'mona.hr@hospital.com',
    'Giza', 'Dokki', 'Tahrir', 'HR Street', '4',
    '2017-02-15', 'Business Administration', TRUE,
    15000, 1000, 300, 15700,
    3, NULL, 5, 5
),
(
    'Omar', 'Samir', 'Fathy', 'Male', '1982-05-19', '28205190123456', 'SSN004',
    '01044444444', 'omar.neuro@hospital.com',
    'Cairo', 'Maadi', 'Degla', 'Clinic Street', '22',
    '2014-01-20', 'MD Neurology', TRUE,
    32000, 6000, 1500, 36500,
    2, 4, 4, 2
),
(
    'Khaled', 'Nabil', 'Sayed', 'Male', '1995-09-30', '29509300123456', 'SSN005',
    '01055555555', 'khaled.sales@hospital.com',
    'Cairo', 'New Cairo', 'Fifth Settlement', 'Sales Street', '10',
    '2021-05-05', 'Commerce Degree', FALSE,
    10000, 2000, 200, 11800,
    4, NULL, 6, 4
);

-- ============================================================
-- 7. SHIFTS
-- ============================================================

INSERT INTO shifts
(shift_type, shift_start_date, shift_end_date, working_hours)
VALUES
('Morning', '2026-05-01 08:00:00', '2026-05-01 16:00:00', 8),
('Evening', '2026-05-01 16:00:00', '2026-05-02 00:00:00', 8),
('Night', '2026-05-02 00:00:00', '2026-05-02 08:00:00', 8);

-- ============================================================
-- 8. EMPLOYEE_SHIFTS
-- ============================================================

INSERT INTO employee_shifts
(employee_id, shift_id)
VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 1),
(5, 2);

-- ============================================================
-- 9. CLINICS
-- ============================================================

INSERT INTO clinics
(clinic_name, clinic_location, room_number, department_id, specialization_id)
VALUES
('Cardiology Clinic A', 'First Floor - East Wing', '101', 1, 1),
('Cardiology Surgery Clinic', 'Second Floor - Surgery Wing', '201', 1, 3),
('Neurology Clinic A', 'First Floor - West Wing', '105', 2, 4),
('Radiology Clinic', 'Ground Floor - Imaging Area', 'G05', 5, 5);

-- ============================================================
-- 10. CLINIC_EMPLOYEES
-- ============================================================

INSERT INTO clinic_employees
(clinic_id, employee_id, assigned_from, assigned_to)
VALUES
(1, 1, '2026-01-01', NULL),
(1, 2, '2026-01-01', NULL),
(2, 1, '2026-02-01', NULL),
(3, 4, '2026-01-15', NULL),
(4, 2, '2026-03-01', NULL);

-- ============================================================
-- 11. PATIENTS
-- Do NOT insert full_name because it is generated automatically.
-- ============================================================

INSERT INTO patients
(
    fname, lname, surname, gender, date_of_birth, national_id,
    government, city, area, street, building,
    insurance, marital_status, blood_type
)
VALUES
(
    'Mahmoud', 'Ibrahim', 'Hassan', 'Male', '1975-04-12', '27504120123456',
    'Cairo', 'Nasr City', 'Makram Ebeid', 'Patient Street', '15',
    TRUE, 'Married', 'A+'
),
(
    'Laila', 'Mostafa', 'Ali', 'Female', '1992-08-25', '29208250123456',
    'Giza', 'Mohandessin', 'Gameat El Dewal', 'Clinic Road', '8',
    FALSE, 'Single', 'O-'
),
(
    'Youssef', 'Kamal', 'Sayed', 'Male', '2000-01-05', '30001050123456',
    'Alexandria', 'Smouha', 'Victor Emanuel', 'Sea Street', '20',
    TRUE, 'Single', 'B+'
);

-- ============================================================
-- 12. PATIENT_PHONES
-- ============================================================

INSERT INTO patient_phones
(patient_id, phone)
VALUES
(1, '01111111111'),
(1, '01211111111'),
(2, '01122222222'),
(3, '01133333333');

-- ============================================================
-- 13. APPOINTMENTS
-- ============================================================

INSERT INTO appointments
(patient_id, clinic_id, doctor_id, appointment_date, appointment_time, appointment_status)
VALUES
(1, 1, 1, '2026-05-05', '10:00:00', 'Scheduled'),
(2, 3, 4, '2026-05-06', '11:30:00', 'Scheduled'),
(3, 1, 1, '2026-05-07', '09:15:00', 'Completed');

-- ============================================================
-- 14. VISITS
-- ============================================================

INSERT INTO visits
(patient_id, appointment_id, clinic_id, doctor_id, visit_date, visit_time, description)
VALUES
(3, 3, 1, 1, '2026-05-07', '09:30:00', 'Patient visited for chest pain examination.'),
(1, 1, 1, 1, '2026-05-05', '10:15:00', 'Regular cardiology checkup.'),
(2, 2, 3, 4, '2026-05-06', '11:45:00', 'Patient reported headache and dizziness.');

-- ============================================================
-- 15. DIAGNOSIS_CATEGORIES
-- ============================================================

INSERT INTO diagnosis_categories
(diagnosis_category_name)
VALUES
('Cardiac Disease'),
('Neurological Disease'),
('General Illness');

-- ============================================================
-- 16. DIAGNOSES
-- ============================================================

INSERT INTO diagnoses
(diagnosis_category_id, diagnosis_name, diagnosis_description)
VALUES
(1, 'Hypertension', 'High blood pressure condition.'),
(1, 'Arrhythmia', 'Irregular heartbeat.'),
(2, 'Migraine', 'Severe recurring headache.'),
(3, 'Flu', 'Common viral infection.');

-- ============================================================
-- 17. PATIENT_DIAGNOSES
-- ============================================================

INSERT INTO patient_diagnoses
(patient_id, visit_id, diagnosis_id, doctor_id, diagnosis_date, description)
VALUES
(1, 2, 1, 1, '2026-05-05', 'Blood pressure was high during examination.'),
(2, 3, 3, 4, '2026-05-06', 'Migraine symptoms detected.'),
(3, 1, 2, 1, '2026-05-07', 'Irregular heartbeat noticed.');

-- ============================================================
-- 18. SURGERIES
-- ============================================================

INSERT INTO surgeries
(surgery_name, surgery_desc)
VALUES
('Open Heart Surgery', 'Major cardiac surgery operation.'),
('Appendectomy', 'Surgical removal of appendix.'),
('Brain Tumor Removal', 'Neurological surgery for tumor removal.');

-- ============================================================
-- 19. PATIENT_SURGERIES
-- ============================================================

INSERT INTO patient_surgeries
(patient_id, surgery_id, doctor_id, visit_id, surgery_date, surgery_num, need_surgery, notes)
VALUES
(1, 1, 1, 2, '2026-06-01', 1, TRUE, 'Patient may need open heart surgery after further tests.'),
(2, 3, 4, 3, NULL, 1, FALSE, 'No surgery needed currently.'),
(3, 1, 1, 1, '2026-06-15', 1, TRUE, 'Surgery recommended after cardiac evaluation.');

-- ============================================================
-- 20. MEDICINES
-- ============================================================

INSERT INTO medicines
(
    commercial_name, medical_name, manufacturing_company,
    production_date, expire_date, quantity,
    commercial_price, vendor_price, profit
)
VALUES
(
    'Concor 5mg', 'Bisoprolol', 'Merck',
    '2025-01-01', '2027-01-01', 200,
    80, 60, 20
),
(
    'Panadol Extra', 'Paracetamol + Caffeine', 'GSK',
    '2025-03-01', '2027-03-01', 500,
    45, 30, 15
),
(
    'Aspirin Protect', 'Aspirin', 'Bayer',
    '2025-02-01', '2027-02-01', 300,
    70, 50, 20
),
(
    'Migramax', 'Migraine Treatment', 'Pharma Inc',
    '2025-04-01', '2027-04-01', 150,
    120, 90, 30
);

-- ============================================================
-- 21. PRESCRIPTIONS
-- ============================================================

INSERT INTO prescriptions
(patient_id, visit_id, doctor_id, medicine_id, prescription_date, dosage, duration, instructions)
VALUES
(1, 2, 1, 1, '2026-05-05', '1 tablet daily', '30 days', 'Take after breakfast.'),
(1, 2, 1, 3, '2026-05-05', '1 tablet daily', '14 days', 'Take after lunch.'),
(2, 3, 4, 4, '2026-05-06', '1 tablet when needed', '7 days', 'Use only during migraine attack.'),
(3, 1, 1, 3, '2026-05-07', '1 tablet daily', '21 days', 'Take with water.');

-- ============================================================
-- 22. PAYMENTS
-- ============================================================

INSERT INTO payments
(patient_id, payment_method, payment_cost, payment_date, payment_time, payment_status, description)
VALUES
(1, 'Cash', 500.00, '2026-05-05', '10:30:00', 'Paid', 'Cardiology consultation payment.'),
(2, 'Card', 700.00, '2026-05-06', '12:00:00', 'Paid', 'Neurology consultation payment.'),
(3, 'Insurance', 1000.00, '2026-05-07', '10:00:00', 'Pending', 'Insurance claim pending approval.');

-- ============================================================
-- 23. BILLS
-- ============================================================

INSERT INTO bills
(
    patient_id, visit_id, payment_id, bill_type, service_name,
    actual_cost, transfer_fees, total_cost,
    bill_date, bill_time, description
)
VALUES
(
    1, 2, 1, 'Consultation', 'Cardiology Consultation',
    500, 0, 500,
    '2026-05-05', '10:35:00', 'Consultation bill.'
),
(
    2, 3, 2, 'Consultation', 'Neurology Consultation',
    650, 50, 700,
    '2026-05-06', '12:05:00', 'Consultation bill with card transfer fees.'
),
(
    3, 1, 3, 'Test', 'ECG Test',
    1000, 0, 1000,
    '2026-05-07', '10:05:00', 'ECG test bill.'
);

-- ============================================================
-- 24. BILL_ITEMS
-- ============================================================

INSERT INTO bill_items
(bill_id, item_type, item_id, description, quantity, unit_cost, total_cost)
VALUES
(1, 'Service', NULL, 'Cardiology consultation', 1, 500, 500),
(2, 'Service', NULL, 'Neurology consultation', 1, 650, 650),
(2, 'Service', NULL, 'Card payment transfer fees', 1, 50, 50),
(3, 'Service', NULL, 'ECG test', 1, 1000, 1000);

-- ============================================================
-- 25. VENDORS
-- ============================================================

INSERT INTO vendors
(vendor_name, email, phone, government, city, area, street, building)
VALUES
(
    'MedSupply Egypt',
    'contact@medsupply.com',
    '01066666666',
    'Cairo', 'Nasr City', 'Makram Ebeid', 'Vendor Street', '3'
),
(
    'Pharma Distribution Co.',
    'sales@pharmadistribution.com',
    '01077777777',
    'Giza', 'Dokki', 'Main Area', 'Distribution Street', '9'
);

-- ============================================================
-- 26. STORES
-- ============================================================

INSERT INTO stores
(store_name, government, city, area, street, building)
VALUES
(
    'Main Hospital Store',
    'Cairo', 'Nasr City', 'Hospital Area', 'Main Store Street', '1'
),
(
    'Pharmacy Store',
    'Cairo', 'Nasr City', 'Pharmacy Area', 'Medicine Street', '2'
);

-- ============================================================
-- 27. PRODUCTS
-- ============================================================

INSERT INTO products
(
    product_name, product_type, commercial_name,
    production_date, expire_date, quantity,
    commercial_price, net_cost, status
)
VALUES
(
    'Surgical Gloves',
    'Medical Supply',
    'SafeGlove',
    '2025-01-01', '2028-01-01', 1000,
    5, 3, 'Available'
),
(
    'Syringe 5ml',
    'Medical Supply',
    'MediSyringe',
    '2025-02-01', '2028-02-01', 2000,
    2, 1, 'Available'
),
(
    'ECG Paper Roll',
    'Medical Equipment Supply',
    'ECGRoll',
    '2025-03-01', '2027-03-01', 100,
    150, 100, 'Available'
);

-- ============================================================
-- 28. VENDOR_PRODUCTS
-- ============================================================

INSERT INTO vendor_products
(vendor_id, product_id, vendor_price)
VALUES
(1, 1, 3),
(1, 2, 1),
(2, 3, 100);

-- ============================================================
-- 29. STORE_PRODUCTS
-- ============================================================

INSERT INTO store_products
(store_id, product_id, quantity)
VALUES
(1, 1, 500),
(1, 2, 1000),
(1, 3, 50),
(2, 1, 200);

-- ============================================================
-- 30. MEDICINES_INVENTORY
-- ============================================================

INSERT INTO medicines_inventory
(store_id, medicine_id, quantity)
VALUES
(2, 1, 100),
(2, 2, 300),
(2, 3, 150),
(2, 4, 80);

-- ============================================================
-- 31. HOSPITAL_FACILITIES
-- ============================================================

INSERT INTO hospital_facilities
(
    facility_number, facility_name, floor, building_number,
    base_cost, cost_per_hour, cost_per_day, status
)
VALUES
(
    'FAC-001', 'Operation Room 1', 'Second Floor', 'B1',
    5000, 1000, 10000, 'Available'
),
(
    'FAC-002', 'ICU Room 1', 'Third Floor', 'B1',
    3000, 500, 7000, 'Occupied'
),
(
    'FAC-003', 'X-Ray Room', 'Ground Floor', 'B2',
    1000, 300, 3000, 'Available'
);

-- ============================================================
-- 32. FACILITY_ASSIGNMENTS
-- ============================================================

INSERT INTO facility_assignments
(
    facility_id, patient_id, employee_id, visit_id,
    assigned_from, assigned_to
)
VALUES
(
    1, 1, 1, 2,
    '2026-06-01 08:00:00', '2026-06-01 12:00:00'
),
(
    2, 3, 1, 1,
    '2026-05-07 10:00:00', NULL
),
(
    3, 3, 1, 1,
    '2026-05-07 09:45:00', '2026-05-07 10:15:00'
);

-- ============================================================
-- 33. ROLE_ACCESS
-- ============================================================

INSERT INTO role_access
(role_id, access_name)
VALUES
(1, 'Manage Users'),
(1, 'Manage Departments'),
(1, 'View Reports'),
(2, 'View Patients'),
(2, 'Create Diagnosis'),
(2, 'Create Prescription'),
(3, 'View Patients'),
(3, 'Update Patient Vital Signs'),
(4, 'Create Appointment'),
(4, 'View Appointments'),
(5, 'Manage Employees'),
(6, 'Manage Medicines'),
(7, 'Manage Store Inventory');

-- ============================================================
-- END OF SEED DATA
-- ============================================================
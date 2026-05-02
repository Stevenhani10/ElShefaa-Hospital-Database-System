-- ============================================================
-- Hospital Management System ORM Schema
-- Generated from ERD
-- DBMS: PostgreSQL
-- ============================================================

-- ============================================================
-- 1. DEPARTMENTS / SPECIALIZATIONS / JOBS / ROLES
-- ============================================================

CREATE TABLE departments (
    department_id      BIGSERIAL PRIMARY KEY,
    department_name    VARCHAR(150) NOT NULL UNIQUE,
    department_type    VARCHAR(50) NOT NULL, -- Medical, HR, Sales, Finance, etc.
    created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE specialization_categories (
    specialization_category_id BIGSERIAL PRIMARY KEY,
    department_id              BIGINT NOT NULL,
    specialization_category_name VARCHAR(150) NOT NULL,

    CONSTRAINT fk_spec_category_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uq_spec_category_per_department
        UNIQUE (department_id, specialization_category_name)
);

CREATE TABLE specializations (
    specialization_id          BIGSERIAL PRIMARY KEY,
    specialization_category_id BIGINT NOT NULL,
    specialization_name        VARCHAR(150) NOT NULL,

    CONSTRAINT fk_specialization_category
        FOREIGN KEY (specialization_category_id)
        REFERENCES specialization_categories(specialization_category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uq_specialization_per_category
        UNIQUE (specialization_category_id, specialization_name)
);

CREATE TABLE jobs (
    job_id        BIGSERIAL PRIMARY KEY,
    department_id BIGINT NOT NULL,
    job_title     VARCHAR(150) NOT NULL,

    CONSTRAINT fk_job_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uq_job_per_department
        UNIQUE (department_id, job_title)
);

CREATE TABLE roles (
    role_id   BIGSERIAL PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL UNIQUE
);

-- ============================================================
-- 2. EMPLOYEES / SHIFTS / CLINICS
-- ============================================================

CREATE TABLE employees (
    employee_id       BIGSERIAL PRIMARY KEY,

    fname             VARCHAR(100) NOT NULL,
    lname             VARCHAR(100) NOT NULL,
    surname           VARCHAR(100),
    full_name         VARCHAR(255) GENERATED ALWAYS AS 
                      (fname || ' ' || lname || COALESCE(' ' || surname, '')) STORED,

    gender            VARCHAR(20),
    date_of_birth     DATE,
    age               INT,
    national_id       VARCHAR(50) UNIQUE,
    ssn               VARCHAR(50) UNIQUE,

    phone             VARCHAR(30),
    email             VARCHAR(150) UNIQUE,

    government        VARCHAR(100),
    city              VARCHAR(100),
    area              VARCHAR(100),
    street            VARCHAR(150),
    building          VARCHAR(50),

    hire_date         DATE NOT NULL DEFAULT CURRENT_DATE,
    degree            VARCHAR(150),
    insurance         BOOLEAN DEFAULT FALSE,

    fixed_salary      NUMERIC(12,2) DEFAULT 0 CHECK (fixed_salary >= 0),
    bonus             NUMERIC(12,2) DEFAULT 0 CHECK (bonus >= 0),
    deduction         NUMERIC(12,2) DEFAULT 0 CHECK (deduction >= 0),
    net_salary        NUMERIC(12,2),

    department_id     BIGINT,
    specialization_id BIGINT,
    job_id            BIGINT,
    role_id           BIGINT,

    CONSTRAINT fk_employee_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_employee_specialization
        FOREIGN KEY (specialization_id)
        REFERENCES specializations(specialization_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_employee_job
        FOREIGN KEY (job_id)
        REFERENCES jobs(job_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_employee_role
        FOREIGN KEY (role_id)
        REFERENCES roles(role_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE TABLE shifts (
    shift_id        BIGSERIAL PRIMARY KEY,
    shift_type      VARCHAR(50) NOT NULL, -- Morning, Evening, Night, etc.
    shift_start_date TIMESTAMP NOT NULL,
    shift_end_date   TIMESTAMP NOT NULL,
    working_hours    NUMERIC(5,2),

    CONSTRAINT chk_shift_date
        CHECK (shift_end_date > shift_start_date)
);

CREATE TABLE employee_shifts (
    employee_id BIGINT NOT NULL,
    shift_id    BIGINT NOT NULL,

    PRIMARY KEY (employee_id, shift_id),

    CONSTRAINT fk_employee_shift_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_employee_shift_shift
        FOREIGN KEY (shift_id)
        REFERENCES shifts(shift_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE clinics (
    clinic_id        BIGSERIAL PRIMARY KEY,
    clinic_name      VARCHAR(150) NOT NULL,
    clinic_location  VARCHAR(255),
    room_number      VARCHAR(50),
    department_id    BIGINT,
    specialization_id BIGINT,

    CONSTRAINT fk_clinic_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_clinic_specialization
        FOREIGN KEY (specialization_id)
        REFERENCES specializations(specialization_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE TABLE clinic_employees (
    clinic_id   BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    assigned_from DATE DEFAULT CURRENT_DATE,
    assigned_to   DATE,

    PRIMARY KEY (clinic_id, employee_id),

    CONSTRAINT fk_clinic_employee_clinic
        FOREIGN KEY (clinic_id)
        REFERENCES clinics(clinic_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_clinic_employee_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ============================================================
-- 3. PATIENTS / APPOINTMENTS / VISITS
-- ============================================================

CREATE TABLE patients (
    patient_id       BIGSERIAL PRIMARY KEY,

    fname            VARCHAR(100) NOT NULL,
    lname            VARCHAR(100) NOT NULL,
    surname          VARCHAR(100),
    full_name        VARCHAR(255) GENERATED ALWAYS AS 
                     (fname || ' ' || lname || COALESCE(' ' || surname, '')) STORED,

    gender           VARCHAR(20),
    date_of_birth    DATE,
    national_id      VARCHAR(50) UNIQUE,

    government       VARCHAR(100),
    city             VARCHAR(100),
    area             VARCHAR(100),
    street           VARCHAR(150),
    building         VARCHAR(50),

    insurance        BOOLEAN DEFAULT FALSE,
    marital_status   VARCHAR(50),
    blood_type       VARCHAR(10),

    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE patient_phones (
    patient_phone_id BIGSERIAL PRIMARY KEY,
    patient_id       BIGINT NOT NULL,
    phone            VARCHAR(30) NOT NULL,

    CONSTRAINT fk_patient_phone_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT uq_patient_phone
        UNIQUE (patient_id, phone)
);

CREATE TABLE appointments (
    appointment_id    BIGSERIAL PRIMARY KEY,
    patient_id        BIGINT NOT NULL,
    clinic_id         BIGINT,
    doctor_id         BIGINT,
    appointment_date  DATE NOT NULL,
    appointment_time  TIME NOT NULL,
    appointment_status VARCHAR(50) DEFAULT 'Scheduled',

    CONSTRAINT fk_appointment_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_appointment_clinic
        FOREIGN KEY (clinic_id)
        REFERENCES clinics(clinic_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_appointment_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES employees(employee_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE TABLE visits (
    visit_id       BIGSERIAL PRIMARY KEY,
    patient_id     BIGINT NOT NULL,
    appointment_id BIGINT,
    clinic_id      BIGINT,
    doctor_id      BIGINT,
    visit_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    visit_time     TIME DEFAULT CURRENT_TIME,
    description    TEXT,

    CONSTRAINT fk_visit_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_visit_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_visit_clinic
        FOREIGN KEY (clinic_id)
        REFERENCES clinics(clinic_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_visit_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES employees(employee_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- ============================================================
-- 4. DIAGNOSIS / MEDICAL HISTORY / SURGERY
-- ============================================================

CREATE TABLE diagnosis_categories (
    diagnosis_category_id   BIGSERIAL PRIMARY KEY,
    diagnosis_category_name VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE diagnoses (
    diagnosis_id          BIGSERIAL PRIMARY KEY,
    diagnosis_category_id BIGINT,
    diagnosis_name        VARCHAR(150) NOT NULL,
    diagnosis_description TEXT,

    CONSTRAINT fk_diagnosis_category
        FOREIGN KEY (diagnosis_category_id)
        REFERENCES diagnosis_categories(diagnosis_category_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE TABLE patient_diagnoses (
    patient_diagnosis_id BIGSERIAL PRIMARY KEY,
    patient_id           BIGINT NOT NULL,
    visit_id             BIGINT,
    diagnosis_id         BIGINT NOT NULL,
    doctor_id            BIGINT,
    diagnosis_date       DATE NOT NULL DEFAULT CURRENT_DATE,
    description          TEXT,

    CONSTRAINT fk_patient_diagnosis_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_patient_diagnosis_visit
        FOREIGN KEY (visit_id)
        REFERENCES visits(visit_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_diagnosis_diagnosis
        FOREIGN KEY (diagnosis_id)
        REFERENCES diagnoses(diagnosis_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_patient_diagnosis_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES employees(employee_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE TABLE surgeries (
    surgery_id    BIGSERIAL PRIMARY KEY,
    surgery_name  VARCHAR(150),
    surgery_desc  TEXT
);

CREATE TABLE patient_surgeries (
    patient_surgery_id BIGSERIAL PRIMARY KEY,
    patient_id         BIGINT NOT NULL,
    surgery_id         BIGINT NOT NULL,
    doctor_id          BIGINT,
    visit_id           BIGINT,
    surgery_date       DATE,
    surgery_num        INT,
    need_surgery       BOOLEAN DEFAULT FALSE,
    notes              TEXT,

    CONSTRAINT fk_patient_surgery_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_patient_surgery_surgery
        FOREIGN KEY (surgery_id)
        REFERENCES surgeries(surgery_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_patient_surgery_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES employees(employee_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_surgery_visit
        FOREIGN KEY (visit_id)
        REFERENCES visits(visit_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- ============================================================
-- 5. MEDICINES / PRESCRIPTIONS
-- ============================================================

CREATE TABLE medicines (
    medicine_id            BIGSERIAL PRIMARY KEY,
    commercial_name        VARCHAR(150) NOT NULL,
    medical_name           VARCHAR(150),
    manufacturing_company  VARCHAR(150),
    production_date        DATE,
    expire_date            DATE,
    quantity               INT DEFAULT 0 CHECK (quantity >= 0),
    commercial_price       NUMERIC(12,2) CHECK (commercial_price >= 0),
    vendor_price           NUMERIC(12,2) CHECK (vendor_price >= 0),
    profit                 NUMERIC(12,2),

    CONSTRAINT chk_medicine_expiry
        CHECK (expire_date IS NULL OR production_date IS NULL OR expire_date > production_date)
);

CREATE TABLE prescriptions (
    prescription_id       BIGSERIAL PRIMARY KEY,
    patient_id            BIGINT NOT NULL,
    visit_id              BIGINT,
    doctor_id             BIGINT,
    medicine_id           BIGINT NOT NULL,
    prescription_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    dosage                VARCHAR(150),
    duration              VARCHAR(150),
    instructions          TEXT,

    CONSTRAINT fk_prescription_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_prescription_visit
        FOREIGN KEY (visit_id)
        REFERENCES visits(visit_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_prescription_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES employees(employee_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_prescription_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES medicines(medicine_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ============================================================
-- 6. PAYMENTS / BILLS
-- ============================================================

CREATE TABLE payments (
    payment_id      BIGSERIAL PRIMARY KEY,
    patient_id      BIGINT NOT NULL,
    payment_method  VARCHAR(50) NOT NULL, -- Cash, Card, Transfer, Insurance
    payment_cost    NUMERIC(12,2) NOT NULL CHECK (payment_cost >= 0),
    payment_date    DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_time    TIME DEFAULT CURRENT_TIME,
    payment_status  VARCHAR(50) DEFAULT 'Pending',
    description     TEXT,

    CONSTRAINT fk_payment_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE bills (
    bill_id        BIGSERIAL PRIMARY KEY,
    patient_id     BIGINT NOT NULL,
    visit_id       BIGINT,
    payment_id     BIGINT,
    bill_type      VARCHAR(100),
    service_name   VARCHAR(150),
    actual_cost    NUMERIC(12,2) DEFAULT 0 CHECK (actual_cost >= 0),
    transfer_fees  NUMERIC(12,2) DEFAULT 0 CHECK (transfer_fees >= 0),
    total_cost     NUMERIC(12,2) DEFAULT 0 CHECK (total_cost >= 0),
    bill_date      DATE NOT NULL DEFAULT CURRENT_DATE,
    bill_time      TIME DEFAULT CURRENT_TIME,
    description    TEXT,

    CONSTRAINT fk_bill_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_bill_visit
        FOREIGN KEY (visit_id)
        REFERENCES visits(visit_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_bill_payment
        FOREIGN KEY (payment_id)
        REFERENCES payments(payment_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE TABLE bill_items (
    bill_item_id BIGSERIAL PRIMARY KEY,
    bill_id      BIGINT NOT NULL,
    item_type    VARCHAR(50) NOT NULL, -- Medicine, Surgery, Clinic, Facility, Product, Service
    item_id      BIGINT,
    description  TEXT,
    quantity     INT DEFAULT 1 CHECK (quantity > 0),
    unit_cost    NUMERIC(12,2) NOT NULL CHECK (unit_cost >= 0),
    total_cost   NUMERIC(12,2) NOT NULL CHECK (total_cost >= 0),

    CONSTRAINT fk_bill_item_bill
        FOREIGN KEY (bill_id)
        REFERENCES bills(bill_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ============================================================
-- 7. VENDORS / STORES / PRODUCTS
-- ============================================================

CREATE TABLE vendors (
    vendor_id   BIGSERIAL PRIMARY KEY,
    vendor_name VARCHAR(150) NOT NULL,
    email       VARCHAR(150),
    phone       VARCHAR(30),

    government  VARCHAR(100),
    city        VARCHAR(100),
    area        VARCHAR(100),
    street      VARCHAR(150),
    building    VARCHAR(50)
);

CREATE TABLE stores (
    store_id    BIGSERIAL PRIMARY KEY,
    store_name  VARCHAR(150) NOT NULL,
    government  VARCHAR(100),
    city        VARCHAR(100),
    area        VARCHAR(100),
    street      VARCHAR(150),
    building    VARCHAR(50)
);

CREATE TABLE products (
    product_id       BIGSERIAL PRIMARY KEY,
    product_name     VARCHAR(150) NOT NULL,
    product_type     VARCHAR(100),
    commercial_name  VARCHAR(150),
    production_date  DATE,
    expire_date      DATE,
    quantity         INT DEFAULT 0 CHECK (quantity >= 0),
    commercial_price NUMERIC(12,2) CHECK (commercial_price >= 0),
    net_cost         NUMERIC(12,2) CHECK (net_cost >= 0),
    status           VARCHAR(50),

    CONSTRAINT chk_product_expiry
        CHECK (expire_date IS NULL OR production_date IS NULL OR expire_date > production_date)
);

CREATE TABLE vendor_products (
    vendor_id  BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    vendor_price NUMERIC(12,2) CHECK (vendor_price >= 0),

    PRIMARY KEY (vendor_id, product_id),

    CONSTRAINT fk_vendor_product_vendor
        FOREIGN KEY (vendor_id)
        REFERENCES vendors(vendor_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_vendor_product_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE store_products (
    store_id   BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity   INT DEFAULT 0 CHECK (quantity >= 0),

    PRIMARY KEY (store_id, product_id),

    CONSTRAINT fk_store_product_store
        FOREIGN KEY (store_id)
        REFERENCES stores(store_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_store_product_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE medicines_inventory (
    store_id    BIGINT NOT NULL,
    medicine_id BIGINT NOT NULL,
    quantity    INT DEFAULT 0 CHECK (quantity >= 0),

    PRIMARY KEY (store_id, medicine_id),

    CONSTRAINT fk_medicine_inventory_store
        FOREIGN KEY (store_id)
        REFERENCES stores(store_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_medicine_inventory_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES medicines(medicine_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ============================================================
-- 8. HOSPITAL FACILITIES
-- ============================================================

CREATE TABLE hospital_facilities (
    facility_id        BIGSERIAL PRIMARY KEY,
    facility_number    VARCHAR(50) UNIQUE,
    facility_name      VARCHAR(150) NOT NULL,
    floor              VARCHAR(50),
    building_number    VARCHAR(50),
    base_cost          NUMERIC(12,2) DEFAULT 0 CHECK (base_cost >= 0),
    cost_per_hour      NUMERIC(12,2) DEFAULT 0 CHECK (cost_per_hour >= 0),
    cost_per_day       NUMERIC(12,2) DEFAULT 0 CHECK (cost_per_day >= 0),
    status             VARCHAR(50) DEFAULT 'Available'
);

CREATE TABLE facility_assignments (
    facility_assignment_id BIGSERIAL PRIMARY KEY,
    facility_id            BIGINT NOT NULL,
    patient_id             BIGINT,
    employee_id            BIGINT,
    visit_id               BIGINT,
    assigned_from          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assigned_to            TIMESTAMP,

    CONSTRAINT fk_facility_assignment_facility
        FOREIGN KEY (facility_id)
        REFERENCES hospital_facilities(facility_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_facility_assignment_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_facility_assignment_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_facility_assignment_visit
        FOREIGN KEY (visit_id)
        REFERENCES visits(visit_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT chk_facility_assignment_date
        CHECK (assigned_to IS NULL OR assigned_to > assigned_from)
);

-- ============================================================
-- 9. ACCESS CONTROL
-- ============================================================

CREATE TABLE role_access (
    role_id       BIGINT NOT NULL,
    access_name   VARCHAR(150) NOT NULL,

    PRIMARY KEY (role_id, access_name),

    CONSTRAINT fk_role_access_role
        FOREIGN KEY (role_id)
        REFERENCES roles(role_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ============================================================
-- 10. INDEXES
-- ============================================================

CREATE INDEX idx_employees_department_id
    ON employees(department_id);

CREATE INDEX idx_employees_specialization_id
    ON employees(specialization_id);

CREATE INDEX idx_employees_job_id
    ON employees(job_id);

CREATE INDEX idx_employees_role_id
    ON employees(role_id);

CREATE INDEX idx_clinics_department_id
    ON clinics(department_id);

CREATE INDEX idx_clinics_specialization_id
    ON clinics(specialization_id);

CREATE INDEX idx_patients_national_id
    ON patients(national_id);

CREATE INDEX idx_appointments_patient_id
    ON appointments(patient_id);

CREATE INDEX idx_appointments_doctor_id
    ON appointments(doctor_id);

CREATE INDEX idx_appointments_clinic_id
    ON appointments(clinic_id);

CREATE INDEX idx_visits_patient_id
    ON visits(patient_id);

CREATE INDEX idx_visits_doctor_id
    ON visits(doctor_id);

CREATE INDEX idx_patient_diagnoses_patient_id
    ON patient_diagnoses(patient_id);

CREATE INDEX idx_patient_diagnoses_diagnosis_id
    ON patient_diagnoses(diagnosis_id);

CREATE INDEX idx_patient_surgeries_patient_id
    ON patient_surgeries(patient_id);

CREATE INDEX idx_prescriptions_patient_id
    ON prescriptions(patient_id);

CREATE INDEX idx_prescriptions_medicine_id
    ON prescriptions(medicine_id);

CREATE INDEX idx_payments_patient_id
    ON payments(patient_id);

CREATE INDEX idx_bills_patient_id
    ON bills(patient_id);

CREATE INDEX idx_bills_payment_id
    ON bills(payment_id);

CREATE INDEX idx_products_product_type
    ON products(product_type);

CREATE INDEX idx_products_status
    ON products(status);

CREATE INDEX idx_facility_assignments_facility_id
    ON facility_assignments(facility_id);

CREATE INDEX idx_facility_assignments_patient_id
    ON facility_assignments(patient_id);
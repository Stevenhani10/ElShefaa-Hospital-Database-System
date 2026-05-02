--Triggers 
--Triggers are useful when you want the database to automatically react
-- when INSERT, UPDATE, or DELETE happens.

-- 1. Trigger: Auto-Calculate Employee Net Salary
-- When you insert or update an employee, the database automatically calculates net_salary

-- ============================================================
-- Trigger 1: Auto Calculate Employee Net Salary
-- ============================================================
--This is the function that the trigger will execute.
CREATE OR REPLACE FUNCTION trg_fn_calculate_employee_net_salary()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.net_salary :=
        COALESCE(NEW.fixed_salary, 0)
        + COALESCE(NEW.bonus, 0)
        - COALESCE(NEW.deduction, 0);

    RETURN NEW;
END;
$$;
---this is the trigger itself 
CREATE OR REPLACE TRIGGER trg_calculate_employee_net_salary
BEFORE INSERT OR UPDATE OF fixed_salary, bonus, deduction
ON employees
--for each row to work with new and old values 
FOR EACH ROW
EXECUTE FUNCTION trg_fn_calculate_employee_net_salary();



-----------------------------------------------------------------------------


-- 2. Trigger: Auto-Calculate Bill Total Cost

-- When you insert or update a bill, the database automatically calculates total_cost 

-- ============================================================
-- Trigger 2: Auto Calculate Bill Total Cost
-- ============================================================

CREATE OR REPLACE FUNCTION trg_fn_calculate_bill_total_cost()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.total_cost :=
        COALESCE(NEW.actual_cost, 0)
        + COALESCE(NEW.transfer_fees, 0);

    RETURN NEW;
END;
$$;


--Trigger itself that will use the function

CREATE OR REPLACE TRIGGER trg_calculate_bill_total_cost
BEFORE INSERT OR UPDATE OF actual_cost, transfer_fees
ON bills
FOR EACH ROW
EXECUTE FUNCTION trg_fn_calculate_bill_total_cost();



--test case 

INSERT INTO bills (
    patient_id,
    visit_id,
    payment_id,
    bill_type,
    service_name,
    actual_cost,
    transfer_fees,
    description
)
VALUES (
    1,
    2,
    NULL,
    'Test',
    'Blood Test',
    800,
    50,
    'Blood test bill'
);

SELECT
    bill_id,
    patient_id,
    service_name,
    actual_cost,
    transfer_fees,
    total_cost
FROM bills
WHERE service_name = 'Blood Test';


--------------------------------------------------------------
-- 3) Trigger: Prevent Doctor Double Booking
-- This trigger prevents assigning the same doctor to two active appointments
-- at the same date and time.



-- One doctor cannot have two active appointments at the same time.



-- ============================================================
-- Trigger 3: Prevent Doctor Double Booking
-- ============================================================

CREATE OR REPLACE FUNCTION trg_fn_prevent_doctor_double_booking()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_existing_count INT;
BEGIN
    SELECT COUNT(*)
    INTO v_existing_count
    FROM appointments
    WHERE doctor_id = NEW.doctor_id
      AND appointment_date = NEW.appointment_date
      AND appointment_time = NEW.appointment_time
      AND appointment_status <> 'Cancelled'
      AND appointment_id <> COALESCE(NEW.appointment_id, -1);

    IF v_existing_count > 0 THEN
        RAISE EXCEPTION
            'Doctor % already has an appointment on % at %',
            NEW.doctor_id,
            NEW.appointment_date,
            NEW.appointment_time;
    END IF;

    RETURN NEW;
END;
$$;


CREATE OR REPLACE TRIGGER trg_prevent_doctor_double_booking
BEFORE INSERT OR UPDATE OF doctor_id, appointment_date, appointment_time, appointment_status
ON appointments
FOR EACH ROW
EXECUTE FUNCTION trg_fn_prevent_doctor_double_booking();


INSERT INTO appointments (
    patient_id,
    clinic_id,
    doctor_id,
    appointment_date,
    appointment_time,
    appointment_status
)
VALUES (
    2,
    1,
    1,
    '2026-05-05',
    '10:00:00',
    'Scheduled'
);


----------------------------------------------------------------

-- 4. Trigger: Prevent Clinic Double Booking
-- One clinic room cannot have two active appointments at the same time.
-- ============================================================
-- Trigger 4: Prevent Clinic Double Booking
-- ============================================================

CREATE OR REPLACE FUNCTION trg_fn_prevent_clinic_double_booking()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_existing_count INT;
BEGIN
    SELECT COUNT(*)
    INTO v_existing_count
    FROM appointments
    WHERE clinic_id = NEW.clinic_id
      AND appointment_date = NEW.appointment_date
      AND appointment_time = NEW.appointment_time
      AND appointment_status <> 'Cancelled'
      AND appointment_id <> COALESCE(NEW.appointment_id, -1);

    IF v_existing_count > 0 THEN
        RAISE EXCEPTION
            'Clinic % is already booked on % at %',
            NEW.clinic_id,
            NEW.appointment_date,
            NEW.appointment_time;
    END IF;

    RETURN NEW;
END;
$$;

-- % sign used to take the first value first like NEW.clinic_id,
-- and second one will be NEW.appointment_date, last one NEW.appointment_time

CREATE OR REPLACE TRIGGER trg_prevent_clinic_double_booking
BEFORE INSERT OR UPDATE OF clinic_id, appointment_date, appointment_time, appointment_status
ON appointments
FOR EACH ROW
EXECUTE FUNCTION trg_fn_prevent_clinic_double_booking();

---test case 
INSERT INTO appointments (
    patient_id,
    clinic_id,
    doctor_id,
    appointment_date,
    appointment_time,
    appointment_status
)
VALUES (
    2,
    1,
    4,
    '2026-05-05',
    '10:00:00',
    'Scheduled'
);


----------------------------------------------------------------------------

-- 5. Trigger: Prevent Negative Medicine Inventory

-- This trigger prevents medicine quantity from becoming negative in medicines_inventory.





-- ============================================================
-- Trigger 5: Prevent Negative Medicine Inventory
-- ============================================================

CREATE OR REPLACE FUNCTION trg_fn_prevent_negative_medicine_inventory()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.quantity < 0 THEN
        RAISE EXCEPTION
            'Medicine inventory quantity cannot be negative. Store: %, Medicine: %',
            NEW.store_id,
            NEW.medicine_id;
    END IF;

    RETURN NEW;
END;
$$;



CREATE OR REPLACE TRIGGER trg_prevent_negative_medicine_inventory
BEFORE INSERT OR UPDATE OF quantity
ON medicines_inventory
FOR EACH ROW
EXECUTE FUNCTION trg_fn_prevent_negative_medicine_inventory();


UPDATE medicines_inventory
SET quantity = -5
WHERE store_id = 2
  AND medicine_id = 1;




------------------------------------------------------------------------------
-- 6. Trigger: Prevent Expired Medicine Prescription

-- This trigger prevents doctors from prescribing expired medicine.

-- ============================================================
-- Trigger 6: Prevent Expired Medicine Prescription
-- ============================================================

CREATE OR REPLACE FUNCTION trg_fn_prevent_expired_medicine_prescription()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_expire_date DATE;
    v_medicine_name VARCHAR;
BEGIN
    SELECT expire_date, commercial_name
    INTO v_expire_date, v_medicine_name
    FROM medicines
    WHERE medicine_id = NEW.medicine_id;

    IF v_expire_date IS NOT NULL
       AND v_expire_date < CURRENT_DATE THEN

        RAISE EXCEPTION
            'Cannot prescribe expired medicine: % expired on %',
            v_medicine_name,
            v_expire_date;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_prevent_expired_medicine_prescription
BEFORE INSERT OR UPDATE OF medicine_id
ON prescriptions
FOR EACH ROW
EXECUTE FUNCTION trg_fn_prevent_expired_medicine_prescription();

--Test Case
-- making an expired medicine 
UPDATE medicines
SET expire_date = CURRENT_DATE - INTERVAL '1 day'
WHERE medicine_id = 1;



INSERT INTO prescriptions (
    patient_id,
    visit_id,
    doctor_id,
    medicine_id,
    prescription_date,
    dosage,
    duration,
    instructions
)
VALUES (
    1,
    2,
    1,
    1,
    CURRENT_DATE,
    '1 tablet daily',
    '7 days',
    'Take after breakfast'
);

------------------------------------------------------------------------
-- 7. Trigger: Prevent Visit Before Appointment Date

-- This trigger prevents creating a visit before its appointment date.



-- ============================================================
-- Trigger 7: Prevent Visit Before Appointment Date
-- ============================================================

CREATE OR REPLACE FUNCTION trg_fn_prevent_visit_before_appointment()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_appointment_date DATE;
BEGIN
    IF NEW.appointment_id IS NOT NULL THEN

        SELECT appointment_date
        INTO v_appointment_date
        FROM appointments
        WHERE appointment_id = NEW.appointment_id;

        IF v_appointment_date IS NOT NULL
           AND NEW.visit_date < v_appointment_date THEN

            RAISE EXCEPTION
                'Visit date % cannot be before appointment date %',
                NEW.visit_date,
                v_appointment_date;
        END IF;

    END IF;

    RETURN NEW;
END;
$$;




CREATE OR REPLACE TRIGGER trg_prevent_visit_before_appointment
BEFORE INSERT OR UPDATE OF appointment_id, visit_date
ON visits
FOR EACH ROW
EXECUTE FUNCTION trg_fn_prevent_visit_before_appointment();








INSERT INTO visits (
    patient_id,
    appointment_id,
    clinic_id,
    doctor_id,
    visit_date,
    visit_time,
    description
)
VALUES (
    1,
    1,
    1,
    1,
    '2026-01-01',
    '10:00:00',
    'Invalid visit before appointment date.'
);







------------------------------------------------------------

-- 8. Trigger: Audit Employee Salary Changes




-- ============================================================
-- Audit Table: Employee Salary Changes
-- ============================================================

CREATE TABLE IF NOT EXISTS employee_salary_audit (
    audit_id        BIGSERIAL PRIMARY KEY,
    employee_id     BIGINT,
    old_fixed_salary NUMERIC(12,2),
    new_fixed_salary NUMERIC(12,2),
    old_bonus        NUMERIC(12,2),
    new_bonus        NUMERIC(12,2),
    old_deduction    NUMERIC(12,2),
    new_deduction    NUMERIC(12,2),
    old_net_salary   NUMERIC(12,2),
    new_net_salary   NUMERIC(12,2),
    changed_by       VARCHAR(100),
    changed_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);




-- ============================================================
-- Trigger 8: Audit Employee Salary Changes
-- ============================================================

CREATE OR REPLACE FUNCTION trg_fn_audit_employee_salary_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF COALESCE(OLD.fixed_salary, 0) <> COALESCE(NEW.fixed_salary, 0)
       OR COALESCE(OLD.bonus, 0) <> COALESCE(NEW.bonus, 0)
       OR COALESCE(OLD.deduction, 0) <> COALESCE(NEW.deduction, 0)
       OR COALESCE(OLD.net_salary, 0) <> COALESCE(NEW.net_salary, 0)
    THEN
        INSERT INTO employee_salary_audit (
            employee_id,
            old_fixed_salary,
            new_fixed_salary,
            old_bonus,
            new_bonus,
            old_deduction,
            new_deduction,
            old_net_salary,
            new_net_salary,
            changed_by,
            changed_at
        )
        VALUES (
            OLD.employee_id,
            OLD.fixed_salary,
            NEW.fixed_salary,
            OLD.bonus,
            NEW.bonus,
            OLD.deduction,
            NEW.deduction,
            OLD.net_salary,
            NEW.net_salary,
            CURRENT_USER,
            CURRENT_TIMESTAMP
        );
    END IF;

    RETURN NEW;
END;
$$;


CREATE OR REPLACE TRIGGER trg_audit_employee_salary_changes
AFTER UPDATE OF fixed_salary, bonus, deduction, net_salary
ON employees
FOR EACH ROW
EXECUTE FUNCTION trg_fn_audit_employee_salary_changes();






UPDATE employees
SET fixed_salary = 45000,
    bonus = 6000,
    deduction = 2500
WHERE employee_id = 1;

SELECT *
FROM employee_salary_audit
WHERE employee_id = 1
ORDER BY changed_at DESC;






-------------------------------------------------------------------------------
-- 9. Trigger: Audit Payment Status Changes



-- This trigger records changes when a payment status changes, for example:

-- Pending → Paid
-- Pending → Failed
-- Paid → Refunded



-- ============================================================
-- Audit Table: Payment Status Changes
-- ============================================================

CREATE TABLE IF NOT EXISTS payment_status_audit (
    audit_id          BIGSERIAL PRIMARY KEY,
    payment_id        BIGINT,
    patient_id        BIGINT,
    old_payment_status VARCHAR(50),
    new_payment_status VARCHAR(50),
    payment_cost      NUMERIC(12,2),
    changed_by        VARCHAR(100),
    changed_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);











-- ============================================================
-- Trigger 9: Audit Payment Status Changes
-- ============================================================

CREATE OR REPLACE FUNCTION trg_fn_audit_payment_status_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF COALESCE(OLD.payment_status, '') <> COALESCE(NEW.payment_status, '') THEN

        INSERT INTO payment_status_audit (
            payment_id,
            patient_id,
            old_payment_status,
            new_payment_status,
            payment_cost,
            changed_by,
            changed_at
        )
        VALUES (
            OLD.payment_id,
            OLD.patient_id,
            OLD.payment_status,
            NEW.payment_status,
            NEW.payment_cost,
            CURRENT_USER,
            CURRENT_TIMESTAMP
        );

    END IF;

    RETURN NEW;
END;
$$;


CREATE OR REPLACE TRIGGER trg_audit_payment_status_changes
AFTER UPDATE OF payment_status
ON payments
FOR EACH ROW
EXECUTE FUNCTION trg_fn_audit_payment_status_changes();


UPDATE payments
SET payment_status = 'Paid'
WHERE payment_id = 3;

SELECT *
FROM payment_status_audit
WHERE payment_id = 3
ORDER BY changed_at DESC;




---------------------------------------------------------------------
-- 10. Trigger: Prevent Deleting Patients With Medical History

-- This trigger prevents deleting a patient 
-- if the patient already has visits, diagnoses, bills, or payments.





-- ============================================================
-- Trigger 10: Prevent Deleting Patients With Medical History
-- ============================================================

CREATE OR REPLACE FUNCTION trg_fn_prevent_patient_delete_with_history()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_history_count INT;
BEGIN
    SELECT
        (
            SELECT COUNT(*) FROM visits WHERE patient_id = OLD.patient_id
        )
        +
        (
            SELECT COUNT(*) FROM patient_diagnoses WHERE patient_id = OLD.patient_id
        )
        +
        (
            SELECT COUNT(*) FROM prescriptions WHERE patient_id = OLD.patient_id
        )
        +
        (
            SELECT COUNT(*) FROM bills WHERE patient_id = OLD.patient_id
        )
        +
        (
            SELECT COUNT(*) FROM payments WHERE patient_id = OLD.patient_id
        )
    INTO v_history_count;

    IF v_history_count > 0 THEN
        RAISE EXCEPTION
            'Cannot delete patient %. Patient has medical or financial history.',
            OLD.patient_id;
    END IF;

    RETURN OLD;
END;
$$;





CREATE OR REPLACE TRIGGER trg_prevent_patient_delete_with_history
BEFORE DELETE
ON patients
FOR EACH ROW
EXECUTE FUNCTION trg_fn_prevent_patient_delete_with_history();




DELETE FROM patients
WHERE patient_id = 1;

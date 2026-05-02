--recommeded functions on this system
-- Function 1: Calculate Employee Net Salary
CREATE OR REPLACE FUNCTION fn_calculate_net_salary(
    p_fixed_salary NUMERIC,
    p_bonus NUMERIC,
    p_deduction NUMERIC
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN COALESCE(p_fixed_salary, 0)
         + COALESCE(p_bonus, 0)
         - COALESCE(p_deduction, 0);
END;
$$;

--coalesce used to check if the value is null then it will replace it with 0
-- else they will use value 

--testing the first function
SELECT fn_calculate_net_salary(30000, 5000, 1000) AS net_salary;




----------------function 2 Get Patient Total Bills
CREATE OR REPLACE FUNCTION fn_get_patient_total_bills(
    p_patient_id BIGINT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(total_cost), 0)
    INTO v_total
    FROM bills
    WHERE patient_id = p_patient_id;

    RETURN v_total;
END;
$$;

---testing
SELECT fn_get_patient_total_bills(1) AS total_bills;



-- Function 3: Get Patient Total Payments
CREATE OR REPLACE FUNCTION fn_get_patient_total_payments(
    p_patient_id BIGINT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(payment_cost), 0)
    INTO v_total
    FROM payments
    WHERE patient_id = p_patient_id
      AND payment_status = 'Paid';

    RETURN v_total;
END;
$$;
---testinf patient total payment 
SELECT fn_get_patient_total_payments(1) AS total_paid;

----------------------------------
-- Function 4: Get Patient Balance

CREATE OR REPLACE FUNCTION fn_get_patient_balance(
    p_patient_id BIGINT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_bills NUMERIC;
    v_total_payments NUMERIC;
BEGIN
    v_total_bills := fn_get_patient_total_bills(p_patient_id);
    v_total_payments := fn_get_patient_total_payments(p_patient_id);

    RETURN v_total_bills - v_total_payments;
END;
$$;

--testinng function for getting patient balance 
SELECT fn_get_patient_balance(1) AS remaining_balance;
--------------------------------------------------
-- Function 5: Check Doctor Availability

CREATE OR REPLACE FUNCTION fn_is_doctor_available(
    p_doctor_id BIGINT,
    p_appointment_date DATE,
    p_appointment_time TIME
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM appointments
    WHERE doctor_id = p_doctor_id
      AND appointment_date = p_appointment_date
      AND appointment_time = p_appointment_time
      AND appointment_status <> 'Cancelled';

    IF v_count = 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$;

---testing Function 5: Check Doctor Availability
SELECT fn_is_doctor_available(1, '2026-05-05', '10:00:00') AS is_available;
------------------------------------------------

-- Function 6: Get Medicine Expiry Status

CREATE OR REPLACE FUNCTION fn_get_medicine_expiry_status(
    p_expire_date DATE
)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_expire_date < CURRENT_DATE THEN
        RETURN 'Expired';
    ELSIF p_expire_date <= CURRENT_DATE + INTERVAL '30 days' THEN
        RETURN 'Near Expiry';
    ELSE
        RETURN 'Valid';
    END IF;
END;
$$;

---testing Function 6: Get Medicine Expiry Status
SELECT
    commercial_name,
    expire_date,
    fn_get_medicine_expiry_status(expire_date) AS expiry_status
FROM medicines;
---------------------------------------------
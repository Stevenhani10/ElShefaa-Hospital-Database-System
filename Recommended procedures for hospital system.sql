-- Recommended Procedures
-- Procedure 1: Create Appointment Safely
CREATE OR REPLACE PROCEDURE sp_create_appointment(
    p_patient_id BIGINT,
    p_clinic_id BIGINT,
    p_doctor_id BIGINT,
    p_appointment_date DATE,
    p_appointment_time TIME
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF fn_is_doctor_available(
        p_doctor_id,
        p_appointment_date,
        p_appointment_time
    ) = FALSE THEN

        RAISE EXCEPTION 'Doctor is not available at this date and time';

    END IF;

    INSERT INTO appointments (
        patient_id,
        clinic_id,
        doctor_id,
        appointment_date,
        appointment_time,
        appointment_status
    )
    VALUES (
        p_patient_id,
        p_clinic_id,
        p_doctor_id,
        p_appointment_date,
        p_appointment_time,
        'Scheduled'
    );
END;
$$;
-- testing 
CALL sp_create_appointment(
    1,
    1,
    1,
    '2026-05-10',
    '12:00:00'
);

-----------------------------------------------
-- Procedure 2: Complete Appointment and Create Visit
--This procedure changes the appointment status to Completed and
-- creates a visit record.

CREATE OR REPLACE PROCEDURE sp_complete_appointment_create_visit(
    p_appointment_id BIGINT,
    p_description TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_patient_id BIGINT;
    v_clinic_id BIGINT;
    v_doctor_id BIGINT;
BEGIN
    SELECT patient_id, clinic_id, doctor_id
    INTO v_patient_id, v_clinic_id, v_doctor_id
    FROM appointments
    WHERE appointment_id = p_appointment_id;

    IF v_patient_id IS NULL THEN
        RAISE EXCEPTION 'Appointment not found';
    END IF;

    UPDATE appointments
    SET appointment_status = 'Completed'
    WHERE appointment_id = p_appointment_id;

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
        v_patient_id,
        p_appointment_id,
        v_clinic_id,
        v_doctor_id,
        CURRENT_DATE,
        CURRENT_TIME,
        p_description
    );
END;
$$;

--testing 
CALL sp_complete_appointment_create_visit(
    1,
    'Patient came for regular checkup.'
);
----------------------------------------------------------------
--Procedure 3: Add Diagnosis to Patient Visit
CREATE OR REPLACE PROCEDURE sp_add_patient_diagnosis(
    p_patient_id BIGINT,
    p_visit_id BIGINT,
    p_diagnosis_id BIGINT,
    p_doctor_id BIGINT,
    p_description TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO patient_diagnoses (
        patient_id,
        visit_id,
        diagnosis_id,
        doctor_id,
        diagnosis_date,
        description
    )
    VALUES (
        p_patient_id,
        p_visit_id,
        p_diagnosis_id,
        p_doctor_id,
        CURRENT_DATE,
        p_description
    );
END;
$$;
--testing 
CALL sp_add_patient_diagnosis(
    1,
    2,
    1,
    1,
    'Patient has high blood pressure.'
);

-------------------------------------------------------------------
-- Procedure 4: Add Prescription and Reduce Medicine Inventory
-- This is a very useful real-world procedure. It creates a prescription
-- and reduces medicine quantity from a store.
CREATE OR REPLACE PROCEDURE sp_prescribe_medicine(
    p_patient_id BIGINT,
    p_visit_id BIGINT,
    p_doctor_id BIGINT,
    p_medicine_id BIGINT,
    p_store_id BIGINT,
    p_quantity INT,
    p_dosage VARCHAR,
    p_duration VARCHAR,
    p_instructions TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_available_quantity INT;
BEGIN
    SELECT quantity
    INTO v_available_quantity
    FROM medicines_inventory
    WHERE store_id = p_store_id
      AND medicine_id = p_medicine_id;

    IF v_available_quantity IS NULL THEN
        RAISE EXCEPTION 'Medicine does not exist in this store';
    END IF;

    IF v_available_quantity < p_quantity THEN
        RAISE EXCEPTION 'Not enough medicine quantity in store';
    END IF;

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
        p_patient_id,
        p_visit_id,
        p_doctor_id,
        p_medicine_id,
        CURRENT_DATE,
        p_dosage,
        p_duration,
        p_instructions
    );

    UPDATE medicines_inventory
    SET quantity = quantity - p_quantity
    WHERE store_id = p_store_id
      AND medicine_id = p_medicine_id;
END;
$$;

---testing
CALL sp_prescribe_medicine(
    1,
    2,
    1,
    1,
    2,
    1,
    '1 tablet daily',
    '30 days',
    'Take after breakfast'
);


-------------------------------------------------------
-- Procedure 5: Create Bill and Payment Together
-- This procedure creates a bill and payment in one operation.

CREATE OR REPLACE PROCEDURE sp_create_bill_with_payment(
    p_patient_id BIGINT,
    p_visit_id BIGINT,
    p_bill_type VARCHAR,
    p_service_name VARCHAR,
    p_actual_cost NUMERIC,
    p_transfer_fees NUMERIC,
    p_payment_method VARCHAR,
    p_payment_status VARCHAR,
    p_description TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_payment_id BIGINT;
    v_total_cost NUMERIC;
BEGIN
--- calculate the total cost from sum of actual cost and transfer fee 
    v_total_cost := COALESCE(p_actual_cost, 0) + COALESCE(p_transfer_fees, 0);

    INSERT INTO payments (
        patient_id,
        payment_method,
        payment_cost,
        payment_date,
        payment_time,
        payment_status,
        description
    )
    VALUES (
        p_patient_id,
        p_payment_method,
        v_total_cost,
        CURRENT_DATE,
        CURRENT_TIME,
        p_payment_status,
        p_description
    )
    RETURNING payment_id INTO v_payment_id;
	--the usage for the returning 
	--after inserting the new row into payments we take 
	-- generate payment id to create the bill 

    INSERT INTO bills (
        patient_id,
        visit_id,
        payment_id,
        bill_type,
        service_name,
        actual_cost,
        transfer_fees,
        total_cost,
        bill_date,
        bill_time,
        description
    )
    VALUES (
        p_patient_id,
        p_visit_id,
        v_payment_id,
        p_bill_type,
        p_service_name,
        p_actual_cost,
        p_transfer_fees,
        v_total_cost,
        CURRENT_DATE,
        CURRENT_TIME,
        p_description
    );
END;
$$;

--------------------------------------------
--testing 
CALL sp_create_bill_with_payment(
    1,
    2,
    'Consultation',
    'Cardiology Follow-up',
    600,
    0,
    'Cash',
    'Paid',
    'Follow-up consultation payment'
);

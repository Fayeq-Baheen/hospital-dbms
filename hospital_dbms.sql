-- =====================================================
-- HOSPITAL MANAGEMENT SYSTEM - AFGHANISTAN VERSION
-- Complete SQL Script (PostgreSQL)
-- =====================================================

-- ایجاد دیتابیس
-- DROP DATABASE IF EXISTS HospitalDB;
-- CREATE DATABASE HospitalDB;
-- \c HospitalDB;

-- =====================================================
-- 1. TABLES (جداول)
-- =====================================================

-- 1. Departments
CREATE TABLE Departments (
    department_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Staff
CREATE TABLE Staff (
    staff_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    role VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    hire_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    department_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id) ON DELETE SET NULL
);

-- 3. Doctors
CREATE TABLE Doctors (
    doctor_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    department_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id) ON DELETE SET NULL
);

-- 4. Patients
CREATE TABLE Patients (
    patient_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    father_name VARCHAR(100),
    gender VARCHAR(10) CHECK (gender IN ('مرد', 'زن', 'سایر')),
    birth_date DATE,
    -- age INT GENERATED ALWAYS AS ((EXTRACT (YEAR FROM CURRENT_DATE)) - (EXTRACT (YEAR FROM birth_date))) STORED,
    phone VARCHAR(20),
    address TEXT,
    national_id VARCHAR(50) UNIQUE,
    blood_type VARCHAR(15) CHECK (blood_type IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    emergency_contact VARCHAR(100),
    register_date TIME DEFAULT CURRENT_TIME,
    is_active BOOLEAN DEFAULT TRUE
);

-- 5. Rooms
CREATE TABLE Rooms (
    room_id SERIAL PRIMARY KEY,
    room_number VARCHAR(20) UNIQUE NOT NULL,
    capacity INT DEFAULT 1,
    status VARCHAR(20) DEFAULT 'Available' CHECK (status IN ('Available', 'Occupied', 'Maintenance', 'Cleaning')),
    floor INT,
    room_type VARCHAR(50) CHECK (room_type IN ('General', 'Private', 'ICU', 'CCU', 'VIP')),
    price_per_day DECIMAL(12,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Admissions
CREATE TABLE Admissions (
    admission_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    room_id INT,
    admission_date TIMESTAMP NOT NULL,
    discharge_date TIMESTAMP,
    diagnosis TEXT,
    notes TEXT,
    status VARCHAR(20) DEFAULT 'Admitted' CHECK (status IN ('Admitted', 'Discharged', 'Transferred')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id) ON DELETE SET NULL
);

-- 7. Prescriptions
CREATE TABLE Prescriptions (
    prescription_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    file_path VARCHAR(255),
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Completed', 'Cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE CASCADE
);

-- 8. Medicines
CREATE TABLE Medicines (
    medicine_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    generic_name VARCHAR(100),
    category VARCHAR(50),
    manufacturer VARCHAR(100),
    unit_price DECIMAL(10,2) DEFAULT 0,
    stock_quantity INT DEFAULT 0,
    reorder_level INT DEFAULT 10,
    expiry_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. Prescription_Medicines
CREATE TABLE Prescription_Medicines (
    id SERIAL PRIMARY KEY,
    prescription_id INT NOT NULL,
    medicine_id INT NOT NULL,
    dosage VARCHAR(50),
    duration VARCHAR(50),
    instruction TEXT,
    quantity INT DEFAULT 1,
    FOREIGN KEY (prescription_id) REFERENCES Prescriptions(prescription_id) ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES Medicines(medicine_id) ON DELETE CASCADE
);

-- 10. Bills
CREATE TABLE Bills (
    bill_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL,
    admission_id INT NULL,
    bill_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    discount DECIMAL(12,2) DEFAULT 0,
    tax DECIMAL(12,2) DEFAULT 0,
    net_amount DECIMAL(12,2) GENERATED ALWAYS AS (total_amount - discount + tax) STORED,
    paid_amount DECIMAL(12,2) DEFAULT 0,
    due_date DATE,
    status VARCHAR(20) DEFAULT 'Unpaid' CHECK (status IN ('Unpaid', 'Partially Paid', 'Paid', 'Overdue')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (admission_id) REFERENCES Admissions(admission_id) ON DELETE SET NULL
);

-- 11. Bill_Items
CREATE TABLE Bill_Items (
    item_id SERIAL PRIMARY KEY,
    bill_id INT NOT NULL,
    item_type VARCHAR(50) NOT NULL CHECK (item_type IN ('Consultation', 'Room', 'Medicine', 'Lab', 'Surgery', 'Radiology', 'Other')),
    item_id_ref INT,
    item_name VARCHAR(100) NOT NULL,
    quantity INT DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bill_id) REFERENCES Bills(bill_id) ON DELETE CASCADE
);

-- 12. Payments
CREATE TABLE Payments (
    payment_id SERIAL PRIMARY KEY,
    bill_id INT NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(12,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('Cash', 'Card', 'Bank Transfer', 'Cheque', 'Insurance')),
    reference_no VARCHAR(100),
    receipt_no VARCHAR(100) UNIQUE,
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bill_id) REFERENCES Bills(bill_id) ON DELETE CASCADE
);

-- 13. Appointments
CREATE TABLE Appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'Scheduled' CHECK (status IN ('Scheduled', 'Completed', 'Cancelled', 'No-Show')),
    reason TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE CASCADE
);

-- 14. Vitals
CREATE TABLE Vitals (
    vital_id SERIAL PRIMARY KEY,
    admission_id INT,
    appointment_id INT,
    temperature DECIMAL(4,1),
    pulse INT CHECK (pulse BETWEEN 0 AND 300),
    respiration INT CHECK (respiration BETWEEN 0 AND 100),
    blood_pressure_systolic INT,
    blood_pressure_diastolic INT,
    oxygen_saturation INT CHECK (oxygen_saturation BETWEEN 0 AND 100),
    recorded_by INT,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admission_id) REFERENCES Admissions(admission_id) ON DELETE CASCADE,
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id) ON DELETE CASCADE,
    FOREIGN KEY (recorded_by) REFERENCES Staff(staff_id) ON DELETE SET NULL,
    CHECK (admission_id IS NOT NULL OR appointment_id IS NOT NULL)
);

-- 15. Lab_Tests
CREATE TABLE Lab_Tests (
    test_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    test_type VARCHAR(100) NOT NULL,
    test_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    result_date TIMESTAMP,
    result TEXT,
    result_file_path VARCHAR(255),
    lab_technician_id INT,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'In Progress', 'Completed', 'Cancelled')),
    normal_range VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE CASCADE,
    FOREIGN KEY (lab_technician_id) REFERENCES Staff(staff_id) ON DELETE SET NULL
);

-- 16. Radiology
CREATE TABLE Radiology (
    radiology_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    type VARCHAR(100) NOT NULL CHECK (type IN ('X-Ray', 'CT Scan', 'MRI', 'Ultrasound', 'Mammography', 'PET Scan')),
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    result TEXT,
    image_path VARCHAR(255),
    radiologist_id INT,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Completed', 'Cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE CASCADE,
    FOREIGN KEY (radiologist_id) REFERENCES Staff(staff_id) ON DELETE SET NULL
);

-- 17. Operating_Theatres
CREATE TABLE Operating_Theatres (
    theatre_id SERIAL PRIMARY KEY,
    theatre_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    status VARCHAR(20) DEFAULT 'Available' CHECK (status IN ('Available', 'In Use', 'Maintenance', 'Sterilizing')),
    equipment_status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 18. Surgeries
CREATE TABLE Surgeries (
    surgery_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    surgery_date TIMESTAMP NOT NULL,
    surgery_type VARCHAR(100) NOT NULL,
    operating_theatre_id INT,
    anesthesiologist_id INT,
    notes TEXT,
    complications TEXT,
    status VARCHAR(20) DEFAULT 'Scheduled' CHECK (status IN ('Scheduled', 'In Progress', 'Completed', 'Cancelled', 'Postponed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE CASCADE,
    FOREIGN KEY (operating_theatre_id) REFERENCES Operating_Theatres(theatre_id) ON DELETE SET NULL,
    FOREIGN KEY (anesthesiologist_id) REFERENCES Doctors(doctor_id) ON DELETE SET NULL
);



-- 19. Insurance
CREATE TABLE Insurance (
    insurance_id SERIAL PRIMARY KEY,
    company VARCHAR(100) NOT NULL,
    coverage_percentage INT CHECK (coverage_percentage BETWEEN 0 AND 100),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    is_active BOOLEAN DEFAULT TRUE
);

-- 20. Patient_Insurance
CREATE TABLE Patient_Insurance (
    patient_id INT,
    insurance_id INT,
    policy_number VARCHAR(100) NOT NULL,
    expiry_date DATE,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (patient_id, insurance_id),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (insurance_id) REFERENCES Insurance(insurance_id) ON DELETE CASCADE
);

-- 21. Inventory_Transactions
CREATE TABLE Inventory_Transactions (
    transaction_id SERIAL PRIMARY KEY,
    medicine_id INT NOT NULL,
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('Purchase', 'Sale', 'Adjust', 'Expiry', 'Return')),
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reference_type VARCHAR(20) CHECK (reference_type IN ('Bill', 'Prescription', 'Purchase Order', 'Adjustment')),
    reference_id INT,
    note TEXT,
    created_by INT,
    FOREIGN KEY (medicine_id) REFERENCES Medicines(medicine_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES Staff(staff_id) ON DELETE SET NULL
);

-- 22. Users
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('Admin', 'Doctor', 'Nurse', 'Receptionist', 'LabTech', 'Pharmacist', 'Accountant')),
    staff_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id) ON DELETE SET NULL
);

-- 23. Audit_Log
CREATE TABLE Audit_Log (
    log_id SERIAL PRIMARY KEY,
    user_id INT,
    action VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    old_data JSONB,
    new_data JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL
);

-- 24. Beds
CREATE TABLE Beds (
	bed_id SERIAL PRIMARY KEY,
	room_id INT NOT NULL,
	bed_number VARCHAR(20) NOT NULL,
	bed_status VARCHAR(20) CHECK (bed_status IN ('Available', 'Occupied', 'Maintenance')),
	FOREIGN KEY (room_id) REFERENCES Rooms(room_id) ON DELETE CASCADE
);

-- 25. Nurse
CREATE TABLE Nurse (
	nurse_id SERIAL PRIMARY KEY,
	nurse_name VARCHAR(50) NOT NULL,
	phone INT,
	email VARCHAR(150) UNIQUE,
	hire_date DATE DEFAULT CURRENT_DATE
);

-- 26. Nurse_Notes
CREATE TABLE Nurse_notes (
	note_id SERIAL PRIMARY KEY,
	admission_id INT NOT NULL,
	nurse_id INT NOT NULL,
	note TEXT,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (admission_id) REFERENCES Admissions(admission_id),
	FOREIGN KEY (nurse_id) REFERENCES Nurse(nurse_id)
);

-- 27. Equipments
CREATE TABLE Equipment (
	equipment_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	department_id INT NOT NULL,
	quantity INT NOT NULL,
	status VARCHAR(20) CHECK (status IN ('Available', 'In Use', 'Maintenance')),
	purchase_date DATE,
	warranty_expiry DATE,
	FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

-- 28. Roles
CREATE TABLE Roles (
	role_id SERIAL PRIMARY KEY,
	role_name VARCHAR(50) NOT NULL,
	description TEXT
);

-- 29.Permissions
CREATE TABLE Permissions (
	permission_id SERIAL PRIMARY KEY,
	permission_name VARCHAR(100) NOT NULL,
	modules VARCHAR(100),
	description TEXT
);

-- 30. Role_Permissions
CREATE TABLE Role_Permissions (
	role_id INT PRIMARY KEY,
	permission_id INT UNIQUE,
	FOREIGN KEY (role_id) REFERENCES Roles(role_id),
	FOREIGN KEY (permission_id) REFERENCES Permissions(permission_id)
);

-- =====================================================
-- 2. INDEXES
-- =====================================================

CREATE INDEX idx_patients_name ON Patients(name);
CREATE INDEX idx_patients_national_id ON Patients(national_id);
CREATE INDEX idx_patients_phone ON Patients(phone);
CREATE INDEX idx_patients_blood_type ON Patients(blood_type);
CREATE INDEX idx_doctors_specialty ON Doctors(specialty);
CREATE INDEX idx_appointments_date ON Appointments(appointment_date);
CREATE INDEX idx_appointments_status ON Appointments(status);
CREATE INDEX idx_appointments_doctor ON Appointments(doctor_id, appointment_date);
CREATE INDEX idx_admissions_patient ON Admissions(patient_id, status);
CREATE INDEX idx_admissions_doctor ON Admissions(doctor_id, status);
CREATE INDEX idx_admissions_dates ON Admissions(admission_date, discharge_date);
CREATE INDEX idx_bills_patient ON Bills(patient_id, status);
CREATE INDEX idx_bills_date ON Bills(bill_date);
CREATE INDEX idx_bills_status ON Bills(status);
CREATE INDEX idx_payments_bill ON Payments(bill_id);
CREATE INDEX idx_payments_date ON Payments(payment_date);
CREATE INDEX idx_prescriptions_patient ON Prescriptions(patient_id, date);
CREATE INDEX idx_prescriptions_status ON Prescriptions(status);
CREATE INDEX idx_lab_tests_patient ON Lab_Tests(patient_id, test_date);
CREATE INDEX idx_lab_tests_status ON Lab_Tests(status);
CREATE INDEX idx_radiology_patient ON Radiology(patient_id, date);
CREATE INDEX idx_surgeries_date ON Surgeries(surgery_date);
CREATE INDEX idx_surgeries_patient ON Surgeries(patient_id);
CREATE INDEX idx_medicines_name ON Medicines(name);
CREATE INDEX idx_medicines_expiry ON Medicines(expiry_date);
CREATE INDEX idx_inventory_date ON Inventory_Transactions(transaction_date);
CREATE INDEX idx_inventory_medicine ON Inventory_Transactions(medicine_id, transaction_type);
CREATE INDEX idx_audit_table ON Audit_Log(table_name, record_id);
CREATE INDEX idx_audit_date ON Audit_Log(created_at);
CREATE INDEX idx_nurse_name ON Nurse(nurse_name);
CREATE INDEX idx_equipment_name ON Equipment(name);

-- =====================================================
-- 3. VIEWS
-- =====================================================

CREATE VIEW v_PatientFullInfo AS
SELECT 
    p.patient_id,
    p.name,
    p.father_name,
    p.gender,
    p.birth_date,
    (EXTRACT (YEAR FROM CURRENT_DATE)) - (EXTRACT (YEAR FROM p.birth_date)) AS age,
    p.phone,
    p.address,
    p.national_id,
    p.blood_type,
    p.emergency_contact,
    p.register_date,
    i.company AS insurance_company,
    pi.policy_number,
    pi.expiry_date AS insurance_expiry
FROM Patients p
LEFT JOIN Patient_Insurance pi ON p.patient_id = pi.patient_id AND pi.is_primary = TRUE
LEFT JOIN Insurance i ON pi.insurance_id = i.insurance_id
WHERE p.is_active = TRUE;

CREATE VIEW v_BillSummary AS
SELECT 
    b.bill_id,
    p.name AS patient_name,
    b.bill_date,
    b.total_amount,
    b.discount,
    b.net_amount,
    b.paid_amount,
    b.net_amount - b.paid_amount AS remaining_amount,
    b.status,
    COUNT(DISTINCT bi.item_id) AS total_items,
    COUNT(DISTINCT pay.payment_id) AS payment_count
FROM Bills b
JOIN Patients p ON b.patient_id = p.patient_id
LEFT JOIN Bill_Items bi ON b.bill_id = bi.bill_id
LEFT JOIN Payments pay ON b.bill_id = pay.bill_id
GROUP BY b.bill_id, p.name;

CREATE VIEW v_DailyStatistics AS
SELECT 
    CURRENT_DATE AS today_date,
    (SELECT COUNT(*) FROM Appointments WHERE DATE(appointment_date) = CURRENT_DATE) AS today_appointments,
    (SELECT COUNT(*) FROM Admissions WHERE DATE(admission_date) = CURRENT_DATE AND status = 'Admitted') AS today_admissions,
    (SELECT COUNT(*) FROM Surgeries WHERE DATE(surgery_date) = CURRENT_DATE AND status = 'Scheduled') AS today_surgeries,
    (SELECT COALESCE(SUM(amount), 0) FROM Payments WHERE DATE(payment_date) = CURRENT_DATE) AS today_revenue;

CREATE VIEW v_MedicineInventory AS
SELECT 
    m.medicine_id,
    m.name,
    m.generic_name,
    m.category,
    m.manufacturer,
    m.stock_quantity,
    m.reorder_level,
    CASE 
        WHEN m.stock_quantity <= m.reorder_level THEN 'Need Reorder'
        WHEN m.stock_quantity <= m.reorder_level * 2 THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status,
    m.unit_price,
    m.expiry_date,
    (m.expiry_date - CURRENT_DATE) AS days_to_expiry
FROM Medicines m;

CREATE VIEW v_DoctorPerformance AS
SELECT 
    d.doctor_id,
    d.name,
    d.specialty,
    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    COUNT(DISTINCT adm.admission_id) AS total_admissions,
    COUNT(DISTINCT s.surgery_id) AS total_surgeries,
    COUNT(DISTINCT p.prescription_id) AS total_prescriptions,
    (SELECT COALESCE(SUM(b.net_amount), 0) 
     FROM Bills b 
     JOIN Admissions adm2 ON b.admission_id = adm2.admission_id 
     WHERE adm2.doctor_id = d.doctor_id) AS revenue_generated
FROM Doctors d
LEFT JOIN Appointments a ON d.doctor_id = a.doctor_id
LEFT JOIN Admissions adm ON d.doctor_id = adm.doctor_id
LEFT JOIN Surgeries s ON d.doctor_id = s.doctor_id
LEFT JOIN Prescriptions p ON d.doctor_id = p.doctor_id
GROUP BY d.doctor_id;

-- =====================================================
-- 4. STORED PROCEDURES
-- =====================================================

CREATE OR REPLACE FUNCTION sp_RevenueReport(p_start_date DATE, p_end_date DATE)
RETURNS TABLE(
    bill_day DATE,
    bill_count BIGINT,
    gross_revenue DECIMAL,
    total_discount DECIMAL,
    total_tax DECIMAL,
    net_revenue DECIMAL,
    collected_amount DECIMAL,
    pending_amount DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        DATE(bill_date)::DATE AS bill_day,
        COUNT(*)::BIGINT AS bill_count,
        SUM(total_amount) AS gross_revenue,
        COALESCE(SUM(discount), 0) AS total_discount,
        COALESCE(SUM(tax), 0) AS total_tax,
        SUM(net_amount) AS net_revenue,
        COALESCE(SUM(paid_amount), 0) AS collected_amount,
        SUM(net_amount - paid_amount) AS pending_amount
    FROM Bills
    WHERE DATE(bill_date) BETWEEN p_start_date AND p_end_date
    GROUP BY DATE(bill_date)
    ORDER BY bill_day DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_RegisterPatient(
    p_name VARCHAR,
    p_father_name VARCHAR,
    p_gender VARCHAR,
    p_birth_date DATE,
    p_phone VARCHAR,
    p_address TEXT,
    p_national_id VARCHAR,
    p_blood_type VARCHAR,
    p_emergency_contact VARCHAR
)
RETURNS INTEGER AS $$
DECLARE
    v_patient_id INTEGER;
BEGIN
    INSERT INTO Patients (name, father_name, gender, birth_date, phone, address, national_id, blood_type, emergency_contact)
    VALUES (p_name, p_father_name, p_gender, p_birth_date, p_phone, p_address, p_national_id, p_blood_type, p_emergency_contact)
    RETURNING patient_id INTO v_patient_id;
    
    RETURN v_patient_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_GetDoctorAppointments(p_doctor_id INT, p_date DATE)
RETURNS TABLE(
    appointment_id INT,
    patient_name VARCHAR,
    phone VARCHAR,
    appointment_date TIMESTAMP,
    status VARCHAR,
    reason TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.appointment_id,
        p.name::VARCHAR AS patient_name,
        p.phone::VARCHAR,
        a.appointment_date,
        a.status::VARCHAR,
        a.reason::TEXT
    FROM Appointments a
    JOIN Patients p ON a.patient_id = p.patient_id
    WHERE a.doctor_id = p_doctor_id 
        AND DATE(a.appointment_date) = p_date
    ORDER BY a.appointment_date;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_AdmitPatient(
    p_patient_id INT,
    p_doctor_id INT,
    p_room_id INT,
    p_diagnosis TEXT
)
RETURNS INTEGER AS $$
DECLARE
    v_admission_id INTEGER;
BEGIN
    INSERT INTO Admissions (patient_id, doctor_id, room_id, admission_date, diagnosis, status)
    VALUES (p_patient_id, p_doctor_id, p_room_id, NOW(), p_diagnosis, 'Admitted')
    RETURNING admission_id INTO v_admission_id;
    
    UPDATE Rooms SET status = 'Occupied' WHERE room_id = p_room_id;
    
    RETURN v_admission_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_DischargePatient(
    p_admission_id INT,
    p_discharge_notes TEXT
)
RETURNS VOID AS $$
DECLARE
    v_patient_id INT;
    v_room_id INT;
BEGIN
    SELECT patient_id, room_id INTO v_patient_id, v_room_id
    FROM Admissions WHERE admission_id = p_admission_id;
    
    UPDATE Admissions 
    SET discharge_date = NOW(), 
        status = 'Discharged',
        notes = COALESCE(notes, '') || ' | ' || p_discharge_notes
    WHERE admission_id = p_admission_id;
    
    UPDATE Rooms SET status = 'Available' WHERE room_id = v_room_id;
    
    INSERT INTO Bills (patient_id, admission_id, total_amount, net_amount, due_date)
    SELECT 
        v_patient_id,
        p_admission_id,
        SUM(price),
        SUM(price),
        CURRENT_DATE + 15
    FROM (
        SELECT EXTRACT(DAY FROM (NOW() - admission_date)) * r.price_per_day AS price
        FROM Admissions a
        JOIN Rooms r ON a.room_id = r.room_id
        WHERE a.admission_id = p_admission_id
        UNION ALL
        SELECT 0
    ) AS costs;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_MakePayment(
    p_bill_id INT,
    p_amount DECIMAL,
    p_method VARCHAR,
    p_reference_no VARCHAR
)
RETURNS VOID AS $$
DECLARE
    v_net_amount DECIMAL;
    v_paid_amount DECIMAL;
    v_new_status VARCHAR;
    v_receipt_no VARCHAR;
BEGIN
    SELECT net_amount, paid_amount INTO v_net_amount, v_paid_amount
    FROM Bills WHERE bill_id = p_bill_id;
    
    v_receipt_no := 'RCP_' || p_bill_id || '_' || to_char(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISS');
    
    INSERT INTO Payments (bill_id, amount, payment_method, reference_no, receipt_no)
    VALUES (p_bill_id, p_amount, p_method, p_reference_no, v_receipt_no);
    
    v_paid_amount := v_paid_amount + p_amount;
    
    IF v_paid_amount >= v_net_amount THEN
        v_new_status := 'Paid';
    ELSE
        v_new_status := 'Partially Paid';
    END IF;
    
    UPDATE Bills 
    SET paid_amount = v_paid_amount, status = v_new_status
    WHERE bill_id = p_bill_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_SearchPatients(
    p_name VARCHAR,
    p_national_id VARCHAR,
    p_phone VARCHAR,
    p_blood_type VARCHAR
)
RETURNS SETOF Patients AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM Patients
    WHERE (p_name IS NULL OR name ILIKE '%' || p_name || '%')
      AND (p_national_id IS NULL OR national_id ILIKE '%' || p_national_id || '%')
      AND (p_phone IS NULL OR phone ILIKE '%' || p_phone || '%')
      AND (p_blood_type IS NULL OR blood_type = p_blood_type)
    ORDER BY register_date DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_BedOccupancyReport()
RETURNS TABLE(
    room_number VARCHAR,
    room_type VARCHAR,
    capacity INT,
    status VARCHAR,
    current_patients BIGINT,
    occupancy_status VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.room_number::VARCHAR,
        r.room_type::VARCHAR,
        r.capacity,
        r.status::VARCHAR,
        COUNT(DISTINCT a.admission_id)::BIGINT AS current_patients,
        CASE 
            WHEN r.status = 'Occupied' THEN 'Full'::VARCHAR
            WHEN r.status = 'Available' THEN 'Empty'::VARCHAR
            ELSE 'Not Available'::VARCHAR
        END AS occupancy_status
    FROM Rooms r
    LEFT JOIN Admissions a ON r.room_id = a.room_id 
        AND a.status = 'Admitted'
    GROUP BY r.room_id
    ORDER BY r.floor, r.room_number;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. TRIGGERS
-- =====================================================

CREATE OR REPLACE FUNCTION trg_update_medicine_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Medicines 
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE medicine_id = NEW.medicine_id;
    
    INSERT INTO Inventory_Transactions (medicine_id, transaction_type, quantity, reference_type, reference_id)
    VALUES (NEW.medicine_id, 'Sale', -NEW.quantity, 'Prescription', NEW.prescription_id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_UpdateMedicineStock
AFTER INSERT ON Prescription_Medicines
FOR EACH ROW
EXECUTE FUNCTION trg_update_medicine_stock();

CREATE OR REPLACE FUNCTION trg_check_appointment_conflict()
RETURNS TRIGGER AS $$
DECLARE
    conflict_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO conflict_count
    FROM Appointments
    WHERE doctor_id = NEW.doctor_id
        AND appointment_date BETWEEN NEW.appointment_date - INTERVAL '30 minutes' 
                                   AND NEW.appointment_date + INTERVAL '30 minutes'
        AND status IN ('Scheduled', 'In Progress');
    
    IF conflict_count > 0 THEN
        RAISE EXCEPTION 'این زمان برای پزشک رزرو شده است';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_CheckAppointmentConflict
BEFORE INSERT ON Appointments
FOR EACH ROW
EXECUTE FUNCTION trg_check_appointment_conflict();

-- =====================================================
-- 6. SAMPLE DATA (با شماره افغانستان و پول افغانی)
-- =====================================================

-- Departments
INSERT INTO Departments (department_id, name, location, description) VALUES 
(1, 'قلب و عروق', 'طبقه سوم - کابل', 'بیماری‌های قلبی و عروقی'),
(2, 'اطفال', 'طبقه دوم - کابل', 'بیماران کودک و نوزاد'),
(3, 'ارتوپدی', 'طبقه اول - کابل', 'بیماری‌های استخوان و مفاصل'),
(4, 'اعصاب و روان', 'طبقه چهارم - کابل', 'بیماری‌های مغز و اعصاب'),
(5, 'پوست و زیبایی', 'طبقه دوم - کابل', 'بیماری‌های پوست');

-- Doctors (با شماره افغانستان)
INSERT INTO Doctors (doctor_id, name, specialty, phone, email, department_id) VALUES
(1, 'دکتر رضا حسینی', 'جراحی قلب', '700111222', 'r.hosseini@hospital.af', 1),
(2, 'دکتر مریم احمدی', 'اطفال', '701222333', 'm.ahmadi@hospital.af', 2),
(3, 'دکتر علی کریمی', 'ارتوپدی', '702333444', 'a.karimi@hospital.af', 3),
(4, 'دکتر سعید رحمانی', 'اعصاب', '703444555', 's.rahamani@hospital.af', 4),
(5, 'دکتر نرگس موسوی', 'پوست', '704555666', 'n.mousavi@hospital.af', 5);

-- Rooms (قیمت به افغانی)
INSERT INTO Rooms (room_id, room_number, capacity, status, floor, room_type, price_per_day) VALUES
(1, '101', 1, 'Available', 1, 'Private', 5000),
(2, '102', 1, 'Occupied', 1, 'Private', 5000),
(3, '201', 2, 'Available', 2, 'General', 3000),
(4, '202', 2, 'Available', 2, 'General', 3000),
(5, '301', 1, 'Available', 3, 'ICU', 10000),
(6, '302', 1, 'Maintenance', 3, 'VIP', 15000);

-- Operating_Theatres
INSERT INTO Operating_Theatres (theatre_id, theatre_name, location, status) VALUES
(1, 'اتاق عمل شماره 1', 'طبقه همکف', 'Available'),
(2, 'اتاق عمل شماره 2', 'طبقه همکف', 'Available'),
(3, 'اتاق عمل قلب', 'طبقه سوم', 'In Use');

-- Medicines (قیمت به افغانی)
INSERT INTO Medicines (medicine_id, name, generic_name, category, manufacturer, unit_price, stock_quantity, reorder_level, expiry_date) VALUES
(1, 'آسپرین', 'Acetylsalicylic Acid', 'ضد درد', 'بایر', 50, 1000, 100, '2025-12-31'),
(2, 'آموکسی سیلین', 'Amoxicillin', 'آنتی‌بیوتیک', 'داروپخش', 80, 500, 50, '2025-10-15'),
(3, 'لوزارتان', 'Losartan', 'فشار خون', 'نوآرتیس', 120, 300, 30, '2025-08-20'),
(4, 'متفورمین', 'Metformin', 'دیابت', 'مرک', 70, 450, 40, '2026-01-10');

-- Insurance (بیمه‌های افغانستان)
INSERT INTO Insurance (insurance_id, company, coverage_percentage, phone, email) VALUES
(1, 'بیمه افغان', 70, '700123456', 'afghan@insurance.af'),
(2, 'بیمه پامیر', 60, '701234567', 'pamir@insurance.af'),
(3, 'بیمه بریج', 80, '702345678', 'bridge@insurance.af');

-- Staff (با شماره افغانستان)
INSERT INTO Staff (staff_id, name, role, phone, email, hire_date, department_id) VALUES
(1, 'احمد رضایی', 'پرستار', '711122233', 'ahmad@hospital.af', '2020-01-15', 1),
(2, 'مریم کاظمی', 'پذیرش', '712233344', 'maryam@hospital.af', '2021-03-20', 2),
(3, 'سعید مظاهری', 'تکنسین', '713344455', 'saeed@hospital.af', '2019-06-10', 3);

-- Patients (با شماره افغانستان)
INSERT INTO Patients (patient_id, name, father_name, gender, birth_date, phone, address, national_id, blood_type, emergency_contact) VALUES
(1, 'علی محمدی', 'رضا', 'مرد', '1989-03-15', '700123789', 'کابل، ناحیه ۳', '123456789', 'O+', '700123788'),
(2, 'سارا کریمی', 'احمد', 'زن', '1996-07-22', '701234890', 'هرات، ناحیه ۲', '987654321', 'A+', '701234889'),
(3, 'محمد رضایی', 'علی', 'مرد', '1982-11-10', '702345901', 'بلخ، ناحیه ۵', '456789123', 'B+', '702345900'),
(4, 'زهرا حسینی', 'حسین', 'زن', '2000-01-05', '703456012', 'کابل، ناحیه ۱۰', '789123456', 'AB+', '703456011'),
(5, 'رضا نوروزی', 'حسن', 'مرد', '1975-09-30', '704567123', 'ننگرهار، ناحیه ۲', '321654987', 'O-', '704567122');

-- Users
INSERT INTO Users (user_id, username, password_hash, email, role, is_active) VALUES
(1, 'admin', 'pbkdf2:sha256:600000$8KhlUyZk7j2XxZ8W$1b5e6c8d9f0a1b2c3d4e5f6a7b8c9d0e', 'admin@hospital.af', 'Admin', TRUE),
(2, 'dr_hosseini', 'pbkdf2:sha256:600000$8KhlUyZk7j2XxZ8W$1b5e6c8d9f0a1b2c3d4e5f6a7b8c9d0e', 'r.hosseini@hospital.af', 'Doctor', TRUE),
(3, 'reception', 'pbkdf2:sha256:600000$8KhlUyZk7j2XxZ8W$1b5e6c8d9f0a1b2c3d4e5f6a7b8c9d0e', 'reception@hospital.af', 'Receptionist', TRUE);

-- Admissions
INSERT INTO Admissions (admission_id, patient_id, doctor_id, room_id, admission_date, discharge_date, diagnosis, notes, status) VALUES
(1, 1, 1, 2, '2024-03-01 10:00:00', '2024-03-05 14:00:00', 'درد قفسه سینه', 'پاسخ به درمان خوب', 'Discharged'),
(2, 3, 3, NULL, '2024-03-10 09:00:00', NULL, 'شکستگی استخوان ران', 'نیاز به جراحی', 'Admitted');

-- Appointments
INSERT INTO Appointments (appointment_id, patient_id, doctor_id, appointment_date, status, reason) VALUES
(1, 1, 1, '2024-03-20 10:00:00', 'Scheduled', 'چکاپ دوره‌ای'),
(2, 2, 2, '2024-03-21 14:30:00', 'Completed', 'تب و سرفه'),
(3, 4, 4, '2024-03-22 11:00:00', 'Scheduled', 'سردرد'),
(4, 5, 5, '2024-03-23 16:00:00', 'Cancelled', 'مشکل پوستی');

-- Bills (قیمت به افغانی)
INSERT INTO Bills (bill_id, patient_id, admission_id, total_amount, discount, tax, paid_amount, status, due_date) VALUES
(1, 1, 1, 15000, 1000, 0, 14000, 'Paid', '2024-03-20'),
(2, 2, NULL, 3500, 0, 350, 0, 'Unpaid', '2024-04-10'),
(3, 3, 2, 28000, 2000, 0, 10000, 'Partially Paid', '2024-03-30');

-- Bill Items (قیمت به افغانی)
INSERT INTO Bill_Items (item_id, bill_id, item_type, item_name, quantity, unit_price) VALUES
(1, 1, 'Consultation', 'ویزیت پزشک', 1, 2000),
(2, 1, 'Room', 'اتاق خصوصی', 4, 2500),
(3, 1, 'Lab', 'آزمایش خون', 2, 1000),
(4, 2, 'Consultation', 'ویزیت پزشک اطفال', 1, 3500),
(5, 3, 'Room', 'ICU', 3, 8000),
(6, 3, 'Surgery', 'جراحی ارتوپدی', 1, 4000);

-- Payments (مبلغ به افغانی)
INSERT INTO Payments (payment_id, bill_id, amount, payment_method, receipt_no) VALUES
(1, 1, 14000, 'Card', 'RCP_1_20240315120000'),
(2, 3, 10000, 'Cash', 'RCP_3_20240316130000');

-- Prescriptions
INSERT INTO Prescriptions (prescription_id, patient_id, doctor_id, notes, status) VALUES
(1, 1, 1, 'آسپرین روزانه - یک ماه', 'Active'),
(2, 2, 2, 'شربت استامینوفن هر 6 ساعت', 'Completed');

-- Prescription Medicines
INSERT INTO Prescription_Medicines (prescription_id, medicine_id, dosage, duration, quantity) VALUES
(1, 1, '80mg', '30 روز', 30),
(2, 2, '250mg', '5 روز', 15);

-- Patient Insurance
INSERT INTO Patient_Insurance (patient_id, insurance_id, policy_number, expiry_date, is_primary) VALUES
(1, 1, 'POL-123456', '2025-12-31', TRUE),
(2, 2, 'POL-234567', '2025-10-15', TRUE),
(3, 1, 'POL-345678', '2026-01-20', TRUE);

-- Vitals
INSERT INTO Vitals (vital_id, admission_id, temperature, pulse, respiration, blood_pressure_systolic, blood_pressure_diastolic, oxygen_saturation, recorded_by) VALUES
(1, 1, 36.5, 72, 16, 110, 70, 98, 1),
(2, 2, 37.2, 88, 18, 125, 85, 95, 1);

-- Lab Tests
INSERT INTO Lab_Tests (test_id, patient_id, doctor_id, test_type, test_date, status, lab_technician_id) VALUES
(1, 1, 1, 'شمارش کامل خون', '2024-03-02', 'Completed', 3),
(2, 3, 3, 'الکترولیت‌ها', '2024-03-11', 'Pending', NULL);

-- Set sequences to continue from last ID
SELECT setval('departments_department_id_seq', 5);
SELECT setval('doctors_doctor_id_seq', 5);
SELECT setval('patients_patient_id_seq', 5);
SELECT setval('rooms_room_id_seq', 6);
SELECT setval('operating_theatres_theatre_id_seq', 3);
SELECT setval('medicines_medicine_id_seq', 4);
SELECT setval('insurance_insurance_id_seq', 3);
SELECT setval('staff_staff_id_seq', 3);
SELECT setval('users_user_id_seq', 3);
SELECT setval('admissions_admission_id_seq', 2);
SELECT setval('appointments_appointment_id_seq', 4);
SELECT setval('bills_bill_id_seq', 3);
SELECT setval('bill_items_item_id_seq', 6);
SELECT setval('payments_payment_id_seq', 2);
SELECT setval('prescriptions_prescription_id_seq', 2);
SELECT setval('vitals_vital_id_seq', 2);
SELECT setval('lab_tests_test_id_seq', 2);

-- =====================================================
-- 7. نمایش خلاصه دیتابیس
-- =====================================================
SELECT '==========================================' AS " ";
SELECT 'DATABASE CREATED SUCCESSFULLY!' AS "Status";
SELECT '==========================================' AS " ";
SELECT 'نسخه مخصوص افغانستان' AS " ";
SELECT 'واحد پول: افغانی (AFN)' AS " ";
SELECT 'شماره تماس: فرمت افغانستان' AS " ";
SELECT '==========================================' AS " ";

-- =====================================================
-- 8. کوئری‌های تست
-- =====================================================

SELECT * FROM v_PatientFullInfo LIMIT 5;
SELECT * FROM Appointments WHERE DATE(appointment_date) = CURRENT_DATE;
SELECT * FROM v_DailyStatistics;
SELECT * FROM sp_RevenueReport(DATE(CURRENT_DATE - INTERVAL '30 days'), CURRENT_DATE);

-- =====================================================
-- END OF SCRIPT
-- =====================================================

Use am_dpadala;
SELECT * FROM am_dpadala.Patient;
SELECT * FROM am_dpadala.Address;
SELECT * FROM am_dpadala.Disease;
SELECT * FROM am_dpadala.Feedback;
SELECT * FROM am_dpadala.Department;
SELECT * FROM am_dpadala.Role;
SELECT * FROM am_dpadala.Appointment;
SELECT * FROM am_dpadala.EmployeeAddress;
SELECT * FROM am_dpadala.Lab_Test;
SELECT * FROM am_dpadala.Patient_Billing;
SELECT * FROM am_dpadala.Patient_Register;
SELECT * FROM am_dpadala.Patient_Disease;
SELECT * FROM am_dpadala.Employee;
SELECT * FROM am_dpadala.Patient_Address;
SELECT * FROM am_dpadala.Patient_Lab_Report;

ALTER TABLE Lab_Test RENAME COLUMN `MaxValue` to Max_Value;




#Query1 Patient Visit History
SELECT 
    p.Patient_ID, 
    CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient_Name,
    p.Gender,
    p.Age,
    p.Blood_Group,
    p.Height,
    p.Weight,
    a.Appointment_Date,
    a.Employee_ID,
    CONCAT(e.First_Name, ' ', e.Last_Name) AS Employee_Name,
    r.Role_Desc
FROM Patient p
JOIN Appointment a ON p.Patient_ID = a.Patient_ID
JOIN Employee e ON a.Employee_ID = e.Employee_ID
JOIN Role r ON e.Role_ID = r.Role_ID
WHERE p.Patient_ID = 13
ORDER BY a.Appointment_Date DESC;


#Patients with multiple times admitted count
SELECT 
    a.PatientID, 
    p.FirstName, 
    p.LastName, 
    COUNT(a.AppointmentID) AS TotalAppointments 
FROM Appointment a
JOIN Patient p ON a.PatientID = p.PatientID
GROUP BY a.PatientID, p.FirstName, p.LastName
HAVING COUNT(a.AppointmentID) > 1
ORDER BY TotalAppointments DESC;

SELECT 
    p.PatientID, 
    p.FirstName, 
    p.LastName, 
    pr.PatientRegisterID, 
    pr.AdmittedOn, 
    pb.Amount AS BillAmount
FROM Patient_Register pr
JOIN Patient p ON pr.PatientID = p.PatientID
LEFT JOIN Patient_Billing pb ON pr.PatientRegisterID = pb.PatientRegisterID
WHERE p.PatientID = 41 
ORDER BY pr.AdmittedOn DESC;


# Top 10 commonly diagnosed diseases
SELECT d.Name AS Disease_Name, 
       COUNT(pd.Patient_Disease_ID) AS Diagnosed_Count
FROM Disease d
JOIN Patient_Disease pd ON d.Disease_ID = pd.Disease_ID
GROUP BY d.Name
ORDER BY Diagnosed_Count DESC;

#Query2 yearly based
SELECT d.Name AS Disease_Name, 
       COUNT(pd.Patient_Disease_ID) AS Diagnosed_Count
FROM Disease d
JOIN Patient_Disease pd ON d.Disease_ID = pd.Disease_ID
JOIN Patient_Register pr ON pd.Patient_Register_ID = pr.Patient_Register_ID
WHERE pr.Admitted_On >= DATE_SUB(NOW(), INTERVAL 2 YEAR) 
GROUP BY d.Name
ORDER BY Diagnosed_Count DESC;

#Query3 Different Age groups visiting hospital
SELECT 
    CASE 
        WHEN p.Age BETWEEN 0 AND 15 THEN '0-15 (Children)'
        WHEN p.Age BETWEEN 16 AND 35 THEN '16-35 (Young Adults)'
        WHEN p.Age BETWEEN 36 AND 50 THEN '36-50 (Middle Aged)'
        WHEN p.Age BETWEEN 51 AND 100 THEN '51-100 (Senior Adults)'
    END AS Age_Group,
    COUNT(DISTINCT a.Patient_ID) AS Total_Visits
FROM Patient p
JOIN Appointment a ON a.Patient_ID = p.Patient_ID
GROUP BY Age_Group
ORDER BY Total_Visits DESC;

SELECT * FROM Disease;
## Query4 Based on location
SELECT a.State,
       d.Name As Disease, 
       COUNT(pd.Patient_Disease_ID) AS Total_Cases
FROM Patient_Disease pd
JOIN Patient_Register pr ON pd.Patient_Register_ID = pr.Patient_Register_ID
JOIN Patient p ON pr.Patient_ID = p.Patient_ID
JOIN Patient_Address pa ON p.Patient_ID = pa.Patient_ID
JOIN Address a ON pa.Address_ID = a.Address_ID
JOIN Disease d ON pd.Disease_ID = d.Disease_ID
WHERE d.Name = 'Diabetes'  -- Replace 'Diabetes' with any disease name
GROUP BY a.State
ORDER BY Total_Cases DESC;

#Query 5 revenue generated by department for better resource allocation
SELECT 
    d.Department_Name, 
    COUNT(pb.Patient_Billing_ID) AS Total_Bills, 
    SUM(pb.Amount) AS Total_Department_Revenue, 
    ROUND(AVG(pb.Amount), 2) AS Avg_Bill_Per_Patient,
    (SUM(pb.Amount) * 100.0 / (SELECT SUM(Amount) FROM Patient_Billing)) AS Revenue_Percentage
FROM Department d
JOIN Employee e ON d.Department_ID = e.Department_ID
JOIN Appointment a ON e.Employee_ID = a.Employee_ID
JOIN Patient_Register pr ON a.Patient_ID = pr.Patient_ID
JOIN Patient_Billing pb ON pr.Patient_Register_ID = pb.Patient_Register_ID
GROUP BY d.Department_Name
ORDER BY Total_Department_Revenue DESC;




#Query 6
SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, p.Date_Of_Birth, CURDATE()) < 18 THEN 'Under 18'
        WHEN TIMESTAMPDIFF(YEAR, p.Date_Of_Birth, CURDATE()) BETWEEN 18 AND 35 THEN '18-35'
        WHEN TIMESTAMPDIFF(YEAR, p.Date_Of_Birth, CURDATE()) BETWEEN 36 AND 50 THEN '36-50'
        WHEN TIMESTAMPDIFF(YEAR, p.Date_Of_Birth, CURDATE()) BETWEEN 51 AND 65 THEN '51-65'
        ELSE '65+'
    END AS AgeGroup, 
    d.Name AS DiseaseName, 
    COUNT(pd.Patient_ID) AS DiseaseCount
FROM Patient_Disease pd
JOIN Patient p ON pd.Patient_ID = p.Patient_ID
JOIN Disease d ON pd.Disease_ID = d.Disease_ID
GROUP BY AgeGroup, d.Name
ORDER BY AgeGroup, DiseaseCount DESC;

#Query 6

SELECT 
    e.Employee_ID, 
    e.First_Name AS DoctorName, 
    COUNT(DISTINCT pr.Patient_ID) AS UniquePatientsTreated
FROM Patient_Register pr
JOIN Employee e ON pr.Employee_ID = e.Employee_ID
JOIN Role r ON r.Role_ID = e.Role_ID
WHERE r.Role_Desc = 'Doctor'
GROUP BY e.Employee_ID, e.First_Name
ORDER BY UniquePatientsTreated DESC;



## Stored Procedure1

DELIMITER $$
DROP PROCEDURE IF EXISTS Get_Employee_Rating;
CREATE PROCEDURE Get_Employee_Rating(IN employee_id INT)
BEGIN
    SELECT 
        e.Employee_ID, 
        CONCAT(e.First_Name, ' ', e.Last_Name) AS Employee_Name,
        d.Department_Name,
        COUNT(f.Feedback_ID) AS Total_Feedbacks,
        IFNULL(ROUND(AVG(f.Rating), 2), 'No Ratings') AS Avg_Rating,
        -- Count total completed appointments for the given employee
        (SELECT COUNT(*) 
         FROM Appointment a 
         WHERE a.Employee_ID = employee_id 
           AND a.Status = 'Completed') AS Completed_Appointments,
        -- Count all appointments assigned to the employee
        (SELECT COUNT(*) 
         FROM Appointment a 
         WHERE a.Employee_ID = employee_id) AS Total_Appointments,
        -- Calculate the completion rate: (Completed Appointments / Total Appointments) * 100
        -- If no appointments exist, return 'No Appointments' instead of a null or division error
        IFNULL(ROUND(
            (SELECT COUNT(*) 
             FROM Appointment a 
             WHERE a.Employee_ID = employee_id 
               AND a.Status = 'Completed') 
            * 100.0 / 
            (SELECT COUNT(*) 
             FROM Appointment a 
             WHERE a.Employee_ID = employee_id), 2), 'No Appointments') 
        AS Completion_Rate
    FROM Employee e
    JOIN Department d ON e.Department_ID = d.Department_ID
    LEFT JOIN Feedback f ON e.Employee_ID = f.Employee_ID

    WHERE e.Employee_ID = employee_id

    GROUP BY e.Employee_ID, d.Department_Name;
END $$

DELIMITER;

SELECT 
    COUNT(CASE WHEN Status = 'Completed' THEN 1 END) AS CompletedAppointments,
    COUNT(CASE WHEN Status = 'Cancelled' THEN 1 END) AS CanceledAppointments,
    (COUNT(CASE WHEN Status = 'Completed' THEN 1 END) / 
     COUNT(CASE WHEN Status IN ('Completed', 'Cancelled') THEN 1 END)) * 100 AS CompletionRate
FROM Appointment;

CALL Get_Employee_Rating(90);



DELIMITER $$

CREATE PROCEDURE Get_Patient_Disease_Lab_Report(IN patient_id INT)
BEGIN
    SELECT p.Patient_ID, 
           CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient_Name, 
           d.Name AS Disease_Name, 
           pr.Admitted_On, 
           pr.Discharge_On, 
           lt.Test_Name, 
           plr.Test_Value, 
           plr.Comment AS Lab_Comment, 
           pb.Amount AS Total_Bill, 
           pb.Transaction_Type
    FROM Patient p
    JOIN Patient_Register pr ON p.Patient_ID = pr.Patient_ID
    LEFT JOIN Patient_Disease pd ON pr.Patient_Register_ID = pd.Patient_Register_ID
    LEFT JOIN Disease d ON pd.Disease_ID = d.Disease_ID
    LEFT JOIN Patient_Lab_Report plr ON pr.Patient_Register_ID = plr.Patient_Register_ID
    LEFT JOIN Lab_Test lt ON plr.Lab_Test_ID = lt.Lab_Test_ID
    LEFT JOIN Patient_Billing pb ON pr.Patient_Register_ID = pb.Patient_Register_ID
    WHERE p.Patient_ID = patient_id
    ORDER BY pr.Admitted_On DESC, plr.Patient_Lab_Report_ID DESC
    LIMIT 10;
END $$
DELIMITER ;

Call Get_Patient_Disease_Lab_Report(300)

## Stored Procedure 2

DELIMITER $$
DROP PROCEDURE IF EXISTS Check_Patient_Health;
CREATE PROCEDURE Check_Patient_Health(IN patient_id INT)
BEGIN
    DECLARE disease_count INT DEFAULT 0;
    DECLARE chronic_status VARCHAR(20);
    DECLARE abnormal_tests INT DEFAULT 0;
    
    -- Count number of diseases a patient has
    SELECT COUNT(pd.Disease_ID) INTO disease_count
    FROM Patient_Register pr
    JOIN Patient_Disease pd ON pr.Patient_Register_ID = pd.Patient_Register_ID
    WHERE pr.Patient_ID = patient_id;
    
    -- Determine if the patient is chronic
    IF disease_count > 3 THEN
        SET chronic_status = 'Chronic Patient';
    ELSE
        SET chronic_status = 'Non-Chronic';
    END IF;
    
    -- Count abnormal lab tests
    SELECT COUNT(*) INTO abnormal_tests
    FROM Patient_Lab_Report plr
    JOIN Lab_Test lt ON plr.Lab_Test_ID = lt.Lab_Test_ID
    JOIN Patient_Register pr ON plr.Patient_Register_ID = pr.Patient_Register_ID
    WHERE pr.Patient_ID = patient_id 
    AND ((CAST(plr.Test_Value AS DECIMAL(10,2)) - CAST(lt.Min_Value AS DECIMAL(10,2))< 0.5) 
         OR (CAST(plr.Test_Value AS DECIMAL(10,2)) - CAST(lt.Max_Value AS DECIMAL(10,2))< 0.5));

    SELECT p.Patient_ID, 
           CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient_Name,
           disease_count AS Total_Diseases,
           chronic_status AS Health_Status,
           abnormal_tests AS Abnormal_Lab_Test_Count
    FROM Patient p
    WHERE p.Patient_ID = patient_id;
    
END $$

DELIMITER ;
CALL Check_Patient_Health(974);









SELECT e.Employee_ID, CONCAT(e.First_Name, ' ', e.Last_Name) AS Doctor_Name, d.Department_Name, COUNT(a.Appointment_ID) AS TotalAppointments
FROM Employee e
JOIN Appointment a ON e.Employee_ID = a.Employee_ID
JOIN Department d ON e.Department_ID = d.Department_ID
-- Filter only doctors
WHERE e.Role_ID = 2  
GROUP BY e.Employee_ID
ORDER BY TotalAppointments DESC;


-- Insert sample employees into the Employee table
INSERT INTO am_dpadala.Employee 
(`Employee_ID`, `Email_ID`, `Department_ID`, `Password`, `First_Name`, `Last_Name`, `Date_Of_Birth`, `Gender`, `Phone_Number`, `Role_ID`, `Created_On`, `Modified_On`) 
VALUES 
(301, 'dpadala@seattleu.edu', 2, 'dsowjanya123', 'Devi', 'Sowjanya', '2001-06-15', 'Male', '1234567890', 1, '2024-01-01', NULL),
(302, 'jbandi@seattleu.edu', 3, 'jeevithab098', 'Jeevitha', 'Bandi', '2001-08-22', 'Female', '9876543210', 2, '2024-02-15', NULL),
(303, 'npasupula@seattleu.edu', 1, 'npasupula456', 'naveen', 'Pasupula', '2001-12-05', 'Male', '5678901234', 3, '2024-03-10', NULL);



SET SQL_SAFE_UPDATES = 0;
DELETE FROM Appointment;
SET SQL_SAFE_UPDATES = 1; -- Re-enable safe mode



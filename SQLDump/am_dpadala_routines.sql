-- MySQL dump 10.13  Distrib 8.0.40, for macos14 (arm64)
--
-- Host: cssql.seattleu.edu    Database: am_dpadala
-- ------------------------------------------------------
-- Server version	8.0.36

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping routines for database 'am_dpadala'
--
/*!50003 DROP PROCEDURE IF EXISTS `CalculateFactorial` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;

/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Check_Patient_Health` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`am_dpadala`@`%` PROCEDURE `Check_Patient_Health`(IN patient_id INT)
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

    -- Return patient details with health analysis
    SELECT p.Patient_ID, 
           CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient_Name,
           disease_count AS Total_Diseases,
           chronic_status AS Health_Status,
           abnormal_tests AS Abnormal_Lab_Test_Count
    FROM Patient p
    WHERE p.Patient_ID = patient_id;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Get_Employee_Rating` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`am_dpadala`@`%` PROCEDURE `Get_Employee_Rating`(IN employee_id INT)
BEGIN
    -- Retrieve employee details along with ratings and appointment statistics
    
    SELECT 
        e.Employee_ID, 
        CONCAT(e.First_Name, ' ', e.Last_Name) AS Employee_Name,  -- Combines first and last name for readability
        d.Department_Name,  -- Fetches department name for better identification

        COUNT(f.Feedback_ID) AS Total_Feedbacks,  -- Total number of feedbacks received by the employee
        IFNULL(ROUND(AVG(f.Rating), 2), 'No Ratings') AS Avg_Rating,  -- Average feedback rating (rounded to 2 decimal places); If no rating exists, display 'No Ratings'

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
    JOIN Department d ON e.Department_ID = d.Department_ID  -- Ensure department details are included
    LEFT JOIN Feedback f ON e.Employee_ID = f.Employee_ID  -- Left Join allows employees with no feedback to still be included

    WHERE e.Employee_ID = employee_id  -- Filter data for a specific employee

    GROUP BY e.Employee_ID, d.Department_Name;  -- Grouping ensures data is fetched uniquely for each employee
END ;;
DELIMITER ;
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
-- Table structure for table `Lab_Test`
--

DROP TABLE IF EXISTS `Lab_Test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Lab_Test` (
  `Lab_Test_ID` int NOT NULL,
  `Test_Name` varchar(45) DEFAULT NULL,
  `Min_Value` varchar(10) DEFAULT NULL,
  `Max_Value` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`Lab_Test_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Lab_Test`
--

LOCK TABLES `Lab_Test` WRITE;
/*!40000 ALTER TABLE `Lab_Test` DISABLE KEYS */;
INSERT INTO `Lab_Test` VALUES (1,'Blood Test','13.5','17.55'),(2,'Urine Analysis','1.005','1.03'),(3,'X-ray','0.1','0.5'),(4,'CT Scan','1','10'),(5,'MRI','0.5','5'),(6,'Ultrasound','0.5','5'),(7,'Biopsy','0','100'),(8,'Electrocardiogram','60','100'),(9,'Thyroid Function Test','0.4','4'),(10,'Liver Function Test','7','56'),(11,'Diabetes','70','99'),(12,'Hypertension','90','120'),(13,'Covid-19','0','0'),(14,'HIV Test','20','1000'),(15,'Pregnancy Test','0','0');
/*!40000 ALTER TABLE `Lab_Test` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-03-10 16:31:54

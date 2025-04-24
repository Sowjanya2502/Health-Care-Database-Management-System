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
-- Table structure for table `Disease`
--

DROP TABLE IF EXISTS `Disease`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Disease` (
  `Disease_ID` int NOT NULL,
  `Name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Disease_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Disease`
--

LOCK TABLES `Disease` WRITE;
/*!40000 ALTER TABLE `Disease` DISABLE KEYS */;
INSERT INTO `Disease` VALUES (1,'COVID-19'),(2,'Influenza'),(3,'Common Cold'),(4,'Malaria'),(5,'Ebola'),(6,'Zika Virus'),(7,'Dengue Fever'),(8,'Tuberculosis'),(9,'Cholera'),(10,'Measles'),(11,'Chickenpox'),(12,'Hepatitis'),(13,'Lyme Disease'),(14,'SARS'),(15,'Yellow Fever'),(16,'Pneumonia'),(17,'Bronchitis'),(18,'Diabetes'),(19,'HIV/AIDS'),(20,'Alzheimer\'s Disease'),(21,'Parkinson\'s Disease'),(22,'Cancer'),(23,'Heart Disease'),(24,'Stroke'),(25,'Arthritis'),(26,'Osteoporosis'),(27,'Eczema'),(28,'Psoriasis'),(29,'Asthma'),(30,'Allergies'),(31,'Gout'),(32,'Ulcer'),(33,'Kidney Stones'),(34,'Appendicitis'),(35,'Gallstones'),(36,'Hemorrhoids'),(37,'Cataracts'),(38,'Glaucoma'),(39,'Hypertension'),(40,'Hyperthyroidism'),(41,'Hypothyroidism'),(42,'Anemia'),(43,'Leukemia'),(44,'Lupus'),(45,'Multiple Sclerosis'),(46,'Rheumatoid Arthritis'),(47,'Schizophrenia'),(48,'Bipolar Disorder'),(49,'Depression'),(50,'Anxiety Disorder');
/*!40000 ALTER TABLE `Disease` ENABLE KEYS */;
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

/*M!999999\- enable the sandbox mode */ 

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `drawsql0909` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */;

USE `drawsql0909`;
DROP TABLE IF EXISTS `Esindaja`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Esindaja` (
  `õpilaseidkood` bigint(20) unsigned NOT NULL,
  `kood` varchar(6) NOT NULL,
  `eesnimi` varchar(255) NOT NULL,
  `perekonnanimi` varchar(255) NOT NULL,
  PRIMARY KEY (`õpilaseidkood`,`kood`),
  CONSTRAINT `esindaja_õpilaseidkood_foreign` FOREIGN KEY (`õpilaseidkood`) REFERENCES `Õpilane` (`idkood`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `Esindaja` WRITE;
/*!40000 ALTER TABLE `Esindaja` DISABLE KEYS */;
INSERT INTO `Esindaja` VALUES
(50503020002,'E002','Peeter','Maasikas'),
(50601010001,'E001','Anna','Onoprijuk'),
(50712120003,'E003','Kadri','Kuusk'),
(50805050004,'E004','Tiit','Lepik');
/*!40000 ALTER TABLE `Esindaja` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
DROP TABLE IF EXISTS `Rühm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Rühm` (
  `kood` varchar(6) NOT NULL,
  `kirjeldus` varchar(255) NOT NULL,
  PRIMARY KEY (`kood`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `Rühm` WRITE;
/*!40000 ALTER TABLE `Rühm` DISABLE KEYS */;
INSERT INTO `Rühm` VALUES
('IT-24','Infotehnoloogia 24'),
('KT-24','Küberturve 24'),
('TA-24A','Tarkvaraarendus 24A'),
('TA-24B','Tarkvaraarendus 24B');
/*!40000 ALTER TABLE `Rühm` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
DROP TABLE IF EXISTS `Rühmaine`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Rühmaine` (
  `rühm` varchar(6) NOT NULL,
  `aine` varchar(6) NOT NULL,
  PRIMARY KEY (`rühm`,`aine`),
  KEY `rühmaine_aine_foreign` (`aine`),
  CONSTRAINT `rühmaine_aine_foreign` FOREIGN KEY (`aine`) REFERENCES `Õppeaine` (`kood`),
  CONSTRAINT `rühmaine_rühm_foreign` FOREIGN KEY (`rühm`) REFERENCES `Rühm` (`kood`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `Rühmaine` WRITE;
/*!40000 ALTER TABLE `Rühmaine` DISABLE KEYS */;
INSERT INTO `Rühmaine` VALUES
('TA-24B','ANDM'),
('IT-24','JS'),
('TA-24B','OS'),
('TA-24A','PROG'),
('TA-24B','PROG');
/*!40000 ALTER TABLE `Rühmaine` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
DROP TABLE IF EXISTS `Õpilane`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Õpilane` (
  `idkood` bigint(20) unsigned NOT NULL,
  `eesnimi` varchar(255) NOT NULL,
  `perekonnanimi` varchar(255) NOT NULL,
  `sünniaeg` date NOT NULL,
  `aadress` varchar(255) DEFAULT NULL,
  `telefon` varchar(255) DEFAULT NULL,
  `rühmakood` varchar(6) NOT NULL,
  PRIMARY KEY (`idkood`),
  KEY `Õpilane_rühmakood_foreign` (`rühmakood`),
  CONSTRAINT `Õpilane_rühmakood_foreign` FOREIGN KEY (`rühmakood`) REFERENCES `Rühm` (`kood`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `Õpilane` WRITE;
/*!40000 ALTER TABLE `Õpilane` DISABLE KEYS */;
INSERT INTO `Õpilane` VALUES
(50503020002,'Mari','Maasikas','2005-03-02','Tallinn',NULL,'TA-24B'),
(50601010001,'Jegor','Onoprijuk','2006-01-01','Tartu','+372 5551 0001','TA-24B'),
(50712120003,'Karl','Kuusk','2007-12-12','Pärnu','+372 5551 0003','TA-24A'),
(50805050004,'Liis','Lepik','2008-05-05',NULL,NULL,'IT-24');
/*!40000 ALTER TABLE `Õpilane` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
DROP TABLE IF EXISTS `Õppeaine`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Õppeaine` (
  `kood` varchar(6) NOT NULL,
  `kirjeldus` varchar(255) NOT NULL,
  PRIMARY KEY (`kood`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `Õppeaine` WRITE;
/*!40000 ALTER TABLE `Õppeaine` DISABLE KEYS */;
INSERT INTO `Õppeaine` VALUES
('ANDM','Andmebaasid'),
('JS','JavaScript'),
('OS','Operatsioonisüsteemid'),
('PROG','Programmeerimise alused');
/*!40000 ALTER TABLE `Õppeaine` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;


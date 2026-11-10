/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.20-13.0.2-MariaDB, for osx10.21 (arm64)
--
-- Host: localhost    Database: jalgpall2026
-- ------------------------------------------------------
-- Server version	13.0.2-MariaDB

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

--
-- Current Database: `jalgpall2026`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `jalgpall2026` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci */;

USE `jalgpall2026`;

--
-- Table structure for table `klubi`
--

DROP TABLE IF EXISTS `klubi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `klubi` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nimi` varchar(80) NOT NULL,
  `linn` varchar(50) NOT NULL,
  `staadion` varchar(80) NOT NULL,
  `treener_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nimi` (`nimi`),
  KEY `treener_id` (`treener_id`),
  CONSTRAINT `1` FOREIGN KEY (`treener_id`) REFERENCES `treener` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `klubi`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `klubi` WRITE;
/*!40000 ALTER TABLE `klubi` DISABLE KEYS */;
INSERT INTO `klubi` VALUES
(1,'FC Flora','Tallinn','Lillekula staadion',1),
(2,'Nomme Kalju','Tallinn','Hiiu staadion',2),
(3,'Paide Linnameeskond','Paide','Paide linnastaadion',3);
/*!40000 ALTER TABLE `klubi` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mang`
--

DROP TABLE IF EXISTS `mang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mang` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `koduklubi_id` int(11) NOT NULL,
  `voorklubi_id` int(11) NOT NULL,
  `kodu_varavad` int(11) NOT NULL,
  `voor_varavad` int(11) NOT NULL,
  `tulemus` varchar(10) NOT NULL,
  `algusaeg` datetime NOT NULL,
  `publiku_arv` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `koduklubi_id` (`koduklubi_id`),
  KEY `voorklubi_id` (`voorklubi_id`),
  CONSTRAINT `1` FOREIGN KEY (`koduklubi_id`) REFERENCES `klubi` (`id`),
  CONSTRAINT `2` FOREIGN KEY (`voorklubi_id`) REFERENCES `klubi` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mang`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mang` WRITE;
/*!40000 ALTER TABLE `mang` DISABLE KEYS */;
INSERT INTO `mang` VALUES
(1,1,2,2,1,'2:1','2026-03-14 17:00:00',3120),
(2,3,1,0,3,'0:3','2026-03-21 15:30:00',1480);
/*!40000 ALTER TABLE `mang` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mangija`
--

DROP TABLE IF EXISTS `mangija`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mangija` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `eesnimi` varchar(50) NOT NULL,
  `perekonnanimi` varchar(50) NOT NULL,
  `synniaeg` date NOT NULL,
  `riik` varchar(50) NOT NULL,
  `palk` decimal(10,2) NOT NULL,
  `klubi_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `klubi_id` (`klubi_id`),
  CONSTRAINT `1` FOREIGN KEY (`klubi_id`) REFERENCES `klubi` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mangija`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mangija` WRITE;
/*!40000 ALTER TABLE `mangija` DISABLE KEYS */;
INSERT INTO `mangija` VALUES
(1,'Rauno','Sappinen','1996-02-23','Eesti',4200.00,1),
(2,'Markus','Poom','2000-07-07','Eesti',3900.00,1),
(3,'Marko','Lipp','1999-04-15','Eesti',3100.00,1),
(4,'Danil','Kuznetsov','2001-10-01','Eesti',2700.00,1),
(5,'Vlasi','Sinjavski','1995-09-06','Eesti',3600.00,2),
(6,'Mihkel','Ainsalu','1996-03-20','Eesti',3300.00,2),
(7,'Tomi','Saarelma','1997-11-14','Soome',2900.00,2),
(8,'Henrik','Purg','1998-01-11','Eesti',2800.00,3),
(9,'Robi','Saarma','2001-05-03','Eesti',2400.00,3),
(10,'Edgars','Berzins','1994-08-29','Lati',2500.00,3);
/*!40000 ALTER TABLE `mangija` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `treener`
--

DROP TABLE IF EXISTS `treener`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `treener` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `eesnimi` varchar(50) NOT NULL,
  `perekonnanimi` varchar(50) NOT NULL,
  `synniaeg` date NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `treener`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `treener` WRITE;
/*!40000 ALTER TABLE `treener` DISABLE KEYS */;
INSERT INTO `treener` VALUES
(1,'Jurgen','Henn','1985-03-12'),
(2,'Roman','Kozhuhhovski','1983-07-09'),
(3,'Karel','Voolaid','1980-06-25');
/*!40000 ALTER TABLE `treener` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Temporary table structure for view `turniiritabel`
--

DROP TABLE IF EXISTS `turniiritabel`;
/*!50001 DROP VIEW IF EXISTS `turniiritabel`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `turniiritabel` AS SELECT
 NULL AS `klubi`,
 NULL AS `mange`,
 NULL AS `voite`,
 NULL AS `viike`,
 NULL AS `kaotusi`,
 NULL AS `loodud`,
 NULL AS `saadud`,
 NULL AS `vahe`,
 NULL AS `punktid` */;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'jalgpall2026'
--

--
-- Dumping routines for database 'jalgpall2026'
--

--
-- Current Database: `jalgpall2026`
--

USE `jalgpall2026`;

--
-- Final view structure for view `turniiritabel`
--

/*!50001 DROP VIEW IF EXISTS `turniiritabel`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED  SQL SECURITY INVOKER VIEW `turniiritabel` AS select `k`.`nimi` AS `klubi`,count(`r`.`klubi_id`) AS `mange`,sum(case when `r`.`loodud` > `r`.`saadud` then 1 else 0 end) AS `voite`,sum(case when `r`.`loodud` = `r`.`saadud` then 1 else 0 end) AS `viike`,sum(case when `r`.`loodud` < `r`.`saadud` then 1 else 0 end) AS `kaotusi`,sum(`r`.`loodud`) AS `loodud`,sum(`r`.`saadud`) AS `saadud`,sum(`r`.`loodud`) - sum(`r`.`saadud`) AS `vahe`,sum(case when `r`.`loodud` > `r`.`saadud` then 3 when `r`.`loodud` = `r`.`saadud` then 1 else 0 end) AS `punktid` from (`klubi` `k` left join (select `mang`.`koduklubi_id` AS `klubi_id`,`mang`.`kodu_varavad` AS `loodud`,`mang`.`voor_varavad` AS `saadud` from `mang` union all select `mang`.`voorklubi_id` AS `klubi_id`,`mang`.`voor_varavad` AS `loodud`,`mang`.`kodu_varavad` AS `saadud` from `mang`) `r` on(`r`.`klubi_id` = `k`.`id`)) group by `k`.`id`,`k`.`nimi` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-11-10 18:32:36

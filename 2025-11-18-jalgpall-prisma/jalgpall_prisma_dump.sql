/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.20-13.0.2-MariaDB, for osx10.21 (arm64)
--
-- Host: 127.0.0.1    Database: jalgpall_prisma
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
-- Current Database: `jalgpall_prisma`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `jalgpall_prisma` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci */;

USE `jalgpall_prisma`;

--
-- Table structure for table `Club`
--

DROP TABLE IF EXISTS `Club`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Club` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `location` varchar(60) NOT NULL,
  `name` varchar(80) NOT NULL,
  `stadium` varchar(80) NOT NULL,
  `createdat` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `Club_name_key` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Club`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `Club` WRITE;
/*!40000 ALTER TABLE `Club` DISABLE KEYS */;
INSERT INTO `Club` VALUES
(4,'Tallinn','FC Flora','Lillekula staadion','2026-11-10 19:53:38.780'),
(5,'Tallinn','Nomme Kalju','Hiiu staadion','2026-11-10 19:53:38.780'),
(6,'Paide','Paide Linnameeskond','Paide linnastaadion','2026-11-10 19:53:38.780');
/*!40000 ALTER TABLE `Club` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `Coach`
--

DROP TABLE IF EXISTS `Coach`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Coach` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `firstname` varchar(50) NOT NULL,
  `lastname` varchar(50) NOT NULL,
  `countryid` int(11) NOT NULL,
  `createdat` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  PRIMARY KEY (`id`),
  KEY `Coach_countryid_idx` (`countryid`),
  CONSTRAINT `Coach_countryid_fkey` FOREIGN KEY (`countryid`) REFERENCES `Country` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Coach`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `Coach` WRITE;
/*!40000 ALTER TABLE `Coach` DISABLE KEYS */;
INSERT INTO `Coach` VALUES
(4,'Jegor','Onoprijuk',4,'2026-11-10 19:53:38.781'),
(5,'Jurgen','Henn',4,'2026-11-10 19:53:38.781'),
(6,'Karel','Voolaid',4,'2026-11-10 19:53:38.781');
/*!40000 ALTER TABLE `Coach` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `CoachClub`
--

DROP TABLE IF EXISTS `CoachClub`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `CoachClub` (
  `coachid` int(11) NOT NULL,
  `clubid` int(11) NOT NULL,
  `role` varchar(40) NOT NULL DEFAULT 'peatreener',
  `createdat` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  PRIMARY KEY (`coachid`,`clubid`),
  KEY `CoachClub_clubid_idx` (`clubid`),
  CONSTRAINT `CoachClub_clubid_fkey` FOREIGN KEY (`clubid`) REFERENCES `Club` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `CoachClub_coachid_fkey` FOREIGN KEY (`coachid`) REFERENCES `Coach` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CoachClub`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `CoachClub` WRITE;
/*!40000 ALTER TABLE `CoachClub` DISABLE KEYS */;
INSERT INTO `CoachClub` VALUES
(4,4,'peatreener','2026-11-10 19:53:38.781'),
(4,5,'peatreener','2026-11-10 19:53:38.781'),
(5,4,'abitreener','2026-11-10 19:53:38.781'),
(6,6,'peatreener','2026-11-10 19:53:38.781');
/*!40000 ALTER TABLE `CoachClub` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `Country`
--

DROP TABLE IF EXISTS `Country`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Country` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(60) NOT NULL,
  `code` varchar(3) NOT NULL,
  `createdat` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `Country_code_key` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Country`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `Country` WRITE;
/*!40000 ALTER TABLE `Country` DISABLE KEYS */;
INSERT INTO `Country` VALUES
(4,'Eesti','EST','2026-11-10 19:53:38.778'),
(5,'Soome','FIN','2026-11-10 19:53:38.779'),
(6,'Lati','LVA','2026-11-10 19:53:38.779');
/*!40000 ALTER TABLE `Country` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `Game`
--

DROP TABLE IF EXISTS `Game`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Game` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `homeclub` int(11) NOT NULL,
  `foreignclub` int(11) NOT NULL,
  `homescore` int(11) NOT NULL,
  `foreignscore` int(11) NOT NULL,
  `homeformation` varchar(20) NOT NULL,
  `foreignformation` varchar(20) NOT NULL,
  `gametime` datetime(3) NOT NULL,
  `createdat` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  PRIMARY KEY (`id`),
  KEY `Game_homeclub_idx` (`homeclub`),
  KEY `Game_foreignclub_idx` (`foreignclub`),
  CONSTRAINT `Game_foreignclub_fkey` FOREIGN KEY (`foreignclub`) REFERENCES `Club` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `Game_homeclub_fkey` FOREIGN KEY (`homeclub`) REFERENCES `Club` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Game`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `Game` WRITE;
/*!40000 ALTER TABLE `Game` DISABLE KEYS */;
INSERT INTO `Game` VALUES
(3,4,5,2,1,'4-3-3','4-4-2','2025-11-15 15:00:00.000','2026-11-10 19:53:38.782'),
(4,6,4,0,3,'5-3-2','4-3-3','2025-11-16 13:30:00.000','2026-11-10 21:53:38.782');
/*!40000 ALTER TABLE `Game` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `Player`
--

DROP TABLE IF EXISTS `Player`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Player` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `firstname` varchar(50) NOT NULL,
  `lastname` varchar(50) NOT NULL,
  `salary` decimal(10,2) NOT NULL,
  `countryid` int(11) NOT NULL,
  `clubid` int(11) NOT NULL,
  `createdat` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  PRIMARY KEY (`id`),
  KEY `Player_clubid_idx` (`clubid`),
  KEY `Player_countryid_idx` (`countryid`),
  CONSTRAINT `Player_clubid_fkey` FOREIGN KEY (`clubid`) REFERENCES `Club` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `Player_countryid_fkey` FOREIGN KEY (`countryid`) REFERENCES `Country` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Player`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `Player` WRITE;
/*!40000 ALTER TABLE `Player` DISABLE KEYS */;
INSERT INTO `Player` VALUES
(7,'Rauno','Sappinen',4200.00,4,4,'2026-11-10 19:53:38.782'),
(8,'Markus','Poom',3900.00,4,4,'2026-11-10 19:53:38.782'),
(9,'Vlasi','Sinjavski',3600.00,4,5,'2026-11-10 19:53:38.782'),
(10,'Tomi','Saarelma',2900.00,5,5,'2026-11-10 19:53:38.782'),
(11,'Henrik','Purg',2800.00,4,6,'2026-11-10 19:53:38.782'),
(12,'Edgars','Berzins',2500.00,6,6,'2026-11-10 19:53:38.782');
/*!40000 ALTER TABLE `Player` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `_prisma_migrations`
--

DROP TABLE IF EXISTS `_prisma_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `_prisma_migrations` (
  `id` varchar(36) NOT NULL,
  `checksum` varchar(64) NOT NULL,
  `finished_at` datetime(3) DEFAULT NULL,
  `migration_name` varchar(255) NOT NULL,
  `logs` text DEFAULT NULL,
  `rolled_back_at` datetime(3) DEFAULT NULL,
  `started_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `applied_steps_count` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `_prisma_migrations`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `_prisma_migrations` WRITE;
/*!40000 ALTER TABLE `_prisma_migrations` DISABLE KEYS */;
INSERT INTO `_prisma_migrations` VALUES
('c6fdc698-16f0-454b-a8ef-15782730f2d3','0ebb664d01b112eaa8d247877ceacbb4a639f256042898463af1d9f61a35afa8','2026-11-10 19:52:32.095','20261110195231_init',NULL,NULL,'2026-11-10 19:52:31.741',1);
/*!40000 ALTER TABLE `_prisma_migrations` ENABLE KEYS */;
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

-- Dump completed on 2026-11-10 21:53:38

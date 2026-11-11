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

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `yhobu` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */;

USE `yhobu`;
DROP TABLE IF EXISTS `arst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `arst` (
  `isikukood` bigint(20) unsigned NOT NULL COMMENT 'Arsti isikukood',
  `eesnimi` varchar(64) NOT NULL COMMENT 'eesnimi',
  `perekonnanimi` varchar(64) DEFAULT NULL,
  `inserted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `telefon` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`isikukood`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Hobuseid arstiavd arstid';
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `arst` WRITE;
/*!40000 ALTER TABLE `arst` DISABLE KEYS */;
INSERT INTO `arst` VALUES
(12312312312,'Hille',NULL,'2025-10-27 16:01:22','2025-10-27 16:01:22',NULL),
(12312312313,'Edgar',NULL,'2025-10-27 16:01:40','2025-10-27 16:01:40',NULL),
(12312312314,'Vassili',NULL,'2025-10-27 16:01:40','2025-10-27 16:01:40',NULL),
(12312312315,'Toomas','Kask','2026-11-11 02:02:46','2026-11-11 02:02:46','5600001'),
(12312312316,'Liina','Sepp','2026-11-11 02:02:46','2026-11-11 02:02:46','5600002'),
(12312312317,'Madis','Lill','2026-11-11 02:02:46','2026-11-11 02:02:46','5600003'),
(12312312318,'Katrin','Pold','2026-11-11 02:02:46','2026-11-11 02:02:46','5600004'),
(12312312319,'Rasmus','Teder','2026-11-11 02:02:46','2026-11-11 02:02:46','5600005'),
(12312312320,'Helen','Mägi','2026-11-11 02:02:46','2026-11-11 02:02:46','5600006'),
(12312312321,'Andres','Raud','2026-11-11 02:02:46','2026-11-11 02:02:46','5600007');
/*!40000 ALTER TABLE `arst` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
DROP TABLE IF EXISTS `hobune`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `hobune` (
  `registreerimiskood` varchar(8) NOT NULL,
  `nimi` varchar(64) NOT NULL,
  `aasta` year(4) DEFAULT NULL,
  `sugu` enum('mark','mara','ruun') DEFAULT NULL COMMENT 'hobuse sugu',
  `omanik_isikukood` bigint(20) unsigned NOT NULL,
  `tall_kood` varchar(6) DEFAULT NULL,
  `inserted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`registreerimiskood`),
  KEY `omanik_isikukood` (`omanik_isikukood`),
  KEY `tall_kood` (`tall_kood`),
  CONSTRAINT `hobune_ibfk_1` FOREIGN KEY (`omanik_isikukood`) REFERENCES `omanik` (`isikukood`),
  CONSTRAINT `hobune_ibfk_2` FOREIGN KEY (`tall_kood`) REFERENCES `tall` (`kood`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Hobused';
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `hobune` WRITE;
/*!40000 ALTER TABLE `hobune` DISABLE KEYS */;
INSERT INTO `hobune` VALUES
('200','Kahli',2010,'ruun',100002,'5','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('201','Kaine',2011,'mark',100002,'5A','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('202','Kalina',2012,'mara',100003,'7','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('203','Kalondra',2013,'ruun',100003,'7','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('204','Kar Kalim',2014,'mark',100003,'7','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('205','Karisha',2015,'mara',100004,'7A','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('206','Kasimira',2016,'ruun',100004,'7A','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('207','Katareena',2017,'mark',100004,'7A','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('208','Katifa',2018,'mara',100006,'7A','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('209','Kayleigh',2019,'ruun',100006,'7A','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('210','Keener Than Keen',2020,'mark',100006,'7A','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('211','Kei',2021,'mara',36576574545,'7B','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('212','Kellendria',2022,'ruun',36576574545,'7B','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('213','Kelly Green',2010,'mark',100006,'7B','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('214','Kelvin',2011,'mara',100006,'7B','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('215','Keno',2012,'ruun',100006,'7B','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('216','Kentucky Roses',2013,'mark',100006,'7B','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('217','Kermit',2014,'mara',100005,'2','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('218','Kevah',2015,'ruun',100000,'2','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('219','Kiawa',2016,'mark',100001,'2','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('220','King',2017,'mara',100000,'2','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('221','King Quakers crystal',2018,'ruun',100001,'2','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('222','Kings Ransom',2019,'mark',100001,'2','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('223','Kipawa',2020,'mara',100000,'2','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('224','Kirby',2021,'ruun',100001,'2','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('225','Kiss',2022,'mark',100003,'5','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('226','Kiss Me Clown',2010,'mara',100004,'5','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('227','Kissin the Sky',2011,'ruun',100005,'5','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('228','Kit-Kats Chat',2012,'mark',100006,'5','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('229','Kitty Hawk',2013,'mara',36576574545,'5','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('230','Kizi',2014,'ruun',100004,'5','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('231','Knight',2015,'mark',100004,'5','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('232','Kochiese',2016,'mara',100008,'5','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('233','Kodiak',2017,'ruun',100008,'5','2025-10-27 15:49:39','2026-11-11 02:02:46');
/*!40000 ALTER TABLE `hobune` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
DROP TABLE IF EXISTS `hobuste_treeningud`;
/*!50001 DROP VIEW IF EXISTS `hobuste_treeningud`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `hobuste_treeningud` AS SELECT
 NULL AS `hobune`,
 NULL AS `treeninguid` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `inventar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventar` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `kirjeldus` varchar(100) DEFAULT NULL,
  `hind` decimal(8,2) DEFAULT NULL,
  `tall_kood` varchar(6) DEFAULT NULL,
  `omanik_isikukood` bigint(20) unsigned DEFAULT NULL COMMENT 'inventari omanik',
  `inserted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `tall_kood` (`tall_kood`),
  KEY `omanik_isikukood` (`omanik_isikukood`),
  CONSTRAINT `inventar_ibfk_1` FOREIGN KEY (`tall_kood`) REFERENCES `tall` (`kood`),
  CONSTRAINT `inventar_ibfk_2` FOREIGN KEY (`omanik_isikukood`) REFERENCES `omanik` (`isikukood`),
  CONSTRAINT `inventar_chk_1` CHECK (`tall_kood` is null and `omanik_isikukood` is not null or `tall_kood` is not null and `omanik_isikukood` is null)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Inventar koos hindadega';
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `inventar` WRITE;
/*!40000 ALTER TABLE `inventar` DISABLE KEYS */;
INSERT INTO `inventar` VALUES
(2,'Sadul',1203.00,NULL,36576574545,'2025-10-27 15:52:55','2025-10-27 15:53:34'),
(3,'Valjad',85.00,NULL,100000,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(4,'Tekk',60.50,NULL,100001,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(5,'Sadul Prestige',1450.00,NULL,100002,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(6,'Kiiver',95.00,NULL,100003,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(7,'Ratsasaapad',180.00,NULL,100004,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(8,'Hobuse transpordikott',120.00,NULL,100006,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(9,'Maneezi tokked',240.00,'5',NULL,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(10,'Soogikausid (20 tk)',180.00,'7',NULL,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(11,'Heinaveoauto',3200.00,'2',NULL,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(12,'Kaarik',2100.00,'7B',NULL,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(13,'Treeningtool',75.00,'5A',NULL,'2026-11-11 02:02:46','2026-11-11 02:02:46');
/*!40000 ALTER TABLE `inventar` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
DROP TABLE IF EXISTS `nimed`;
/*!50001 DROP VIEW IF EXISTS `nimed`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `nimed` AS SELECT
 NULL AS `eesnimi`,
 NULL AS `perekonnanimi`,
 NULL AS `nimi` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `omanik`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `omanik` (
  `isikukood` bigint(20) unsigned NOT NULL,
  `eesnimi` varchar(64) NOT NULL,
  `perekonnanimi` varchar(64) NOT NULL,
  `aadress` varchar(64) DEFAULT NULL,
  `telefon` varchar(16) DEFAULT NULL,
  `inserted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`isikukood`),
  UNIQUE KEY `telefon` (`telefon`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Omanikud';
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `omanik` WRITE;
/*!40000 ALTER TABLE `omanik` DISABLE KEYS */;
INSERT INTO `omanik` VALUES
(100000,'Aadu','Laid','Tallinn','55231231','2025-10-27 15:49:39','2025-10-27 15:49:39'),
(100001,'Ester','Teeveer','Kuressaare','5832325','2025-10-27 15:49:39','2025-10-27 15:49:39'),
(100002,'Raul','Väli','Paide','435345643','2025-10-27 15:49:39','2025-10-27 15:49:39'),
(100003,'Mihkel','Soo','Lehtse','534345','2025-10-27 15:49:39','2025-10-27 15:49:39'),
(100004,'Paavo','Neihaus','Aruküla','34534','2025-10-27 15:49:39','2025-10-27 15:49:39'),
(100005,'Oskar','Vallik','Tartu','','2025-10-27 15:49:39','2025-10-27 15:49:39'),
(100006,'Reet','Romanjuk','Pärnu','52377','2025-10-27 15:49:39','2025-10-27 15:49:39'),
(100008,'Carina Romana','Ciaro','Ikla','53242342','2025-10-27 15:49:39','2025-10-27 15:49:39'),
(36576574545,'Jegor','Onoprijuk','Mooste','557877667','2025-10-27 15:49:39','2026-11-11 02:02:46'),
(50203040055,'Mari','Tamm','Tartu','5551234','2026-11-11 02:02:46','2026-11-11 02:02:46');
/*!40000 ALTER TABLE `omanik` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
DROP TABLE IF EXISTS `omanike_arstimaksed`;
/*!50001 DROP VIEW IF EXISTS `omanike_arstimaksed`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `omanike_arstimaksed` AS SELECT
 NULL AS `eesnimi`,
 NULL AS `perekonnanimi`,
 NULL AS `hobune`,
 NULL AS `arst_isikukood`,
 NULL AS `hind` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `omanike_inventari_kulu`;
/*!50001 DROP VIEW IF EXISTS `omanike_inventari_kulu`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `omanike_inventari_kulu` AS SELECT
 NULL AS `isikukood`,
 NULL AS `eesnimi`,
 NULL AS `perekonnanimi`,
 NULL AS `esemeid`,
 NULL AS `inventari_eest_makstud` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `personal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal` (
  `isikukood` bigint(20) unsigned NOT NULL,
  `eesnimi` varchar(64) NOT NULL,
  `perekonnanimi` varchar(64) NOT NULL,
  `ametikoht` enum('treener','tallimees','veterinaarabi','administraator') NOT NULL,
  `tall_kood` varchar(6) DEFAULT NULL COMMENT 'tallimehe tall (iga tallimees tootab tapselt uhes tallis)',
  `telefon` varchar(16) DEFAULT NULL,
  `palk` decimal(8,2) DEFAULT NULL,
  `inserted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`isikukood`),
  UNIQUE KEY `telefon` (`telefon`),
  KEY `tall_kood` (`tall_kood`),
  CONSTRAINT `1` FOREIGN KEY (`tall_kood`) REFERENCES `tall` (`kood`),
  CONSTRAINT `personal_tallimees_chk` CHECK (`ametikoht` <> 'tallimees' or `tall_kood` is not null)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Treenerid, tallimehed ja muu personal';
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `personal` WRITE;
/*!40000 ALTER TABLE `personal` DISABLE KEYS */;
INSERT INTO `personal` VALUES
(36505050055,'Peeter','Saar','tallimees','2','5701005',1500.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(37703030033,'Toomas','Oja','treener',NULL,'5701003',2500.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(37811110011,'Mart','Ilves','veterinaarabi',NULL,'5701011',1800.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(38001010011,'Karl','Kuusk','treener',NULL,'5701001',2400.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(38309090099,'Marko','Tamm','tallimees','7A','5701009',1500.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(38502020022,'Eve','Nurm','treener',NULL,'5701002',2300.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(38806060066,'Rein','Parn','tallimees','5','5701006',1450.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(39107070077,'Jaan','Lepik','tallimees','5A','5701007',1480.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(46512120012,'Helle','Sepp','administraator',NULL,'5701012',1700.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(48508080088,'Liis','Kask','tallimees','7','5701008',1520.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(49004040044,'Kadri','Mets','treener',NULL,'5701004',2350.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(49210100010,'Anu','Rebane','tallimees','7B','5701010',1460.00,'2026-11-11 02:02:46','2026-11-11 02:02:46');
/*!40000 ALTER TABLE `personal` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
DROP TABLE IF EXISTS `tall`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tall` (
  `kood` varchar(6) NOT NULL,
  `nimi` varchar(64) DEFAULT NULL COMMENT 'talli nimi',
  `aadress` varchar(64) NOT NULL,
  `inserted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`kood`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Andmed tallide kohta';
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `tall` WRITE;
/*!40000 ALTER TABLE `tall` DISABLE KEYS */;
INSERT INTO `tall` VALUES
('11','Tall Rakvere 1','Rakvere 1','2026-11-11 02:02:46','2026-11-11 02:02:46'),
('11A','Tall Rakvere 2','Rakvere 2','2026-11-11 02:02:46','2026-11-11 02:02:46'),
('2','Tall Karksi','Karksi','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('5','Tall Tallinn 1','Tallinn 1','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('5A','Tall Tallinn 3','Tallinn 3','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('7','Tall Jäneda 1','Jäneda 1','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('7A','Tall Jäneda 2','Jäneda 2','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('7B','Tall Jäneda 3','Jäneda 3','2025-10-27 15:49:39','2026-11-11 02:02:46'),
('9','Tall Viljandi 1','Viljandi 1','2026-11-11 02:02:46','2026-11-11 02:02:46'),
('9A','Tall Viljandi 2','Viljandi 2','2026-11-11 02:02:46','2026-11-11 02:02:46');
/*!40000 ALTER TABLE `tall` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
DROP TABLE IF EXISTS `talli_ulevaade`;
/*!50001 DROP VIEW IF EXISTS `talli_ulevaade`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `talli_ulevaade` AS SELECT
 NULL AS `kood`,
 NULL AS `nimi`,
 NULL AS `hobuseid`,
 NULL AS `tallimehi`,
 NULL AS `inventari_vaartus` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `tallimehed`;
/*!50001 DROP VIEW IF EXISTS `tallimehed`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `tallimehed` AS SELECT
 NULL AS `isikukood`,
 NULL AS `eesnimi`,
 NULL AS `perekonnanimi`,
 NULL AS `ametikoht`,
 NULL AS `tall_kood`,
 NULL AS `telefon`,
 NULL AS `palk`,
 NULL AS `inserted_at`,
 NULL AS `updated_at` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `treening`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `treening` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `hobune_registreerimiskood` varchar(8) NOT NULL,
  `treener_isikukood` bigint(20) unsigned NOT NULL,
  `tall_kood` varchar(6) NOT NULL COMMENT 'treeninguaas (tall)',
  `programm_nimi` varchar(12) NOT NULL,
  `treeningu_aeg` datetime NOT NULL COMMENT 'kuhu / millal treening kuulub',
  `inserted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `hobune_registreerimiskood` (`hobune_registreerimiskood`),
  KEY `treener_isikukood` (`treener_isikukood`),
  KEY `tall_kood` (`tall_kood`),
  KEY `programm_nimi` (`programm_nimi`),
  CONSTRAINT `1` FOREIGN KEY (`hobune_registreerimiskood`) REFERENCES `hobune` (`registreerimiskood`),
  CONSTRAINT `2` FOREIGN KEY (`treener_isikukood`) REFERENCES `personal` (`isikukood`),
  CONSTRAINT `3` FOREIGN KEY (`tall_kood`) REFERENCES `tall` (`kood`),
  CONSTRAINT `4` FOREIGN KEY (`programm_nimi`) REFERENCES `treeningprogramm` (`nimi`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Treeningud: hobune, treener, treeningukoht, programm, aeg';
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `treening` WRITE;
/*!40000 ALTER TABLE `treening` DISABLE KEYS */;
INSERT INTO `treening` VALUES
(1,'200',38001010011,'5','KOOLISOIT','2025-10-06 17:00:00','2026-11-11 02:02:46','2026-11-11 02:02:46'),
(2,'200',38502020022,'5','TAKISTUS','2025-10-08 18:30:00','2026-11-11 02:02:46','2026-11-11 02:02:46'),
(3,'201',38001010011,'5A','KOOLISOIT','2025-10-07 16:00:00','2026-11-11 02:02:46','2026-11-11 02:02:46'),
(4,'202',37703030033,'7','VASTUPID','2025-10-09 15:00:00','2026-11-11 02:02:46','2026-11-11 02:02:46'),
(5,'203',37703030033,'7','VASTUPID','2025-10-09 16:30:00','2026-11-11 02:02:46','2026-11-11 02:02:46'),
(6,'205',49004040044,'7A','NOORHOBUNE','2025-10-10 10:00:00','2026-11-11 02:02:46','2026-11-11 02:02:46'),
(7,'211',38502020022,'7B','TAKISTUS','2025-10-13 17:30:00','2026-11-11 02:02:46','2026-11-11 02:02:46'),
(8,'211',38001010011,'7B','KOOLISOIT','2025-10-15 17:30:00','2026-11-11 02:02:46','2026-11-11 02:02:46'),
(9,'211',38502020022,'7B','TAKISTUS','2025-10-20 17:30:00','2026-11-11 02:02:46','2026-11-11 02:02:46'),
(10,'220',37703030033,'2','VASTUPID','2025-10-14 14:00:00','2026-11-11 02:02:46','2026-11-11 02:02:46'),
(11,'220',49004040044,'2','TAASTUS','2025-10-21 14:00:00','2026-11-11 02:02:46','2026-11-11 02:02:46'),
(12,'229',38001010011,'5','KOOLISOIT','2025-10-16 18:00:00','2026-11-11 02:02:46','2026-11-11 02:02:46'),
(13,'232',49004040044,'5','NOORHOBUNE','2025-10-17 09:30:00','2026-11-11 02:02:46','2026-11-11 02:02:46'),
(14,'233',38502020022,'5','TAKISTUS','2025-10-22 19:00:00','2026-11-11 02:02:46','2026-11-11 02:02:46');
/*!40000 ALTER TABLE `treening` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER treening_treener_kontroll BEFORE INSERT ON treening
FOR EACH ROW
BEGIN
    IF (SELECT ametikoht FROM personal WHERE isikukood = NEW.treener_isikukood) <> 'treener' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Treeningu treener peab olema personal ametikohaga treener';
    END IF;
END 
*/;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `treeningprogramm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `treeningprogramm` (
  `nimi` varchar(12) NOT NULL,
  `kirjeldus` varchar(255) NOT NULL,
  `vastutaja` bigint(20) unsigned NOT NULL COMMENT 'vastutav isik',
  `inserted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`nimi`),
  KEY `vastutaja` (`vastutaja`),
  CONSTRAINT `1` FOREIGN KEY (`vastutaja`) REFERENCES `personal` (`isikukood`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Treeningprogrammid';
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `treeningprogramm` WRITE;
/*!40000 ALTER TABLE `treeningprogramm` DISABLE KEYS */;
INSERT INTO `treeningprogramm` VALUES
('KOOLISOIT','Koolisoit: alused, voltigeerimine, hobuse tasakaal ja kuulekus',38001010011,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
('NOORHOBUNE','Noorhobuse opetamine: sadula ja valjade harjutamine, pealeistumine',49004040044,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
('TAASTUS','Taastusprogramm parast vigastust: kaimine, kerge sisetreening',38001010011,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
('TAKISTUS','Takistussoit: hupped, rajasoit ja hobuse ning ratsaniku usaldus',38502020022,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
('VASTUPID','Vastupidavus: pikad maastikuringid, tempo ja hingamise treening',37703030033,'2026-11-11 02:02:46','2026-11-11 02:02:46');
/*!40000 ALTER TABLE `treeningprogramm` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
DROP TABLE IF EXISTS `visiit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `visiit` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `hobune_registreerimiskood` varchar(8) NOT NULL COMMENT 'Peab olema hobuste tabelis',
  `arst_isikukood` bigint(20) unsigned NOT NULL,
  `visiidi_aeg` datetime DEFAULT NULL,
  `visiidi_kirjeldus` varchar(255) DEFAULT NULL,
  `hind` decimal(8,2) DEFAULT NULL,
  `inserted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `hobune_registreerimiskood` (`hobune_registreerimiskood`),
  KEY `arst_isikukood` (`arst_isikukood`),
  CONSTRAINT `visiit_ibfk_1` FOREIGN KEY (`hobune_registreerimiskood`) REFERENCES `hobune` (`registreerimiskood`),
  CONSTRAINT `visiit_ibfk_2` FOREIGN KEY (`arst_isikukood`) REFERENCES `arst` (`isikukood`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Inventar koos hindadega';
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `visiit` WRITE;
/*!40000 ALTER TABLE `visiit` DISABLE KEYS */;
INSERT INTO `visiit` VALUES
(1,'220',12312312312,'2025-11-02 00:00:00','Hobune on täiesti terve',125.00,'2025-10-27 16:03:00','2025-10-27 16:03:00'),
(2,'200',12312312313,'2025-10-02 10:00:00','Aastakontroll',60.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(3,'202',12312312314,'2025-10-03 11:30:00','Vaktsineerimine',45.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(4,'205',12312312315,'2025-10-04 09:00:00','Hammaste kontroll',70.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(5,'211',12312312316,'2025-10-06 14:00:00','Jala pehmenduskontroll',95.50,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(6,'211',12312312317,'2025-10-10 12:00:00','Uuesti jalg - paranemine',40.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(7,'218',12312312318,'2025-10-07 15:30:00','Silmapohjus',110.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(8,'220',12312312319,'2025-10-08 08:30:00','Pikkade jalgade krambid',130.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(9,'223',12312312320,'2025-10-09 16:00:00','Vaktsineerimine',45.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(10,'229',12312312321,'2025-10-11 10:30:00','Hammaste kontroll',70.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(11,'232',12312312312,'2025-10-13 13:00:00','Aastakontroll',60.00,'2026-11-11 02:02:46','2026-11-11 02:02:46'),
(12,'225',12312312313,'2025-10-15 09:30:00','Seedehaired',85.00,'2026-11-11 02:02:46','2026-11-11 02:02:46');
/*!40000 ALTER TABLE `visiit` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

USE `yhobu`;
/*!50001 DROP VIEW IF EXISTS `hobuste_treeningud`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013  SQL SECURITY DEFINER */
/*!50001 VIEW `hobuste_treeningud` AS select `h`.`nimi` AS `hobune`,count(`t`.`id`) AS `treeninguid` from (`hobune` `h` left join `treening` `t` on(`t`.`hobune_registreerimiskood` = `h`.`registreerimiskood`)) group by `h`.`registreerimiskood`,`h`.`nimi` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `nimed`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013  SQL SECURITY DEFINER */
/*!50001 VIEW `nimed` AS select `o`.`eesnimi` AS `eesnimi`,`o`.`perekonnanimi` AS `perekonnanimi`,`h`.`nimi` AS `nimi` from (`omanik` `o` left join `hobune` `h` on(`o`.`isikukood` = `h`.`omanik_isikukood`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `omanike_arstimaksed`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013  SQL SECURITY DEFINER */
/*!50001 VIEW `omanike_arstimaksed` AS select `o`.`eesnimi` AS `eesnimi`,`o`.`perekonnanimi` AS `perekonnanimi`,`h`.`nimi` AS `hobune`,`v`.`arst_isikukood` AS `arst_isikukood`,`v`.`hind` AS `hind` from ((`visiit` `v` join `hobune` `h` on(`h`.`registreerimiskood` = `v`.`hobune_registreerimiskood`)) join `omanik` `o` on(`o`.`isikukood` = `h`.`omanik_isikukood`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `omanike_inventari_kulu`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013  SQL SECURITY DEFINER */
/*!50001 VIEW `omanike_inventari_kulu` AS select `o`.`isikukood` AS `isikukood`,`o`.`eesnimi` AS `eesnimi`,`o`.`perekonnanimi` AS `perekonnanimi`,count(`i`.`id`) AS `esemeid`,coalesce(sum(`i`.`hind`),0) AS `inventari_eest_makstud` from (`omanik` `o` left join `inventar` `i` on(`i`.`omanik_isikukood` = `o`.`isikukood`)) group by `o`.`isikukood`,`o`.`eesnimi`,`o`.`perekonnanimi` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `talli_ulevaade`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013  SQL SECURITY DEFINER */
/*!50001 VIEW `talli_ulevaade` AS select `t`.`kood` AS `kood`,`t`.`nimi` AS `nimi`,(select count(0) from `hobune` `h` where `h`.`tall_kood` = `t`.`kood`) AS `hobuseid`,(select count(0) from `personal` `p` where `p`.`tall_kood` = `t`.`kood`) AS `tallimehi`,(select coalesce(sum(`i`.`hind`),0) from `inventar` `i` where `i`.`tall_kood` = `t`.`kood`) AS `inventari_vaartus` from `tall` `t` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `tallimehed`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013  SQL SECURITY DEFINER */
/*!50001 VIEW `tallimehed` AS select `p`.`isikukood` AS `isikukood`,`p`.`eesnimi` AS `eesnimi`,`p`.`perekonnanimi` AS `perekonnanimi`,`p`.`ametikoht` AS `ametikoht`,`p`.`tall_kood` AS `tall_kood`,`p`.`telefon` AS `telefon`,`p`.`palk` AS `palk`,`p`.`inserted_at` AS `inserted_at`,`p`.`updated_at` AS `updated_at` from `personal` `p` where `p`.`ametikoht` = 'tallimees' */;
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


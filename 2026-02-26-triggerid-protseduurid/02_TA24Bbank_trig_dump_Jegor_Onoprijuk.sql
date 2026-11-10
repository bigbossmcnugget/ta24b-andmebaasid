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

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `TA24Bbank_trig` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `TA24Bbank_trig`;
DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `account` (
  `accountnumber` bigint(20) unsigned NOT NULL,
  `accounttype` char(6) NOT NULL,
  `customerid` bigint(20) unsigned NOT NULL,
  `currency` char(3) NOT NULL DEFAULT 'EUR',
  `balance` decimal(12,2) NOT NULL,
  `interestrate` decimal(5,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`accountnumber`),
  KEY `accounttype` (`accounttype`),
  CONSTRAINT `1` FOREIGN KEY (`accounttype`) REFERENCES `accounttype` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `account` WRITE;
/*!40000 ALTER TABLE `account` DISABLE KEYS */;
INSERT INTO `account` VALUES
(100000,'EQUITY',10000,'EUR',-10000000.00,0.00),
(100001,'CASH',10000,'EUR',10000000.00,0.00),
(100100,'CURR',50603142719,'EUR',2500.00,0.00),
(100101,'CURR',39001010011,'EUR',1500.00,0.00),
(100102,'CURR',38505050022,'EUR',8800.50,0.00);
/*!40000 ALTER TABLE `account` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER after_account_insert
AFTER INSERT ON account
FOR EACH ROW BEGIN
    INSERT INTO audit (tablename, tableid, operation, user)
    VALUES ('ACCOUNT', NEW.accountnumber, 'INS', USER());
END 
*/;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER after_account_update
AFTER UPDATE ON account
FOR EACH ROW BEGIN
    INSERT INTO audit (tablename, tableid, operation, user)
    VALUES ('ACCOUNT', NEW.accountnumber, 'UPD', USER());
END 
*/;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER after_account_delete
AFTER DELETE ON account
FOR EACH ROW BEGIN
    INSERT INTO audit (tablename, tableid, operation, user)
    VALUES ('ACCOUNT', OLD.accountnumber, 'DEL', USER());
END 
*/;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `accounttype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `accounttype` (
  `type` char(6) NOT NULL,
  `description` varchar(255) NOT NULL,
  PRIMARY KEY (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `accounttype` WRITE;
/*!40000 ALTER TABLE `accounttype` DISABLE KEYS */;
INSERT INTO `accounttype` VALUES
('CASH','Sularaha'),
('CURR','Arvelduskonto'),
('EQUITY','Omakapital'),
('HLOAN','Kodulaen');
/*!40000 ALTER TABLE `accounttype` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
DROP TABLE IF EXISTS `audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tablename` varchar(36) DEFAULT NULL,
  `tableid` varchar(36) DEFAULT NULL,
  `operation` char(3) DEFAULT NULL,
  `user` varchar(64) DEFAULT NULL,
  `audittime` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `audit` WRITE;
/*!40000 ALTER TABLE `audit` DISABLE KEYS */;
INSERT INTO `audit` VALUES
(1,'CUSTOMER','48701022321','INS','jegor_onoprijuk@localhost','2026-11-11 01:56:39'),
(2,'CUSTOMER','50603142719','INS','jegor_onoprijuk@localhost','2026-11-11 01:56:39'),
(3,'ACCOUNT','100100','INS','jegor_onoprijuk@localhost','2026-11-11 01:56:39'),
(4,'CUSTOMER','39001010011','INS','jegor_onoprijuk@localhost','2026-11-11 01:56:39'),
(5,'CUSTOMER','38505050022','INS','jegor_onoprijuk@localhost','2026-11-11 01:56:39'),
(6,'CUSTOMER','49203030033','INS','jegor_onoprijuk@localhost','2026-11-11 01:56:39'),
(7,'CUSTOMER','37707070044','INS','jegor_onoprijuk@localhost','2026-11-11 01:56:39'),
(8,'ACCOUNT','100000','INS','jegor_onoprijuk@localhost','2026-11-11 01:56:39'),
(9,'ACCOUNT','100001','INS','jegor_onoprijuk@localhost','2026-11-11 01:56:39'),
(10,'ACCOUNT','100101','INS','jegor_onoprijuk@localhost','2026-11-11 01:56:39'),
(11,'ACCOUNT','100102','INS','jegor_onoprijuk@localhost','2026-11-11 01:56:39'),
(12,'CUSTOMER','48701022321','UPD','jegor_onoprijuk@localhost','2026-11-11 01:56:39'),
(13,'CUSTOMER','39001010011','UPD','jegor_onoprijuk@localhost','2026-11-11 01:56:39'),
(14,'ACCOUNT','100101','UPD','jegor_onoprijuk@localhost','2026-11-11 01:56:39'),
(15,'CUSTOMER','37707070044','DEL','jegor_onoprijuk@localhost','2026-11-11 01:56:39');
/*!40000 ALTER TABLE `audit` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
DROP TABLE IF EXISTS `audit_kokkuvote`;
/*!50001 DROP VIEW IF EXISTS `audit_kokkuvote`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `audit_kokkuvote` AS SELECT
 NULL AS `tabel`,
 NULL AS `lisatud`,
 NULL AS `muudetud`,
 NULL AS `kustutatud`,
 NULL AS `kokku`,
 NULL AS `viimane_muudatus` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer` (
  `idcode` bigint(20) unsigned NOT NULL,
  `firstname` varchar(64) NOT NULL,
  `lastname` varchar(64) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `email` varchar(64) DEFAULT NULL,
  `customertype` char(6) DEFAULT NULL,
  `phone` varchar(32) DEFAULT NULL,
  `gender` varchar(8) DEFAULT NULL,
  PRIMARY KEY (`idcode`),
  UNIQUE KEY `email` (`email`),
  KEY `customertype` (`customertype`),
  CONSTRAINT `1` FOREIGN KEY (`customertype`) REFERENCES `customertype` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES
(38505050022,'Jaan','Kask','Parnu','jaan.kask@example.com','GOLD',NULL,NULL),
(39001010011,'Mari','Tamm','Tallinn','mari.tamm@example.com','GOLD',NULL,NULL),
(48701022321,'Anna','Kask','Tartu','anna@gmail.com','BASIC',NULL,NULL),
(49203030033,'Liis','Saar','Viljandi','liis.saar@example.com','BASIC',NULL,NULL),
(50603142719,'Jegor','Onoprijuk',NULL,'jegor.onoprijuk@example.com','OURS',NULL,NULL);
/*!40000 ALTER TABLE `customer` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER after_customer_insert
AFTER INSERT ON customer
FOR EACH ROW BEGIN
    INSERT INTO audit (tablename, tableid, operation, user)
    VALUES ('CUSTOMER', NEW.idcode, 'INS', USER());
END 
*/;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER after_customer_update
AFTER UPDATE ON customer
FOR EACH ROW BEGIN
    INSERT INTO audit (tablename, tableid, operation, user)
    VALUES ('CUSTOMER', NEW.idcode, 'UPD', USER());
END 
*/;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER after_customer_delete
AFTER DELETE ON customer
FOR EACH ROW BEGIN
    INSERT INTO audit (tablename, tableid, operation, user)
    VALUES ('CUSTOMER', OLD.idcode, 'DEL', USER());
END 
*/;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `customertype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `customertype` (
  `type` char(6) NOT NULL,
  `description` varchar(64) NOT NULL,
  PRIMARY KEY (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `customertype` WRITE;
/*!40000 ALTER TABLE `customertype` DISABLE KEYS */;
INSERT INTO `customertype` VALUES
('BASIC','Tavaklient'),
('BRONZE','Pronksklient'),
('GOLD','Kuldklient'),
('OURS','Meie ise'),
('SILVER','Hoberklient');
/*!40000 ALTER TABLE `customertype` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

USE `TA24Bbank_trig`;
/*!50001 DROP VIEW IF EXISTS `audit_kokkuvote`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013  SQL SECURITY DEFINER */
/*!50001 VIEW `ta24bbank_trig`.`audit_kokkuvote` AS select `ta24bbank_trig`.`audit`.`tablename` AS `tabel`,sum(`ta24bbank_trig`.`audit`.`operation` = 'INS') AS `lisatud`,sum(`ta24bbank_trig`.`audit`.`operation` = 'UPD') AS `muudetud`,sum(`ta24bbank_trig`.`audit`.`operation` = 'DEL') AS `kustutatud`,count(0) AS `kokku`,max(`ta24bbank_trig`.`audit`.`audittime`) AS `viimane_muudatus` from `ta24bbank_trig`.`audit` group by `ta24bbank_trig`.`audit`.`tablename` */;
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

-- Protseduurid (mariadb-dump 13 jatab need --routines korral vahele, seega
-- lisasin kasitsi - samad, mis failis 01_triggerid_protseduurid.sql)
USE `TA24Bbank_trig`;
-- ----------------------------------------------------------- protseduurid
DELIMITER //

-- klient + tema esimene konto uhe korraga (tehing: kui konto ebaonnestub,
-- ei jaa ka klient pooleli)
CREATE PROCEDURE add_customer_with_account(
    IN p_idcode BIGINT UNSIGNED, IN p_firstname VARCHAR(64), IN p_lastname VARCHAR(64),
    IN p_email VARCHAR(64), IN p_customertype CHAR(6),
    IN p_accountnumber BIGINT UNSIGNED, IN p_balance DECIMAL(12,2))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
    INSERT INTO customer (idcode, firstname, lastname, email, customertype)
    VALUES (p_idcode, p_firstname, p_lastname, p_email, p_customertype);
    INSERT INTO account (accountnumber, accounttype, customerid, balance)
    VALUES (p_accountnumber, 'CURR', p_idcode, p_balance);
    COMMIT;
END//

-- kogu ajalugu uhe kirje kohta (nii customer kui tema kontod)
CREATE PROCEDURE audit_history(IN p_idcode BIGINT UNSIGNED)
BEGIN
    SELECT a.id, a.tablename, a.tableid, a.operation, a.user, a.audittime
    FROM audit a
    WHERE (a.tablename = 'CUSTOMER' AND a.tableid = p_idcode)
       OR (a.tablename = 'ACCOUNT'  AND a.tableid IN
              (SELECT accountnumber FROM account WHERE customerid = p_idcode))
    ORDER BY a.id;
END//

DELIMITER ;

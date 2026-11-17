-- 2025-09-23 Tabelid käskude abil  -  Jegor Onoprijuk, TA-24B
-- Uus kooli andmebaas (tunniplaan), kõik tabelid inglise keeles.
DROP DATABASE IF EXISTS tunniplaan;
CREATE DATABASE tunniplaan CHARACTER SET utf8mb4;
USE tunniplaan;

CREATE TABLE teacher (
  code      VARCHAR(8)   NOT NULL PRIMARY KEY,
  firstname VARCHAR(50)  NOT NULL,
  lastname  VARCHAR(50)  NOT NULL
);

CREATE TABLE subject (
  code VARCHAR(10)  NOT NULL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE studentgroup (
  code VARCHAR(10) NOT NULL PRIMARY KEY,
  name VARCHAR(50) NOT NULL
);

CREATE TABLE student (
  idcode    VARCHAR(11) NOT NULL PRIMARY KEY,
  firstname VARCHAR(50) NOT NULL,
  lastname  VARCHAR(50) NOT NULL
);

CREATE TABLE enrollment (
  studentidcode    VARCHAR(11) NOT NULL,
  studentgroupcode VARCHAR(10) NOT NULL,
  PRIMARY KEY (studentidcode, studentgroupcode),
  FOREIGN KEY (studentidcode)    REFERENCES student (idcode),
  FOREIGN KEY (studentgroupcode) REFERENCES studentgroup (code)
);

-- Õppetundide tabel
CREATE TABLE class (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  subjectcode      VARCHAR(10)  NOT NULL,
  studentgroupcode VARCHAR(10)  NULL,
  starttime        DATETIME     NOT NULL,
  endtime          DATETIME     NOT NULL,
  comments         VARCHAR(255) NULL,
  FOREIGN KEY (subjectcode)      REFERENCES subject (code),
  FOREIGN KEY (studentgroupcode) REFERENCES studentgroup (code),
  CONSTRAINT chk_class_time CHECK (starttime < endtime)
);

CREATE TABLE room (
  code      VARCHAR(8) NOT NULL PRIMARY KEY,   -- nt A-309
  seats     INT        NOT NULL,
  computers INT        NOT NULL
);

CREATE TABLE grade (
  studentidcode VARCHAR(11) NOT NULL,
  subjectcode   VARCHAR(10) NOT NULL,
  grade         TINYINT     NOT NULL,
  time          DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,   -- hinde panemise aeg, vaikimisi sisestamise hetk
  PRIMARY KEY (studentidcode, subjectcode, time),
  FOREIGN KEY (studentidcode) REFERENCES student (idcode),
  FOREIGN KEY (subjectcode)   REFERENCES subject (code),
  CONSTRAINT chk_grade CHECK (grade IN (1, 2, 3, 4, 5))
);

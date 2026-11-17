-- 2025-09-09 drawSQL eksport, parandatud ja täiendatud   Jegor Onoprijuk, TA-24B
-- Muudatused originaali võrreldes:
--  1) Esindaja ja Rühmaine: originaalis oli kaks korda "ADD PRIMARY KEY" -> MySQL: "Multiple primary key defined".
--     Esindaja PK = (õpilaseidkood, kood), Rühmaine PK = (rühm, aine)  (seosetabeli liitvõti).
--  2) Esindaja veerg "peekonnanimi" -> "perekonnanimi" (trükiviga).
CREATE TABLE `Rühm`(
    `kood` VARCHAR(6) NOT NULL,
    `kirjeldus` VARCHAR(255) NOT NULL,
    PRIMARY KEY(`kood`)
);
CREATE TABLE `Õppeaine`(
    `kood` VARCHAR(6) NOT NULL,
    `kirjeldus` VARCHAR(255) NOT NULL,
    PRIMARY KEY(`kood`)
);
CREATE TABLE `Õpilane`(
    `idkood` BIGINT UNSIGNED NOT NULL,
    `eesnimi` VARCHAR(255) NOT NULL,
    `perekonnanimi` VARCHAR(255) NOT NULL,
    `sünniaeg` DATE NOT NULL,
    `aadress` VARCHAR(255) NULL,
    `telefon` VARCHAR(255) NULL,
    `rühmakood` VARCHAR(6) NOT NULL,
    PRIMARY KEY(`idkood`),
    CONSTRAINT `Õpilane_rühmakood_foreign` FOREIGN KEY(`rühmakood`) REFERENCES `Rühm`(`kood`)
);
CREATE TABLE `Esindaja`(
    `õpilaseidkood` BIGINT UNSIGNED NOT NULL,
    `kood` VARCHAR(6) NOT NULL,
    `eesnimi` VARCHAR(255) NOT NULL,
    `perekonnanimi` VARCHAR(255) NOT NULL,
    PRIMARY KEY(`õpilaseidkood`, `kood`),
    CONSTRAINT `esindaja_õpilaseidkood_foreign` FOREIGN KEY(`õpilaseidkood`) REFERENCES `Õpilane`(`idkood`)
);
CREATE TABLE `Rühmaine`(
    `rühm` VARCHAR(6) NOT NULL,
    `aine` VARCHAR(6) NOT NULL,
    PRIMARY KEY(`rühm`, `aine`),
    CONSTRAINT `rühmaine_rühm_foreign` FOREIGN KEY(`rühm`) REFERENCES `Rühm`(`kood`),
    CONSTRAINT `rühmaine_aine_foreign` FOREIGN KEY(`aine`) REFERENCES `Õppeaine`(`kood`)
);

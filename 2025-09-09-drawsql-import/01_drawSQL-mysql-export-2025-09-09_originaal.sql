CREATE TABLE `Õpilane`(
    `idkood` BIGINT UNSIGNED NOT NULL,
    `eesnimi` VARCHAR(255) NOT NULL,
    `perekonnanimi` VARCHAR(255) NOT NULL,
    `sünniaeg` DATE NOT NULL,
    `aadress` VARCHAR(255) NULL,
    `telefon` VARCHAR(255) NULL,
    `rühmakood` VARCHAR(6) NOT NULL,
    PRIMARY KEY(`idkood`)
);
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
CREATE TABLE `Esindaja`(
    `õpilaseidkood` BIGINT UNSIGNED NOT NULL,
    `kood` VARCHAR(6) NOT NULL,
    `eesnimi` VARCHAR(255) NOT NULL,
    `peekonnanimi` VARCHAR(255) NOT NULL,
    PRIMARY KEY(`õpilaseidkood`)
);
ALTER TABLE
    `Esindaja` ADD PRIMARY KEY(`kood`);
CREATE TABLE `Rühmaine`(
    `rühm` VARCHAR(6) NOT NULL,
    `aine` VARCHAR(6) NOT NULL,
    PRIMARY KEY(`rühm`)
);
ALTER TABLE
    `Rühmaine` ADD PRIMARY KEY(`aine`);
ALTER TABLE
    `Esindaja` ADD CONSTRAINT `esindaja_õpilaseidkood_foreign` FOREIGN KEY(`õpilaseidkood`) REFERENCES `Õpilane`(`idkood`);
ALTER TABLE
    `Rühmaine` ADD CONSTRAINT `rühmaine_rühm_foreign` FOREIGN KEY(`rühm`) REFERENCES `Rühm`(`kood`);
ALTER TABLE
    `Rühmaine` ADD CONSTRAINT `rühmaine_aine_foreign` FOREIGN KEY(`aine`) REFERENCES `Õppeaine`(`kood`);
ALTER TABLE
    `Õpilane` ADD CONSTRAINT `Õpilane_rühmakood_foreign` FOREIGN KEY(`rühmakood`) REFERENCES `Rühm`(`kood`);
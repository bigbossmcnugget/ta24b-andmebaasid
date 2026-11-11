// Andmemudel - tabel "test" kahe veeruga (ulesande noue):
//   id          - autoincrement / serial ja primary key
//   description - varchar(255) not null
// Jegor Onoprijuk, TA-24B
//
// NB! Ulesandes oli  id: serial("id").primaryKey().  MySQL-is on SERIAL lihtsalt
// nimi veerule  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE.  Minu masinas
// jookseb MariaDB 13, mis ei luba Drizzle'i genereeritud "serial AUTO_INCREMENT"
// kirjutust (ER_PARSE_ERROR), seega kirjutasin sama asja lahti:
// bigint unsigned + autoincrement + primary key.
// Algne variant ulesande jargi on failis src/schema.serial_yl.ts.
import { mysqlTable, bigint, varchar } from 'drizzle-orm/mysql-core';

export const test = mysqlTable('test', {
  id: bigint('id', { mode: 'number', unsigned: true }).autoincrement().primaryKey(),
  description: varchar('description', { length: 255 }).notNull(),
});

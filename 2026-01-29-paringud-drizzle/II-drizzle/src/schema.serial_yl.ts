// Andmemudel - tabel "test" kahe veeruga (ulesande noue):
//   id          - autoincrement / serial ja primary key
//   description - varchar(255) not null
// Jegor Onoprijuk, TA-24B
import { mysqlTable, serial, varchar } from 'drizzle-orm/mysql-core';

export const test = mysqlTable('test', {
  id: serial('id').primaryKey(),
  description: varchar('description', { length: 255 }).notNull(),
});

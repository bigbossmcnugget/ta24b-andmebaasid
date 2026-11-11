// Kasutan tabelit "test" Drizzle'i kaudu: lisan, loen, muudan, kustutan.
// Jegor Onoprijuk, TA-24B
import 'dotenv/config';
import { drizzle } from 'drizzle-orm/mysql2';
import { eq } from 'drizzle-orm';
import { test } from './schema';

async function main() {
  const db = drizzle(process.env.DATABASE_URL!);
  console.log('Jegor Onoprijuk, TA-24B - Drizzle + MySQL');

  await db.delete(test);
  await db.insert(test).values([
    { description: 'Minu esimene rida Drizzle abil - Jegor Onoprijuk' },
    { description: 'Teine rida' },
    { description: 'Kolmas rida (see kustutatakse)' },
  ]);
  console.log('\nKoik read:');
  console.table(await db.select().from(test));

  await db.update(test).set({ description: 'Teine rida (muudetud)' }).where(eq(test.id, 2));
  const kolmas = (await db.select().from(test)).find(r => r.description.startsWith('Kolmas'))!;
  await db.delete(test).where(eq(test.id, kolmas.id));
  console.log('\nParast muutmist ja kustutamist:');
  console.table(await db.select().from(test));
  process.exit(0);
}
main().catch(e => { console.error(e); process.exit(1); });

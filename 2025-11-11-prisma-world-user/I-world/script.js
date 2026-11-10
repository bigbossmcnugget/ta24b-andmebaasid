/*
 * I osa - World andmebaas Prismas.
 * Jegor Onoprijuk, ruhm TA-24B   (ulesanne 2025-11-11 "Prisma")
 *
 * Mida teeb:
 *   1. naitab, et login kaib MINU nimelise kasutajaga (mitte root)
 *   2. teeb world-baasi peal paringuid (CRUD: create, read, update, delete)
 *   3. taidab minu lisatud tabeli 'university', mis on seotud riikide tabeliga
 */
const { PrismaClient } = require('@prisma/client');
const db = new PrismaClient();
const joon = (n = 78) => console.log('-'.repeat(n));

async function main() {
  console.log('='.repeat(78));
  console.log('WORLD ANDMEBAAS PRISMAGA');
  console.log('Jegor Onoprijuk, ruhm TA-24B');
  console.log('='.repeat(78));

  // --- 1. kes ma andmebaasis olen? --------------------------------------
  const kes = await db.$queryRawUnsafe('SELECT CURRENT_USER() AS kasutaja, DATABASE() AS baas');
  console.log(`\nuhendus: ${kes[0].kasutaja}  andmebaas: ${kes[0].baas}`);
  console.log('(kasutaja on loodud CREATE USER-iga minu nime jargi, .env-is on tema andmed)');

  // --- 2. READ -----------------------------------------------------------
  console.log('\nREAD: viis koige suurema rahvaarvuga riiki');
  joon();
  const suured = await db.country.findMany({
    orderBy: { Population: 'desc' }, take: 5,
    select: { Code: true, Name: true, Continent: true, Population: true },
  });
  for (const r of suured)
    console.log(`${r.Code}  ${r.Name.padEnd(28)}${r.Continent.padEnd(16)}${r.Population.toLocaleString('et-EE').padStart(14)}`);

  console.log('\nREAD: Eesti ja tema suuremad linnad');
  joon();
  const eesti = await db.country.findUnique({
    where: { Code: 'EST' },
    include: { city: { orderBy: { Population: 'desc' }, take: 5 } },
  });
  console.log(`${eesti.Name} (${eesti.Continent}), pindala ${eesti.SurfaceArea} km2, rahvaarv ${eesti.Population}`);
  for (const l of eesti.city) console.log(`   ${l.Name.padEnd(16)}${String(l.Population).padStart(8)}`);

  console.log('\nREAD koos grupeerimisega: mitu linna on igal mandril');
  joon();
  const mandrid = await db.country.groupBy({
    by: ['Continent'], _count: { Code: true }, _sum: { Population: true },
    orderBy: { _sum: { Population: 'desc' } },
  });
  for (const m of mandrid)
    console.log(`${m.Continent.padEnd(16)}riike: ${String(m._count.Code).padStart(3)}   rahvaarv: ${(m._sum.Population ?? 0).toLocaleString('et-EE').padStart(14)}`);

  // --- 3. CREATE / UPDATE / DELETE --------------------------------------
  console.log('\nCREATE: lisan uue linna');
  joon();
  await db.city.deleteMany({ where: { Name: 'Onoprijuki linn' } });
  const uusLinn = await db.city.create({
    data: { Name: 'Onoprijuki linn', CountryCode: 'EST', District: 'Harjumaa', Population: 1234 },
  });
  console.log(`lisatud: id=${uusLinn.ID} ${uusLinn.Name}, ${uusLinn.District}, ${uusLinn.Population} elanikku`);

  console.log('\nUPDATE: muudan rahvaarvu');
  joon();
  const muudetud = await db.city.update({
    where: { ID: uusLinn.ID }, data: { Population: 5678 } });
  console.log(`uus rahvaarv: ${muudetud.Population}`);

  console.log('\nDELETE: kustutan selle linna ara');
  joon();
  await db.city.delete({ where: { ID: uusLinn.ID } });
  const alles = await db.city.count({ where: { Name: 'Onoprijuki linn' } });
  console.log(`linnu nimega "Onoprijuki linn": ${alles}`);

  // --- 4. minu lisatud tabel university ---------------------------------
  console.log('\nMINU LISATUD TABEL: university (seotud country tabeliga)');
  joon();
  await db.university.deleteMany({});
  await db.university.createMany({
    data: [
      { Name: 'Tallinna Tehnikaulikool', City: 'Tallinn', CountryCode: 'EST', Founded: 1918, Students: 9500,  Website: 'taltech.ee' },
      { Name: 'Tartu Ulikool',           City: 'Tartu',   CountryCode: 'EST', Founded: 1632, Students: 13000, Website: 'ut.ee' },
      { Name: 'Tallinna Tehnoloogiakolledz', City: 'Tallinn', CountryCode: 'EST', Founded: 2005, Students: 1200, Website: 'tktk.ee' },
      { Name: 'Helsingin yliopisto',     City: 'Helsinki', CountryCode: 'FIN', Founded: 1640, Students: 31000, Website: 'helsinki.fi' },
      { Name: 'Latvijas Universitate',   City: 'Riga',     CountryCode: 'LVA', Founded: 1919, Students: 14000, Website: 'lu.lv' },
      { Name: 'Uppsala universitet',     City: 'Uppsala',  CountryCode: 'SWE', Founded: 1477, Students: 28000, Website: 'uu.se' },
    ],
  });
  const koolid = await db.university.findMany({
    include: { country: { select: { Name: true } } },
    orderBy: [{ CountryCode: 'asc' }, { Founded: 'asc' }],
  });
  console.log('ulikool'.padEnd(32) + 'linn'.padEnd(12) + 'riik'.padEnd(16) + 'asut.'.padStart(6) + 'tudengeid'.padStart(11));
  for (const u of koolid)
    console.log(u.Name.padEnd(32) + u.City.padEnd(12) + u.country.Name.padEnd(16) +
                String(u.Founded).padStart(6) + String(u.Students).padStart(11));

  console.log('\nPARING ULE SEOSE: ulikoolid koos riigi rahvaarvuga');
  joon();
  const seotud = await db.country.findMany({
    where: { university: { some: {} } },
    select: { Name: true, Population: true, _count: { select: { university: true } } },
    orderBy: { Name: 'asc' },
  });
  for (const r of seotud)
    console.log(`${r.Name.padEnd(16)}ulikoole: ${r._count.university}   riigi rahvaarv: ${r.Population.toLocaleString('et-EE')}`);

  console.log('\nKOOL, KUS MA ISE OPIN');
  joon();
  const minuKool = await db.university.findFirst({
    where: { Name: { contains: 'Tehnoloogiakolledz' } },
    include: { country: { select: { Name: true } } },
  });
  console.log(`${minuKool.Name}, ${minuKool.City}, ${minuKool.country.Name} - siin opib Jegor Onoprijuk, ruhm TA-24B`);
}

main().catch(e => { console.error(e); process.exit(1); }).finally(() => db.$disconnect());

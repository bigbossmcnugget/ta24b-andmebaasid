/*
 * Jalgpalli andmebaasi taitmine Prismaga.
 * Jegor Onoprijuk, ruhm TA-24B
 *
 * Kaivitamine:  node seed.js
 *
 * Ulesande nouded, mida see fail taidab:
 *   - igas tabelis vahemalt 2 kirjet
 *   - 6 mangijat, jagatud vahemalt kahe klubi vahel
 *   - mina ise olen Coach tabelis ja olen KAHE klubi treener (n:m seos)
 *   - koigis tabelites vali createdat vaikevaartusega CURRENT_TIMESTAMP
 */
const { PrismaClient } = require('@prisma/client');
const db = new PrismaClient();

async function main() {
  // --- puhas leht (lapsed enne vanemaid) --------------------------------
  await db.game.deleteMany();
  await db.coachClub.deleteMany();
  await db.player.deleteMany();
  await db.coach.deleteMany();
  await db.club.deleteMany();
  await db.country.deleteMany();

  // --- riigid ------------------------------------------------------------
  const eesti = await db.country.create({ data: { name: 'Eesti', code: 'EST' } });
  const soome = await db.country.create({ data: { name: 'Soome', code: 'FIN' } });
  const lati  = await db.country.create({ data: { name: 'Lati',  code: 'LVA' } });

  // --- klubid ------------------------------------------------------------
  const flora = await db.club.create({
    data: { name: 'FC Flora', location: 'Tallinn', stadium: 'Lillekula staadion' } });
  const kalju = await db.club.create({
    data: { name: 'Nomme Kalju', location: 'Tallinn', stadium: 'Hiiu staadion' } });
  const paide = await db.club.create({
    data: { name: 'Paide Linnameeskond', location: 'Paide', stadium: 'Paide linnastaadion' } });

  // --- treenerid ---------------------------------------------------------
  // Ulesandes oli kirjas, et pean lisama iseenda Coach tabelisse.
  const mina = await db.coach.create({
    data: { firstname: 'Jegor', lastname: 'Onoprijuk', countryid: eesti.id } });
  const henn = await db.coach.create({
    data: { firstname: 'Jurgen', lastname: 'Henn', countryid: eesti.id } });
  const voolaid = await db.coach.create({
    data: { firstname: 'Karel', lastname: 'Voolaid', countryid: eesti.id } });

  // --- n:m seos: MINA olen kahe klubi treener ----------------------------
  await db.coachClub.createMany({
    data: [
      { coachid: mina.id,    clubid: flora.id, role: 'peatreener' },
      { coachid: mina.id,    clubid: kalju.id, role: 'peatreener' },
      { coachid: henn.id,    clubid: flora.id, role: 'abitreener' },
      { coachid: voolaid.id, clubid: paide.id, role: 'peatreener' },
    ],
  });

  // --- mangijad: 6 tukki, jagatud kolme klubi vahel ----------------------
  await db.player.createMany({
    data: [
      { firstname: 'Rauno',  lastname: 'Sappinen',  salary: 4200.00, countryid: eesti.id, clubid: flora.id },
      { firstname: 'Markus', lastname: 'Poom',      salary: 3900.00, countryid: eesti.id, clubid: flora.id },
      { firstname: 'Vlasi',  lastname: 'Sinjavski', salary: 3600.00, countryid: eesti.id, clubid: kalju.id },
      { firstname: 'Tomi',   lastname: 'Saarelma',  salary: 2900.00, countryid: soome.id, clubid: kalju.id },
      { firstname: 'Henrik', lastname: 'Purg',      salary: 2800.00, countryid: eesti.id, clubid: paide.id },
      { firstname: 'Edgars', lastname: 'Berzins',   salary: 2500.00, countryid: lati.id,  clubid: paide.id },
    ],
  });

  // --- mangud ------------------------------------------------------------
  await db.game.create({
    data: {
      homeclub: flora.id, foreignclub: kalju.id,
      homescore: 2, foreignscore: 1,
      homeformation: '4-3-3', foreignformation: '4-4-2',
      gametime: new Date('2025-11-15T17:00:00'),
    },
  });

  // Teise mangu lisan MEELEGA toore SQL-iga ja JATAN createdat valja -
  // nii on naha, et vaikevaartus CURRENT_TIMESTAMP tuleb andmebaasist
  // endast, mitte Prisma kliendist.
  await db.$executeRawUnsafe(
    'INSERT INTO `Game` (homeclub, foreignclub, homescore, foreignscore, ' +
    'homeformation, foreignformation, gametime) VALUES (?, ?, ?, ?, ?, ?, ?)',
    paide.id, flora.id, 0, 3, '5-3-2', '4-3-3', new Date('2025-11-16T15:30:00'));

  // ---------------------------------------------------------------- aruanne
  const joon = (n = 78) => console.log('-'.repeat(n));
  console.log('='.repeat(78));
  console.log('JALGPALLI ANDMEBAAS (Prisma + MySQL/MariaDB)');
  console.log('Jegor Onoprijuk, ruhm TA-24B');
  console.log('='.repeat(78));

  console.log('\nKIRJETE ARV TABELITES');
  joon();
  for (const [nimi, arv] of [
    ['Country',   await db.country.count()],
    ['Club',      await db.club.count()],
    ['Coach',     await db.coach.count()],
    ['CoachClub', await db.coachClub.count()],
    ['Player',    await db.player.count()],
    ['Game',      await db.game.count()],
  ]) console.log(nimi.padEnd(12) + String(arv).padStart(3));

  console.log('\nTREENERID JA NENDE KLUBID (n:m seos)');
  joon();
  const treenerid = await db.coach.findMany({
    include: { country: true, clubs: { include: { club: true } } },
    orderBy: { id: 'asc' },
  });
  for (const t of treenerid) {
    const klubid = t.clubs.map(c => `${c.club.name} (${c.role})`).join(', ');
    console.log(`${(t.firstname + ' ' + t.lastname).padEnd(22)}${t.country.code}  ${klubid}`);
  }

  console.log('\nMANGIJAD');
  joon();
  console.log('nimi'.padEnd(24) + 'riik'.padEnd(6) + 'klubi'.padEnd(24) + 'palk'.padStart(9));
  const mangijad = await db.player.findMany({
    include: { club: true, country: true }, orderBy: { lastname: 'asc' } });
  for (const m of mangijad) {
    console.log((m.firstname + ' ' + m.lastname).padEnd(24) + m.country.code.padEnd(6) +
      m.club.name.padEnd(24) + Number(m.salary).toFixed(2).padStart(9));
  }

  console.log('\nMANGUD');
  joon();
  const mangud = await db.game.findMany({
    include: { home: true, foreign: true }, orderBy: { gametime: 'asc' } });
  for (const g of mangud) {
    console.log(
      g.gametime.toLocaleString('et-EE').padEnd(22) +
      `${g.home.name} (${g.homeformation})`.padEnd(30) +
      `${g.homescore}:${g.foreignscore}`.padEnd(6) +
      `${g.foreign.name} (${g.foreignformation})`);
  }

  console.log('\nKONTROLL: vali createdat on koikjal taidetud');
  joon();
  for (const g of mangud) {
    console.log(`Game id=${g.id}  createdat = ${g.createdat.toISOString()}`);
  }
  console.log('(teine mang lisati toore SQL-iga ILMA createdat vaartuseta -');
  console.log(' vaartuse pani sinna andmebaasi vaikevaartus CURRENT_TIMESTAMP)');
}

main()
  .catch(e => { console.error(e); process.exit(1); })
  .finally(() => db.$disconnect());

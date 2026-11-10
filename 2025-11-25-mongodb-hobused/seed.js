/*
 * Hobuste andmebaas MongoDB-s.
 * Jegor Onoprijuk, ruhm TA-24B   (ulesanne 2025-11-25 "Mongodb")
 *
 * Kaivitamine:  node seed.js
 *
 * Ulesande nouded:
 *   - kollektsioonid hobuste, omanike, tallide, varustuse ja treeningute jaoks
 *   - igas vahemalt 6 dokumenti
 *   - hobusel on omanik, varustus kuulub kellelegi, treeningul on aeg,
 *     treener ja hobused
 *   - MINA ISE pean olema omanike kollektsioonis
 *   - peab olema find kask, mis tagastab varustuse, mis kuulub MULLE
 */
const { MongoClient } = require('mongodb');

const URL = 'mongodb://127.0.0.1:27017';
const DB  = 'hobused';

const joon = (n = 78) => console.log('-'.repeat(n));

async function main() {
  const client = new MongoClient(URL);
  await client.connect();
  const db = client.db(DB);

  // --- puhas leht --------------------------------------------------------
  for (const c of ['omanikud', 'tallid', 'hobused', 'varustus', 'treeningud']) {
    await db.collection(c).deleteMany({});
  }

  // --- 1. OMANIKUD (6, nende hulgas mina ise) ----------------------------
  const omanikud = await db.collection('omanikud').insertMany([
    { eesnimi: 'Jegor', perekonnanimi: 'Onoprijuk', ruhm: 'TA-24B',
      telefon: '+372 5555 0101',
      aadress: { riik: 'Eesti', linn: 'Tallinn', tanav: 'Parnu maantee 62' },
      liitus: new Date('2024-09-01') },
    { eesnimi: 'Mari',  perekonnanimi: 'Tamm',   telefon: '+372 5555 0102',
      aadress: { riik: 'Eesti', linn: 'Tartu', tanav: 'Riia 15' },
      liitus: new Date('2023-04-12') },
    { eesnimi: 'Jaan',  perekonnanimi: 'Kask',   telefon: '+372 5555 0103',
      aadress: { riik: 'Eesti', linn: 'Parnu', tanav: 'Ringi 8' },
      liitus: new Date('2022-07-30') },
    { eesnimi: 'Liis',  perekonnanimi: 'Saar',   telefon: '+372 5555 0104',
      aadress: { riik: 'Eesti', linn: 'Viljandi', tanav: 'Tallinna 4' },
      liitus: new Date('2025-01-20') },
    { eesnimi: 'Peeter', perekonnanimi: 'Lepik', telefon: '+372 5555 0105',
      aadress: { riik: 'Eesti', linn: 'Rakvere', tanav: 'Pikk 21' },
      liitus: new Date('2021-11-05') },
    { eesnimi: 'Anna',  perekonnanimi: 'Ilves',  telefon: '+372 5555 0106',
      aadress: { riik: 'Eesti', linn: 'Haapsalu', tanav: 'Posti 3' },
      liitus: new Date('2024-02-17') },
  ]);
  const O = omanikud.insertedIds;
  const MINA = O[0];                         // Jegor Onoprijuk

  // --- 2. TALLID (6) -----------------------------------------------------
  const tallid = await db.collection('tallid').insertMany([
    { nimi: 'Lilleoru tall', linn: 'Tallinn',  bokse: 24, manees: true,  rajatud: 1998 },
    { nimi: 'Tartu ratsabaas', linn: 'Tartu',  bokse: 18, manees: true,  rajatud: 2005 },
    { nimi: 'Niidu tall',    linn: 'Parnu',    bokse: 12, manees: false, rajatud: 2011 },
    { nimi: 'Kaseoja tall',  linn: 'Viljandi', bokse: 16, manees: true,  rajatud: 2016 },
    { nimi: 'Mannimae tall', linn: 'Rakvere',  bokse: 10, manees: false, rajatud: 2009 },
    { nimi: 'Rannaniidu tall', linn: 'Haapsalu', bokse: 14, manees: true, rajatud: 2019 },
  ]);
  const T = tallid.insertedIds;

  // --- 3. HOBUSED (7) - igal hobusel on omanik ja tall -------------------
  const hobused = await db.collection('hobused').insertMany([
    { nimi: 'Tormi',   tous: 'Eesti hobune',      synniaeg: new Date('2016-05-14'),
      sugu: 'markk', varv: 'raudjas', korgus_cm: 148, omanik_id: MINA, tall_id: T[0] },
    { nimi: 'Pilve',   tous: 'Trakeen',           synniaeg: new Date('2018-03-02'),
      sugu: 'mara',  varv: 'hall',    korgus_cm: 165, omanik_id: MINA, tall_id: T[0] },
    { nimi: 'Rubiin',  tous: 'Hannoveri',         synniaeg: new Date('2015-06-21'),
      sugu: 'markk', varv: 'kollane', korgus_cm: 170, omanik_id: O[1], tall_id: T[1] },
    { nimi: 'Luna',    tous: 'Araabia taisverb',  synniaeg: new Date('2019-04-30'),
      sugu: 'mara',  varv: 'must',    korgus_cm: 156, omanik_id: O[2], tall_id: T[2] },
    { nimi: 'Sulg',    tous: 'Eesti sporthobune', synniaeg: new Date('2017-08-11'),
      sugu: 'ruun',  varv: 'voks',    korgus_cm: 162, omanik_id: O[3], tall_id: T[3] },
    { nimi: 'Tuuleke', tous: 'Shetlandi poni',    synniaeg: new Date('2020-02-08'),
      sugu: 'mara',  varv: 'pruun',   korgus_cm: 104, omanik_id: O[4], tall_id: T[4] },
    { nimi: 'Vaher',   tous: 'Tori hobune',       synniaeg: new Date('2014-09-25'),
      sugu: 'ruun',  varv: 'raudjas', korgus_cm: 158, omanik_id: O[5], tall_id: T[5] },
  ]);
  const H = hobused.insertedIds;

  // --- 4. VARUSTUS (8) ---------------------------------------------------
  // Noue oli: "iga ese peab kuidagi kellelegi kuuluma". Tegin ule valja
  // 'kuulub', kus on nii tuup kui viide - nii saab ese kuuluda kas
  // omanikule, hobusele voi tallile, aga kunagi mitte mitte kellelegi.
  await db.collection('varustus').insertMany([
    { ese: 'Sadul Wintec 500', tuup: 'sadul',  seisund: 'hea',
      hind_eur: 790,  ostetud: new Date('2024-10-02'),
      kuulub: { tuup: 'omanik', id: MINA, nimi: 'Jegor Onoprijuk' } },
    { ese: 'Valjad Stubben',   tuup: 'valjad', seisund: 'uus',
      hind_eur: 145,  ostetud: new Date('2025-03-11'),
      kuulub: { tuup: 'omanik', id: MINA, nimi: 'Jegor Onoprijuk' } },
    { ese: 'Tekk Horseware 200g', tuup: 'tekk', seisund: 'hea',
      hind_eur: 120,  ostetud: new Date('2024-11-19'),
      kuulub: { tuup: 'hobune', id: H[0], nimi: 'Tormi' } },
    { ese: 'Transpordimassid',  tuup: 'kaitsmed', seisund: 'kulunud',
      hind_eur: 60,   ostetud: new Date('2023-05-06'),
      kuulub: { tuup: 'hobune', id: H[1], nimi: 'Pilve' } },
    { ese: 'Sadul Prestige X',  tuup: 'sadul',  seisund: 'uus',
      hind_eur: 2100, ostetud: new Date('2025-06-14'),
      kuulub: { tuup: 'omanik', id: O[1], nimi: 'Mari Tamm' } },
    { ese: 'Hobuse kiiver',     tuup: 'muu',    seisund: 'hea',
      hind_eur: 95,   ostetud: new Date('2024-01-23'),
      kuulub: { tuup: 'omanik', id: O[2], nimi: 'Jaan Kask' } },
    { ese: 'Maneezi tokked (12 tk)', tuup: 'manezivarustus', seisund: 'hea',
      hind_eur: 240,  ostetud: new Date('2022-08-30'),
      kuulub: { tuup: 'tall',   id: T[0], nimi: 'Lilleoru tall' } },
    { ese: 'Soogikausid (20 tk)',    tuup: 'tallivarustus',  seisund: 'kulunud',
      hind_eur: 180,  ostetud: new Date('2021-09-15'),
      kuulub: { tuup: 'tall',   id: T[1], nimi: 'Tartu ratsabaas' } },
  ]);

  // --- 5. TREENINGUD (6) - aeg, treener, hobused -------------------------
  await db.collection('treeningud').insertMany([
    { aeg: new Date('2025-11-03T17:00:00'), treener: 'Kadri Kuusk',
      ala: 'koolisoit',    kestus_min: 60, tall_id: T[0], hobused: [H[0], H[1]] },
    { aeg: new Date('2025-11-05T18:30:00'), treener: 'Kadri Kuusk',
      ala: 'takistussoit', kestus_min: 90, tall_id: T[0], hobused: [H[1]] },
    { aeg: new Date('2025-11-07T16:00:00'), treener: 'Toomas Oja',
      ala: 'koolisoit',    kestus_min: 45, tall_id: T[1], hobused: [H[2]] },
    { aeg: new Date('2025-11-10T15:00:00'), treener: 'Toomas Oja',
      ala: 'vastupidavus', kestus_min: 120, tall_id: T[2], hobused: [H[3], H[4]] },
    { aeg: new Date('2025-11-12T17:30:00'), treener: 'Eve Nurm',
      ala: 'poni-tund',    kestus_min: 30, tall_id: T[4], hobused: [H[5]] },
    { aeg: new Date('2025-11-14T18:00:00'), treener: 'Eve Nurm',
      ala: 'takistussoit', kestus_min: 60, tall_id: T[5], hobused: [H[6], H[0]] },
  ]);

  // ====================================================================
  //                           ARUANNE
  // ====================================================================
  console.log('='.repeat(78));
  console.log('HOBUSTE ANDMEBAAS (MongoDB)');
  console.log('Jegor Onoprijuk, ruhm TA-24B');
  console.log('='.repeat(78));

  console.log('\nDOKUMENTIDE ARV KOLLEKTSIOONIDES');
  joon();
  for (const c of ['omanikud', 'tallid', 'hobused', 'varustus', 'treeningud']) {
    console.log(c.padEnd(14) + String(await db.collection(c).countDocuments()).padStart(3));
  }

  console.log('\nMINA OMANIKE KOLLEKTSIOONIS');
  joon();
  const mina = await db.collection('omanikud').findOne({ perekonnanimi: 'Onoprijuk' });
  console.log(JSON.stringify(mina, null, 2));

  console.log('\nMINU HOBUSED');
  joon();
  const minuHobused = await db.collection('hobused').find({ omanik_id: MINA }).toArray();
  for (const h of minuHobused) {
    console.log(`${h.nimi.padEnd(10)}${h.tous.padEnd(22)}${h.varv.padEnd(10)}${h.korgus_cm} cm`);
  }

  // --------------------------------------------------------------------
  // NOUTUD FIND: varustus, mis kuulub MULLE
  // --------------------------------------------------------------------
  console.log('\nFIND: VARUSTUS, MIS KUULUB MULLE (Jegor Onoprijuk)');
  joon();
  console.log('1) otse minu nimel:');
  console.log("   db.varustus.find({ 'kuulub.tuup': 'omanik', 'kuulub.id': minuId })");
  const otse = await db.collection('varustus')
    .find({ 'kuulub.tuup': 'omanik', 'kuulub.id': MINA }).toArray();
  for (const v of otse) console.log(`   - ${v.ese.padEnd(26)} ${v.hind_eur} EUR`);

  console.log('\n2) koos minu hobuste varustusega:');
  const minuHobusteIdd = minuHobused.map(h => h._id);
  console.log("   db.varustus.find({ 'kuulub.id': { $in: [minuId, ...minuHobusteIdd] } })");
  const koik = await db.collection('varustus')
    .find({ 'kuulub.id': { $in: [MINA, ...minuHobusteIdd] } }).toArray();
  let summa = 0;
  for (const v of koik) {
    summa += v.hind_eur;
    console.log(`   - ${v.ese.padEnd(26)} ${String(v.hind_eur).padStart(5)} EUR` +
                `   (kuulub: ${v.kuulub.tuup} "${v.kuulub.nimi}")`);
  }
  console.log(`   ${''.padEnd(26)} ${String(summa).padStart(5)} EUR kokku`);

  console.log('\nKONTROLL: kas iga ese kuulub kellelegi?');
  joon();
  const ilma = await db.collection('varustus')
    .countDocuments({ $or: [{ kuulub: { $exists: false } }, { 'kuulub.id': null }] });
  console.log(`esemeid ilma omanikuta: ${ilma}  (peab olema 0)`);

  console.log('\nTREENINGUD (aeg, treener, hobused)');
  joon();
  const tr = await db.collection('treeningud').find({}).sort({ aeg: 1 }).toArray();
  for (const t of tr) {
    const nimed = await db.collection('hobused')
      .find({ _id: { $in: t.hobused } }).project({ nimi: 1 }).toArray();
    console.log(`${t.aeg.toLocaleString('et-EE').padEnd(22)}${t.treener.padEnd(16)}` +
                `${t.ala.padEnd(16)}${nimed.map(n => n.nimi).join(', ')}`);
  }

  await client.close();
}

main().catch(e => { console.error(e); process.exit(1); });

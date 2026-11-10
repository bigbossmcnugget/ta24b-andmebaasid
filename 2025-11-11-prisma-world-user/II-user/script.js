/*
 * II osa - uus andmebaas (user / post) Prismaga.
 * Jegor Onoprijuk, ruhm TA-24B   (ulesanne 2025-11-11 "Prisma")
 *
 * Esimesed kaks rida peavad olema iga skripti alguses - nii oli
 * PRISMA.docx-is kirjas.
 */
const { PrismaClient } = require('@prisma/client');
const db = new PrismaClient();
const joon = (n = 78) => console.log('-'.repeat(n));

async function main() {
  console.log('='.repeat(78));
  console.log('UUS ANDMEBAAS: jegor_blog  (user / post)');
  console.log('Jegor Onoprijuk, ruhm TA-24B');
  console.log('='.repeat(78));

  const kes = await db.$queryRawUnsafe('SELECT CURRENT_USER() AS kasutaja, DATABASE() AS baas');
  console.log(`\nuhendus: ${kes[0].kasutaja}  andmebaas: ${kes[0].baas}`);

  // --- puhas leht --------------------------------------------------------
  await db.post.deleteMany();
  await db.profile.deleteMany();
  await db.user.deleteMany();

  // --- CREATE: kasutaja koos postituste ja profiiliga uhe paringuga ------
  console.log('\nCREATE: kasutajad (nested create - kasutaja + profiil + postitused korraga)');
  joon();
  const mina = await db.user.create({
    data: {
      email: 'jegor.onoprijuk@tktk.ee',
      name: 'Jegor Onoprijuk',
      position: 'ADMIN',
      profile: { create: { bio: 'TA-24B oppur, Tallinna Tehnoloogiakolledz', linn: 'Tallinn' } },
      posts: {
        create: [
          { title: 'Minu esimene postitus', body: 'Proovin Prismat.', isPublished: true },
          { title: 'Prisma migratsioonid',  body: 'migrate dev teeb SQL-i ise.', isPublished: true },
          { title: 'Mustand',               body: 'See ei ole veel valmis.' },
        ],
      },
    },
    include: { posts: true, profile: true },
  });
  console.log(`${mina.name} <${mina.email}>  roll=${mina.position}  postitusi=${mina.posts.length}`);

  const mari = await db.user.create({
    data: {
      email: 'mari.tamm@tktk.ee', name: 'Mari Tamm',
      profile: { create: { bio: 'Opin samas ruhmas', linn: 'Tartu' } },
      posts: { create: [{ title: 'Tere', body: 'Esimene kord siin.', isPublished: true }] },
    },
    include: { posts: true },
  });
  console.log(`${mari.name} <${mari.email}>  roll=${mari.position}  postitusi=${mari.posts.length}`);

  const jaan = await db.user.create({ data: { email: 'jaan.kask@tktk.ee' } });  // name = NULL
  console.log(`(nimeta kasutaja) <${jaan.email}>  name=${jaan.name}  roll=${jaan.position}`);

  // --- READ --------------------------------------------------------------
  console.log('\nREAD: koik kasutajad koos postituste arvuga');
  joon();
  const koik = await db.user.findMany({
    include: { _count: { select: { posts: true } }, profile: true },
    orderBy: { id: 'asc' },
  });
  for (const u of koik)
    console.log(`${String(u.id).padStart(2)}  ${(u.name ?? '(nimi puudub)').padEnd(20)}` +
                `${u.email.padEnd(26)}${u.position.padEnd(7)}postitusi: ${u._count.posts}` +
                `   ${u.profile ? u.profile.linn : '-'}`);

  console.log('\nREAD koos filtriga: ainult avaldatud postitused');
  joon();
  const avaldatud = await db.post.findMany({
    where: { isPublished: true },
    include: { author: { select: { name: true } } },
    orderBy: { id: 'asc' },
  });
  for (const p of avaldatud)
    console.log(`${p.title.padEnd(26)}${(p.author.name ?? '-').padEnd(20)}${p.loodud.toLocaleString('et-EE')}`);

  // --- UPDATE ------------------------------------------------------------
  console.log('\nUPDATE: avaldan mustandi ja annan Marile ADMIN rolli');
  joon();
  const mustand = await db.post.findFirst({ where: { isPublished: false } });
  await db.post.update({ where: { id: mustand.id }, data: { isPublished: true } });
  await db.user.update({ where: { email: 'mari.tamm@tktk.ee' }, data: { position: 'ADMIN' } });
  console.log(`avaldatud postitusi nuud: ${await db.post.count({ where: { isPublished: true } })}`);
  console.log(`ADMIN-e nuud: ${await db.user.count({ where: { position: 'ADMIN' } })}`);

  // --- DELETE (kaskaadiga) ----------------------------------------------
  console.log('\nDELETE: kustutan nimeta kasutaja');
  joon();
  await db.user.delete({ where: { id: jaan.id } });
  console.log(`kasutajaid alles: ${await db.user.count()}`);

  console.log('\nKASKAAD: kui kustutada kasutaja, kaovad ka tema postitused');
  joon();
  const enne = await db.post.count();
  const ajutine = await db.user.create({
    data: { email: 'ajutine@tktk.ee', name: 'Ajutine',
            posts: { create: [{ title: 'kaob ara 1' }, { title: 'kaob ara 2' }] } } });
  console.log(`postitusi parast lisamist: ${await db.post.count()}`);
  await db.user.delete({ where: { id: ajutine.id } });
  console.log(`postitusi parast kasutaja kustutamist: ${await db.post.count()} (algne oli ${enne})`);

  console.log('\nLOPPSEIS');
  joon();
  console.log(`kasutajaid : ${await db.user.count()}`);
  console.log(`profiile   : ${await db.profile.count()}`);
  console.log(`postitusi  : ${await db.post.count()}`);
}

main().catch(e => { console.error(e); process.exit(1); }).finally(() => db.$disconnect());

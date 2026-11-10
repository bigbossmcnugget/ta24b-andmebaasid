/*
 * Prisma algtookoda - PRISMA.docx jargi.
 * Jegor Onoprijuk, ruhm TA-24B   (ulesanne 2025-11-04 "Prisma")
 *
 * Dokumendis oli kirjas: "Script.ts - esimesed kaks rida peavad olema
 * iga skripti alguses." Need ongi kaks jargmist rida.
 */
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

const joon = (n = 78) => console.log('-'.repeat(n));

async function main() {
  console.log('='.repeat(78));
  console.log('PRISMA ALGTOOKODA  (User + Article + enum Positions)');
  console.log('Jegor Onoprijuk, ruhm TA-24B');
  console.log('='.repeat(78));

  const kes: any = await prisma.$queryRawUnsafe(
    'SELECT CURRENT_USER() AS kasutaja, DATABASE() AS baas');
  console.log(`\nuhendus: ${kes[0].kasutaja}   andmebaas: ${kes[0].baas}`);

  // puhas leht - Article enne, sest tal on viide User-ile
  await prisma.article.deleteMany();
  await prisma.user.deleteMany();

  // --- LISAMINE (dokumendi naide: prisma.user.create) --------------------
  console.log('\nLISAMINE');
  joon();
  const john = await prisma.user.create({
    data: { name: 'John', email: 'john@gmail.com' },
  });
  console.log(`loodud: id=${john.id} ${john.name} <${john.email}> position=${john.position}`);

  // mina ise, ADMIN-ina, koos artiklitega
  const jegor = await prisma.user.create({
    data: {
      name: 'Jegor Onoprijuk',
      email: 'jegor.onoprijuk@tktk.ee',
      position: 'ADMIN',
      Article: {
        create: [
          { title: 'Mis on ORM?',           body: 'Object-relational mapping.', isPublished: true },
          { title: 'Prisma esimene proov',  body: 'migrate dev tegi tabelid ise.', isPublished: true },
          { title: 'Mustand',               body: 'veel pooleli' },
        ],
      },
    },
    include: { Article: true },
  });
  console.log(`loodud: id=${jegor.id} ${jegor.name} <${jegor.email}> position=${jegor.position}` +
              `  artikleid=${jegor.Article.length}`);

  // --- LUGEMINE ----------------------------------------------------------
  console.log('\nLUGEMINE');
  joon();
  const koik = await prisma.user.findMany({
    include: { Article: true }, orderBy: { id: 'asc' } });
  for (const u of koik) {
    console.log(`${String(u.id).padStart(2)}  ${(u.name ?? '(nimeta)').padEnd(18)}` +
                `${u.email.padEnd(26)}${u.position.padEnd(7)}artikleid: ${u.Article.length}`);
    for (const a of u.Article)
      console.log(`      - ${a.title.padEnd(26)}${a.isPublished ? 'avaldatud' : 'mustand'}`);
  }

  console.log('\nLUGEMINE TINGIMUSEGA: ainult avaldatud artiklid');
  joon();
  const avaldatud = await prisma.article.findMany({
    where: { isPublished: true }, include: { author: { select: { name: true } } } });
  for (const a of avaldatud) console.log(`${a.title.padEnd(28)}${a.author.name}`);

  // --- MUUTMINE ----------------------------------------------------------
  console.log('\nMUUTMINE');
  joon();
  const uuendatud = await prisma.user.update({
    where: { email: 'john@gmail.com' },
    data: { name: 'John Smith', position: 'ADMIN' } });
  console.log(`${uuendatud.email} -> nimi "${uuendatud.name}", position ${uuendatud.position}`);

  const mustand = await prisma.article.findFirst({ where: { isPublished: false } });
  if (mustand) {
    await prisma.article.update({ where: { id: mustand.id }, data: { isPublished: true } });
    console.log(`artikkel "${mustand.title}" on nuud avaldatud`);
  }

  // --- VALIDEERIMINE: email peab olema unikaalne -------------------------
  console.log('\nVALIDEERIMINE: proovin lisada sama e-posti teist korda');
  joon();
  try {
    await prisma.user.create({ data: { name: 'Teine John', email: 'john@gmail.com' } });
    console.log('lisati ara - see ei tohiks juhtuda!');
  } catch (e: any) {
    console.log(`Prisma ei lubanud. Veakood: ${e.code}`);
    console.log(`Pohjus: vali "${e.meta?.target}" on skeemis margitud @unique.`);
  }

  // --- KUSTUTAMINE -------------------------------------------------------
  console.log('\nKUSTUTAMINE');
  joon();
  await prisma.user.delete({ where: { email: 'john@gmail.com' } });
  console.log(`kasutajaid alles: ${await prisma.user.count()}`);
  console.log(`artikleid alles : ${await prisma.article.count()}`);
}

main()
  .catch((e) => { console.error(e.message); process.exit(1); })
  .finally(async () => { await prisma.$disconnect(); });

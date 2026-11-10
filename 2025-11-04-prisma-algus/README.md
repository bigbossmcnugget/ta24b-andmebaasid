# 2025-11-04 — Prisma (PRISMA.docx läbi tehtud)

Jegor Onoprijuk, rühm TA-24B.

## Ülesanne

Ülesande juures oli kirjas ainult "Dokument lisatud" ja kaasas oli **PRISMA.docx**.
Dokumendis on seletatud, mis on ORM, kuidas Prisma paigaldada, mis on
`schema.prisma` kolm osa ja mida teevad `prisma generate` ja `prisma migrate dev`.
Näidisandmemudelina on seal `User` + `Article` + `enum Positions`, ning
`script.ts`, mille esimesed kaks rida peavad olema iga skripti alguses.

Tegin selle kõik päriselt läbi: oma projekt, oma andmebaas, migratsioon ja
skript, mis lisab / loeb / muudab / valideerib / kustutab andmeid.

## Failid

| Fail | Mis see on |
|---|---|
| [`prisma/schema.prisma`](prisma/schema.prisma) | andmemudel dokumendi näite järgi |
| [`prisma/migrations`](prisma/migrations) | Prisma tehtud migratsioon |
| [`script.ts`](script.ts) | lisamine, lugemine, muutmine, valideerimine, kustutamine |
| [`tsconfig.json`](tsconfig.json) | TypeScripti seaded |
| [`jegor_prisma_algus_dump.sql`](jegor_prisma_algus_dump.sql) | andmebaasi dump |
| [`valjund.txt`](valjund.txt) | terve terminali logi |

## Käivitamine

```
npm install
npx prisma migrate dev --name init
npm start        # ts-node script.ts
npm run devStart # nodemon script.ts
```

## Andmemudel

```prisma
enum Positions { ADMIN  BASIC }

model User {
  id       Int       @id @default(autoincrement())
  email    String    @unique
  name     String?
  Article  Article[]
  position Positions @default(BASIC)
}

model Article {
  id          Int     @id @default(autoincrement())
  title       String
  body        String?
  author      User    @relation(fields: [userId], references: [id])
  isPublished Boolean @default(false)
  userId      Int
}
```

## Mida ma siit aru sain

**`name String?` ja `body String?` — küsimärk tähendab NULL.** Logis on näha
kasutaja, kellel nime ei ole. Ilma küsimärgita nõuaks Prisma väärtust.

**`@unique` ei ole lihtsalt kommentaar.** Proovisin meelega sama e-postiga teist
kasutajat lisada ja sain `P2002` koos väljanimega `User_email_key` — see on
andmebaasi unikaalne indeks, mille migratsioon tegi. Veakood on logis näha.

**Seos kirjutatakse mõlemale poole.** `Article` küljes on `author User
@relation(fields: [userId], references: [id])` ja `User` küljes `Article
Article[]`. Esimene teeb välisvõtme, teine on ainult Prisma jaoks, et saaks
`include: { Article: true }` kirjutada.

**`migrate dev` kirjutab SQL-i ise.** Ma ei kirjutanud ühtegi `CREATE TABLE`
lauset — need on failis `prisma/migrations/.../migration.sql` ja on logis välja
trükitud. Nii jääb ajalugu alles, erinevalt `db push`-ist.

**`ts-node script.ts` ei käivitunud kohe.** TypeScript kurtis
`verbatimModuleSyntax` ja puuduva `process` tüübi üle. Kirjutasin `tsconfig.json`
ise üle: `"module": "CommonJS"` ja `"types": ["node"]`. Pärast seda töötas.

**Ühendus käib minu nimelise kasutajaga**, mitte `root`-iga — skript trükib
iga käivituse alguses välja `CURRENT_USER()`:

```
uhendus: jegor_onoprijuk@localhost   andmebaas: jegor_prisma_algus
```

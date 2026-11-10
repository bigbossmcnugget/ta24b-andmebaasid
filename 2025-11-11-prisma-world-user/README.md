# 2025-11-11 — Prisma: I World, II User/Post

Jegor Onoprijuk, rühm TA-24B.

## Ülesanne

**Esmane ülesanne.** Teha oma masinasse enda nimeline MySQL-i kasutaja ja anda
talle kõik õigused andmebaasile `world`. Muuta Prisma `.env` nii, et sisselogimine
toimuks minu nime all.

**I World.** Tuua `world` andmemudel Prismasse (`prisma db pull`), teha päringuid,
lisada andmeid. Lisada mudelisse tabel ülikoolide kohta, mis on seotud riikide tabeliga.

**II User.** Teha uus MySQL-i andmebaas, koostada `user`/`post` andmemudel
`prisma.schema` failis, migreerida muudatused MySQL-i ja sisestada andmed.

## Failid

| Fail | Mis see on |
|---|---|
| [`I-world/prisma/schema.prisma`](I-world/prisma/schema.prisma) | `db pull`-iga toodud world + minu lisatud `university` |
| [`I-world/script.js`](I-world/script.js) | päringud world-baasi peal (CRUD) |
| [`II-user/prisma/schema.prisma`](II-user/prisma/schema.prisma) | user / post / profile mudel |
| [`II-user/prisma/migrations`](II-user/prisma/migrations) | Prisma migratsioon (päris `CREATE TABLE` laused) |
| [`II-user/script.js`](II-user/script.js) | andmete lisamine ja CRUD |
| [`world_university_dump.sql`](world_university_dump.sql) | minu lisatud tabel koos andmetega |
| [`jegor_blog_dump.sql`](jegor_blog_dump.sql) | teise osa andmebaasi dump |
| [`valjund.txt`](valjund.txt) | terve terminali logi algusest lõpuni |

## Esmane ülesanne — minu nimeline kasutaja

```sql
CREATE USER 'jegor_onoprijuk'@'localhost' IDENTIFIED BY 'TA24B_parool';
GRANT ALL PRIVILEGES ON world.* TO 'jegor_onoprijuk'@'localhost';
FLUSH PRIVILEGES;
```

`.env`:

```
DATABASE_URL="mysql://jegor_onoprijuk:TA24B_parool@localhost:3306/world"
```

Kontroll skripti sees — iga käivitus trükib välja, kelle nime all ühendus käib:

```
uhendus: jegor_onoprijuk@localhost   andmebaas: world
```

Nii on näha, et ma ei kasuta `root`-i.

## I osa — World

`npx prisma db pull` tõi sisse 4 mudelit: `city`, `country`, `countrylanguage`
ja `country_log` (viimane on minu enda tabel eelmisest, triggerite tööst —
`db pull` toob **kõik**, mis baasis on, ka selle, mida ise varem tegin).

Minu lisatud tabel:

```prisma
model university {
  id          Int     @id @default(autoincrement())
  Name        String  @db.VarChar(120)
  City        String  @db.VarChar(60)
  CountryCode String  @db.Char(3)
  Founded     Int?    @db.SmallInt
  Students    Int?
  Website     String? @db.VarChar(120)
  country     country @relation(fields: [CountryCode], references: [Code])
}
```

Ühes riigis võib olla mitu ülikooli, üks ülikool on ühes riigis — 1:n.

Skript teeb `world` peal kõik neli CRUD-tegevust: loeb (top-5 riiki, Eesti
linnad, grupeerimine mandrite kaupa), lisab linna, muudab selle rahvaarvu ja
kustutab selle jälle ära.

### Üks asi, mis mul kohe ei töötanud

`prisma db push` tegi tabeli ära, aga välisvõti jäi tekkimata. Põhjus tuli
välja `SHOW TABLE STATUS`-est: `country` on sortimisega `utf8mb4_uca1400_ai_ci`,
aga Prisma tegi uue tabeli `utf8mb4_unicode_ci`-ga. MySQL ei luba välisvõtit
kahe erineva sortimisega `CHAR(3)` veeru vahele. Parandus:

```sql
ALTER TABLE university CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci;
ALTER TABLE university ADD CONSTRAINT university_country_fk
  FOREIGN KEY (CountryCode) REFERENCES country(Code);
```

Teine asi: mu eelmise töö triggerid olid tehtud nii, et `DEFINER` oli tühi, ja
niipea kui ma enam `root`-ina ei ühendunud, andis iga `INSERT` linnade tabelisse
vea *"The user specified as a definer ('' @ '') does not exist"*. Tegin triggerid
korraliku definer'iga uuesti.

## II osa — uus andmebaas `jegor_blog`

Mudel on PRISMA.docx näite järgi (`User` + `Article` + `enum Positions`), aga
`Article` sai nimeks `Post`, nagu ülesandes kirjas oli. Lisasin juurde `Profile`,
et oleks näha ka 1:1 seos:

* `User` ↔ `Post` — 1:n
* `User` ↔ `Profile` — 1:1 (`@unique` välisvõtme peal)
* `position` on enum `ADMIN` / `BASIC`, vaikimisi `BASIC`

`npx prisma migrate dev --name init` kirjutas migratsiooni ise — seda faili ma
käsitsi ei kirjutanud, see on kaasas kaustas `prisma/migrations`.

Skript näitab:

* **nested create** — kasutaja, tema profiil ja kolm postitust ühe päringuga,
* lugemist koos `_count`-iga ja filtriga (`isPublished: true`),
* muutmist,
* kustutamist ja **kaskaadi**: kui kustutada kasutaja, kaovad ka tema
  postitused (`onDelete: Cascade`) — logis on näha, kuidas postituste arv
  6 → 4 tagasi läheb.

## Lõppseis

```
world      : 239 riiki, 4079 linna, + minu tabel university (6 kirjet)
jegor_blog : 2 kasutajat, 2 profiili, 4 postitust
```

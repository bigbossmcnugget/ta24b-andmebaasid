# 2026-01-29 — Päringud (world) ja Drizzle

Jegor Onoprijuk, rühm TA-24B.

## Ülesanne

**I Päringud** (`world` andmebaasil): leia riigid, mille riigipea nimi algab
U-tähega / sisaldab z-tähte; kolm riigipead, kes valitsevad kõige rohkem riike;
riigid pindala järgi 21.–40. kohal; Ameerika riikide keskmine eluiga; Ameerika
inimeste keskmine eluiga (riikide kaalutud keskmine); millisel kontinendil on
kõige rohkem vabariike; mitmes riigis, mis kontinentidel ja kui paljud inimesed
räägivad portugali keelt.

**II Drizzle install.** Uus projekt VS Code'is: `npm init -y`, TypeScript, `tsx`,
`drizzle-orm`, `mysql2`, `drizzle-kit`, `dotenv`, `drizzle.config.ts`, MySQL-is
andmebaas `test-db`, tabel `test` (`id` autoincrement/primary key,
`description varchar(255) not null`), `drizzle-kit generate` ja `drizzle-kit push`.

## Failid

| Fail | Mis see on |
|---|---|
| [`I-paringud/paringud.sql`](I-paringud/paringud.sql) | kõik päringud kommenteeritult |
| [`II-drizzle/src/schema.ts`](II-drizzle/src/schema.ts) | andmemudel (tabel `test`) |
| [`II-drizzle/src/schema.serial_yl.ts`](II-drizzle/src/schema.serial_yl.ts) | sama, täpselt nagu ülesandes (`serial`) |
| [`II-drizzle/src/index.ts`](II-drizzle/src/index.ts) | lisab / loeb / muudab / kustutab Drizzle'iga |
| [`II-drizzle/drizzle/`](II-drizzle/drizzle) | `drizzle-kit generate` tehtud migratsioon |
| [`II-drizzle/drizzle.config.ts`](II-drizzle/drizzle.config.ts) | seadistus |
| [`valjund.txt`](valjund.txt) | terve terminali logi |
| [`screenshots/`](screenshots) | logi ekraanipiltidena |

## I osa — tulemused

| # | Päring | Vastus |
|---|---|---|
| 1 | riigipea nimi algab U | 27 riiki |
| 2 | riigipea nimes z | nimekiri logis (`valjund.txt`, päring 2) |
| 3 | 3 riigipead, kes valitsevad kõige rohkem riike | Elisabeth II — 35, Jacques Chirac — 11, George W. Bush — 7 |
| 4 | pindala 21.–40. koht | Peru (21.) … Zambia (40.) |
| 5 | Ameerika keskmine eluiga | **72,46** aastat (50 riiki) |
| 6 | Ameerika inimeste keskmine eluiga (kaalutud) | **71,84** aastat |
| 7 | kõige rohkem vabariike | **Aafrika** — 49 |
| 8 | portugali keel | 12 riiki, 5 kontinenti; räägib **177 595 269** inimest, ametliku keelena **175 868 881** |

**Miks 5 ja 6 on erinevad.** Lihtne keskmine annab Costa Ricale (4 miljonit
inimest) ja Brasiiliale (170 miljonit) sama kaalu. Kaalutud keskmine arvestab
rahvaarvuga, seega on see õigem vastus küsimusele "inimeste keskmine eluiga".

**Päring 3 ja tühjad riigipead.** Jätsin välja tühjad ja NULL riigipead —
muidu "valitseks" kõige rohkem riike tühi string (Antarktika jt).

**Päring 4.** Järjestan pindala järgi kahanevalt, jätan `OFFSET 20` esimest
vahele ja võtan `LIMIT 20`.

**Päring 7.** "Vabariik" = `GovernmentForm LIKE '%Republic%'`. Selle peale
läheb ka nt "Federal Republic" ja "Islamic Republic".

**Päring 8.** Keele kõnelejate arv = `riigi rahvaarv × protsent / 100`, sest
tabelis on ainult protsent. Cape Verde ja East Timor on portugali keelega
ametlikud, aga protsent on 0,0 — seega 12 riiki, aga nad ei lisa inimesi.

## II osa — Drizzle

```
npm init -y
npm i -D typescript
npm i -D tsx @types/node --save-dev
tsc --init
npm i drizzle-orm mysql2
npm i -D drizzle-kit
npm i dotenv
npx drizzle-kit generate
npx drizzle-kit push
npx tsx src/index.ts
```

Migratsioon (`drizzle/0000_*.sql`):

```sql
CREATE TABLE `test` (
	`id` bigint unsigned AUTO_INCREMENT NOT NULL,
	`description` varchar(255) NOT NULL,
	CONSTRAINT `test_id` PRIMARY KEY(`id`)
);
```

### Üks asi, mis mul kohe ei töötanud

Ülesandes oli `id: serial("id").primaryKey()`. `drizzle-kit generate` tegi sellest
`id serial AUTO_INCREMENT NOT NULL` ja `push` kukkus `ER_PARSE_ERROR`-iga. Põhjus:
MySQL-is on `SERIAL` lühend `BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE`, aga
minu masinas jookseb **MariaDB 13**, mis ei võta `serial AUTO_INCREMENT` kirjutust vastu.

Parandus: `bigint('id', { mode: 'number', unsigned: true }).autoincrement().primaryKey()`
— see on täpselt see, milleks MySQL `serial` lahti kirjutab. Algne variant ülesande
järgi on alles failis `schema.serial_yl.ts`, et oleks näha, mida ma muutsin ja miks.

Ühendus käib minu nimelise kasutajaga `jegor_onoprijuk`, mitte `root`-iga.
Andmebaasi nimes on kriips (`test-db`), seega SQL-is tuleb see tagurpidi
ülakomade vahele panna.

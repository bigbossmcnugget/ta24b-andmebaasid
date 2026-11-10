# 2025-11-18 — Jalgpall (Prisma + MySQL)

Jegor Onoprijuk, rühm TA-24B.

## Ülesanne

Luua jalgpalli andmebaas Prismaga. Igasse tabelisse vähemalt 2 kirjet,
mängijaid 6 ja jagatud vähemalt kahe klubi vahel. **Iseennast tuli lisada
Coach tabelisse ja panna end kahe klubi treeneriks.** Igas tabelis peab olema
väli `createdat`, mille vaikeväärtus on `CURRENT_TIMESTAMP`.

Nõutud tabelid: `Player`, `Club`, `Coach`, `Game`.
Treeneri ja klubi seos peab olema **n:m**.

## Failid

| Fail | Mis see on |
|---|---|
| [`prisma/schema.prisma`](prisma/schema.prisma) | kogu andmemudel |
| [`prisma/migrations`](prisma/migrations) | Prisma tehtud migratsioon (päris `CREATE TABLE` laused) |
| [`seed.js`](seed.js) | andmete lisamine ja väljatrükk |
| [`jalgpall_prisma_dump.sql`](jalgpall_prisma_dump.sql) | andmebaasi dump koos andmetega |
| [`valjund.txt`](valjund.txt) | terve terminali logi: migratsioon, tabelid, seed, kontrollpäringud |
| [`.env.example`](.env.example) | `DATABASE_URL` näidis |

## Käivitamine

```
npm install
cp .env.example .env
npx prisma migrate dev --name init
node seed.js
```

## Mina ise andmebaasis

Ülesandes oli otse kirjas, et pean end treenerite hulka panema. Olen `Coach`
tabelis ja **kahe** klubi peatreener — see ongi n:m seos:

```
treener            klubi                 roll
Jegor Onoprijuk    FC Flora              peatreener
Jegor Onoprijuk    Nomme Kalju           peatreener
Jurgen Henn        FC Flora              abitreener
Karel Voolaid      Paide Linnameeskond   peatreener
```

Üks treener on kahes klubis ja ühes klubis (FC Flora) on kaks treenerit —
nii on mõlemat pidi näha, et seos päriselt on n:m, mitte 1:n.

## Mida ma ise otsustasin

**Vahetabeli tegin ise, mitte Prisma implicit m-n.** Prisma oskab n:m seose
ise ära teha (`coaches Coach[]` mõlemal pool), aga siis tekib tabel, kuhu ma
ei saa oma välju panna. Ülesandes oli nõue, et **igas** tabelis on `createdat`,
seega tegin `CoachClub` käsitsi — nii mahub sinna ka `createdat` ja boonusena
`role` (peatreener / abitreener).

**Lisasin tabeli `Country`.** `Player` ja `Coach` väli oli `countryid` — see
viitab millelegi. Kui jätta lihtsalt numbriks, pole sellel mõtet; kui panna
riigi nimi tekstina, kordub sama nimi igas reas. Seega eraldi tabel.

**Palk on `Decimal(10,2)`, mitte `Float`.** Raha ja ujukomaarv ei käi kokku.

**`Game` viitab `Club`-ile kaks korda.** `homeclub` ja `foreignclub` on mõlemad
sama tabeli võtmed, seega tuli Prismas seosed nimega eristada
(`@relation("homeclub")` ja `@relation("foreignclub")`), muidu ta ei tea,
kumb kumb on.

## Kontroll: kas `createdat` tuleb päriselt andmebaasist?

`@default(now())` paneb Prisma migratsiooni `DEFAULT CURRENT_TIMESTAMP(3)` —
seda on näha `migration.sql`-is ja `information_schema`-st (logis punkt 2).

Aga Prisma klient saadab tavaliselt ise ka väärtuse kaasa, nii et see ei
tõesta veel midagi. Seepärast lisasin **teise mängu meelega toore SQL-iga ja
jätsin `createdat` välja**:

```js
await db.$executeRawUnsafe(
  'INSERT INTO `Game` (homeclub, foreignclub, homescore, foreignscore, ' +
  'homeformation, foreignformation, gametime) VALUES (?, ?, ?, ?, ?, ?, ?)', ...);
```

Rida tekkis ikkagi täidetud `createdat`-iga — järelikult väärtuse pani sinna
andmebaas ise.

Üks huvitav kõrvalmärkus: nende kahe rea ajad erinevad täpselt 2 tunni võrra.
Põhjus on see, et Prisma salvestab aja UTC-s, MariaDB `CURRENT_TIMESTAMP` aga
kasutab serveri ajavööndit (meil UTC+2). Päris projektis tuleks üks neist
valida ja sellest kinni pidada.

## Lõppseis

```
Country       3      Player        6
Club          3      Game          2
Coach         3      CoachClub     4
```

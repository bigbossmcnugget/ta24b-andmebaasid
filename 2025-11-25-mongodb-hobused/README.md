# 2025-11-25 — MongoDB, hobuste andmebaas

Jegor Onoprijuk, rühm TA-24B.

## Ülesanne

Teha hobuste andmebaas MongoDB-s: hobused, omanikud, tallid, varustus,
treeningud. Igas kollektsioonis vähemalt 6 dokumenti. Andmebaas peab olema
tehtud nii, et teaksime:

* kellele hobune kuulub,
* kellele varustus kuulub — **iga ese peab kuidagi kellelegi kuuluma**,
* treeningul aeg, treener ja hobused.

**NB!** Iseennast tuli lisada omanike kollektsiooni ja teha `find` käsk, mis
tagastab varustuse, mis kuulub mulle.

## Failid

| Fail | Mis see on |
|---|---|
| [`seed.js`](seed.js) | kogu töö — kollektsioonid, andmed, päringud, väljatrükk |
| [`kasud.js`](kasud.js) | samad käsud mongosh'i kujul (kopeeri-kleebi) |
| [`export.js`](export.js) | kollektsioonide eksport JSON-i |
| [`andmed/`](andmed) | eksporditud dokumendid (varukoopia asemel) |
| [`valjund.txt`](valjund.txt) | terve terminali logi koos serveri versiooniga |

## Käivitamine

```
mongod --dbpath /tmp/mongodata --port 27017
npm install
node seed.js
```

## Mina ise andmebaasis

```json
{
  "eesnimi": "Jegor",
  "perekonnanimi": "Onoprijuk",
  "ruhm": "TA-24B",
  "telefon": "+372 5555 0101",
  "aadress": { "riik": "Eesti", "linn": "Tallinn", "tanav": "Parnu maantee 62" },
  "liitus": "2024-09-01"
}
```

Mulle kuuluvad hobused **Tormi** (Eesti hobune) ja **Pilve** (Trakeen).

## Nõutud `find`: varustus, mis kuulub mulle

```js
const mina = db.omanikud.findOne({ perekonnanimi: "Onoprijuk" })
db.varustus.find({ "kuulub.tuup": "omanik", "kuulub.id": mina._id })
```

annab:

```
- Sadul Wintec 500    790 EUR
- Valjad Stubben      145 EUR
```

Tegin ka teise variandi, mis võtab kaasa minu **hobuste** varustuse — minu
meelest on see õigem vastus küsimusele "mis mulle kuulub", sest hobused on
samamoodi minu omad:

```js
const minuHobused = db.hobused.find({ omanik_id: mina._id }).toArray().map(h => h._id)
db.varustus.find({ "kuulub.id": { $in: [mina._id, ...minuHobused] } })
```

```
- Sadul Wintec 500       790 EUR   (kuulub: omanik "Jegor Onoprijuk")
- Valjad Stubben         145 EUR   (kuulub: omanik "Jegor Onoprijuk")
- Tekk Horseware 200g    120 EUR   (kuulub: hobune "Tormi")
- Transpordimassid        60 EUR   (kuulub: hobune "Pilve")
                        1115 EUR kokku
```

## Mida ma ise otsustasin

**Varustusel on üks väli `kuulub`, mitte kolm eraldi välja.** Ülesandes oli
öeldud, et ese võib kuuluda tallile või hobusele või omanikule, aga peab
kuuluma kellelegi. Kui teha kolm välja (`omanik_id`, `hobune_id`, `tall_id`),
siis on võimalik, et kõik kolm on tühjad ja ese ripub õhus. Seepärast tegin:

```js
kuulub: { tuup: "omanik" | "hobune" | "tall", id: ObjectId, nimi: "..." }
```

Üks päring leiab omaniku sõltumata sellest, mis tüüpi ta on. Logis on ka
kontroll, mis loeb kokku esemed ilma omanikuta — vastus on 0.

**`nimi` on `kuulub` sees meelega dubleeritud.** Relatsioonilises baasis oleks
see viga (andmed kahes kohas). MongoDB-s on see tavaline — nii saab varustuse
nimekirja välja trükkida ilma teist päringut tegemata. Õpetaja ütles, et
`$lookup`-i me veel ei vaata, nii et see on siin mõistlik lahendus.

**Treeningul on hobused massiivina.** Ühel treeningul võib olla mitu hobust ja
üks hobune käib mitmel treeningul. SQL-is oleks selleks vahetabel, MongoDB-s
piisab massiivist `hobused: [ObjectId, ObjectId]`.

**Kuupäevad on `new Date()`, mitte tekst.** Muidu ei saaks neid sorteerida ega
võrrelda — `sort({ aeg: 1 })` logis töötab just seepärast.

## Lõppseis

```
omanikud        6
tallid          6
hobused         7
varustus        8
treeningud      6
```

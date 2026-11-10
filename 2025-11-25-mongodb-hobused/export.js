// Kollektsioonide eksport JSON-faili (varukoopia asemel).
// Jegor Onoprijuk, TA-24B
const { MongoClient } = require('mongodb');
const fs = require('fs');
(async () => {
  const c = new MongoClient('mongodb://127.0.0.1:27017');
  await c.connect();
  const db = c.db('hobused');
  fs.mkdirSync('andmed', { recursive: true });
  for (const k of ['omanikud', 'tallid', 'hobused', 'varustus', 'treeningud']) {
    const d = await db.collection(k).find({}).toArray();
    fs.writeFileSync(`andmed/${k}.json`, JSON.stringify(d, null, 2), 'utf8');
    console.log(`andmed/${k}.json  ${d.length} dokumenti`);
  }
  await c.close();
})();

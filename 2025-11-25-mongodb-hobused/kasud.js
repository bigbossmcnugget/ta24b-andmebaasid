// Samad kasud mongosh'i jaoks (kopeeri ja kleebi).
// Jegor Onoprijuk, ruhm TA-24B

use hobused

// --- vaatame, mis sees on ------------------------------------------------
show collections
db.omanikud.countDocuments()
db.tallid.countDocuments()
db.hobused.countDocuments()
db.varustus.countDocuments()
db.treeningud.countDocuments()

// --- mina omanike kollektsioonis -----------------------------------------
db.omanikud.findOne({ perekonnanimi: "Onoprijuk" })

// --- minu hobused --------------------------------------------------------
const mina = db.omanikud.findOne({ perekonnanimi: "Onoprijuk" })
db.hobused.find({ omanik_id: mina._id })

// --- NOUTUD FIND: varustus, mis kuulub mulle -----------------------------
db.varustus.find({ "kuulub.tuup": "omanik", "kuulub.id": mina._id })

// sama, aga koos minu hobuste varustusega
const minuHobused = db.hobused.find({ omanik_id: mina._id }).toArray().map(h => h._id)
db.varustus.find({ "kuulub.id": { $in: [mina._id, ...minuHobused] } })

// --- kontroll: kas moni ese on ilma omanikuta? ---------------------------
db.varustus.countDocuments({ $or: [ { kuulub: { $exists: false } }, { "kuulub.id": null } ] })

// --- treeningud ajalises jarjekorras -------------------------------------
db.treeningud.find({}).sort({ aeg: 1 })

// --- paar naidet teistest kaskudest --------------------------------------
db.hobused.find({ korgus_cm: { $gte: 160 } })                    // suured hobused
db.varustus.updateOne({ ese: "Transpordimassid" }, { $set: { seisund: "vahetatud" } })
db.varustus.find({ seisund: "kulunud" })
db.treeningud.find({ treener: "Kadri Kuusk" })

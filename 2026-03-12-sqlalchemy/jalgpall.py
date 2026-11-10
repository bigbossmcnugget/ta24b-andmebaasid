# -*- coding: utf-8 -*-
"""
Lihtne jalgpalli andmebaas SQLAlchemy abil.
Jegor Onoprijuk, ruhm TA-24B

Sama skript teeb sama andmebaasi NII SQLite-s KUI MySQL-is - vahetada
tuleb ainult uhendusstring. Kaivitamine:

    python3 jalgpall.py sqlite
    python3 jalgpall.py mysql

Mida skript teeb:
  1. loob tabelid (klubi, treener, mangija, mang)
  2. taidab andmetega: 4 klubi, 4 treenerit, 10 mangijat
  3. paneb kokku turniiri, kus iga klubi mangib iga teisega KAKS korda -
     uks kord kodus, teine kord voorsil => 4 * 3 = 12 mangu
  4. loob vaate 'turniiritabel', mis arvutab punktid ja jarjestuse
  5. trukib turniiritabeli valja
"""
import sys
import datetime as dt
import random

from sqlalchemy import (create_engine, Column, Integer, String, Date, DateTime,
                        Numeric, ForeignKey, text, select)
from sqlalchemy.orm import declarative_base, relationship, Session

random.seed(24)
Base = declarative_base()


# ---------------------------------------------------------------- mudelid
class Treener(Base):
    __tablename__ = "treener"
    id            = Column(Integer, primary_key=True, autoincrement=True)
    eesnimi       = Column(String(50), nullable=False)
    perekonnanimi = Column(String(50), nullable=False)
    synniaeg      = Column(Date, nullable=False)      # kuupaev, mitte vanus

    klubi = relationship("Klubi", back_populates="treener", uselist=False)

    def __repr__(self):
        return f"{self.eesnimi} {self.perekonnanimi}"


class Klubi(Base):
    __tablename__ = "klubi"
    id         = Column(Integer, primary_key=True, autoincrement=True)
    nimi       = Column(String(80), nullable=False, unique=True)
    linn       = Column(String(50), nullable=False)
    staadion   = Column(String(80), nullable=False)
    treener_id = Column(Integer, ForeignKey("treener.id"), nullable=True)   # NULL = treenerit ei ole

    treener   = relationship("Treener", back_populates="klubi")
    mangijad  = relationship("Mangija", back_populates="klubi")

    def __repr__(self):
        return self.nimi


class Mangija(Base):
    __tablename__ = "mangija"
    id            = Column(Integer, primary_key=True, autoincrement=True)
    eesnimi       = Column(String(50), nullable=False)
    perekonnanimi = Column(String(50), nullable=False)
    synniaeg      = Column(Date, nullable=False)
    riik          = Column(String(50), nullable=False)
    palk          = Column(Numeric(10, 2), nullable=False)   # raha ei ole FLOAT
    klubi_id      = Column(Integer, ForeignKey("klubi.id"), nullable=False)

    klubi = relationship("Klubi", back_populates="mangijad")


class Mang(Base):
    __tablename__ = "mang"
    id           = Column(Integer, primary_key=True, autoincrement=True)
    koduklubi_id = Column(Integer, ForeignKey("klubi.id"), nullable=False)
    voorklubi_id = Column(Integer, ForeignKey("klubi.id"), nullable=False)
    kodu_varavad = Column(Integer, nullable=False)
    voor_varavad = Column(Integer, nullable=False)
    tulemus      = Column(String(10), nullable=False)        # nait "2:1"
    algusaeg     = Column(DateTime, nullable=False)
    publiku_arv  = Column(Integer, nullable=False)

    koduklubi = relationship("Klubi", foreign_keys=[koduklubi_id])
    voorklubi = relationship("Klubi", foreign_keys=[voorklubi_id])


# ---------------------------------------------------------------- vaade
# Turniiritabel. Kirjutan selle puhta SQL-ina, sest VIEW ei ole ORM-i osa.
# Loogika: iga mang annab kaks rida (kodu ja voorsil), siis grupeerin.
VIEW_SQL = """
CREATE VIEW turniiritabel AS
SELECT  k.nimi                                        AS klubi,
        COUNT(r.klubi_id)                             AS mange,
        SUM(CASE WHEN r.loodud >  r.saadud THEN 1 ELSE 0 END) AS voite,
        SUM(CASE WHEN r.loodud =  r.saadud THEN 1 ELSE 0 END) AS viike,
        SUM(CASE WHEN r.loodud <  r.saadud THEN 1 ELSE 0 END) AS kaotusi,
        SUM(r.loodud)                                 AS loodud,
        SUM(r.saadud)                                 AS saadud,
        SUM(r.loodud) - SUM(r.saadud)                 AS vahe,
        SUM(CASE WHEN r.loodud >  r.saadud THEN 3
                 WHEN r.loodud =  r.saadud THEN 1
                 ELSE 0 END)                          AS punktid
FROM    klubi k
LEFT JOIN (
        SELECT koduklubi_id AS klubi_id, kodu_varavad AS loodud, voor_varavad AS saadud FROM mang
        UNION ALL
        SELECT voorklubi_id AS klubi_id, voor_varavad AS loodud, kodu_varavad AS saadud FROM mang
) r ON r.klubi_id = k.id
GROUP BY k.id, k.nimi
"""

# ---------------------------------------------------------------- andmed
KLUBID = [
    ("FC Flora",      "Tallinn", "Lilleküla staadion"),
    ("Levadia",       "Tallinn", "Kadrioru staadion"),
    ("Paide Linnameeskond", "Paide", "Paide linnastaadion"),
    ("Narva Trans",   "Narva",   "Kreenholmi staadion"),
]

TREENERID = [
    ("Jürgen",  "Henn",     dt.date(1985, 3, 12)),
    ("Marko",   "Savić",    dt.date(1978, 11, 2)),
    ("Karel",   "Voolaid",  dt.date(1980, 6, 25)),
    ("Aleksei", "Jagudin",  dt.date(1974, 1, 30)),
]

MANGIJAD = [
    ("Rauno",     "Sappinen",  dt.date(1996,  2, 23), "Eesti",  4200.00, 0),
    ("Markus",    "Poom",      dt.date(2000,  7,  7), "Eesti",  3900.00, 0),
    ("Marko",     "Lipp",      dt.date(1999,  4, 15), "Eesti",  3100.00, 0),
    ("Sergei",    "Zenjov",    dt.date(1989,  4, 20), "Eesti",  4500.00, 1),
    ("Vlasi",     "Sinjavski", dt.date(1995,  9,  6), "Eesti",  3600.00, 1),
    ("Mihkel",    "Ainsalu",   dt.date(1996,  3, 20), "Eesti",  3300.00, 1),
    ("Henrik",    "Pürg",      dt.date(1998,  1, 11), "Eesti",  2800.00, 2),
    ("Robi",      "Saarma",    dt.date(2001,  5,  3), "Eesti",  2400.00, 2),
    ("Ilja",      "Antonov",   dt.date(1992, 12,  5), "Eesti",  3000.00, 3),
    ("Vladislav", "Kreida",    dt.date(1999,  8, 12), "Eesti",  2600.00, 3),
]


def tee_andmebaas(url, nimi):
    print(f"\n{'='*62}\n{nimi}\n{url}\n{'='*62}")
    engine = create_engine(url, echo=False, future=True)

    # puhas leht: vaade tuleb enne tabeleid maha votta, muidu jaab rippuma
    with engine.begin() as conn:
        conn.execute(text("DROP VIEW IF EXISTS turniiritabel"))
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)

    with Session(engine) as s:
        treenerid = [Treener(eesnimi=e, perekonnanimi=p, synniaeg=d)
                     for e, p, d in TREENERID]
        s.add_all(treenerid)
        s.flush()

        klubid = [Klubi(nimi=n, linn=l, staadion=st, treener=treenerid[i])
                  for i, (n, l, st) in enumerate(KLUBID)]
        s.add_all(klubid)
        s.flush()

        s.add_all([Mangija(eesnimi=e, perekonnanimi=p, synniaeg=d, riik=r,
                           palk=pa, klubi=klubid[ki])
                   for e, p, d, r, pa, ki in MANGIJAD])

        # --- turniir: iga klubi iga teisega kaks korda (kodus + voorsil)
        algus = dt.datetime(2026, 3, 14, 17, 0)
        voor = 0
        for kodu in klubid:
            for voors in klubid:
                if kodu is voors:
                    continue
                kv = random.randint(0, 4)
                vv = random.randint(0, 3)
                s.add(Mang(
                    koduklubi=kodu, voorklubi=voors,
                    kodu_varavad=kv, voor_varavad=vv,
                    tulemus=f"{kv}:{vv}",
                    algusaeg=algus + dt.timedelta(days=voor * 7, hours=voor % 3),
                    publiku_arv=random.randint(450, 4800),
                ))
                voor += 1
        s.commit()

    with engine.begin() as conn:
        conn.execute(text(VIEW_SQL))

    # --- kontroll ja valjatrukk
    with Session(engine) as s:
        print(f"klubisid   : {s.query(Klubi).count()}")
        print(f"treenereid : {s.query(Treener).count()}")
        print(f"mangijaid  : {s.query(Mangija).count()}")
        print(f"mange      : {s.query(Mang).count()}")

        print("\nMANGUD")
        print(f"{'kuupaev':<17}{'kodu':<22}{'tulemus':<9}{'voorsil':<22}{'publik':>7}")
        print("-" * 78)
        for m in s.query(Mang).order_by(Mang.algusaeg):
            print(f"{m.algusaeg.strftime('%d.%m.%Y %H:%M'):<17}"
                  f"{m.koduklubi.nimi:<22}{m.tulemus:^9}"
                  f"{m.voorklubi.nimi:<22}{m.publiku_arv:>7}")

        print("\nTURNIIRITABEL (vaade 'turniiritabel')")
        print(f"{'#':<3}{'klubi':<22}{'M':>3}{'V':>3}{'Vi':>4}{'K':>3}"
              f"{'L':>4}{'S':>4}{'+/-':>5}{'P':>4}")
        print("-" * 55)
        rows = s.execute(text(
            "SELECT klubi, mange, voite, viike, kaotusi, loodud, saadud, vahe, punktid "
            "FROM turniiritabel ORDER BY punktid DESC, vahe DESC, loodud DESC")).all()
        for i, r in enumerate(rows, start=1):
            print(f"{i:<3}{r[0]:<22}{r[1]:>3}{r[2]:>3}{r[3]:>4}{r[4]:>3}"
                  f"{r[5]:>4}{r[6]:>4}{r[7]:>+5}{r[8]:>4}")
    return engine


if __name__ == "__main__":
    valik = sys.argv[1] if len(sys.argv) > 1 else "sqlite"

    if valik in ("sqlite", "molemad"):
        tee_andmebaas("sqlite:///jalgpall.sqlite", "SQLite")

    if valik in ("mysql", "molemad"):
        # PyMySQL on puhas Python, seega ei vaja mysqlclient'i kompileerimist.
        tee_andmebaas(
            "mysql+pymysql://root@localhost/jalgpall?unix_socket=/tmp/maria.sock",
            "MySQL / MariaDB")

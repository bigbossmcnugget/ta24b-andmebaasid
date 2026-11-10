# -*- coding: utf-8 -*-
"""
Lihtne jalgpalli andmebaas SQLAlchemy abil.
Jegor Onoprijuk, ruhm TA-24B   (ulesanne 2026-03-05 "Python, sqlalchemy")

Ulesande noue oli: mangijad (eesnimi, perekonnanimi, sunniaeg, riik, klubi,
palk), klubid (linn, nimi, staadion, treener), treenerid (eesnimi,
perekonnanimi, sunniaeg), mangud (koduklubi, voorklubi, tulemus, mangu
alguseaeg, publiku arv). Lisada 3 klubi, 10 mangijat, 3 treenerit, 2 mangu.
Andmebaas tuleb teha NII sqlite-s KUI ka mysql-is.

Sama skript teeb molemad - vahetub ainult uhendusstring:

    python3 jalgpall.py sqlite
    python3 jalgpall.py mysql
    python3 jalgpall.py molemad
"""
import sys
import datetime as dt

from sqlalchemy import (create_engine, Column, Integer, String, Date, DateTime,
                        Numeric, ForeignKey, text)
from sqlalchemy.orm import declarative_base, relationship, Session

Base = declarative_base()


# ---------------------------------------------------------------- mudelid
class Treener(Base):
    """treenerid (eesnimi, perekonnanimi, sunniaeg)"""
    __tablename__ = "treener"
    id            = Column(Integer, primary_key=True, autoincrement=True)
    eesnimi       = Column(String(50), nullable=False)
    perekonnanimi = Column(String(50), nullable=False)
    synniaeg      = Column(Date, nullable=False)     # kuupaev, mitte vanus:
                                                     # vanus vananeb, kuupaev ei vanane
    klubi = relationship("Klubi", back_populates="treener", uselist=False)

    def __repr__(self):
        return f"{self.eesnimi} {self.perekonnanimi}"


class Klubi(Base):
    """klubid (linn, nimi, staadion, treener)"""
    __tablename__ = "klubi"
    id         = Column(Integer, primary_key=True, autoincrement=True)
    nimi       = Column(String(80), nullable=False, unique=True)
    linn       = Column(String(50), nullable=False)
    staadion   = Column(String(80), nullable=False)
    # treener ei ole tekstivali vaid viide treeneri tabelisse
    treener_id = Column(Integer, ForeignKey("treener.id"), nullable=True)

    treener  = relationship("Treener", back_populates="klubi")
    mangijad = relationship("Mangija", back_populates="klubi")

    def __repr__(self):
        return self.nimi


class Mangija(Base):
    """mangijad (eesnimi, perekonnanimi, sunniaeg, riik, klubi, palk)"""
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
    """mangud (koduklubi, voorklubi, tulemus, mangu alguseaeg, publiku arv)"""
    __tablename__ = "mang"
    id           = Column(Integer, primary_key=True, autoincrement=True)
    koduklubi_id = Column(Integer, ForeignKey("klubi.id"), nullable=False)
    voorklubi_id = Column(Integer, ForeignKey("klubi.id"), nullable=False)
    kodu_varavad = Column(Integer, nullable=False)   # arvutamiseks
    voor_varavad = Column(Integer, nullable=False)
    tulemus      = Column(String(10), nullable=False)  # inimesele lugemiseks "2:1"
    algusaeg     = Column(DateTime, nullable=False)
    publiku_arv  = Column(Integer, nullable=False)

    koduklubi = relationship("Klubi", foreign_keys=[koduklubi_id])
    voorklubi = relationship("Klubi", foreign_keys=[voorklubi_id])


# ---------------------------------------------------------------- andmed
KLUBID = [
    # (nimi, linn, staadion)
    ("FC Flora",            "Tallinn", "Lillekula staadion"),
    ("Nomme Kalju",         "Tallinn", "Hiiu staadion"),
    ("Paide Linnameeskond", "Paide",   "Paide linnastaadion"),
]

TREENERID = [
    # (eesnimi, perekonnanimi, synniaeg)
    ("Jurgen",  "Henn",    dt.date(1985,  3, 12)),
    ("Roman",   "Kozhuhhovski", dt.date(1983, 7, 9)),
    ("Karel",   "Voolaid", dt.date(1980,  6, 25)),
]

MANGIJAD = [
    # (eesnimi, perekonnanimi, synniaeg, riik, palk, klubi indeks)
    ("Rauno",     "Sappinen",  dt.date(1996,  2, 23), "Eesti",  4200.00, 0),
    ("Markus",    "Poom",      dt.date(2000,  7,  7), "Eesti",  3900.00, 0),
    ("Marko",     "Lipp",      dt.date(1999,  4, 15), "Eesti",  3100.00, 0),
    ("Danil",     "Kuznetsov", dt.date(2001, 10,  1), "Eesti",  2700.00, 0),
    ("Vlasi",     "Sinjavski", dt.date(1995,  9,  6), "Eesti",  3600.00, 1),
    ("Mihkel",    "Ainsalu",   dt.date(1996,  3, 20), "Eesti",  3300.00, 1),
    ("Tomi",      "Saarelma",  dt.date(1997, 11, 14), "Soome",  2900.00, 1),
    ("Henrik",    "Purg",      dt.date(1998,  1, 11), "Eesti",  2800.00, 2),
    ("Robi",      "Saarma",    dt.date(2001,  5,  3), "Eesti",  2400.00, 2),
    ("Edgars",    "Berzins",   dt.date(1994,  8, 29), "Lati",   2500.00, 2),
]

MANGUD = [
    # (kodu indeks, voor indeks, kodu varavad, voor varavad, algusaeg, publik)
    (0, 1, 2, 1, dt.datetime(2026, 3, 14, 17, 0), 3120),
    (2, 0, 0, 3, dt.datetime(2026, 3, 21, 15, 30), 1480),
]


# ---------------------------------------------------------------- vaade
# Turniiritabel kirjutan puhta SQL-ina, sest VIEW ei ole ORM-i osa.
# Trikk: iga mang annab kaks rida (kodu ja voorsil), siis grupeerin klubi jargi.
VIEW_SQL = """
CREATE VIEW turniiritabel AS
SELECT  k.nimi                                                AS klubi,
        COUNT(r.klubi_id)                                     AS mange,
        SUM(CASE WHEN r.loodud >  r.saadud THEN 1 ELSE 0 END) AS voite,
        SUM(CASE WHEN r.loodud =  r.saadud THEN 1 ELSE 0 END) AS viike,
        SUM(CASE WHEN r.loodud <  r.saadud THEN 1 ELSE 0 END) AS kaotusi,
        SUM(r.loodud)                                         AS loodud,
        SUM(r.saadud)                                         AS saadud,
        SUM(r.loodud) - SUM(r.saadud)                         AS vahe,
        SUM(CASE WHEN r.loodud >  r.saadud THEN 3
                 WHEN r.loodud =  r.saadud THEN 1
                 ELSE 0 END)                                  AS punktid
FROM    klubi k
LEFT JOIN (
        SELECT koduklubi_id AS klubi_id, kodu_varavad AS loodud,
               voor_varavad AS saadud FROM mang
        UNION ALL
        SELECT voorklubi_id AS klubi_id, voor_varavad AS loodud,
               kodu_varavad AS saadud FROM mang
) r ON r.klubi_id = k.id
GROUP BY k.id, k.nimi
"""


def tee_andmebaas(url, nimi):
    print(f"\n{'=' * 70}\n{nimi}\n{url}\n{'=' * 70}")
    engine = create_engine(url, echo=False, future=True)

    # puhas leht: vaade tuleb ENNE tabeleid maha votta, muidu jaab rippuma
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

        for ki, vi, kv, vv, aeg, pub in MANGUD:
            s.add(Mang(koduklubi=klubid[ki], voorklubi=klubid[vi],
                       kodu_varavad=kv, voor_varavad=vv,
                       tulemus=f"{kv}:{vv}", algusaeg=aeg, publiku_arv=pub))
        s.commit()

    with engine.begin() as conn:
        conn.execute(text(VIEW_SQL))

    # --- kontroll ja valjatrukk
    with Session(engine) as s:
        print(f"klubisid   : {s.query(Klubi).count()}")
        print(f"treenereid : {s.query(Treener).count()}")
        print(f"mangijaid  : {s.query(Mangija).count()}")
        print(f"mange      : {s.query(Mang).count()}")

        print("\nKLUBID")
        print(f"{'klubi':<22}{'linn':<10}{'staadion':<24}{'treener':<24}")
        print("-" * 80)
        for k in s.query(Klubi).order_by(Klubi.nimi):
            print(f"{k.nimi:<22}{k.linn:<10}{k.staadion:<24}{str(k.treener):<24}")

        print("\nMANGIJAD")
        print(f"{'nimi':<24}{'sundinud':<12}{'riik':<8}{'klubi':<22}{'palk':>9}")
        print("-" * 80)
        for m in s.query(Mangija).order_by(Mangija.perekonnanimi):
            print(f"{m.eesnimi + ' ' + m.perekonnanimi:<24}"
                  f"{m.synniaeg.strftime('%d.%m.%Y'):<12}{m.riik:<8}"
                  f"{m.klubi.nimi:<22}{float(m.palk):>9.2f}")

        print("\nMANGUD")
        print(f"{'algusaeg':<18}{'koduklubi':<22}{'tulemus':^9}"
              f"{'voorklubi':<22}{'publik':>7}")
        print("-" * 80)
        for m in s.query(Mang).order_by(Mang.algusaeg):
            print(f"{m.algusaeg.strftime('%d.%m.%Y %H:%M'):<18}"
                  f"{m.koduklubi.nimi:<22}{m.tulemus:^9}"
                  f"{m.voorklubi.nimi:<22}{m.publiku_arv:>7}")

        print("\nTURNIIRITABEL (vaade 'turniiritabel')")
        print(f"{'#':<3}{'klubi':<22}{'M':>3}{'V':>3}{'Vi':>4}{'K':>3}"
              f"{'L':>4}{'S':>4}{'+/-':>5}{'P':>4}")
        print("-" * 55)
        rows = s.execute(text(
            "SELECT klubi, mange, voite, viike, kaotusi, loodud, saadud, "
            "vahe, punktid FROM turniiritabel "
            "ORDER BY punktid DESC, vahe DESC, loodud DESC")).all()
        for i, r in enumerate(rows, start=1):
            print(f"{i:<3}{r[0]:<22}{r[1]:>3}{r[2]:>3}{r[3]:>4}{r[4]:>3}"
                  f"{r[5]:>4}{r[6]:>4}{r[7]:>+5}{r[8]:>4}")
    return engine


if __name__ == "__main__":
    valik = sys.argv[1] if len(sys.argv) > 1 else "molemad"

    if valik in ("sqlite", "molemad"):
        tee_andmebaas("sqlite:///jalgpall.sqlite", "SQLite")

    if valik in ("mysql", "molemad"):
        # PyMySQL on puhas Python - ei vaja mysqlclient'i kompileerimist.
        tee_andmebaas(
            "mysql+pymysql://root@localhost/jalgpall2026"
            "?unix_socket=/tmp/maria.sock", "MySQL / MariaDB")

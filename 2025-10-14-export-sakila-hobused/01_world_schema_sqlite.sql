-- B1: MySQL world -> SQLite (struktuur)   Jegor Onoprijuk, TA-24B
-- SQLite andmetüübid: INTEGER, REAL, TEXT; ENUM asemel CHECK; DECIMAL -> REAL
PRAGMA foreign_keys = ON;
CREATE TABLE country (
  Code           TEXT NOT NULL DEFAULT '' PRIMARY KEY,
  Name           TEXT NOT NULL DEFAULT '',
  Continent      TEXT NOT NULL DEFAULT 'Asia' CHECK (Continent IN ('Asia','Europe','North America','Africa','Oceania','Antarctica','South America')),
  Region         TEXT NOT NULL DEFAULT '',
  SurfaceArea    REAL NOT NULL DEFAULT 0,
  IndepYear      INTEGER,
  Population     INTEGER NOT NULL DEFAULT 0,
  LifeExpectancy REAL,
  GNP            REAL,
  GNPOld         REAL,
  LocalName      TEXT NOT NULL DEFAULT '',
  GovernmentForm TEXT NOT NULL DEFAULT '',
  HeadOfState    TEXT,
  Capital        INTEGER,
  Code2          TEXT NOT NULL DEFAULT ''
);
CREATE TABLE city (
  ID          INTEGER PRIMARY KEY AUTOINCREMENT,
  Name        TEXT NOT NULL DEFAULT '',
  CountryCode TEXT NOT NULL DEFAULT '' REFERENCES country (Code),
  District    TEXT NOT NULL DEFAULT '',
  Population  INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX city_CountryCode ON city (CountryCode);
CREATE TABLE countrylanguage (
  CountryCode TEXT NOT NULL DEFAULT '' REFERENCES country (Code),
  Language    TEXT NOT NULL DEFAULT '',
  IsOfficial  TEXT NOT NULL DEFAULT 'F' CHECK (IsOfficial IN ('T','F')),
  Percentage  REAL NOT NULL DEFAULT 0,
  PRIMARY KEY (CountryCode, Language)
);

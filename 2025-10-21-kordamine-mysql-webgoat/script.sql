use world;
-- kõik andmed kõigi riikide kohta
select * from country;

-- kõik linnad
select * from city;

-- Ainult linna nimi ja rahvaarv (name, population)
select name, population from city;

-- Ainult Ka -ga algavad linnad
select * from city where name like 'Ka%';

-- linna nimi ja rahvaarv, kui rahvaarv on 1000000 ja 2000000 vahel
select name, population from city where population >= 1000000 and population <= 2000000;
select name, population from city where population between 1000000 and 2000000;

-- valime ainult Eesti
select * from country where name = 'Estonia';

-- agregaatkäsk, mitu linna on mingis riigis
select countrycode, count(*) from city group by countrycode;

-- mitu riiki on mingil kontinendil ja mitu inimest seal elab
select continent, count(*), sum(population) from country group by continent;

-- riigikood, linna nimi ja rahvaarv
select countrycode, name, population from city;

-- lisame riigi nime
select code, name from country;

select co.name country_name, co.code, ci.name city_name, ci.population from city ci
join country co on ci.countrycode = co.code;

-- vaatame Eestit
select * from country where name = 'Estonia';
update country set headofstate = 'Alar Karis' where code = 'EST';

-- lisame ühe riigi
insert into country (code, name, continent, population, headofstate) values
('ALI', 'Aliens colony', 'Europe', 123, 'Üllar Lindmaa');

select * from country where code = 'ALI';
insert into city(name, CountryCode, District, Population) values
('Colony', 'ALI', '', 123);

select co.name country_name, co.code, ci.name city_name, ci.population from city ci
join country co on ci.countrycode = co.code where co.code = 'ALI';
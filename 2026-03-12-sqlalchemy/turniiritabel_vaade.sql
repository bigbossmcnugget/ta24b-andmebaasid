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

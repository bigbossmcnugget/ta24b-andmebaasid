-- =====================================================================
-- TA24Bbank - protseduur transfer, parandatud
-- Jegor Onoprijuk, TA-24B
--
-- Algses protseduuris oli neli viga. Kolm neist on kirjavead, mille peale
-- protseduur lihtsalt katkeb, neljas on loogikaviga, mille peale ta
-- töötab, aga teeb valesti - ja see on kõige ohtlikum.
--
-- 1) insert into log (msg)          -> veerg on nimega `message`, mitte `msg`
-- 2) where accountnumb = debaccount -> veergu `accountnumb` ei ole ja
--                                      muutuja on `p_debaccount`, mitte
--                                      `debaccount`. Kaks viga ühes reas.
-- 3) insert into transaction (..., summa) -> veerg on nimega `sum`.
--                                      `sum` on MySQL-is funktsiooni nimi,
--                                      seega peab olema tagurpidi ülakomade
--                                      vahel: `sum`.
-- 4) LOOGIKAVIGA: kui kontol ei ole raha, kirjutati ainult hoiatus logisse
--    ja ülekanne tehti ikka ära. Pank ei tohi nii teha - panin selle
--    juhtumi ROLLBACK'i alla.
--    Lisaks: kui deebetkontot ei ole olemas, tuli newbalance NULL ja
--    võrdlus `NULL < 0` ei ole tõene, seega ka see juhtum läks läbi.
--
-- 5) Ja veel üks asi, mille ma ise avastasin alles testides: kui kirjutada
--    logisse ENNE ROLLBACK-i, läheb ka see kirje tagasi ja logi jääb tühjaks.
--    Seepärast on igas keeldumise harus esimene ROLLBACK ja alles siis
--    INSERT INTO log. Veahandleris oli see juba algselt õiges järjekorras.
--
-- Veateade läks algses versioonis logisse nii, nagu pidigi - see osa oli
-- õige ja jäi alles. Just tänu sellele oli viga nr 2 logist näha:
--   "ERROR: 1054 (42S22) Unknown column 'accountnumb' in 'where clause'"
-- =====================================================================

DROP PROCEDURE IF EXISTS transfer;

DELIMITER //

CREATE PROCEDURE transfer(IN p_debaccount BIGINT, IN p_creaccount BIGINT,
                          IN p_sum DECIMAL(10,2), IN p_refnumber BIGINT,
                          IN p_description VARCHAR(256))
BEGIN
    DECLARE v_oldbalance DECIMAL(10,2);
    DECLARE v_newbalance DECIMAL(10,2);
    DECLARE v_crexists   INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
            @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET @full_error = CONCAT("ERROR: ", @errno, " (", @sqlstate, ') ', @text);
        ROLLBACK;
        INSERT INTO log (message) VALUES (@full_error);
    END;

    START TRANSACTION;

    -- summa peab olema positiivne
    IF p_sum IS NULL OR p_sum <= 0 THEN
        ROLLBACK;                      -- kõigepealt tagasi, alles siis logi
        INSERT INTO log (message)
        VALUES (CONCAT('transfer: vigane summa ', IFNULL(p_sum, 'NULL')));
    ELSE
        -- deebetkonto olemasolu ja jääk
        SELECT balance INTO v_oldbalance
          FROM account WHERE accountnumber = p_debaccount FOR UPDATE;

        SELECT COUNT(*) INTO v_crexists
          FROM account WHERE accountnumber = p_creaccount;

        IF v_oldbalance IS NULL THEN
            ROLLBACK;
            INSERT INTO log (message)
            VALUES (CONCAT('transfer: deebetkontot ', p_debaccount, ' ei ole olemas'));

        ELSEIF v_crexists = 0 THEN
            ROLLBACK;
            INSERT INTO log (message)
            VALUES (CONCAT('transfer: kreeditkontot ', p_creaccount, ' ei ole olemas'));

        ELSEIF p_debaccount = p_creaccount THEN
            ROLLBACK;
            INSERT INTO log (message)
            VALUES (CONCAT('transfer: deebet- ja kreeditkonto on sama (', p_debaccount, ')'));

        ELSE
            SET v_newbalance = v_oldbalance - p_sum;

            IF v_newbalance < 0 THEN
                -- SIIN OLI PÕHIVIGA: enne tehti ülekanne sellest hoolimata ära.
                ROLLBACK;
                INSERT INTO log (message)
                VALUES (CONCAT('transfer: kontol ', p_debaccount, ' ei ole katet. Jääk ',
                               v_oldbalance, ', soovitud ', p_sum,
                               ' -> ülekanne tühistatud'));
            ELSE
                UPDATE account SET balance = balance - p_sum
                 WHERE accountnumber = p_debaccount;

                UPDATE account SET balance = balance + p_sum
                 WHERE accountnumber = p_creaccount;

                INSERT INTO transaction (debitaccount, creditaccount, description,
                                         referencenumber, `sum`)
                VALUES (p_debaccount, p_creaccount, p_description, p_refnumber, p_sum);

                INSERT INTO log (message)
                VALUES (CONCAT('transfer OK: ', p_debaccount, ' -> ', p_creaccount,
                               ' ', p_sum, ' EUR (', IFNULL(p_description, ''), ')'));
                COMMIT;
            END IF;
        END IF;
    END IF;
END//

DELIMITER ;

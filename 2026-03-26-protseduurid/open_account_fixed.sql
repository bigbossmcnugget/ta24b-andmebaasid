-- =====================================================================
-- TA24Bbank - protseduur open_current_account, parandatud
-- Jegor Onoprijuk, TA-24B
--
-- Algne versioon jäi igavesse tsüklisse. Põhjus: rida, mis tsüklist
-- välja viib, oli kommentaari sisse jäetud:
--
--     /*  if done then
--             leave read_loop;
--         end if;  */
--
-- Kursor jõuab viimase kliendini, NOT FOUND handler paneb done = TRUE,
-- aga kuna seda muutujat kuskil ei vaadata, keerleb loop edasi ja kordab
-- viimast klienti lõputult. Mina lasin seda 7 minutit - protseduur ei
-- lõppenud ja serveri protsess tuli ära tappa.
--
-- Teine asi, mille ma ära muutsin: uue konto number võeti käsuga
--     select max(accountnumber) + 1 into new_account_number from account;
-- See on sees tsüklis õige, aga kui tabel on tühi, annab MAX() NULL ja
-- siis ei teki ühtegi kontot. Lisasin IFNULL-i.
-- =====================================================================

DROP PROCEDURE IF EXISTS open_current_account;

DELIMITER //

CREATE PROCEDURE open_current_account()
BEGIN
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE id_code BIGINT;
    DECLARE new_account_number BIGINT;
    DECLARE ac_count INTEGER;
    DECLARE opened INTEGER DEFAULT 0;
    DECLARE customer_cursor CURSOR FOR SELECT idcode FROM customer;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN customer_cursor;

    read_loop: LOOP
        FETCH customer_cursor INTO id_code;

        -- SIIN OLI VIGA: see kolm rida olid kommentaari sees
        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT COUNT(*) INTO ac_count
          FROM account
         WHERE customerid = id_code AND accounttype = 'CURR';

        IF ac_count = 0 THEN
            SELECT IFNULL(MAX(accountnumber), 100000) + 1
              INTO new_account_number FROM account;

            INSERT INTO account (accountnumber, accounttype, customerid, balance)
            VALUES (new_account_number, 'CURR', id_code, 0);

            SET opened = opened + 1;
        END IF;
    END LOOP;

    CLOSE customer_cursor;

    INSERT INTO log (message)
    VALUES (CONCAT('open_current_account: avati ', opened, ' uut arvelduskontot'));
END//

DELIMITER ;

USE TA24Bbank_trig;
-- sama e-post -> UNIQUE rikkumine, protseduur teeb ROLLBACK
CALL add_customer_with_account(30000000001, 'Test', 'Duplikaat',
     'mari.tamm@example.com', 'BASIC', 100999, 10.00);
